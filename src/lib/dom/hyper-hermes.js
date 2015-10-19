import ClassList from './class-list.js'
// var split = function (str) {
//   return str ? String.prototype.split(str) : []
// }
import words from '../lodash/string/words'
var document = window.document

function context () {

  var cleanupFuncs = []

  function h() {
    var args = [].slice.call(arguments), e = null
    function item (l) {
      var r
      function parseClass (string) {
        // var m = split(string, /([\.#]?[a-zA-Z0-9_:-]+)/)
        var m = words(string)
        if (/^\.|#/.test(m[1]))
          e = document.createElement('div')
        forEach(m, function (v) {
          var s = v.substring(1,v.length)
          if (!v) return
          if (!e) {
            e = document.createElement(v)
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
          e.appendChild(r = document.createTextNode(l))
        }
      } else if ('number' === typeof l
        || 'boolean' === typeof l
        || l instanceof Date
        || l instanceof RegExp ) {
          e.appendChild(r = document.createTextNode(l.toString()))
      } else if (Array.isArray(l)) {
        forEach(l, item)
      } else if (isNode(l)) {
        e.appendChild(r = l)
      } else if (l instanceof window.Text) {
        e.appendChild(r = l)
      } else if ('object' === typeof l) {
        for (var k in l) {
          if ('function' === typeof l[k]) {
            if (/^on\w+/.test(k)) {
              if (e.addEventListener){
                e.addEventListener(k.substring(2), l[k], false)
                cleanupFuncs.push(function(){
                  e.removeEventListener(k.substring(2), l[k], false)
                })
              } else {
                e.attachEvent(k, l[k])
                cleanupFuncs.push(function(){
                  e.detachEvent(k, l[k])
                })
              }
            } else {
              // observable
              e[k] = l[k]()
              cleanupFuncs.push(l[k](function (v) {
                e[k] = v
              }))
            }
          } else if (k === 'data') {
            for(var s in l[k]) e.dataset[s] = l[k][s]
          } else if (k === 'for') {
            e.htmlFor = l[k]
          } else if (k === 'c' || k === 'class') {
            e.className = Array.isArray(l[k]) ? l[k].join(' ') : l[k]
          } else if (k === 'on') {
            if ('object' === typeof l[k]) {
              for (var s in l[k]) (function(event, listener) {
                if ('function' === typeof listener) {
                  // ???
                  (e.on || e.addEventListener)
                    .call(e, event, listener, false)

                  cleanupFuncs.push(function() {
                    // copied from observable
                    (e.removeListener || e.removeEventListener || e.off)
                      .call(e, event, listener, false)
                  })
                }
              })(s, l[k][s])
            // } else if ('function' === typeof l[k]) {
            //   // another event listener ...
            //   // re-emit listened events into this listener...
            //   // for(k in l[k]._listeners) { ... }
            // } else {
            //   debugger
            }
          } else if (k === 's' || k === 'style') {
            if ('string' === typeof l[k]) {
              e.style.cssText = l[k]
            } else {
              for (var s in l[k]) (function(s, v) {
                if ('function' === typeof v) {
                  // observable
                  e.style.setProperty(s, v())
                  cleanupFuncs.push(v(function (val) {
                    e.style.setProperty(s, val)
                  }))
                } else {
                  e.style.setProperty(s, l[k][s])
                }
              })(s, l[k][s])
            }
          } else if (k.substr(0, 5) === "data-") {
            e.setAttribute(k, l[k])
          } else if (typeof l[k] !== 'undefined') {
            // this is an ugly hack to be able to use holder.js
            // I'd like to perhaps move it out to a wrapper function
            // TODO: add composition hooks instead of this shit...
            if (k === 'src' && e.tagName === 'IMG' && ~l[k].indexOf('holder.js')) {
              e.dataset.src = l[k]
              console.log('you are using holder ... fix this')
              // setTimeout(function () {
              //   require('holderjs').run({images: e})
              // },0)
            } else {
              e[k] = l[k]
            }
          }
        }
      } else if ('function' === typeof l) {
        //assume it's an observable!
        var v = l.call(e)
        e.appendChild(
          r = isNode(v) ? v
            : Array.isArray(v) ? arrayFragment(e,v)
            : document.createTextNode(v)
        )

        cleanupFuncs.push(l(function (v) {
          if (isNode(v) && r.parentElement) {
            r.parentElement.replaceChild(v, r), r = v
          // TODO: observable-array cleanup
          } else {
            r.textContent = v
          }
        }))
      }

      return r
    }
    while(args.length) {
      item(args.shift())
    }

    return e
  }

  h.cleanup = function () {
    for (var i = 0; i < cleanupFuncs.length; i++){
      cleanupFuncs[i]()
    }
  }

  return h
}

var h = module.exports = context()
h.context = context

export default h

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
  var frag = document.createDocumentFragment()
  var first = e.childNodes.length
  forEach(arr, function(v) {
    frag.appendChild(isNode(v) ? v : document.createTextNode(v))
  })

  var last = first + arr.length
  if (typeof arr.on === 'function') {
    // if it's an EE, then it's likely an observable-array (like) Array,
    arr.on('change', function (ev) {
      switch (ev.type) {
      case 'unshift':
        forEachReverse(ev.values, function(v) {
          e.insertBefore(isNode(v) ? v : document.createTextNode(v), e.childNodes[first])
          last++
        })
      break
      case 'push':
        forEach(ev.values, function(v) {
          e.insertBefore(isNode(v) ? v : document.createTextNode(v), e.childNodes[last])
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
      case 'sort':    // TODO
      case 'reverse': // TODO
      case 'splice':  // TODO
      default:
        debugger
      }
    })
  }
  return frag
}
