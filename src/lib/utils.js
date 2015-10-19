// TODO - move all this into ./utils/

export function assign (object, source) {
  for (var i = 1, c = arguments.length; i < c; i++) {
    for (var x in arguments[i]) {
      if (arguments[i].hasOwnProperty(x) && arguments[i][x] !== undefined) {
        object[x] = arguments[i][x]
      }
    }
  }

  return object
}


import compact from './lodash/array/compact'
/*
export function compact (collection) {
  return pick(collection, function (value) {
    return !isEmpty(value)
  })
}
*/

import isEmpty from './lodash/lang/isEmpty'
/*
export function isEmpty (value) {
  if (!value || typeof value !== 'object') {
    return !value
  }

  return !Object.keys(value).length
}
*/

export function joinPaths (parts) {
  return Array.prototype.slice.call(arguments)
    .join('/')
    .replace(/\/+/g, '/')
}

export function parents (el, name) {
  while (el && el.nodeName.toLowerCase() !== name) {
    el = el.parentNode
  }

  return el && el.nodeName.toLowerCase() === name
    ? el
    : null
}

export function parseHash (hash, keys) {
  try {
    var parsed = compact(JSON.parse(decodeURIComponent(hash.substr(2))))

    return keys
      ? pick(parsed, keys)
      : parsed
  } catch (e) {
    return {}
  }
}

export function parseJSON (string) {
  try {
    return JSON.parse(string)
  } catch (e) {
    return string || ''
  }
}

export function parseUri (uri) {
  var parts = uri.match(/^(?:([\w+.-]+):\/\/([^/]+))?([^?#]*)?(\?[^#]*)?(#.*)?/)

  return {
    protocol: parts[1] || '',
    host: parts[2] || '',
    path: parts[3] || '',
    qs: parts[4] || '',
    hash: parts[5] || ''
  }
}

export function parseQS (qs, keys) {
  var index = qs.indexOf('?')
  var parsed = {}

  if (index !== -1) {
    var pairs = qs.substr(index + 1).split('&')
    var pair = []

    for (var i = 0, c = pairs.length; i < c; i++) {
      pair = pairs[i].split('=')

      if ((!isEmpty(pair[1])) && (!isEmpty(parseJSON(pair[1])))) {
        parsed[decodeURIComponent(pair[0])] = parseJSON(decodeURIComponent(pair[1]))
      }
    }
  }

  return keys
    ? pick(parsed, keys)
    : parsed
}

import pick from './lodash/object/pick'
/*
export function pick (object, keys) {
  var data = {}

  if (typeof keys === 'function') {
    for (var x in object) {
      if (object.hasOwnProperty(x) && keys(object[x], x)) {
        data[x] = object[x]
      }
    }
  } else {
    for (var i = 0, c = keys.length; i < c; i++) {
      data[keys[i]] = object[keys[i]]
    }
  }

  return data
}
*/

export function scrollTo (id) {
  if (!id) return
  var el = document.getElementById(id)

  if (el) {
    window.scrollBy(0, el.getBoundingClientRect().top)
  } else {
    window.scrollTo(0, 0)
  }
}

export function stringify (value) {
  if (!value || typeof value !== 'object') {
    return value
  }

  return JSON.stringify(value)
}

export function stringifyHash (data) {
  data = compact(data)

  return !isEmpty(data)
    ? '#!' + encodeURIComponent(stringify(data))
    : ''
}

export function stringifyQS (data) {
  var qs = ''

  for (var x in data) {
    if (data.hasOwnProperty(x) && !isEmpty(data[x])) {
      qs += '&' + encodeURIComponent(x) + '=' + encodeURIComponent(stringify(data[x]))
    }
  }

  return qs
    ? '?' + qs.substr(1)
    : ''
}

export function addClass (node, className) {
  if (node.classList) {
    node.classList.add(className)
  } else {
    var pattern = new RegExp(`\\b${className}\\b`)
    if (!pattern.test(node.getAttribute('class'))) {
      node.setAttribute('class', node.getAttribute('class') + ' ' + className)
    }
  }
}

export function removeClass (node, className) {
  if (node.classList) {
    node.classList.remove(className)
  } else {
    var pattern = new RegExp(`\\b${className}\\b`, 'g')
    if (pattern.test(node.getAttribute('class'))) {
      node.setAttribute('class', node.getAttribute('class').replace(pattern, ''))
    }
  }
}

import repeat from './lodash/string/repeat'

export default {
  assign,
  compact,
  isEmpty,
  joinPaths,
  parents,
  parseHash,
  parseJSON,
  parseUri,
  parseQS,
  pick,
  scrollTo,
  stringify,
  stringifyHash,
  stringifyQS,
  addClass,
  removeClass,
  repeat,
}
