
import assign from '../lodash/object/assign'
import h from '../dom/hyper-hermes'
import each from '../lodash/collection/each'

function nlElastic (node, keypath, padding) {
  function int(str) {
    return parseInt(str, 10)
  }

  padding = padding || 24
  var ta = node,
    $ta = node

  // exit if elastic already applied (or is the mirror element)
  if ($ta.dataset.elastic) return

  // ensure the element is a textarea, and browser is capable
  if (ta.nodeName !== 'TEXTAREA' || !window.getComputedStyle) return

  // set these properties before measuring dimensions
  assign($ta.style, {
    'overflow': 'hidden',
    'overflowY': 'hidden',
    'wordWrap': 'break-word'
  })

  // force text reflow
  var text = ta.value
  ta.value = ''
  ta.value = text

  var win = window,
    ractive = node._ractive.root,
    mirrorInitStyle = 'position: absolute; top: -999px; right: auto; bottom: auto;' +
      'left: 0; overflow: hidden; -webkit-box-sizing: content-box;' +
      '-moz-box-sizing: content-box; box-sizing: content-box;' +
      'min-height: 0 !important; height: 0 !important; padding: 0;' +
      'word-wrap: break-word; border: 0;',
    mirror = h('textarea', {
      aria: {
        hidden: 'true'
      },
      tabindex: -1,
      style: mirrorInitStyle,
      data: {
        elastic: true
      }
    }),
    taStyle = getComputedStyle(ta),
    resize = taStyle.getPropertyValue('resize'),
    borderBox = taStyle.getPropertyValue('box-sizing') === 'border-box' ||
      taStyle.getPropertyValue('-moz-box-sizing') === 'border-box' ||
      taStyle.getPropertyValue('-webkit-box-sizing') === 'border-box',
    boxOuter = !borderBox ? {width: 0, height: 0} : {
      width: int(taStyle.getPropertyValue('border-right-width')) +
        int(taStyle.getPropertyValue('padding-right')) +
        int(taStyle.getPropertyValue('padding-left')) +
        int(taStyle.getPropertyValue('border-left-width')),
      height: int(taStyle.getPropertyValue('border-top-width')) +
        int(taStyle.getPropertyValue('padding-top')) +
        int(taStyle.getPropertyValue('padding-bottom')) +
        int(taStyle.getPropertyValue('border-bottom-width'))
    },
    minHeightValue = int(taStyle.getPropertyValue('min-height')),
    heightValue = int(taStyle.getPropertyValue('height')),
    minHeight = Math.max(minHeightValue, heightValue) - boxOuter.height,
    maxHeight = int(taStyle.getPropertyValue('max-height')),
    mirrored,
    active,
    copyStyle = [
      'font-family',
      'font-size',
      'font-weight',
      'font-style',
      'letter-spacing',
      'line-height',
      'text-transform',
      'word-spacing',
      'text-indent'
    ]

  // Opera returns max-height of -1 if not set
  maxHeight = maxHeight && maxHeight > 0 ? maxHeight : 9e4

  // append mirror to the DOM
  if (mirror.parentNode !== document.body) {
    document.body.appendChild(mirror)
  }

  // set resize and apply elastic
  assign($ta.style, {
    'resize': (resize === 'none' || resize === 'vertical') ? 'none' : 'horizontal'
  })
  $ta.dataset.elastic = true

  /*
   * methods
   */

  function initMirror () {
    var mirrorStyle = mirrorInitStyle

    mirrored = ta
    // copy the essential styles from the textarea to the mirror
    taStyle = getComputedStyle(ta)
    each(copyStyle, function (val) {
      mirrorStyle += val + ':' + taStyle.getPropertyValue(val) + ';'
    })
    mirror.setAttribute('style', mirrorStyle)
  }

  function adjust () {
    var taHeight,
      taComputedStyleWidth,
      mirrorHeight,
      width,
      overflow

    if (mirrored !== ta) {
      initMirror()
    }

    // active flag prevents actions in function from calling adjust again
    if (!active) {
      active = true

      mirror.value = ta.value // optional whitespace to improve animation
      mirror.style.overflowY = ta.style.overflowY

      taHeight = ta.style.height === '' ? 'auto' : int(ta.style.height)

      taComputedStyleWidth = getComputedStyle(ta).getPropertyValue('width')

      // ensure getComputedStyle has returned a readable 'used value' pixel width
      if (taComputedStyleWidth.substr(taComputedStyleWidth.length - 2, 2) === 'px') {
        // update mirror width in case the textarea width has changed
        width = int(taComputedStyleWidth) - boxOuter.width
        mirror.style.width = width + 'px'
      }

      mirrorHeight = mirror.scrollHeight

      if (mirrorHeight > maxHeight) {
        mirrorHeight = maxHeight
        overflow = 'scroll'
      } else if (mirrorHeight < minHeight) {
        mirrorHeight = minHeight
      }
      mirrorHeight += boxOuter.height + 24
      ta.style.overflowY = overflow || 'hidden'

      if (taHeight !== mirrorHeight) {
        console.log('h:', mirrorHeight)
        ta.style.height = mirrorHeight + 'px'
        ractive.fire('elastic:resize', $ta)
      }

      // small delay to prevent an infinite loop
      setTimeout(function () {
        active = false
      }, 1)
    }
  }

  function forceAdjust () {
    active = false
    adjust()
  }

  /*
   * initialise
   */

  // listen
  if ('onpropertychange' in ta && 'oninput' in ta) {
    // IE9
    ta['oninput'] = ta.onkeyup = adjust
  } else {
    ta['oninput'] = adjust
  }

  win.addEventListener('resize', forceAdjust)

  if (keypath) ractive.observe(keypath, function (v) {
    forceAdjust()
  })


  ractive.on('elastic:adjust', function () {
    initMirror()
    forceAdjust()
  })

  setTimeout(adjust, 0)

  return {
    teardown () {
      mirror.parentNode.removeChild(mirror)
      win.removeEventListener('resize', forceAdjust)
    }
  }
}
// select (node, keypath) {
//   node.focus()
//   return {
//     teardown () {
//       // pika.destroy()
//     }
//   }
// }

export default nlElastic
