
import api from '../api'
import local from '../local'

import assign from '../lib/lodash/object/assign'
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
  if (end - start <= 1) return c == -1 ? pivot - 1 : pivot

  switch (c) {
    case -1: return locationOf(element, array, comparer, start, pivot)
    case 0: return pivot
    case 1: return locationOf(element, array, comparer, pivot, end)
  }
}

// let category_ = Ractive.extend({
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
    this.dd = new Map
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
      this.exists[d._id] = insert(d, this.list, (a, b) => {
        return a.title > b.title ? 1 : a.title < b.title ? -1 : 0
      })
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

      local.setItems({
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
