
import local from '../local'
import assign from '../lib/lodash/assign'
import isEqual from '../lib/lodash/isEqual'
import Ambition from '../lib/insightful/consciousness/ambition'


class Stats extends Ambition {
  constructor (type, id) {
    super()
    this.situations = {
      update: {
        '>' () {
          api.action(this.type+'-stats', assign({}, this.query), (data) => {
            // eg. get all >= created
            this.now('/', data)
            let items = {}
            items[this.key] = data
            local.setItems(items).then(() => {
              console.log('saved stats into local')
            }).catch((err) => {
              console.error('setItems error', err)
            })
          })
        }
      },
      '/': {
        '>' (data) {
          this.data = data
        }
      }
    }
    this.ages = [18, 25, 35, 45]
    this.id = id
    this.type = type
    this.key = type+'-stats:'+id
    this.query = {
      ages: this.ages,
      _id: id,
    }

    local.getItem(this.key, (err, data) => {
      // later, need to check the last stats time to see if a refresh is needed
      if (data) {
        // this.now('/', data)
        this.now('update')
      } else {
        // this.go()
        this.now('update')
      }

    })
  }

  go (next) {
    let list = this.list
    // TODO change the queries to go based on time
    api.action(this.type+'-stats', assign({}, this.query), (data) => {
      // let silent = this.skip < 1321052100000

      if (next) next()
      if (data.length === this.query.limit) setTimeout(() => { this.go() }, 100)
      else this.now('/', data)

      let items = {}
      items['stats*:'+this.creator] = list
      local.setItems(items).then(() => {
        console.log('saved statss into local')
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
    return api.action('stats!', assign({pos: pos}, target), (data) => {
      this.insert(data)
    })
  }

  debate (debate) {
    // TODO - I think this can use this.list[this.exists[debate]]
    for (var i = 0; i < this.list.length; i++) {
      if (this.list[i].debate === debate) return +this.list[i].pos
    }
    return 0
  }
}

export default Stats
