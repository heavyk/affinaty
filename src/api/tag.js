
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

// let tag_ = Ractive.extend({
class tag_ extends Ambition {
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

    local.getItems(['tag', 'tag:recent'], (err, data) => {
      if (data) {
        if (data.tag)
          for (var i = 0; i < data.tag.length; i++)
            this.insert(data.tag[i])

        if (data['tag:recent']) {
          this.recent = data['tag:recent']
          for (var i = 0; i < this.recent.length; i++)
            this.insert(this.recent[i])
        }
      }
      this.now('/')

      // this.go()
    })
  }

  insert (d, silent) {
    let loc = this.exists[d._id]
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

  // recent () {
  //   return
  // }
}

export default tag_
