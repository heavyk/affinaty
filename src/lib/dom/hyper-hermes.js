// hyper-hermes
// knicked from https://github.com/dominictarr/hyperscript
// many modifications...
// also took some inspiration from https://github.com/Raynos/mercury

import ClassList from './class-list.js'
// import observable from './observable.js'
var doc = window.document

/*
TODO ITEMS:
 * extract out the attribute setting function and make it available to the attribute observable so setting attributes will work properyly for shortcut syntax
*/

function txt (t) {
  return doc.createTextNode(t)
}

function context (createElement, arrayFragment) {

  var cleanupFuncs = []

  function add_event (e, event, listener, opts) {
    (e.on || e.addEventListener)
      .call(e, event, listener, opts)

    cleanupFuncs.push(function () {
      // copied from observable
      (e.removeListener || e.removeEventListener || e.off)
        .call(e, event, listener, opts)
    })
  }


  function h() {
    var args = [].slice.call(arguments), e = null
    function item (l) {
      var r, s, i, o
      function parseClass (string) {
        var m = string.split(/([\.#]?[a-zA-Z0-9_:-]+)/)
        if (/^\.|#/.test(m[1])) e = createElement('div')
        forEach(m, function (v) {
          if (typeof v === 'string' && (i = v.length)) {
            if (!e) {
              e = createElement(v)
            } else {
              s = v.substring(1, i)
              if (v[0] === '.') {
                ClassList(e).add(s)
              } else if (v[0] === '#') {
                e.setAttribute('id', s)
              }
            }
          }
        })
      }

      if (l != null)
      if (typeof l === 'string') {
        if (!e) {
          parseClass(l)
        } else {
          e.appendChild(r = txt(l))
        }
      } else if (typeof l === 'number'
        || typeof l === 'boolean'
        || l instanceof Date
        || l instanceof RegExp ) {
          e.appendChild(r = txt(l.toString()))
      } else if (Array.isArray(l)) {
        forEach(l, item)
      } else if (isNode(l) || l instanceof window.Text) {
        e.appendChild(r = l)
      } else if (typeof l === 'object') {
        // each(l, function (attr_val, k) {
        for (var k in l) (function (attr_val, k) {
          if (typeof attr_val === 'function') {
            // TODO: not sure which one is faster: regex or substr test
            // if (/^on\w+/.test(k)) {
            if (k.substr(0, 2) === 'on') {
              add_event(e, k.substr(2), attr_val, false)
            } else {
              // observable
              e.setAttribute(k, attr_val())
              cleanupFuncs.push(attr_val(function (v) {
                e.setAttribute(k, v)
                // console.log('set attribute', k, '->', v)
              }))
            }
          } else if (k === 'data') {
            for(s in attr_val) e.dataset[s] = attr_val[s]
          } else if (k === 'for') {
            e.htmlFor = attr_val
          } else if (k === 'c' || k === 'class') {
            // e.className = Array.isArray(attr_val) ? attr_val.join(' ') : attr_val
            if (Array.isArray(attr_val)) {
              forEach(attr_val, function (c) {
                if (c) ClassList(e).add(c)
              })
            } else if (attr_val) ClassList(e).add(attr_val)
          } else if (k === 'on') {
            if (typeof attr_val === 'object') {
              for (s in attr_val)
                if (typeof (o = attr_val[s]) === 'function')
                  add_event(e, s, o, false)
            }
          } else if (k === 'capture') {
            if (typeof attr_val === 'object') {
              for (s in attr_val)
                if (typeof (o = attr_val[s]) === 'function')
                  add_event(e, s, o, true)
            }
          } else if (k === 's' || k === 'style') {
            if (typeof attr_val === 'string') {
              e.style.cssText = attr_val
            } else {
              for (s in attr_val) (function (s, v) {
                if (typeof v === 'function') {
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
            // for namespaced attributes, such as xlink:href
            // (I'm really not aware of any others than xlink... PRs accepted!)
            if (~(i = k.indexOf(':'))) {
              // var attr = k.split(':')
              // debugger
              switch (k.substr(0, i)) {
                case 'xlink':
                  // debugger
                  e.setAttributeNS('http://www.w3.org/1999/xlink', k.substr(++i), attr_val)
                //   break
                // default:
                //   console.error('unknown namespaced attribute: ' + k)
              }
            // } else if (k === 'src' && e.tagName === 'IMG' && ~attr_val.indexOf('holder.js')) {
            //   e.dataset.src = attr_val
            //   console.log('you are using holder ... fix this')
            //   // setTimeout(function () {
            //   //   require('holderjs').run({images: e})
            //   // },0)
            } else {
              // e[k] = attr_val
              console.log('set-attribute', k, attr_val)
              e.setAttribute(k, attr_val)
            }
          }
        })(l[k], k)
      } else if (typeof l === 'function') {
        i = l.observable && l.observable === 'value' ? 1 : 0
        o = i ? l.call(e) : l.call(this, e)
        if (o !== undefined) {
          r = isNode(o) ? o
            : Array.isArray(o) ? arrayFragment(e, o, cleanupFuncs)
            : txt(o)
          if (r) e.appendChild(r)
        }
        // assume we want to make a scope...
        // call the function and if it returns an element, or an array, appendChild
        if (r && i) {
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
    while (args.length) {
      item(args.shift())
    }

    return e
  }

  h.cleanupFuncs = cleanupFuncs
  h.cleanup = function () {
    for (var i = 0; i < cleanupFuncs.length; i++) {
      cleanupFuncs[i]()
    }
  }

  return h
}

export function isNode (el) {
  return el && el.nodeType
}

export function isText (el) {
  return el && el.nodeType == 3
}

// micro-optimization: http://jsperf.com/for-vs-foreach/292
export function forEach (arr, fn) {
  for (var i = 0; i < arr.length; ++i) fn(arr[i], i)
}

export function forEachReverse (arr, fn) {
  for (var i = arr.length - 1; i >= 0; i--) fn(arr[i], i)
}

function arrayFragment(e, arr, cleanupFuncs) {
  var frag = doc.createDocumentFragment()
  var first = e.childNodes.length
  forEach(arr, function (_v) {
    var i, v = _v
    if (typeof v === 'function') {
      i = v.observable && v.observable === 'value' ? 1 : 0
      v = i ? v.call(e) : v.call(this, e)
    }

    if (v) {
      frag.appendChild(
        isNode(v) ? v
          : Array.isArray(v) ? arrayFragment(frag, v, cleanupFuncs)
          : txt(v)
      )

      if (i === 1) {
        // assume it's an observable!
        cleanupFuncs.push(_v(function (__v) {
          // console.log(v)
          if (isNode(__v) && v.parentElement) {
            v.parentElement.replaceChild(__v, v), v = __v
          // TODO: observable-array cleanup
          } else {
            v.textContent = __v
          }
        }))
      }
    }
  })

  var last = first + arr.length
  if (typeof arr.on === 'function') {
    // if it's an EE, then it's likely an observable-array (like) Array,
    arr.on('change', function (ev) {
      var i, j, o
      switch (ev.type) {
      case 'unshift':
        forEachReverse(ev.values, function (o) {
          e.insertBefore(isNode(o) ? o : txt(o), e.childNodes[first])
          last++
        })
      break
      case 'push':
        forEach(ev.values, function (o) {
          e.insertBefore(isNode(o) ? o : txt(o), e.childNodes[last])
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
        j = ev.arguments.length
        if (j > 2) {
          for (i = 2; i < j; i++) {
            o = ev.arguments[i]
            e.insertBefore(isNode(o) ? o : txt(o), e.childNodes[last])
          }
        }
        break
      case 'sort':
        i = 0
        for (var orig = ev.orig; i < orig.length; i++) {
          o = orig[i]
          if (i !== (j = arr.indexOf(o))) {
            e.removeChild(o)
            e.insertBefore(arr[j], e.childNodes[j])
          }
        }
        break
      case 'empty':
        while (o = e.childNodes[first])
          e.removeChild(o)
        break
      case 'reverse':
        // this can potentially be optimized...
        while (o = e.childNodes[0])
          e.removeChild(o)
        for (i = 0; i < arr.length; i++)
          e.appendChild(arr[i])
        break
      default:
        console.log('unknown event', ev)
      }
    })
  }
  return frag
}

export function svgArrayFragment(e, arr, cleanupFuncs) {
  var first = e.childNodes.length
  forEach(arr, function (_v) {
    var i, v = _v
    if (typeof v === 'function') {
      i = v.observable && v.observable === 'value' ? 1 : 0
      v = i ? v.call(e) : v.call(this, e)
    }

    if (v) {
      e.appendChild(
        isNode(v) ? v
          : Array.isArray(v) ? svgArrayFragment(e, v, cleanupFuncs)
          : txt(v)
      )

      if (i === 1) {
        // assume it's an observable!
        cleanupFuncs.push(_v(function (__v) {
          // console.log(v)
          if (isNode(__v) && v.parentElement) {
            v.parentElement.replaceChild(__v, v), v = __v
          // TODO: observable-array cleanup
          } else {
            v.textContent = __v
          }
        }))
      }
    }
  })

  if (typeof arr.on === 'function') {
    var last = first + arr.length
    // if it's an EE, then it's likely an observable-array (like) Array,
    arr.on('change', function (ev) {
      var i, j, o
      switch (ev.type) {
      case 'unshift':
        forEachReverse(ev.values, function (v) {
          e.insertBefore(isNode(v) ? v : txt(v), e.childNodes[first])
          last++
        })
      break
      case 'push':
        forEach(ev.values, function (v) {
          e.insertBefore(isNode(v) ? v : txt(v), e.childNodes[last])
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
        j = ev.arguments.length
        if (j > 2) {
          for (i = 2; i < j; i++) {
            o = ev.arguments[i]
            e.insertBefore(isNode(o) ? o : txt(o), e.childNodes[last])
          }
        }
        break
      case 'sort':
        for (i = 0, orig = ev.orig; i < orig.length; i++) {
          o = orig[i]
          j = arr.indexOf(o)
          if (i !== j) {
            e.removeChild(o)
            e.insertBefore(arr[j], e.childNodes[j])
          }
        }
        break
      case 'empty':
        while (o = e.childNodes[first])
          e.removeChild(o)
        break
      case 'reverse':
        // this can potentially be optimized...
        while (o = e.childNodes[0])
          e.removeChild(o)
        for (i = 0; i < arr.length; i++)
          e.appendChild(arr[i])
        break
      default:
        debugger
      }
    })
  }
}

export function dom_context () {
  return context(function (el) {
    return doc.createElement(el)
  }, arrayFragment)
}

var h = dom_context()
h.context = dom_context

export function svg_context () {
  return context(function (el) {
    return doc.createElementNS('http://www.w3.org/2000/svg', el)
  }, svgArrayFragment)
}

var s = svg_context()
s.context = svg_context

export { s }
export default h
