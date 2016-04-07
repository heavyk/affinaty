
import local from '../local'

import assign from '../lib/lodash/object/assign'
import isEqual from '../lib/lodash/lang/isEqual'
import Ambition from '../lib/insightful/consciousness/ambition'
import { insert_d } from '../lib/ordered-array'
import { title_dsc } from '../lib/order-by'

class category_ extends Ambition {
  constructor () {
    super()
    this.situations = {
      '/': {
        '>' () {
          this.skip = this['+created']
        }
      }
    }
  }

  pregage () {
    this['+created'] = this['-created'] = 0
    this.list = []
    this.exists = {}
    this.skip = 0
    this.sort = true
    this.fetched = false
    this.query = {
      order: '+created',
      limit: 100,
    }

    local.getItems(['category', 'category:+created', 'category:-created'], (err, data) => {
      if (data && data.category) {
        for (var i = 0; i < data.category.length; i++)
          this.insert(data.category[i])
        this.skip = this['+created']
        this.now('/')
      }

      this.go()
    })
  }

  insert (d, silent) {
    let loc = this.exists[d._id]
    if (!this['+created'] || this['+created'] > d.created) this['+created'] = d.created
    if (!this['-created'] || this['-created'] < d.created) this['-created'] = d.created
    if (loc === void 0) {
      insert_d(d, this.list, this.exists, title_dsc)
      if (!silent) {
        this.emit(d._id, d)
      }
    } else {
      let _d = this.list[loc]
      if (!isEqual(_d, d)) {
        // make a copy
        let __d = assign({}, _d)
        assign(_d, d)
        if (!silent) {
          this.emit(d._id, d, __d)
        }
      }
    }
  }

  get (id) {
    let exists = this.exists[id]
    return exists !== void 0 ? this.list[exists] : null
  }

  go (next) {
    let query = this.query
    if (typeof api !== 'object') return setTimeout(() => { this.go(next) }, 10)
    // TODO change the queries to go based on time
    api.action('category*', assign({skip: this.skip}, query), (data) => {
      // if skip is really big, then we've already fetched
      let silent = this.skip < 1321052100000
      let gt_created = 0
      let lt_created = 0
      for (var i = 0; i < data.length; i++)
        this.insert(data[i], silent)

      // this.skip += data.length
      if (next) next()
      if (data.length === this.query.limit) setTimeout(() => this.go(), 100)
      else this.now('/')

      api.local.setItems({
        'category': this.list,
        'category:+created': this['+created'],
        'category:-created': this['-created'],
      }, (err) => {
        if (err) return
        else console.log('saved categories into local')
      })
    })
  }

}

export default category_
