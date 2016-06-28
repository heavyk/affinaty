// knicked from https://github.com/Alex1990/tiny-qs/blob/master/tiny-qs.js

var objProto = Object.prototype

// Util object.
var _ = {}

_.toString = function (obj) {
  return obj + ''
}

_.isEmpty = function (obj) {
  return obj == null || obj === ''
}

_.isType = function (type) {
  return function (obj) {
    return objProto.toString.call(obj) === '[object ' + type + ']'
  }
}

_.isObject = _.isType('Object')
_.isArray = _.isType('Array')
_.isFunction = _.isType('Function')
_.isString = _.isType('String')

_.has = function (obj, prop) {
  return objProto.hasOwnProperty.call(obj, prop)
}

_.each = function (obj, callback) {
  if (_.isArray(obj)) {
    if (_.isFunction(obj.forEach)) {
      obj.forEach(callback)
    } else {
      for (var i = 0, len = obj.length; i < len; i++) {
        callback(obj[i], i, obj)
      }
    }
  } else if (_.isObject(obj)) {
    for (var p in obj) {
      if (_.has(obj, p)) {
        callback(obj[p], p, obj)
      }
    }
  }
}

var sep = '&'; // Query string seperator character..
var eq = '='; // Query string assignment character.

// Deserialize a query string to an object.
// Serialize an object to a query string.
// Deserialize the current page query string to an object.
function qs (val, isCodec) {
  if (_.isString(val)) {
    return qs.parse(val, isCodec)
  } else if (_.isObject(val)) {
    return qs.stringify(val, isCodec)
  } else {
    return qs.parse(location.search.slice(1))
  }
}

// Deserialize a query string to an object.
qs.parse = function (str, decode) {
  if (_.isEmpty(str)) return {}

  if (decode === false) {
    decode = _.toString
  } else if (!_.isFunction(decode)) {
    decode = decodeURIComponent
  }

  str = str.split(sep)
  var data = {}

  _.each(str, function (pair) {
    pair = pair.split(eq)
    var key = decode(pair[0])
    var value = pair[1] !== undefined ? decode(pair[1]) : ''

    if (!_.has(data, key)) {
      data[key] = value
    } else {
      if (_.isArray(data[key])) {
        data[key].push(value)
      } else {
        data[key] = [ data[key]]
        data[key].push(value)
      }
    }
  })

  return data
}

// Serialize an object to a query string.
qs.stringify = function (obj, encode) {
  if (!_.isObject(obj)) return ''

  if (encode === false) {
    encode = _.toString
  } else if (!_.isFunction(encode)) {
    encode = encodeURIComponent
  }

  var data = []

  _.each(obj, function (value, key) {
    if (!_.isArray(value)) {
      data.push(encode(key) + eq + (value == null ? '' : encode(value)))
    } else {
      _.each(value, function (subVal) {
        data.push(encode(key) + eq + (subVal == null ? '' : encode(subVal)))
      })
    }
  })

  return data.join(sep)
}

export default qs
