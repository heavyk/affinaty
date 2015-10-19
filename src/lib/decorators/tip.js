
import h from '../dom/hyper-hermes'

function tip (node, text) {
  let el
  let body = document.body
  let rect = node.getBoundingClientRect()
  let o = (rect.width / 2)
  let s = {
    position: 'absolute',
    top: 5 + rect.top + 'px',
    left: (rect.right - o) + 'px'
  }
  let onmouseover = () => {
    if (!el) {
      body.appendChild(el =
        h('div', {s},
          h('div', {c: 'tooltip-arrow'}),
          h('div', {c: 'tooltip-inner'}, text)
        )
      )
    }
    el.style.display = 'block'
    el.style.marginLeft = -(el.clientWidth / 2) + 'px'
  }
  let onmouseout = () => {
    el.style.display = 'none'
  }
  node.addEventListener('mouseover', onmouseover)
  node.addEventListener('mouseout', onmouseout)

  return {
    teardown () {
      node.removeEventListener('mouseover', onmouseover)
      node.removeEventListener('mouseout', onmouseout)
      if (el) body.removeChild(el)
    }
  }
}

export default tip
