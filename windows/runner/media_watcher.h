#ifndef RUNNER_MEDIA_WATCHER_H_
#define RUNNER_MEDIA_WATCHER_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <atomic>
#include <condition_variable>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <thread>
#include <vector>

// Сообщение окну о новом снимке.
constexpr UINT kMediaSnapshotMessage = WM_APP + 0x51;

// Слежение за медиасессиями Windows и адресами вкладки браузера.
class MediaWatcher {
 public:
  MediaWatcher(flutter::BinaryMessenger* messenger, HWND window);
  ~MediaWatcher();

  // Передаёт снимок в Dart.
  void Deliver();

 private:
  void Start(int interval_ms, std::vector<std::wstring> keywords);
  void Stop();
  void Loop();

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  HWND window_;
  std::thread thread_;
  std::atomic<bool> running_{false};
  std::mutex mutex_;
  std::condition_variable wake_;
  int interval_ms_ = 5000;
  std::vector<std::wstring> keywords_;
  std::optional<flutter::EncodableValue> pending_;
};

#endif  // RUNNER_MEDIA_WATCHER_H_
