/**
 * Keyboard scrolling for Antora + BoostLook: main text often scrolls inside a nested
 * box (e.g. #content) while focus stays on body/links, so the browser does not apply
 * PageUp/PageDown/Home to that box.
 *
 * Uses scroll geometry (scrollHeight vs clientHeight), not computed overflow-y alone,
 * because shorthand / layer rules may not report 'auto' even when the box scrolls.
 */
(function () {
  'use strict';

  function isFormField(el) {
    if (!el || el.nodeType !== 1) return false;
    if (el.isContentEditable) return true;
    var tag = el.tagName;
    if (tag === 'TEXTAREA' || tag === 'SELECT') return true;
    if (tag !== 'INPUT') return false;
    var type = (el.getAttribute('type') || 'text').toLowerCase();
    return (
      type !== 'button' &&
      type !== 'checkbox' &&
      type !== 'color' &&
      type !== 'file' &&
      type !== 'hidden' &&
      type !== 'image' &&
      type !== 'radio' &&
      type !== 'reset' &&
      type !== 'submit'
    );
  }

  function maxScrollTop(el) {
    if (!el || el.nodeType !== 1) return 0;
    return Math.max(0, el.scrollHeight - el.clientHeight);
  }

  /**
   * Nearest ancestor of `from` that can scroll vertically; else prefer #content,
   * then document scrollingElement / body.
   */
  function resolveScrollContainer(from) {
    var n = from;
    while (n && n !== document.documentElement) {
      if (maxScrollTop(n) > 0) return n;
      n = n.parentElement;
    }
    var prefer = [
      document.querySelector('.boostlook #content'),
      document.getElementById('content'),
      document.scrollingElement || document.documentElement,
      document.body,
    ];
    for (var i = 0; i < prefer.length; i++) {
      var el = prefer[i];
      if (el && maxScrollTop(el) > 0) return el;
    }
    return prefer[0] || prefer[2] || document.documentElement;
  }

  function focusStartNode() {
    var a = document.activeElement;
    if (a && a !== document.body && a !== document.documentElement) return a;
    return (
      document.querySelector('#content article.doc') ||
      document.querySelector('article.doc') ||
      document.querySelector('.boostlook #content') ||
      document.getElementById('content') ||
      document.body
    );
  }

  function viewportPageDelta(container) {
    if (container === document.documentElement || container === document.body) {
      return Math.max(1, Math.round((window.innerHeight || document.documentElement.clientHeight) * 0.85));
    }
    return Math.max(1, Math.round(container.clientHeight * 0.85));
  }

  function supportsSmoothScroll() {
    return 'scrollBehavior' in document.documentElement.style;
  }

  function scrollWindowBy(dy) {
    if (supportsSmoothScroll()) window.scrollBy({ left: 0, top: dy, behavior: 'smooth' });
    else window.scrollBy(0, dy);
  }

  function scrollWindowTop() {
    if (supportsSmoothScroll()) window.scrollTo({ left: 0, top: 0, behavior: 'smooth' });
    else window.scrollTo(0, 0);
  }

  function scrollElementBy(el, dy) {
    if (supportsSmoothScroll()) el.scrollBy({ left: 0, top: dy, behavior: 'smooth' });
    else el.scrollTop += dy;
  }

  function scrollElementTop(el) {
    if (supportsSmoothScroll()) el.scrollTo({ left: 0, top: 0, behavior: 'smooth' });
    else el.scrollTop = 0;
  }

  function isWindowScrollBox(el) {
    return el === document.documentElement || el === document.body;
  }

  document.addEventListener(
    'keydown',
    function (e) {
      if (e.defaultPrevented) return;
      if (e.altKey || e.ctrlKey || e.metaKey) return;
      var key = e.key;
      if (key !== 'PageDown' && key !== 'PageUp' && key !== 'Home') return;
      if (isFormField(e.target)) return;

      var container = resolveScrollContainer(focusStartNode());
      if (!container) return;

      var max = maxScrollTop(container);
      if (key !== 'Home' && max < 1) return;
      if (key === 'Home' && max < 1 && container.scrollTop < 1) return;

      e.preventDefault();

      var delta = viewportPageDelta(container);

      if (isWindowScrollBox(container)) {
        if (key === 'Home') scrollWindowTop();
        else if (key === 'PageDown') scrollWindowBy(delta);
        else scrollWindowBy(-delta);
        return;
      }
      if (key === 'Home') scrollElementTop(container);
      else if (key === 'PageDown') scrollElementBy(container, delta);
      else scrollElementBy(container, -delta);
    },
    true
  );
})();
