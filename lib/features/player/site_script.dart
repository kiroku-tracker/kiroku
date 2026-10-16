/// Скрипт во всех фреймах сайта: видео, реклама, вид «только плеер»,
/// выбор озвучки, плеера и серии кнопками сайта.
const siteScript = r'''
(function () {
  if (window.__kiroku) return;
  window.__kiroku = true;
  var top = window === window.top;
  var ads = /adfinity|an\.yandex\.ru|yandex\.ru\/ads|adfox|doubleclick|googlesyndication|adriver|betweendigital|buzzoola|mediasniper/i;
  function isAd(url) { return ads.test(url || ''); }

  if (!top && isAd(location.href)) {
    document.documentElement.style.display = 'none';
    setInterval(function () {
      document.querySelectorAll('video').forEach(function (v) {
        v.muted = true;
        v.pause();
      });
    }, 500);
    return;
  }
  function sweep() {
    document.querySelectorAll('iframe').forEach(function (frame) {
      if (isAd(frame.src)) frame.remove();
    });
  }
  new MutationObserver(sweep).observe(document, { childList: true, subtree: true });

  function send(message) {
    if (top) {
      try { window.chrome.webview.postMessage(message); } catch (e) {}
    } else {
      try { window.top.postMessage(message, '*'); } catch (e) {}
    }
  }
  function forward(message) {
    for (var i = 0; i < window.frames.length; i++) {
      try { window.frames[i].postMessage(message, '*'); } catch (e) {}
    }
  }

  if (!top) {
    var mini = false;
    var spoilers = true;
    var started = false;
    var player = /kodik|alloha|cdnvideohub/.test(location.hostname);
    var frameStyle = document.createElement('style');
    frameStyle.textContent =
      'html.kiroku-mini,html.kiroku-mini body{background:#000!important}' +
      'html.kiroku-mini body *{visibility:hidden!important}' +
      'html.kiroku-mini video{visibility:visible!important}' +
      'html.kiroku-spoilers img,html.kiroku-spoilers video{opacity:0!important}' +
      (/kodik/.test(location.hostname)
        ? '.share_button,.fp-share_button,#get_code_window{display:none!important}'
        : '');
    function refresh() {
      var videos = document.querySelectorAll('video');
      started = started || Array.prototype.some.call(videos, function (v) {
        return !v.paused && v.currentTime > 0;
      });
      var root = document.documentElement;
      if (!root) return;
      if (!frameStyle.isConnected && document.head) document.head.appendChild(frameStyle);
      root.classList.toggle('kiroku-spoilers', player && spoilers && !started);
      root.classList.toggle('kiroku-mini', mini && videos.length > 0);
    }
    function pause(on) {
      var videos = Array.prototype.slice.call(document.querySelectorAll('video'));
      if (on) {
        videos.forEach(function (v) {
          if (!v.paused) { v.pause(); v.__kirokuPaused = true; }
        });
        return;
      }
      var paused = videos.filter(function (v) { return v.__kirokuPaused; });
      if (paused.length === 0) {
        paused = videos.filter(function (v) { return v.currentTime > 0; })
          .sort(function (a, b) { return (b.duration || 0) - (a.duration || 0); })
          .slice(0, 1);
      }
      paused.forEach(function (v) {
        v.__kirokuPaused = false;
        var playing = v.play();
        if (playing && playing.catch) playing.catch(function () {});
      });
    }
    window.addEventListener('message', function (e) {
      var data = e.data;
      if (e.source !== window.parent || !data) return;
      if (data.kiroku === 3) {
        mini = data.mini;
        spoilers = data.spoilers;
        refresh();
      } else if (data.kiroku === 5) {
        if (!data.url || data.url === location.href) pause(data.pause);
      } else {
        return;
      }
      forward(data);
    });
    setInterval(refresh, 300);
    refresh();
  }

  if (top) {
    window.addEventListener('message', function (e) {
      if (e.data && e.data.kiroku === 1) send(e.data);
    });
    document.addEventListener('fullscreenchange', function () {
      send({ kiroku: 4, full: !!document.fullscreenElement });
    });

    var dubbingLabel = 'Выберите озвучку';
    var playerLabel = 'Выберите плеер';
    function field(label) {
      return document.querySelector('input[aria-label="' + label + '"]');
    }
    function wait(find, done) {
      var tries = 0;
      var timer = setInterval(function () {
        var found = find();
        if (found || ++tries > 80) { clearInterval(timer); done(found); }
      }, 250);
    }
    function episodeButtons(root) {
      return Array.prototype.filter.call(
        root.querySelectorAll('[role=button]'),
        function (b) { return /^\d+$/.test(b.textContent.trim()); });
    }
    function current(label) {
      var input = field(label);
      var box = input && input.closest('[class*=container]');
      return box ? box.innerText.split('\n')[0].trim() : null;
    }
    function choose(label, value, next) {
      var input = field(label);
      if (!value || !input || current(label) === value) { next(); return; }
      var attempts = 0;
      function open() {
        input.focus();
        input.dispatchEvent(new KeyboardEvent('keydown',
          { key: 'ArrowDown', keyCode: 40, bubbles: true }));
      }
      open();
      wait(function () {
        var options = document.querySelectorAll('[id*=-option-]');
        if (options.length === 0 && ++attempts % 6 === 0) open();
        return Array.prototype.find.call(options, function (option) {
          var text = option.textContent.trim();
          return text.indexOf(value) === 0 &&
            /^(\d|$)/.test(text.slice(value.length));
        });
      }, function (option) {
        if (option) {
          option.click();
        } else {
          input.dispatchEvent(new KeyboardEvent('keydown',
            { key: 'Escape', keyCode: 27, bubbles: true }));
        }
        setTimeout(next, 800);
      });
    }
    window.__kirokuPlay = function (want) {
      wait(function () { return field(dubbingLabel); }, function (input) {
        if (!input) return;
        choose(dubbingLabel, want.dubbing, function () {
          choose(playerLabel, want.player, function () {
            if (!want.episode) return;
            var section = input.closest('section') || document;
            wait(function () {
              return episodeButtons(section).find(function (b) {
                return b.textContent.trim() === String(want.episode);
              });
            }, function (button) { if (button) button.click(); });
          });
        });
      });
    };

    var focus = true;
    var native = false;
    var focused = false;
    var style = document.createElement('style');
    style.textContent =
      'html.kiroku-focus [data-kiroku-hide]{display:none!important}' +
      'html.kiroku-focus [data-kiroku-outer]{display:block!important;' +
      'max-width:none!important;width:auto!important;margin:0!important;' +
      'padding-top:0!important;padding-bottom:0!important}' +
      'html.kiroku-focus [data-kiroku-inner]{max-width:none!important;' +
      'width:auto!important;margin-left:0!important;margin-right:0!important}' +
      'html.kiroku-focus.kiroku-native [data-kiroku-away]{position:fixed!important;' +
      'left:-10000px!important;top:0!important;opacity:0!important;' +
      'pointer-events:none!important}' +
      'html.kiroku-focus body{padding:0!important;margin:0!important}' +
      'html.kiroku-focus.kiroku-native,html.kiroku-focus.kiroku-native body' +
      '{overflow:hidden!important;scrollbar-gutter:auto!important}' +
      'html.kiroku-focus.kiroku-native [data-kiroku-player]{position:fixed!important;' +
      'left:0!important;top:0!important;width:100vw!important;height:100vh!important;' +
      'max-width:none!important;max-height:none!important;aspect-ratio:auto!important;' +
      'margin:0!important;border-radius:0!important;z-index:2147483647!important}' +
      'html.kiroku-focus:not(.kiroku-native) [data-kiroku-player]{' +
      'aspect-ratio:auto!important;height:min(100vh,56.25vw)!important}' +
      'html.kiroku-focus [data-kiroku-player] :has(iframe),' +
      'html.kiroku-focus [data-kiroku-player] iframe' +
      '{width:100%!important;height:100%!important}';
    window.__kirokuFocus = function (on) { focus = on; tidy(); };
    window.__kirokuNative = function (on) { native = on; tidy(); };
    var miniMode = false;
    var hideSpoilers = true;
    window.__kirokuMini = function (on) { miniMode = on; };
    window.__kirokuSpoilers = function (on) { hideSpoilers = on; };
    window.__kirokuPause = function (on, url) {
      forward({ kiroku: 5, pause: on, url: url || null });
    };
    setInterval(function () {
      forward({ kiroku: 3, mini: miniMode, spoilers: hideSpoilers });
    }, 300);
    function mark(element, name) { element.setAttribute(name, ''); }
    function blockOf(element, section) {
      var block = element;
      while (block.parentElement && block.parentElement !== section &&
             !block.parentElement.querySelector('iframe')) {
        block = block.parentElement;
      }
      return block;
    }
    function markPlayer(frame, section) {
      var player = section.querySelector('[data-kiroku-player]');
      if (player && player.contains(frame)) return;
      if (player) player.removeAttribute('data-kiroku-player');
      player = frame;
      while (player.parentElement !== section &&
             player.parentElement.offsetHeight <= frame.offsetHeight + 2) {
        player = player.parentElement;
      }
      mark(player, 'data-kiroku-player');
    }
    function report(section) {
      var frame = section && section.querySelector('iframe');
      var match = frame && /[?&]episode=(\d+)/.exec(frame.src);
      send({
        kiroku: 2,
        path: location.pathname,
        dubbing: current(dubbingLabel),
        player: current(playerLabel),
        episode: match ? Number(match[1]) : null,
        modes: [focus, native, miniMode, hideSpoilers],
        ready: !focus || focused ||
          location.pathname.indexOf('/catalog/item/') !== 0
      });
    }
    function tidy() {
      if (!style.isConnected && document.head) document.head.appendChild(style);
      var input = field(dubbingLabel);
      var section = input && input.closest('section');
      document.documentElement.classList.toggle('kiroku-native', native);
      if (!focus || !section) {
        document.documentElement.classList.remove('kiroku-focus');
        focused = false;
        if (focus && /^\/catalog\/item\//.test(location.pathname)) {
          var heading = Array.prototype.find.call(
            document.querySelectorAll('[role=button] h2'),
            function (h) { return /Смотреть аниме/i.test(h.textContent); });
          if (heading) heading.scrollIntoView({ block: 'start' });
        }
        report(section);
        return;
      }
      section.querySelectorAll('h2').forEach(function (h) {
        mark(h, 'data-kiroku-hide');
      });
      Array.prototype.forEach.call(section.querySelectorAll('button'), function (b) {
        if (!/FAQ/.test(b.textContent)) return;
        var block = b;
        while (block.parentElement && !block.parentElement.contains(input)) {
          block = block.parentElement;
        }
        mark(block, 'data-kiroku-hide');
      });
      var frame = section.querySelector('iframe');
      if (frame) {
        mark(blockOf(input, section), 'data-kiroku-away');
        var episode = episodeButtons(section)[0];
        if (episode) mark(blockOf(episode, section), 'data-kiroku-away');
        markPlayer(frame, section);
      }
      var node = section;
      var inner = true;
      while (node && node !== document.body) {
        var parent = node.parentElement;
        if (parent) {
          Array.prototype.forEach.call(parent.children, function (child) {
            if (child !== node && !/^(SCRIPT|STYLE|LINK)$/.test(child.tagName)) {
              mark(child, 'data-kiroku-hide');
            }
          });
        }
        mark(node, inner ? 'data-kiroku-inner' : 'data-kiroku-outer');
        inner = false;
        node = parent;
      }
      document.documentElement.classList.add('kiroku-focus');
      if (!focused) window.scrollTo(0, 0);
      focused = true;
      report(section);
    }
    setInterval(tidy, 400);
  }

  setInterval(function () {
    var videos = Array.prototype.map.call(document.querySelectorAll('video'), function (v) {
      return {
        time: v.currentTime,
        duration: isFinite(v.duration) ? v.duration : -1,
        paused: v.paused,
        muted: v.muted
      };
    });
    send({ kiroku: 1, url: location.href, title: document.title, top: top, videos: videos });
  }, 2000);
})();
''';
