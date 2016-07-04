import ClassList from './class-list.js'
import observable from './observable.js'
import each from '../lodash/forEach'
var doc = window.document
var observable_name = observable().name
/*
TODO ITEMS:
 * extract out the attribute setting function and make it available to the attribute observable so setting attributes will work properyly for shortcut syntax
*/

function context (createElement) {

  var cleanupFuncs = []

  function h() {
    var args = [].slice.call(arguments), e = null
    function item (l) {
      var r
      function parseClass (string) {
        var m = string.split(/([\.#]?[a-zA-Z0-9_:-]+)/)
        if (/^\.|#/.test(m[1])) e = createElement('div')
        forEach(m, function (v) {
          var s = v.substring(1, v.length)
          if (!v) return
          if (!e) {
            e = createElement(v)
          } else if (v[0] === '.') {
            ClassList(e).add(s)
          } else if (v[0] === '#') {
            e.setAttribute('id', s)
          }
        })
      }

      if (l == null) {
        ;
      } else if ('string' === typeof l) {
        if (!e) {
          parseClass(l)
        } else {
          e.appendChild(r = doc.createTextNode(l))
        }
      } else if ('number' === typeof l
        || 'boolean' === typeof l
        || l instanceof Date
        || l instanceof RegExp ) {
          e.appendChild(r = doc.createTextNode(l.toString()))
      } else if (Array.isArray(l)) {
        forEach(l, item)
      } else if (isNode(l)) {
        e.appendChild(r = l)
      } else if (l instanceof window.Text) {
        e.appendChild(r = l)
      } else if ('object' === typeof l) {
        // for (var k in l) {
        each(l, function (attr_val, k) {
          if ('function' === typeof attr_val) {
            if (/^on\w+/.test(k)) {
              if (e.addEventListener) {
                e.addEventListener(k.substring(2), attr_val, false)
                cleanupFuncs.push(function () {
                  e.removeEventListener(k.substring(2), attr_val, false)
                })
              } else {
                e.attachEvent(k, attr_val)
                cleanupFuncs.push(function () {
                  e.detachEvent(k, attr_val)
                })
              }
            } else {
              // observable
              // e[k] = attr_val()
              e.setAttribute(k, attr_val())
              cleanupFuncs.push(attr_val(function (v) {
                // e[k] = v
                e.setAttribute(k, v)
                // console.log('set attribute', k, '->', v)
              }))
            }
          } else if (k === 'data') {
            for(var s in attr_val) e.dataset[s] = attr_val[s]
          } else if (k === 'for') {
            e.htmlFor = attr_val
          } else if (k === 'c' || k === 'class') {
            // e.className = Array.isArray(attr_val) ? attr_val.join(' ') : attr_val
            if (Array.isArray(attr_val)) {
              forEach(attr_val, function (c) {
                ClassList(e).add(c)
              })
            } else ClassList(e).add(attr_val)
          } else if (k === 'on') {
            if ('object' === typeof attr_val) {
              for (var s in attr_val) (function (event, listener) {
                if ('function' === typeof listener) {
                  // ???
                  (e.on || e.addEventListener)
                    .call(e, event, listener, false)

                  cleanupFuncs.push(function () {
                    // copied from observable
                    (e.removeListener || e.removeEventListener || e.off)
                      .call(e, event, listener, false)
                  })
                }
              })(s, attr_val[s])
            // } else if ('function' === typeof attr_val) {
            //   // another event listener ...
            //   // re-emit listened events into this listener...
            //   // for(k in attr_val._listeners) { ... }
            // } else {
            //   debugger
            }
          } else if (k === 's' || k === 'style') {
            if ('string' === typeof attr_val) {
              e.style.cssText = attr_val
            } else {
              for (var s in attr_val) (function (s, v) {
                if ('function' === typeof v) {
                  // observable
                  e.style.setProperty(s, v())
                  cleanupFuncs.push(v(function (val) {
                    e.style.setProperty(s, val)
                  }))
                } else {
                  e.style.setProperty(s, attr_val[s])
                }
              })(s, attr_val[s])
            }
          } else if (k.substr(0, 5) === "data-") {
            e.setAttribute(k, attr_val)
          } else if (typeof attr_val !== 'undefined') {
            // this is an ugly hack to be able to use holder.js
            // I'd like to perhaps move it out to a wrapper function
            // TODO: add composition hooks instead of this shit...
            if (~k.indexOf(':')) {
              var attr = k.split(':')
              switch (attr[0]) {
                case 'xlink':
                  e.setAttributeNS('http://www.w3.org/1999/xlink', attr[1], attr_val)
                  break
                default:
                  console.error('unknown namespaced attribute: ' + k)
              }
            } else if (k === 'src' && e.tagName === 'IMG' && ~attr_val.indexOf('holder.js')) {
              e.dataset.src = attr_val
              console.log('you are using holder ... fix this')
              // setTimeout(function () {
              //   require('holderjs').run({images: e})
              // },0)
            } else {
              // e[k] = attr_val
              e.setAttribute(k, attr_val)
            }
          }
        })
      } else if ('function' === typeof l) {
        var is_observable = !!l.observable
        var v = is_observable ? l.call(e) : l.call(this, e)
        // console.log('v', l.length, l.name, v)
        if (v !== void 0) e.appendChild(
          r = isNode(v) ? v
            : Array.isArray(v) ? arrayFragment(e, v)
            : doc.createTextNode(v)
        )
        // assume we want to make a scope...
        // call the function and if it returns an element, or an array, appendChild
        if (r && is_observable) {
          // assume it's an observable!
          // TODO: allow for an observable-array implementation
          cleanupFuncs.push(l(function (v) {
            // console.log(v)
            if (isNode(v) && r.parentElement) {
              r.parentElement.replaceChild(v, r), r = v
            // TODO: observable-array cleanup
            } else {
              r.textContent = v
            }
          }))
        }
      }

      return r
    }
    while(args.length) {
      item(args.shift())
    }

    return e
  }

  h.cleanup = function () {
    for (var i = 0; i < cleanupFuncs.length; i++) {
      cleanupFuncs[i]()
    }
  }

  return h
}

function isNode (el) {
  return el && el.nodeName && el.nodeType
}

function isText (el) {
  return el && el.nodeName === '#text' && el.nodeType == 3
}

function forEach (arr, fn) {
  // micro-optimization here: http://jsperf.com/for-vs-foreach/292
  // was: if (arr.forEach) return arr.forEach(fn)
  for (var i = 0; i < arr.length; ++i) fn(arr[i], i)
}

function forEachReverse (arr, fn) {
  for (var i = arr.length - 1; i >= 0; i--) fn(arr[i], i)
}

function arrayFragment(e, arr) {
  var frag = doc.createDocumentFragment()
  var first = e.childNodes.length
  forEach(arr, function (v) {
    frag.appendChild(
      isNode(v) ? v
        : Array.isArray(v) ? arrayFragment(frag, v)
        : doc.createTextNode(v)
    )
  })

  var last = first + arr.length
  if (typeof arr.on === 'function') {
    // if it's an EE, then it's likely an observable-array (like) Array,
    arr.on('change', function (ev) {
      switch (ev.type) {
      case 'unshift':
        forEachReverse(ev.values, function (v) {
          e.insertBefore(isNode(v) ? v : doc.createTextNode(v), e.childNodes[first])
          last++
        })
      break
      case 'push':
        forEach(ev.values, function (v) {
          e.insertBefore(isNode(v) ? v : doc.createTextNode(v), e.childNodes[last])
          last++
        })
        break
      case 'pop':
        e.removeChild(e.childNodes[--last])
        break
      case 'shift':
        e.removeChild(e.childNodes[first])
        last--
        break
      case 'splice':
        if (ev.removed) forEach(ev.removed, function (v) {
          e.removeChild(v)
          last--
        })
        var len = ev.arguments.length
        if (len > 2) {
          for (var i = 2; i < len; i++) {
            var v = ev.arguments[i]
            e.insertBefore(isNode(v) ? v : doc.createTextNode(v), e.childNodes[last])
          }
        }
        break
      case 'sort':
        for (var i = 0, orig = ev.orig; i < orig.length; i++) {
          var o = orig[i]
          var idx = arr.indexOf(o)
          if (i !== idx) {
            e.removeChild(o)
            e.insertBefore(arr[idx], e.childNodes[idx])
          }
        }
        break
      case 'reverse': // TODO
      default:
        debugger
      }
    })
  }
  return frag
}


var h = context(function (el) { return doc.createElement(el) })
h.context = context
export default h
