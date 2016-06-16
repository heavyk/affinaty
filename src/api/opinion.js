
import local from '../local'
import assign from '../lib/lodash/assign'
import isEqual from '../lib/lodash/isEqual'
import Ambition from '../lib/insightful/consciousness/ambition'
import { insert_d } from '../lib/ordered-array'
import { created_asc } from '../lib/order-by'

class opinion_ extends Ambition {
  constructor (creator) {
    super()
    this.situations = {
      '/': {
        '>' () {
          this.skip = this['+created']
        }
      }
    }

    this.exists = {}
    this.creator = creator
    this.list = []
    this.skip = 0
    this.sort = true
    this.keys = [
      'opinion:'+creator,
      'opinion:'+creator+':+created',
      'opinion:'+creator+':-created',
    ]
    this.query = assign({}, {
      sort: '+created',
      limit: 100,
      creator: creator,
    })

    local.getItems(this.keys, (err, data) => {
      if (data && data[this.keys[0]]) {
        // PUT ME BACK KENNY
        // for (var i = 0; i < data[this.keys[0]].length; i++)
        //   this.insert(data[this.keys[0]][i])

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
      insert_d(d, this.list, this.exists, created_asc)
      if (!silent) {
        this.emit(d.debate + '.' + d.creator, d)
        this.emit(d.creator + '.' + d.debate, d)
      }
    } else {
      let _d = this.list[loc]
      if (!isEqual(_d, d)) {
        let __d = assign({}, _d)
        assign(_d, d)
        if (!silent) {
          this.emit(d.debate + '.' + d.creator, d, __d)
          this.emit(d.creator + '.' + d.debate, d, __d)
          this.emit(d._id, d, __d)
        }
      }
    }
  }

  get fetched () {
    return this.skip > 1321052100000
  }

  go (next) {
    let query = this.query
    let creator = this.creater
    let list = this.list
    // TODO change the queries to go based on time
    api.action('opinion*', assign({skip: this.skip}, query), (data) => {
      let silent = this.skip < 1321052100000
      for (var i = 0; i < data.length; i++)
        this.insert(data[i], silent)

      // eg. get all >= created
      this.skip += data.length
      if (next) next()
      if (data.length === this.query.limit) setTimeout(() => { this.go() }, 100)
      else this.now('/')

      let items = {}
      items['opinion*:'+this.creator] = list
      local.setItems(items).then(() => {
        console.log('saved opinions into local')
      }).catch((err) => {
        console.error('setItems error', err)
      })
    })
  }

  debate_pos (debate) {
    for (var i = 0; i < this.list.length; i++) {
      if (this.list[i].debate === debate) return +this.list[i].pos
    }
    return 0
  }

  create (target, pos) {
    return api.action('opinion!', assign({pos: pos}, target), (data) => {
      this.insert(data.opinion)
      api.my.affinaties.update(data.affinaties)
    })
  }

  debate (debate) {
    for (var i = 0; i < this.list.length; i++) {
      if (this.list[i].debate === debate) return this.list[i]
    }
  }
}

export default opinion_
