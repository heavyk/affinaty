// knicked from: https://github.com/k4wo/tiny-xhr/blob/master/index.js
//  * use callbacks instead promises

import qs from './qs'

function xhr (opt, cb) {
  if (!opt || !opt.url) {
    cb('No required options - url and/or method.')
  }
  var data = null,
    url = opt.url,
    method = opt.method ? opt.method.toLowerCase() : 'get',
    xhr = new XMLHttpRequest()

  if (opt.data) {
    if (opt.type === 'multipart') {
      data = String.prototype.slice.call(opt.data) === '[object FormData]' ? opt.data : new FormData(opt.data)
    } else {
      data = qs.stringify(opt.data)
    }

    if (method === 'get' && opt.type.toLowerCase() === 'json' && data) {
      url += '?' + data
    }
  }
  // console.log('xhr.open', method, url)
  xhr.open(method, url, true)

  if (opt.headers) {
    for ( var header in opt.headers ) {
      xhr.setRequestHeader(header, opt.headers[header])
    }
  }

  xhr.onload = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {
      try {
        cb(null, JSON.parse(xhr.response))
      } catch(e) {
        cb(null, xhr.response)
      }
    } else {
      cb(xhr)
    }
  }

  xhr.onerror = function (e) {
    cb(e)
  }
  xhr.send(data)
}

export function binary (url, cb) {
  return new BinaryXHR(url, cb)
}

function BinaryXHR (url, cb) {
  // if (!this instanceof BinaryXHR) return new BinaryXHR(url, cb)
  var xhr = new XMLHttpRequest()
  this.xhr = xhr
  xhr.open('GET', url, true)
  xhr.responseType = 'arraybuffer'
  xhr.onreadystatechange = () => {
    if (this.readyState === 4) {
      if (this.status !== 200) {
        cb(this.status, this.response)
      } else if (this.response && this.response.byteLength > 0) {
        cb(false, this.response)
      } else if (this.response && this.response.byteLength === 0) {
        cb('response length 0')
      } else {
        cb('no response')
      }
    }
  }
  xhr.send(null)
}

export default xhr
