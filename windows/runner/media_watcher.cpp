#include "media_watcher.h"

#include <flutter/standard_method_codec.h>
#include <UIAutomation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Media.Control.h>
#include <wrl/client.h>

#include <chrono>

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;
using Microsoft::WRL::ComPtr;
using winrt::Windows::Media::Control::
    GlobalSystemMediaTransportControlsSessionManager;

std::string ToUtf8(const std::wstring& text) {
  if (text.empty()) return {};
  const int size = WideCharToMultiByte(CP_UTF8, 0, text.data(),
                                       static_cast<int>(text.size()), nullptr,
                                       0, nullptr, nullptr);
  std::string result(size, '\0');
  WideCharToMultiByte(CP_UTF8, 0, text.data(), static_cast<int>(text.size()),
                      result.data(), size, nullptr, nullptr);
  return result;
}

std::wstring FromUtf8(const std::string& text) {
  if (text.empty()) return {};
  const int size = MultiByteToWideChar(CP_UTF8, 0, text.data(),
                                       static_cast<int>(text.size()), nullptr,
                                       0);
  std::wstring result(size, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()),
                      result.data(), size);
  return result;
}

double Seconds(winrt::Windows::Foundation::TimeSpan span) {
  return std::chrono::duration<double>(span).count();
}

// Окна, чей заголовок начинается с title.
std::vector<HWND> WindowsWithTitle(const std::wstring& title) {
  struct Search {
    const std::wstring* title;
    std::vector<HWND> found;
  } search{&title, {}};
  EnumWindows(
      [](HWND hwnd, LPARAM param) -> BOOL {
        auto* search = reinterpret_cast<Search*>(param);
        if (!IsWindowVisible(hwnd)) return TRUE;
        wchar_t buffer[1024];
        const int length = GetWindowTextW(hwnd, buffer, 1024);
        if (length > 0 &&
            std::wstring(buffer, length).rfind(*search->title, 0) == 0) {
          search->found.push_back(hwnd);
        }
        return TRUE;
      },
      reinterpret_cast<LPARAM>(&search));
  return search.found;
}

// Страница и плееры активной вкладки браузера.
EncodableList Documents(IUIAutomation* automation, HWND hwnd) {
  EncodableList result;
  ComPtr<IUIAutomationElement> root;
  if (FAILED(automation->ElementFromHandle(hwnd, &root)) || !root) {
    return result;
  }
  VARIANT type;
  VariantInit(&type);
  type.vt = VT_I4;
  type.lVal = UIA_DocumentControlTypeId;
  ComPtr<IUIAutomationCondition> condition;
  if (FAILED(automation->CreatePropertyCondition(UIA_ControlTypePropertyId,
                                                 type, &condition))) {
    return result;
  }
  ComPtr<IUIAutomationElementArray> found;
  if (FAILED(root->FindAll(TreeScope_Descendants, condition.Get(), &found)) ||
      !found) {
    return result;
  }
  int count = 0;
  found->get_Length(&count);
  for (int i = 0; i < count; ++i) {
    ComPtr<IUIAutomationElement> element;
    if (FAILED(found->GetElement(i, &element)) || !element) continue;
    BSTR name = nullptr;
    element->get_CurrentName(&name);
    VARIANT value;
    VariantInit(&value);
    element->GetCurrentPropertyValue(UIA_ValueValuePropertyId, &value);
    std::wstring url =
        value.vt == VT_BSTR && value.bstrVal ? value.bstrVal : L"";
    if (!url.empty()) {
      result.push_back(EncodableValue(EncodableMap{
          {EncodableValue("name"),
           EncodableValue(ToUtf8(name ? std::wstring(name) : L""))},
          {EncodableValue("url"), EncodableValue(ToUtf8(url))},
      }));
    }
    if (name) SysFreeString(name);
    VariantClear(&value);
  }
  return result;
}

}  // namespace

MediaWatcher::MediaWatcher(flutter::BinaryMessenger* messenger, HWND window)
    : window_(window) {
  channel_ = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      messenger, "kiroku/media", &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    if (call.method_name() == "start") {
      int interval = 5000;
      std::vector<std::wstring> keywords;
      if (const auto* args = std::get_if<EncodableMap>(call.arguments())) {
        if (auto it = args->find(EncodableValue("intervalMs"));
            it != args->end()) {
          if (const auto* value = std::get_if<int32_t>(&it->second)) {
            interval = *value;
          }
        }
        if (auto it = args->find(EncodableValue("keywords"));
            it != args->end()) {
          if (const auto* list = std::get_if<EncodableList>(&it->second)) {
            for (const auto& item : *list) {
              if (const auto* text = std::get_if<std::string>(&item)) {
                keywords.push_back(FromUtf8(*text));
              }
            }
          }
        }
      }
      Start(interval, std::move(keywords));
      result->Success();
    } else if (call.method_name() == "stop") {
      Stop();
      result->Success();
    } else {
      result->NotImplemented();
    }
  });
}

MediaWatcher::~MediaWatcher() {
  Stop();
  channel_->SetMethodCallHandler(nullptr);
}

void MediaWatcher::Start(int interval_ms, std::vector<std::wstring> keywords) {
  Stop();
  {
    std::lock_guard lock(mutex_);
    interval_ms_ = interval_ms;
    keywords_ = std::move(keywords);
  }
  running_ = true;
  thread_ = std::thread([this] { Loop(); });
}

void MediaWatcher::Stop() {
  running_ = false;
  wake_.notify_all();
  if (thread_.joinable()) thread_.join();
}

void MediaWatcher::Deliver() {
  std::optional<EncodableValue> snapshot;
  {
    std::lock_guard lock(mutex_);
    snapshot.swap(pending_);
  }
  if (snapshot) {
    channel_->InvokeMethod("update",
                           std::make_unique<EncodableValue>(*snapshot));
  }
}

void MediaWatcher::Loop() {
  winrt::init_apartment(winrt::apartment_type::multi_threaded);
  ComPtr<IUIAutomation> automation;
  CoCreateInstance(__uuidof(CUIAutomation), nullptr, CLSCTX_INPROC_SERVER,
                   IID_PPV_ARGS(&automation));
  GlobalSystemMediaTransportControlsSessionManager manager{nullptr};

  while (running_) {
    EncodableList sessions;
    try {
      if (!manager) {
        manager = GlobalSystemMediaTransportControlsSessionManager::
                      RequestAsync()
                          .get();
      }
      std::vector<std::wstring> keywords;
      {
        std::lock_guard lock(mutex_);
        keywords = keywords_;
      }
      for (const auto& session : manager.GetSessions()) {
        const auto properties = session.TryGetMediaPropertiesAsync().get();
        const auto timeline = session.GetTimelineProperties();
        const auto playback = session.GetPlaybackInfo();
        const std::wstring title(properties.Title());
        const auto status = static_cast<int32_t>(playback.PlaybackStatus());

        // Текущая позиция воспроизведения.
        double position = Seconds(timeline.Position());
        if (status == 4) {
          position += std::chrono::duration<double>(
                          winrt::clock::now() - timeline.LastUpdatedTime())
                          .count();
        }
        const double duration =
            Seconds(timeline.EndTime()) - Seconds(timeline.StartTime());

        EncodableList documents;
        bool wanted = false;
        for (const auto& keyword : keywords) {
          if (!keyword.empty() && title.find(keyword) != std::wstring::npos) {
            wanted = true;
            break;
          }
        }
        if (wanted && automation) {
          for (HWND hwnd : WindowsWithTitle(title)) {
            for (auto& document : Documents(automation.Get(), hwnd)) {
              documents.push_back(std::move(document));
            }
          }
        }

        sessions.push_back(EncodableValue(EncodableMap{
            {EncodableValue("app"),
             EncodableValue(ToUtf8(std::wstring(
                 session.SourceAppUserModelId())))},
            {EncodableValue("title"), EncodableValue(ToUtf8(title))},
            {EncodableValue("status"), EncodableValue(status)},
            {EncodableValue("position"), EncodableValue(position)},
            {EncodableValue("duration"), EncodableValue(duration)},
            {EncodableValue("documents"), EncodableValue(documents)},
        }));
      }
    } catch (...) {
      // Ошибка медиасессий.
      manager = nullptr;
    }

    {
      std::lock_guard lock(mutex_);
      pending_ = EncodableValue(sessions);
    }
    PostMessage(window_, kMediaSnapshotMessage, 0, 0);

    std::unique_lock lock(mutex_);
    wake_.wait_for(lock, std::chrono::milliseconds(interval_ms_),
                   [this] { return !running_.load(); });
  }

  automation.Reset();
  winrt::uninit_apartment();
}
