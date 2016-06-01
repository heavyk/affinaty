'use strict'

// replace forEach method for performance reasons
// Array.prototype.forEach = function (fn) {
//   for (var i = 0; i < this.length; i++) {
//     // fn.call(this[i], this[i], i)
//     fn(this[i], i)
//   }
// }

// stupid hack for FF
if (!NodeList.prototype.forEach) NodeList.prototype.forEach = Array.prototype.forEach

const body = document.body
// this is to allow any subdomain (or port) of affinaty to access this frame
var domain = document.domain.split('.')
if (isNaN(domain[0] * 1) && domain[0] !== 'localhost') {
  // skip ip address domains like 192.168.x.x and localhost
  while (domain.length > 2) domain.shift()
  domain = domain.join('.')
} else {
  domain = document.domain
}

document.domain = domain
console.info('set affinaty-web domain to ' + domain)

import Api from './api'
import Ractive from 'ractive'
import local from './local'
import moment from './moment'
// import phoenix from '../../../../phoenix/phoenix/web/static/js/phoenix'
// import { Socket } from './lib/phoenix'
// import { httpGet, httpPost, httpDelete }  from './lib/fetch'

// let socket = new Socket("/ws", {params: {userToken: "123"}})
// socket.connect()


// debug will be false when code is minified because the comment will be removed
Ractive.DEBUG = /lala/.test(function(){/*lala*/})

// polyfill map
// TODO delete me when doing koa polyfills
if (typeof Map === 'undefined')
  window.Map = require('es6-map')

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
// TODO: move router into main
// import router from './router'
import Router from './lib/router.js'

// header / footer
import header from './partials/header'
import footer from './partials/footer'

// views
// import landing from './views/landing'
import listing from './views/listing'
import inbox from './views/inbox'
import profile from './views/profile'
import settings from './views/settings'
import debate from './views/debate'
import poll from './views/poll'
// import opinions from './views/opinions'
import notifications from './views/notifications'

// import blog from './views/blog'
// import rpi from './views/rpi'

// these are the views which will change the body's class to view-### otherwise view-default
let classView = {
  // landing,
  listing,
  inbox,
  profile,
  settings,
  debate,
  poll,
}

let router = new Router({ el: 'view' }, function (request) {
  // TODO better redirects - to a 404 page
  // maybe should be logging this as well
  // this.redirect(api.me ? '/home' : '/')
  console.log('??', request)
}, function (path, options) {
  console.log('::', path)
  // if (path === '/' && api.me)
  //   return router.dispatch('/home')
  // if (path !== '/' && !api.me)
  //   return router.dispatch('/')
})

// implement enter / leave
// https://github.com/rich-harris/roadtrip
// probably want to do it as a static method on the component

// landing page
// router.addRoute('/', landing)
router.addRoute('/', listing)
// listing (of posts)
router.addRoute('/home', listing)
router.addRoute('/mis-top', listing)
router.addRoute('/tag/:id', listing)
router.addRoute('/category/:category', listing)
router.addRoute('/search/:query', listing)
router.addRoute('/tag/:tag', listing)
// inbox
router.addRoute('/inbox/:panel?/:mbox?', inbox)
// profile
router.addRoute('/profile/:id?/:active?', profile)
// settings
router.addRoute('/settings/:active?', settings)
// debate
router.addRoute('/debate/:id/:active?', debate)
// poll
router.addRoute('/poll/:id/:active?', poll)
// opinions
// router.addRoute('/opinions/:id?', opinions)
// notifications
router.addRoute('/notifications/:id?', notifications)
//blog
// router.addRoute('/blog', blog)
// rpi experiment
// router.addRoute('/rpi/:id?', rpi)

router.on('route', (route) => {
  let cls = 'default'
  for (let k in classView) {
    if (route.view instanceof classView[k])
      cls = k
  }

  if (window.isMobile) cls += ' movil'

  body.className = cls
  route.view.el.className = 'view-' + cls
})

window.onload = function () {
  window.Ractive = Ractive
  window.router = router
  window.local = local
  window.isMobile = (function(a){
    return /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))
  })(navigator.userAgent||navigator.vendor||window.opera)

  let api = window.api = new Api

  // error handler
  // TODO: only enable this if in release mode, that way we can log the error
  // window.onerror = function (err) {
  //   console.error(err)
  //   debugger
  // }

  // TODO: temporary :)
  api.ages = [18, 25, 35, 45]

  Ractive.header = new header({ el: 'header' })

  // router init
  router
    .watchLinks()
    .watchState()

  if (api.token) {
    api.on('me', function (me, _me) {
      // console.log('me:', me, _me)
      if (me) {
        if (!_me) router.init()
        // else if (isEqual(me, _me))
        //   console.log('the same me')
        // else
        //   console.log('something about me changed')
      } else {
        if (_me) api.signOut(true)
      }
    })
  } else {
    api.signOut(true)
    router.init()
  }
  if (window.isMobile) {
    Ractive.footer = new footer({ el: 'footer' })
    setTimeout(function(){
  		// Hide the address bar!
      console.info('set scroll')
  		window.scrollTo(0, 1);
  	}, 0)
  }
}
