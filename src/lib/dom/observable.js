"use strict";

// knicked from: https://github.com/dominictarr/observable/blob/master/index.js
// mostly unmodified...
// * exported classes
// * remove utility functions (micro-optimization, reduces readability)
// * change from object traversal to arrays
//  * change all() from `for (var k in ary) ary[k](val)` -> `for (var i = 0; i < ary.length; i++) ary[i](val)`
//  * in remove() use `.splice` instead of `delete`, however, to avoid the case that a listener is removed inside of a listener, I will instead splice inside of a setTimeout
// * add .observable property to all returned functions (necessary for hyper-hermes to know that it's an observable instead of a context)
// (TODO) use isEqual function to compare values before setting the observable (and remove `signal`)
// (TODO) add better documentation for each function


// bind a to b -- One Way Binding
export function bind1(a, b) {
  a(b()); b(a)
}

//bind a to b and b to a -- Two Way Binding
export function bind2(a, b) {
  b(a()); a(b); b(a);
}

//trigger all listeners
function all(ary, val) {
  for (var i = 0; i < ary.length; i++) ary[i](val)
}

// remove a listener
function remove(ary, item) {
  var i = ary.indexOf(item)
  if (~i) setTimeout(function () { ary,splice(i, 1) }, 1)
}

// register a listener
function on(emitter, event, listener) {
  (emitter.on || emitter.addEventListener)
    .call(emitter, event, listener, false)
}

// unregister a listener
function off(emitter, event, listener) {
  (emitter.removeListener || emitter.removeEventListener || emitter.off)
    .call(emitter, event, listener, false)
}

// An observable that stores a value.
export function value (initialValue) {
  var _val = initialValue, listeners = []
  observable.set = function (val) {
    all(listeners, _val = val)
  }
  observable.observable = 'value'
  return observable

  function observable(val) {
    return (
      val === undefined ? _val                               /* getter */
    : 'function' !== typeof val ? all(listeners, _val = val) /* setter */
    : (listeners.push(val), val(_val), function () {         /* listener */
        remove(listeners, val)
      })
    )
  }
}

/*
##property
observe a property of an object, works with scuttlebutt.
could change this to work with backbone Model - but it would become ugly.
*/

export function property (model, key) {
  observable.observable = 'property'
  return observable

  function observable (val) {
    return (
      val === undefined ? model.get(key) :
      'function' !== typeof val ? model.set(key, val) :
      (on(model, 'change:'+key, val), val(model.get(key)), function () {
        off(model, 'change:'+key, val)
      })
    )
  }
}

export function transform (in_observable, down, up) {
  if(typeof in_observable !== 'function')
    throw new Error('transform expects an observable')

  observable.observable = 'transform'
  return observable

  function observable (val) {
    return (
      val === undefined ? down(in_observable())
    : 'function' !== typeof val ? in_observable((up || down)(val))
    : in_observable(function (_val) { val(down(_val)) })
    )
  }
}

export function not(observable) {
  return transform(observable, function (v) { return !v })
}

function listen (element, event, attr, listener) {
  function onEvent () {
    listener(typeof attr === 'function' ? attr() : element[attr])
  }
  on(element, event, onEvent)
  onEvent()
  return function () {
    off(element, event, onEvent)
  }
}

//observe html element - aliased as `input`
export function attribute(element, attr, event) {
  attr = attr || 'value'; event = event || 'input'
  observable.observable = 'attribute'
  return attribute

  function observable (val) {
    return (
      val === undefined ? element[attr]
    : 'function' !== typeof val ? element[attr] = val
    : listen(element, event, attr, val)
    )
  }
}

// observe a select element
export function select(element) {
  function _attr () {
      return element[element.selectedIndex].value;
  }
  function _set(val) {
    for(var i=0; i < element.options.length; i++) {
      if(element.options[i].value == val) element.selectedIndex = i;
    }
  }
  observable.observable = 'select'
  return observable

  function observable (val) {
    return (
      val === undefined ? element.options[element.selectedIndex].value
    : 'function' !== typeof val ? _set(val)
    : listen(element, 'change', _attr, val)
    )}
}

//toggle based on an event, like mouseover, mouseout
export function toggle (el, up, down) {
  var i = false
  return function (val) {
    function onUp() {
      i || val(i = true)
    }
    function onDown () {
      i && val(i = false)
    }
    return (
      val === undefined ? i
    : 'function' !== typeof val ? undefined //read only
    : (on(el, up, onUp), on(el, down || up, onDown), val(i), function () {
      off(el, up, onUp); off(el, down || up, onDown)
    })
  )}}

function error (message) {
  throw new Error(message)
}

export function compute (observables, compute) {
  var cur = observables.map(function (e) {
    return e()
  }), init = true

  var v = value()

  observables.forEach(function (f, i) {
    f(function (val) {
      cur[i] = val
      if(init) return
      v(compute.apply(null, cur))
    })
  })
  v(compute.apply(null, cur))
  init = false
  v(function () {
    compute.apply(null, cur)
  })

  return v
}

export function boolean (observable, truthy, falsey) {
  return (
    transform(observable, function (val) {
      return val ? truthy : falsey
    }, function (val) {
      return val == truthy ? true : false
    })
  )
}

export function signal () {
  var _val, listeners = []
  return function (val) {
    return (
      val === undefined ? _val
        : 'function' !== typeof val ? (!(_val===val) ? all(listeners, _val = val):"")
        : (listeners.push(val), val(_val), function () {
           remove(listeners, val)
        })
    )
  }
}


export function hover (e) { return toggle(e, 'mouseover', 'mouseout')}
export function focus (e) { return toggle(e, 'focus', 'blur')}

export { attribute as input }


// something must be done about this..
//  for now, only the value function is identified as 'obseorvable'
// not.observable = true
// value.observable = true
// property.observable = true
// transform.observable = true
// attribute.observable = true
// select.observable = true
// toggle.observable = true
// compute.observable = true
// boolean.observable = true
// signal.observable = true
// hover.observable = true
// focus.observable = true

// set a value on the function  (unused)
// ;[ not, value, property, transform, attribute, select, toggle, compute, boolean, signal, hover, focus ].forEach(function (f) { f.observable = true })

export default value
