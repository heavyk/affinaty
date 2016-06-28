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
  console.log('xhr.open', method, url)
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
      } catch(e ) {
        cb(null, xhr.response)
      }
    } else {
      cb(xhr)
    }
  }

  xhr.onerror = function () {
    reject(xhr)
  }
  xhr.send(data)
}

export default xhr
