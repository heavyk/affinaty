
import h from '../dom/hyper-hermes'

function tip (node, text, offset) {
  offset = offset || 5
  let el, body = document.body
  let onmouseover = () => {
    let r = body.getBoundingClientRect()
    let rect = node.getBoundingClientRect()
    if (!el) {
      body.appendChild(el =
        h('div', {c: 'tooltip-outer', s: {position: 'absolute'}},
          h('div', {c: 'tooltip-arrow'}),
          h('div', {c: 'tooltip-inner'}, text)
        )
      )
    }
    el.style.display = 'block'
    el.style.top = offset + rect.top - r.top + 'px'
    el.style.left = Math.ceil(rect.right - (rect.width / 2)) + 'px'
    el.style.marginLeft = -Math.ceil((el.clientWidth-4) / 2) + 'px'
  }
  let onmouseout = () => {
    if (el) el.style.display = 'none'
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
