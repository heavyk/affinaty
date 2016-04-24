// functions to parse video urls

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
