
// bump this number if you need to purge localStorage
let VERSION = '1'

import Ambition from './lib/insightful/consciousness/ambition'

// TODO move this out of here and make an abstration of api (so it's not so specific)
// generic containers
import category_ from './api/category'
import tag_ from './api/tag'
// my stuff
import opinion from './api/opinion'
import selection from './api/selection'
import affinaties from './api/affinaties'
import notifier from './api/notifier'
// import relation_ from './api/relation'

import CronTab from 'crontabjs'


function hashCode(str) {
  var hash = 0;
  if (str.length == 0) return hash
  for (var i = 0; i < str.length; i++) {
    let char = str.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash // Convert to 32bit integer
  }
  return hash
}

class Api extends Ambition {
  constructor () {
    super()
    this.situations = {
      '/': {
        '>' () {
          // this.skip = this['+created']
        }
      }
    }

    this.category = new category_
    this.tag = new tag_
  }

  pregage () {
    // this.yo = null
    this.my = {}
    this.url = (function() {
      try {
        // forced host override
        switch (window.localStorage.host) {
          case 'term': return 'http://5.9.94.75:1158' // action-terminal
          case 'local': return `http://${window.location.hostname}:1155` // local
          case 'mothership': return 'http://5.9.94.75:1155' // normal
          case 'web': return 'http://affinaty.com' // website
        }

        // rest of the world
        let host = window.location.host
        return ( host === '127.0.0.1'
          || host.substr(-10) === 'c9users.io'
          || host.indexOf('localhost') === 0
          // || host.indexOf('192.168') === 0
        ) ? 'http://5.9.94.75:1155'
          // : window.location.origin
          : `http://${window.location.hostname}:1155`
      } catch(e) {}
    }())

    this.fb_app = window.localStorage.host === 'local' ?
      '1503936663269011' : // local
      '953713761340812' // affinaty.com


    this.delay = 0 // set this higher to simulate network delay
    this._token = hashCode(this.url + ':token')
    this.token = window.localStorage.getItem(this._token)
    this.rolex = new CronTab(20000)
    let store = 'affinaty_'+hashCode(this.url)

    let version = window.localStorage.affinaty_version
    if (version !== VERSION) local.clear(() => {
      console.warn(`upgraded from version ${version} -> ${VERSION}`)
      window.localStorage.affinaty_version = VERSION
    })

    local.getItem('me', (err, val) => {
      if (err || !this.token) this.signOut()
      else this.initialize(val)
    })

    this.client = new ActionheroClient({ url: this.url })
    this.client.on('connected', () => { console.log('connected'); this.connected = Date.now() })
    this.client.on('disconnected', () => { console.log('disconnected'); this.connected = 0 })

    // reconnecting logic?
    this.client.connect(() => {
      if (this.token) this.client.action('who-am-i', {token: this.token}, (res) => {
        if (res.data) {
          this.whoIaM(res.data)
        } else {
          this.signOut()
        }
      })
    })
  }

  initialize (me) {
    let _me = this.me
    this.me = me
    if (me) {
      this.yo = me._id
      this.authenticated = true
      // my.* initialization
      if (!api.my.opinion || api.my.opinion.creator !== me._id)
        api.my.opinion = new opinion(me._id)
      if (!api.my.selection || api.my.selection.creator !== me._id)
        api.my.selection = new selection(me._id)
      // if (!api.my.relation || api.my.relation.creator !== me._id)
      //   api.my.relation = new relation_(me._id)
      // if (!api.my.debate || api.my.debate.creator !== me._id)
      //   api.my.debate = new debate_(me._id)
      if (!api.my.affinaties || api.my.affinaties.creator !== me._id)
        api.my.affinaties = new affinaties(me._id)
      if (!api.my.notifier || api.my.notifier.creator !== me._id)
        api.my.notifier = new notifier(me._id)

      // other initialization
      // if (!api.category)
      //   api.category = new category_
      // if (!api.tag)
      //   api.tag = new tag_

      this.emit('me', me, _me)
      this.emit('auth', me)
    }
  }

  signIn (data) {
    this.mundial = data.mundial
    this.token = data.token
    window.localStorage.setItem(this._token, data.token)
    return this.whoIaM(data.mundial[0])
  }

  whoIaM(me) {
    return local.setItem('me', me, (err) => {
      if (!err) this.initialize(me)
    })
  }

  signOut (redirect) {
    let yo = api.yo
    window.localStorage.removeItem(this._token)
    local.removeItem('me')
    if (redirect) router.dispatch('/')
    this.authenticated = false
    this.yo = null
    this.me = null
    this.emit('deauth', yo)
  }

  action (action, params, resolve, reject) {
    // if (action === 'debate*' && !arguments[4]) {
    //   return setTimeout(() => { this.action(action, params, resolve, reject, true) }, 500)
    // }
    const start = Date.now()
    let _params = {}
    for (var k in params) {
      if (params.hasOwnProperty(k) && params[k] != null) {
        _params[k] = params[k]
      }
    }
    console.log('action:', action, _params)
    if (this.token && !params.token)
      // TODO - instead of redirecting to the login page, we should just show a login modal
    //   this.signOut(true)
    // else
      _params.token = this.token

    return new Ractive.Promise((_resolve, _reject) => {
      let respond = (res) => {
        const now = Date.now()
        // api.log.unshift({
        //   action: action,
        //   params: _params,
        //   response: res,
        //   duration: now - start,
        //   time: now
        // })
        setTimeout(() => {
          console.log('response:', action, _params, res)
          if (res.error) {
            console.error(action, res.error)
            // TODO: log errors and send them to the server
            if (reject) reject(res.error)
            else _reject(res.error)
          } else {
            _resolve(res.data)
            if (resolve) resolve(res.data)
          }
        }, this.delay)
      }

      if (this.client.state !== 'connected') {
        this.client.once('connected', () =>  {
          setTimeout(() => {
            if (this.delay) setTimeout(() => {
              this.client.action(action, _params, respond)
            }, this.delay)
            else this.client.action(action, _params, respond)
          }, 1)
        })
      } else {
        if (this.delay) setTimeout(() => {
          this.client.action(action, _params, respond)
        }, this.delay)
        else this.client.action(action, _params, respond)
      }
    })
  }

}


// let Api = Ractive.extend({
//   data: {
//     authenticated: false,
//     connected: false,
//   },
//     ,
//   my: {},
//   onconfig () {
//
//   },
//   ,
//   initialize (me, _me) {
//     if (me) {
//       // my.* initialization
//       if (!api.my.opinion || api.my.opinion.creator !== me._id)
//         api.my.opinion = new opinion(me._id)
//       // if (!api.my.relation || api.my.relation.creator !== me._id)
//       //   api.my.relation = new relation_(me._id)
//       // if (!api.my.debate || api.my.debate.creator !== me._id)
//       //   api.my.debate = new debate_(me._id)
//       if (!api.my.affinaties || api.my.affinaties.creator !== me._id)
//         api.my.affinaties = new affinaties(me._id)
//       if (!api.my.notifier || api.my.notifier.creator !== me._id)
//         api.my.notifier = new notifier(me._id)
//
//       // other initialization
//       // if (!api.category)
//       //   api.category = new category_
//       // if (!api.tag)
//       //   api.tag = new tag_
//     }
//   },
//
// })

export default Api
