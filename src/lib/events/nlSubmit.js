
// function nlSubmit (node, _event) {
  // var submit = _event || 'submit'
function nlSubmit (node, fire) {
  // var submit = 'submit'
  var not_ta = node.nodeName !== 'TEXTAREA'
  node.addEventListener('keydown', handler)
  function handler (e) {
    var code = e.keyCode || e.which
    if (code === 13) {
      if (not_ta) {
        e.preventDefault()
      }
      if (e.shiftKey) {
        if (not_ta) {
          e.target.value += '\n'
        }
      } else {
        fire({
          node: node,
          original: e,
          value: e.target.value
        })

        e.target.value = ''
        e.preventDefault()
        node._ractive.root.fire('elastic:adjust')
      }
    }
  }

  return {
    teardown: function () {
      node.removeEventListener('keydown', handler)
    }
  };
}

export default nlSubmit
