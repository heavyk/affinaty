
let _markdown = require('markdown-it')
let md = _markdown({
  breaks: true,
  xhtmlOut: true,
  typographer: true,
  linkify: true,
})
// plugins
.use(require('markdown-it-emoji'))
.use(require('markdown-it-video'), {
  youtube: {
    width: 250,
    height: 140,
  },
  vimeo: {
    width: 250,
    height: 140,
  },
  vine: {
    width: 250,
    height: 250,
    embed: 'simple?audio=1',
  }
})

function markdown (node, keypath) {
  let info = Ractive.getNodeInfo(node)
  let transform = (text) => {
    text = text ? md.render(text) : ''
    node.innerHTML = text.replace(/<a href=/g, '<a target="blank" href=')
    let width = node.clientWidth
    if (~text.indexOf('embed-responsive')) {
      let n = node.querySelectorAll('.embed-responsive')
      for (var i = 0; i < n.length; i++) {
        n[i].style.height = (n[i].childNodes[0].id.indexOf('vine') === 0 ? width : Math.round(width * 9 / 16)) + 'px'
      }
    }
  }

  if (info.keypath) {
    transform(this.get(info.keypath + '.' + keypath))
  } else {
    this.observe(keypath, transform, {defer: true})
  }

  return {
    teardown () {}
  }
}

export default markdown
