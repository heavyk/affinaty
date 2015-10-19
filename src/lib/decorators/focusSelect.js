
function focusSelect (node, keypath, direction) {
  node.addEventListener('focus', function onfocus () {
    node.select(true)
  }, false)
  return {
    teardown () {
      node.removeEventListener('focus', onfocus, false)
    }
  }
}

export default focusSelect
