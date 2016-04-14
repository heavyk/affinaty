
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

class affinaties extends Ambition {
  constructor (creator) {
    super()
    this.creator = creator
    this.initialSituation = 'loading'
    this.situations = {
      'loading': {
        '>' () {
          this.exists = {}
          this.list = []
          this.go()
        }
      },
      '/': {
        '>' () {

        }
      }
    }

    // setTimeout because api may not be resolved just yet
    // (after all, we are constructing this inside of the api)
    // setTimeout(() => {
    //   api.on('me', (me, _me) => {
    //     if (me && this._id !== me._id) {
    //       this._id = me._id
    //       this.now('loading')
    //     }
    //   })
    // }, 1)
    this.now('loading')
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

  insert (d, silent) {
    let loc = this.exists[d._id]
    if (loc === void 0) {
      this.exists[d._id] = insert(d, this.list, (a, b) => b.affinaty > a.affinaty ? 1 : b.affinaty < a.affinaty ? -1 : 0)
      if (!silent) {
        this.emit(d._id, d)
      }
    } else {
      let _d = this.list[loc]
      if (!isEqual(_d, d)) {
        let __d = assign({}, _d)
        assign(_d, d)
        if (!silent) {
          this.emit(d._id, d, __d)
        }
      }
    }
  }

  go (next) {
    let list = this.list
    api.action('affinaties', {}, (data) => {
      let silent = this.situation !== '/'
      each(data.affinaties, (v, id) => {
        let d = data[id]
        if (d && d._id !== api.yo) {
          this.insert(assign({affinaty: v}, d), silent)
        }
      })

      this.now('/')
    })
  }

  affinaty (_id) {
    let exists = this.exists[id]
    return exists ? this.list[exists].affinaty : 0
  }
}

export default affinaties
