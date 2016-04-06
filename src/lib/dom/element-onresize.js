
// original code from:
// http://www.backalleycoder.com/2013/03/18/cross-browser-event-based-element-resize-detection/

let isIE = navigator.userAgent.match(/Trident/)
let requestFrame = (function () {
  let raf = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame ||
    function (fn) { return window.setTimeout(fn, 20) }
  return function (fn) { return raf(fn) }
})()

let cancelFrame = (function () {
  let cancel = window.cancelAnimationFrame || window.mozCancelAnimationFrame || window.webkitCancelAnimationFrame ||
    window.clearTimeout
  return function (id) { return cancel(id) }
})()

function resizeListener (e) {
  let win = e.target || e.srcElement
  if (win._raf) cancelFrame(win._raf)
  win._raf = requestFrame(function () {
    let trigger = win._trigger
    if (trigger) trigger._listeners.forEach(function (fn) {
      fn.call(trigger, e)
    })
  })
}

function addResizeListener(element, fn) {
  if (!element._listeners || element._listeners.length) {
    element._listeners = []
    if (getComputedStyle(element).position == 'static') element.style.position = 'relative'
    let obj = element._trigger = document.createElement('object')
    obj.setAttribute('style', 'display:block;position:absolute;top:0;left:0;height:100%;width:100%;overflow:hidden;pointer-events:none;z-index:-1;')
    obj._el = element
    obj.onload = function () {
      this.contentDocument.defaultView._trigger = this._el
      this.contentDocument.defaultView.addEventListener('resize', resizeListener)
    }

    obj.type = 'text/html'
    if (isIE) element.appendChild(obj)
    obj.data = 'about:blank'
    if (!isIE) element.appendChild(obj)
  }
  element._listeners.push(fn)
}

function removeResizeListener(element, fn) {
  if (!element._listeners) return
  element._listeners.splice(element._listeners.indexOf(fn), 1)
  if (!element._listeners.length) {
    if (element._trigger.contentDocument)
      element._trigger.contentDocument.defaultView.removeEventListener('resize', resizeListener)
    // element._trigger = !element.removeChild(element._trigger)
    element.removeChild(element._trigger)
  }
}

export default {
  addResizeListener,
  removeResizeListener
}
