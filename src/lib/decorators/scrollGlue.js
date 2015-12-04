
// origin: https://github.com/Luegg/angularjs-scroll-glue

import onresize from '../dom/element-onresize'

function scrollGlue (node, keypath, direction) {
  direction = direction || 'bottom'
  var directions = {
    bottom: {
      isAttached (el) {
        // + 1 catches off by one errors in chrome
        return el.scrollTop + el.clientHeight + 1 >= el.scrollHeight
      },
      scroll (el) {
        el.scrollTop = el.scrollHeight
      }
    },

    top: {
      isAttached (el) {
        return el.scrollTop <= 1
      },
      scroll (el) {
        el.scrollTop = 0
      }
    },

    right: {
      isAttached (el) {
        return el.scrollLeft + el.clientWidth + 1 >= el.scrollWidth
      },
      scroll (el) {
        el.scrollLeft = el.scrollWidth
      }
    },

    left: {
      isAttached (el) {
        return el.scrollLeft <= 1
      },
      scroll (el) {
        el.scrollLeft = 0
      }
    },
  }

  let i = 0
  let glue = () => {
    let attached = directions[direction].isAttached(node)
    if (attached || i++ === 0) {
      setTimeout(() => {
        directions[direction].scroll(node)
      }, 1)
    }
  }

  onresize.addResizeListener(node, glue)
  let info = Ractive.getNodeInfo(node)
  let observer = info.ractive.observe(keypath, glue)
  return {
    teardown () {
      onresize.removeResizeListener(node, glue)
      observer.cancel()
    }
  }
}

export default scrollGlue
