// functions to parse video urls
import Url from 'url'
import qs from 'querystring'

var vimeo_regex = /https?:\/\/(?:www\.|player\.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|)(\d+)(?:$|\/|\?)/
export function vimeo_id (url) {
  var match = url.match(vimeo_regex)
  return match && typeof match[3] === 'string' ? match[3] : null
}

var yt_regex = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/
export function youtube_id (url) {
  var match = url.match(yt_regex)
  return match && match[7].length === 11 ? match[7] : null
}

var vine_regex = /^http(?:s?):\/\/(?:www\.)?vine\.co\/v\/([a-zA-Z0-9]{1,13}).*/
export function vine_id (url) {
  var match = url.match(vine_regex)
  return match && match[1].length === 11 ? match[1] : null
}

// to parse this:
// <iframe src="http://cdnapi.kaltura.com/p/1910301/sp/191030100/embedIframeJs/uiconf_id/28928951/partner_id/1910301?iframeembed=true&playerId=verteletv-main-clip-571e3bcee87d1&entry_id=1_a9s8ncyo&flashvars[streamerType]=auto" width="560" height="395" allowfullscreen webkitallowfullscreen mozAllowFullScreen frameborder="0"></iframe>
//                                                                                                                                                                 ^^^^^^^^^^^^^    |     ^^^^^^^^^^
export function vertele_id (url) {
  // if (!~url.indexOf('verteletv-main-clip')) return null
  var u, v
  if (u = Url.parse(url)) {
    v = qs.parse(u.query)
    u = v.playerId
  }
  return v && u ? u.substr(u.lastIndexOf('-') + 1) + '|' + v.entry_id : null
}

export function iframe_src (txt) {
  var url, i, u, v
  if (~(i = txt.indexOf('src="'))) {
    url = txt.substring(i+5)
    url = url.substr(0, url.indexOf('"'))
    return url
  }
  return url ? url : txt
}
