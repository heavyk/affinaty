
// TODO: use the format link function instead of text.replace

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
  url: function (service, videoID, options) {
    switch (service) {
      case 'youtube': return '//www.youtube.com/embed/' + videoID;
      case 'vimeo': return '//player.vimeo.com/video/' + videoID;
      case 'vine': return '//vine.co/v/' + videoID + '/embed/' + options.vine.embed;
      case 'vertele':
        var id = videoID.split('|')
        return `http://cdnapi.kaltura.com/p/1910301/sp/191030100/embedIframeJs/uiconf_id/28928951/partner_id/1910301?iframeembed=true&playerId=verteletv-main-clip-${id[0]}&entry_id=${id[1]}&flashvars[streamerType]=auto`;
    }
  },
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
  },
  vertele: {
    width: 250,
    height: 140,
  },
})

function markdown (node, text) {
  text = text ? md.render(text) : ''
  node.innerHTML = text.replace(/<a href=/g, '<a target="blank" href=')
  let width = node.clientWidth
  if (~text.indexOf('embed-responsive')) {
    let n = node.querySelectorAll('.embed-responsive')
    for (var i = 0; i < n.length; i++) {
      n[i].style.height = (n[i].childNodes[0].id.indexOf('vine') === 0 ? width : Math.round(width * 9 / 16)) + 'px'
    }
  }

  return {
    teardown () {}
  }
}

export default markdown
