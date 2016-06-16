import { parseQS, parseHash, parseJSON } from './utils.js'

import assign from './lodash/assign'
import isEmpty from './lodash/isEmpty'
import uniq from './lodash/uniq'
import flatten from './lodash/flatten'
import map from './lodash/map'
import pick from './lodash/pick'

export default class Route {
  constructor (pattern, Handler, data, observe, router) {
    this.pattern = pattern
    this.vars = parsePattern(pattern)
    this.map = [this.vars]
    this.regExp = [patternToRegExp(pattern)]
    this.strictRegExp = [patternToStrictRegExp(pattern)]
    this.isComponent = !!Handler.extend
    this.Handler = Handler
    this.observe = assign({ qs: [], hash: [], state: [] }, observe)
    this.allObserved = this.observe.qs.concat(this.observe.hash, this.observe.state)
    this.router = router || {}
    this.data = data || Handler.data || {}
    this.view = null
  }

  destroy () {
    if (this.view) {
      this.view.teardown()
      this.view = null
    }

    return this
  }

  addPattern (pattern) {
    this.map.push(parsePattern(pattern))
    this.regExp.push(patternToRegExp(pattern))
    this.strictRegExp.push(patternToStrictRegExp(pattern))
    this.vars = uniq(flatten(this.map))
  }

  getState () {
    let data = {}

    for (let i = 0, c = this.allObserved.length; i < c; i++) {
      data[this.allObserved[i]] = this.view.get(this.allObserved[i])
    }

    return {
      qs: pick(data, this.observe.qs),
      hash: pick(data, this.observe.hash),
      state: pick(data, this.observe.state)
    }
  }

  parse (uri, data) {
    let d = assign(data
      , this.data
      , this.parsePath(uri.path)
      , parseQS(uri.qs, this.observe.qs)
      , parseHash(uri.hash, this.observe.hash)
    )

    // console.info('parse:before', d, assign({}, d))
    for (let i = 0; i < this.vars.length; i++) {
      let k = this.vars[i]
      if (d[k] === void 9)
        d[k] = null
    }

    // console.info('parse:after', d, assign({}, d))
    return d
  }

  update (uri, data) {
    if (this.view) this.view.set(this.parse(uri, data))
    // if (this.view) data = assign(this.view.get(), data)
    // if (this.view) this.view.reset(data)
    return this
  }

  init (uri, data) {
    let _this = this
    let _data = this.parse(uri, data)

    // not a component
    if (!this.isComponent) {
      this.Handler({ el: this.router.el, data: _data, uri: this.router.uri })
    } else {
      // init new Ractive
      this.view = new this.Handler({
        el: this.router.el,
        data: _data
      })

      // observe
      if (this.allObserved.length) {
        this.view.observe(this.allObserved.join(' '), function () {
          if (!_this.updating) {
            _this.router.update()
          }
        }, { init: false })
      }

      // notify Ractive we're done here
      this.view.set('__ready', true)
    }

    return this
  }

  match (request, strict) {
    for (let i = 0; i < this.regExp.length; i++) {
      if (strict
        ? this.strictRegExp[i].test(request)
        : this.regExp[i].test(request))
        return true
    }
    return false
  }

  parsePath (path) {
    let data = {}
    for (let ii = 0; ii < this.regExp.length; ii++) {
      let parsed = path.match(this.regExp[ii])

      if (parsed) for (let i = 0; i < this.map[ii].length; i++) {
        if (!isEmpty(parsed[i + 1])) {
          data[this.map[ii][i]] = parseJSON(parsed[i + 1])
        }
      }
    }

    return data
  }
}

function parsePattern (pattern) {
  let m = pattern.match(/\/:\w+/g)
  return m ? map(m, function (name) {
    return name.substr(2)
  }) : []
}

function patternToRegExp (pattern) {
  return new RegExp(
    patternToRegExpString(pattern)
      .replace(/^\^(\\\/)?/, '^\\/?')
      .replace(/(\\\/)?\$$/, '\\/?$'),
    'i'
  )
}

function patternToRegExpString (pattern) {
  return ('^' + pattern + '$')
    .replace(/\/:\w+(\([^)]+\))?/g, '(?:\/([^/]+)$1)')
    .replace(/\(\?:\/\(\[\^\/]\+\)\(/, '(?:/(')
    .replace(/\//g, '\\/')
}

function patternToStrictRegExp (pattern) {
  return new RegExp(patternToRegExpString(pattern))
}
