
import local from '../local'
import assign from '../lib/lodash/assign'
import each from '../lib/lodash/forEach'
import isEqual from '../lib/lodash/isEqual'
import Ambition from '../lib/insightful/consciousness/ambition'
import { insert_d } from '../lib/ordered-array'
import { affinaty_asc } from '../lib/order-by'

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
    this.list.sort(affinaty_asc)
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
      insert_d(d, this.list, this.exists, affinaty_asc)
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

  get (id) {
    let pos = this.exists[id]
    return pos === void 0 ? null : this.list[pos]
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
