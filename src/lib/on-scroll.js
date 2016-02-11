import debounce from './lodash/function/debounce'

export default function onScroll (el, percent_or_px, handler) {
  let _el = el && el.scrollHeight ? el : window
  let body = el && el.scrollHeight ? el : document.body
  let throttled = debounce(_onScroll, 100, {leading: true, trailing: true, maxWait: 200})
  // let throttled = () => { console.log('scroll?'); _throttled.apply(this, arguments) }
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
    let bottom_px = window.pageYOffset + window.innerHeight

    // console.log(percent_or_px, rect.height - percent_or_px, bottom_px)
    if ((percent_or_px < 1 && (rect.height * percent_or_px) < bottom_px) || (rect.height - percent_or_px) < bottom_px) {
      obj.working = true
      handler(function () {
        setTimeout(throttled, 10)
        obj.working = false
      })
    }
  }
}
