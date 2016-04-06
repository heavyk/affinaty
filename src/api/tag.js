
import api from '../api'
import local from '../local'
import assign from '../lib/lodash/object/assign'
import isEqual from '../lib/lodash/lang/isEqual'
import Ambition from '../lib/insightful/consciousness/ambition'
import { insert } from '../lib/ordered-array'

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
