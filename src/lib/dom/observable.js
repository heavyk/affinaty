"use strict";

// knicked from: https://github.com/dominictarr/observable/blob/master/index.js
// mostly unmodified...
// * exported classes


// bind a to b -- One Way Binding
export function bind1(a, b) {
  a(b()); b(a)
}
//bind a to b and b to a -- Two Way Binding
export function bind2(a, b) {
  b(a()); a(b); b(a);
}

//---util-funtions------

//check if this call is a get.
function isGet(val) {
  return undefined === val
}

//check if this call is a set, else, it's a listen
function isSet(val) {
  return 'function' !== typeof val
}

function assertObservable (observable) {
  if(typeof observable !== 'function')
    throw new Error('transform expects an observable')
  return observable
}

//trigger all listeners
function all(ary, val) {
  for(var k in ary)
    ary[k](val)
}

//remove a listener
function remove(ary, item) {
  delete ary[ary.indexOf(item)]
}

//register a listener
function on(emitter, event, listener) {
  (emitter.on || emitter.addEventListener)
    .call(emitter, event, listener, false)
}

function off(emitter, event, listener) {
  (emitter.removeListener || emitter.removeEventListener || emitter.off)
    .call(emitter, event, listener, false)
}

//An observable that stores a value.

export function value (initialValue) {
  var _val = initialValue, listeners = []
  observable.set = function (val) {
    all(listeners, _val = val)
  }
  observable.observable = true
  return observable

  function observable(val) {
    return (
      isGet(val) ? _val
    : isSet(val) ? all(listeners, _val = val)
    : (listeners.push(val), val(_val), function () {
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
  return function (val) {
    return (
      isGet(val) ? model.get(key) :
      isSet(val) ? model.set(key, val) :
      (on(model, 'change:'+key, val), val(model.get(key)), function () {
        off(model, 'change:'+key, val)
      })
    )}}

/*
note the use of the elvis operator `?:` in chained else-if formation,
and also the comma operator `,` which evaluates each part and then
returns the last value.
only 8 lines! that isn't much for what this baby can do!
*/

export function transform (observable, down, up) {
  assertObservable(observable)
  return function (val) {
    return (
      isGet(val) ? down(observable())
    : isSet(val) ? observable((up || down)(val))
    : observable(function (_val) { val(down(_val)) })
    )}}

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
  return function (val) {
    return (
      isGet(val) ? element[attr]
    : isSet(val) ? element[attr] = val
    : listen(element, event, attr, val)
    )}
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
  return function (val) {
    return (
      isGet(val) ? element.options[element.selectedIndex].value
    : isSet(val) ? _set(val)
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
      isGet(val) ? i
    : isSet(val) ? undefined //read only
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
      isGet(val) ? _val
        : isSet(val) ? (!(_val===val) ? all(listeners, _val = val):"")
        : (listeners.push(val), val(_val), function () {
           remove(listeners, val)
        })
    )}}


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