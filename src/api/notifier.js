
import api from '../api'
import local from '../local'
import assign from '../lib/lodash/object/assign'
import each from '../lib/lodash/collection/each'
import isEqual from '../lib/lodash/lang/isEqual'
import Ambition from '../lib/insightful/consciousness/ambition'

function insert(element, array, comparer) {
  let location = locationOf(element, array, comparer) + 1
  array.splice(location, 0, element)
  return location
}

function locationOf(element, array, comparer, start, end) {
  if (array.length === 0) return -1

  start = start || 0
  end = end || array.length
  var pivot = (start + end) >> 1

  var c = comparer(element, array[pivot])
  if (end - start <= 1) return c === -1 ? pivot - 1 : pivot

  switch (c) {
    case -1: return locationOf(element, array, comparer, start, pivot)
    case 0: return pivot
    case 1: return locationOf(element, array, comparer, pivot, end)
  }
}

class notifier extends Ambition {
  constructor (creator) {
    super()
    this.situations = {
      'loading': {
        '>' () {
          // default
          this.list = []
          this.exists = {}

          // msg
          this.msg = []
          this.msg_exists = {}

          // post
          this.post = []
          this.post_exists = {}

          // vote
          this.vote = []
          this.vote_exists = {}

          this.box = {}
          this.go()
        }
      },
      '/': {
        '>' () {}
      }
    }

    // setTimeout because api may not be resolved just yet
    // (after all, we are constructing this inside of the api)
    setTimeout(() => {
      api.observe('me', (me, _me) => {
        if (me && this._id !== me._id) {
          this._id = me._id
          this.now('loading')
        }
      })
    }, 1)
  }

  update (updates) {
    each(updates, (v, id) => {
      let exists = this.exists[id]
      if (exists) {
        this.list[exists].affinaty += v
      }
    })
    this.list.sort((a, b) => b.affinaty > a.affinaty ? 1 : b.affinaty < a.affinaty ? -1 : 0)
    // reset our exists list
    for (let i = 0; i < this.list.length; i++) {
      let d = this.list[i]
      this.exists[d._id] = i
    }
    let updated = []
    each(updates, (v, id) => {
      let exists = this.exists[id]
      if (exists)
        updated.push(exists)
    })
    this.emit('updated', updated)
  }

  resolve (d) {
    let list, exists, ns
    switch (d.t) {
      // msg
      case 'm':
        ns = 'msg'
        list = this.msg
        exists = this.msg_exists
        break

      // post
      case 'P':
      case 'D':
        ns = 'post'
        list = this.post
        exists = this.post_exists
        break

      // vote
      // case 'u':
      // case 'j':
      case 'O':
      case 'S':
        ns = 'vote'
        list = this.vote
        exists = this.vote_exists
        break

      default:
        ns = 'list'
        list = this.list
        exists = this.exists
    }

    return {list, exists, ns}
  }

  insert (d, silent) {
    let r = this.resolve(d)
    let exists = r.exists
    let list = r.list
    let ns = r.ns

    let loc = exists[d._id]
    if (loc === void 0) {
      exists[d._id] = insert(d, list, (a, b) => b.T > a.T ? 1 : b.T < a.T ? -1 : 0)
      if (!silent) {
        this.emit(d._id, d)
      }
    } else {
      let _d = list[loc]
      if (!isEqual(_d, d)) {
        let __d = assign({}, _d)
        assign(_d, d)
        if (!silent) {
          this.emit(d._id, d, __d)
        }
      }
    }

    let b = this.box[d._b]
    if (b) {
      b.push(d._id)
    } else {
      this.box[d._b] = [d._id]
    }

    if (!silent) {
      this.emit(`${ns}*`, this[ns].length)
    }
  }

  go (next) {
    api.action('n*', {gt: 0, lt: 0}, (data) => {
      let silent = this.situation !== '/'
      each(data, (d, id) => {
        d._id = d.t + d._a + ':' + d._b + ':' + d._c
        if (d.b) this.insert(d, silent)
        else {
          // debugger
          this._remove(d)
        }
      })

      this.now('/')
      this.emit('msg*', this.msg.length)
      this.emit('post*', this.post.length)
      this.emit('vote*', this.vote.length)
      this.emit('list*', this.list.length)
    })
  }

  _remove (d) {
    let r = this.resolve(d)
    let exists = r.exists
    let list = r.list
    let ns = r.ns

    let idx = exists[d._id]
    if (idx !== void 0) {
      list.splice(idx, 1)
      delete exists[d._id]
      let b = this.box[d._b]
      if (b) ~(idx = b.indexOf(d._id)) && b.splice(idx, 1)
      for (var i = 0; i < list.length; i++) {
        exists[list[i]._id] = i
      }
      this.emit(`${ns}*`, list.length)
    }

    // remove it anyway
    api.action('n-', {t: d.t, k: d._id}, () => {
      // good
		}, () => {
      // some sort of error
      // this.insert(d)
    })
  }

  remove_box (id) {
    let b = this.box[id]
    if (b) {
      for (var i = 0; i < b.length; i++) {
        let bb = b[i].split(':')
        let d = {
          _id: b[i],
          t: bb[0][0],
          _a: bb[0].substr(1),
          _b: bb[1],
          _c: bb[2]
        }
        this._remove(d)
      }
      delete this.box[id]
    }
  }

  get_box (id) {
    let b = this.box[id]
    return b ? b.length : 0
  }
}

export default notifier
