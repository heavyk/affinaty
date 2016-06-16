
import local from '../local'

import assign from '../lib/lodash/assign'
import isEqual from '../lib/lodash/isEqual'
import Ambition from '../lib/insightful/consciousness/ambition'
import { insert_d, remove_d } from '../lib/ordered-array'
import { title_dsc } from '../lib/order-by'

class category_ extends Ambition {
  constructor () {
    super()
    this.situations = {
      '/': {
        '>' () {
          this.skip = this.t_created
        }
      }
    }
  }

  pregage () {
    this.t_created = 0
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
        if (data.t_created) this.t_created = data.t_created
        for (var i = 0; i < data.category.length; i++)
          this.insert(data.category[i], true)
        this.now('/')
      }

      setTimeout(() => { this.go() }, 1)
    })
  }

  insert (d, silent) {
    let loc = this.exists[d._id]
    if (!this.t_created || this.t_created < d.created) this.t_created = d.created
    if (loc === void 0) {
      insert_d(d, this.list, this.exists, title_dsc)
      if (!silent) {
        this.emit(d._id, d)
        console.log('inserted new category', d._id, d)
      }
    } else {
      let _d = this.list[loc]
      if (!isEqual(_d, d)) {
        remove_d(d, this.list, this.exists, loc)
        insert_d(d, this.list, this.exists, title_dsc)
        // TODO: only emit if there are listeners
        if (!silent) {
          // make a copy (for the event)
          let __d = assign({}, _d)
          console.log('updated category', d._id, d, __d)
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
    let skip = this.t_created
    api.action('category*', assign({skip: skip}, query), (data) => {
      // if skip is really big, then we've already fetched
      let silent = skip < 1321052100000
      for (var i = 0; i < data.length; i++)
        this.insert(data[i], silent)

      if (next) next()
      if (data.length === this.query.limit) setTimeout(() => this.go(), 100)
      else if (this.situation !== '/') this.now('/')
      else if (data.length) this.emit('update')

      if (data.length) local.setItems({
        'category': this.list,
        'category:+created': this.t_created,
      }, (err) => {
        if (err) return console.error('could not save categories into local', err)
        else console.log('saved categories into local')
      })
    })
  }

}

export default category_
