'use strict'

let Ractive = require('ractive')

Ractive.nexus = {
  dd: new Map,
  debate: new Ractive({
    dd: new Map,
    text: new Map,
    opinions: new Map,
    insert (d) {
      this.dd.set(d._id, d)
    },
    create (d) {
      d._creator = d.creator._id
      d._category = d.category._id
      d._tag = d.tag.map((t) => t._id)
      if (!d.totals) {
        if (d.options) {
          // is poll
          d.totals = new Array(d.options.length)
          for (var i = 0; i < d.options.length; i++) {
            d.totals[i] = 0
          }
        } else {
          // is debate
          // you automatically agree with what you wrote
          d.totals = [0,0,0,1]
        }
      }
      if (d.creator !== 'object') d.creator = api.me
      if (d.category !== 'object') d.category = api.category.get(d.category)
      if (d.opinion) {
        api.my.opinion.insert(d.opinion.opinion)
        delete d.opinion
      }
      // this should read:
      // if (d._tag && d.tag === void 9)
      if (d.tag && d.tag.length) {
        for (var i = 0; i < d.tag.length; i++) {
          d.tag[i] = api.tag.get(d.tag[i])
        }
      }

      // Ractive.opinon.create
      this.fire('+', d)
    },
  }),
  poll: new Ractive({
    dd: new Map,
    text: new Map,
    insert (d) {
      this.dd.set(d._id, d)
      search.transform(d.text.toUpperCase()).concat(search.words(d.text.toUpperCase()))
        // TODO - move to debate
        .concat(d.options.map((opt) => {
          return search.transform(opt.text.toUpperCase()).concat(search.words(opt.text.toUpperCase()))
        }))
        .forEach((word) => {
          let m = this.text.get(word) || new Map()
          m.set(d._id, d)
          this.text.set(word, m)
        })
    },
    create (d) {
      // d.totals = [0, 0, 0, 1]
      if (!d.creator) d.creator = api.me
      // TODO - this.insert (once db confirms it)
      this.fire('+', d)
    },
  }),
}

// globals
window.Ractive = Ractive
import router from './router'
window.router = router
import api from './api'
window.api = api
import local from './local'
window.local = local

// error handler
// TODO: only enable this if in release mode, that way we can log the error
// window.onerror = function (err) {
//   console.error(err)
//   debugger
// }

// router init
router
  .watchLinks()
  .watchState()

import footer from './partials/footer'
Ractive.footer = new footer({ el: 'footer' })
import header from './partials/header'
Ractive.header = new header({ el: 'header' })
