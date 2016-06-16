import h from '../dom/hyper-hermes'

function floatingTip (node, text, width) {
  if (text === undefined) return { teardown () {} }
  var top = 3
  var left = 3
  var maxw = 300
  var speed = 10
  var timer = 20
  var endalpha = 95
  var alpha = 0
  var doc = document
  var doce = doc.documentElement
  var T,t,c,b,height,hidden
  var ie = document.all ? true : false

  var onmousemove = function (e) {
    if (hidden) return
    var u = ie ? event.clientY + doce.scrollTop : e.pageY
    var l = ie ? event.clientX + doce.scrollLeft : e.pageX
    T.style.top = (u - height) + 'px'
    T.style.left = (l + left) + 'px'
  }

  var show = function (v, w) {
    hidden = false
    if (T === void 0) {
      doc.body.appendChild(
        T = h('div', {id: 'T', style: {opacity: 0, filter: 'alpha(opacity=0)'}},
          // t = h('div', {id: 'Ttop'}),
          c = h('div', {id: 'Tcont'})
          // b = h('div', {id: 'Tbot'})
        )
      )

      // TODO: use global addEventListener a la `rolex`
      doc.addEventListener('mousemove', onmousemove)
    }
    T.style.display = 'block'
    c.innerHTML = typeof text === 'function' ? text() : text
    T.style.width = width ? width + 'px' : 'auto'
    if (!width && ie) {
      // t.style.display = 'none'
      // b.style.display = 'none'
      T.style.width = T.offsetWidth // + 'px'
      // t.style.display = 'block'
      // b.style.display = 'block'
    }
    if (T.offsetWidth > maxw) T.style.width = maxw + 'px'
    height = ~~T.offsetHeight + top
    clearInterval(T.timer)
    T.timer = setInterval(function () { fade(1) }, timer)
  }

  var fade = function (d) {
    var a = alpha
    if ((a != endalpha && d == 1) || (a != 0 && d === -1)) {
      var i = speed
      if (endalpha - a < speed && d === 1) {
        i = endalpha - a
      } else if (alpha < speed && d === -1) {
        i = a
      }
      alpha = a + (i * d)
      T.style.opacity = alpha * .01
      T.style.filter = 'alpha(opacity=' + alpha + ')'
    } else {
      clearInterval(T.timer)
      if (hidden = d === -1) T.style.display = 'none'
    }
  }

  var hide = function () {
    clearInterval(T.timer)
    T.timer = setInterval(function () { fade(-1) }, timer)
  }

  node.addEventListener('mouseenter', function onmouseenter () { show() })
  node.addEventListener('mouseleave', function onmouseleave () { hide() })

  return {
    teardown() {
      node.removeEventListener('mouseenter', onmouseenter)
      node.removeEventListener('mouseleave', onmouseleave)
      if (T) {
        clearInterval(T.timer)
        doc.removeEventListener('mousemove', onmousemove)
        doc.body.removeChild(T)
      }
    }
  }
}

export default floatingTip
