
import h from '../dom/hyper-hermes'

function tip (node, text, offset) {
  offset = offset || 5
  let el, body = document.body
  let onmouseleave = (event) => {
    if (el) el.style.display = 'none'
  }
  let onmouseenter = () => {
    let r = body.getBoundingClientRect()
    let rect = node.getBoundingClientRect()
    if (!el) {
      body.appendChild(el =
        h('div', {c: 'tooltip-outer', s: {position: 'absolute', onmouseleave}},
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
  node.addEventListener('mouseenter', onmouseenter)
  node.addEventListener('mouseleave', onmouseleave)

  return {
    teardown () {
      node.removeEventListener('mouseenter', onmouseenter)
      node.removeEventListener('mouseleave', onmouseleave)
      if (el) body.removeChild(el)
    }
  }
}

export default tip
