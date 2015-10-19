import debounce from './lodash/function/debounce'

export default function onScroll (el, percent, handler) {
  let _el = el && el.scrollHeight ? el : window
  let body = el && el.scrollHeight ? el : document.body
  let throttled = debounce(_onScroll, 100, true)
  let timeout

  _el.addEventListener('scroll', throttled)
  let obj = {
    cancel () {
      _el.removeEventListener('scroll', throttled)
    }
  }
  setTimeout(() => {
    if (timeout) clearTimeout(timeout)
    throttled()
  }, 1000)
  return obj

  function _onScroll (e) {
    if (obj.working) return timeout ? null : timeout = setTimeout(throttled, 10)
    let rect = body.getBoundingClientRect()
    if ((rect.top + body.clientHeight + window.pageYOffset - rect.height/2) < (window.pageYOffset + window.innerHeight)) {
      obj.working = true
      handler(function () {
        setTimeout(throttled, 10)
        obj.working = false
      })
    }
  }
}
