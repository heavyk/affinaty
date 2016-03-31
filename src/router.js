'use strict'

const body = document.body
import Router from './lib/router.js'

// views
import landing from './views/landing'
import listing from './views/listing'
import inbox from './views/inbox'
import profile from './views/profile'
import settings from './views/settings'
import debate from './views/debate'
import poll from './views/poll'
// import opinions from './views/opinions'
import notifications from './views/notifications'
import cpanel from './views/cpanel'
import api_docs from './views/action-docs'
// import blog from './views/blog'
// import rpi from './views/rpi'

// these are the views which will change the body's class to view-### otherwise view-default
let classView = {
  landing,
  listing,
  inbox,
  profile,
  settings,
  debate,
  poll,
  // blog,
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
// cpanel (remove me)
router.addRoute('/cpanel/:active?/:id?', cpanel)
// api-docs (remove me)
router.addRoute('/action-docs/:active?/:id?', api_docs)
//blog
// router.addRoute('/blog', blog)

// rpi experiment
// router.addRoute('/rpi/:id?', rpi)

// TODO remove me when the styles are fixed
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

export default router

// a small hack to get around circular dependencies.
// if I put this code into api.js, router will not be defined yet (in the api.signOut method)
// this is the only way I can be sure that I do not run into the issue

import api from './api'
import isEqual from './lib/lodash/lang/isEqual'

setTimeout(function () {
  if (api.token) {
    api.observe('me', function (me, _me) {
      // console.log('me:', me, _me)
      if (me) {
        if (!_me) router.init()
        // else if (isEqual(me, _me))
        //   console.log('the same me')
        // else
        //   console.log('something about me changed')
      } else {
        if (_me) api.signOut(true)
        // else
        //   console.log("I'm still no one")
      }
    })
  } else {
    // api.signOut(true)
    router.init()
  }
}, 1)

//  ==============================
// ======== T E S T I N G =========
//  ==============================

// testing out the ace editor
// I will be moving this to sector-11 anyway
// import editor from './views/editor'
// router.addRoute('/test/editor', editor)

// testing out codemirror
// import codemirror from './views/codemirror'
// router.addRoute('/test/codemirror', codemirror)

// import crop from './partials/foto-crop'
// router.addRoute('/test/foto-crop', Ractive.extend({
//   template: `
//     crop: {{url}}/i/s/{{api.me.foto}}
//     <foto-crop src="{{url}}/i/s/{{api.me.foto}}" area-type="square" image="{{lala}}" rect="{{rect}}" />
//     <img src="{{lala}}" width="100" height="100" />
//     {{JSON.stringify(rect)}}
//   `,
//   data: {
//     api: api,
//     url: api.get('url')
//   },
//   components: {
//     'foto-crop': crop
//   },
// }))

/*
import upload from './partials/foto-upload'
import debate_create from './partials/debate-create'
router.addRoute('/test/debate-create', Ractive.extend({
  template: `
    <debate-create />
  `,
  components: {
    'debate-create': debate_create
  },
}))

import poll_create from './partials/poll-create'
router.addRoute('/test/poll-create', Ractive.extend({
  template: `
    <poll-create />
  `,
  components: {
    'poll-create': poll_create
  },
}))

import pop_tag from './partials/pop-tag-carousel'
router.addRoute('/test/pop-tag', Ractive.extend({
  template: `
    <pop-tag />
  `,
  components: {
    'pop-tag': pop_tag
  },
}))

// you take the front! I'll go around back!
router.addRoute('/secret/kenny', Ractive.extend(landing, {
  data: {
    email: 'kenny@gatunes.com',
    password: 'lala',
  },
}))

router.addRoute('/secret/user', Ractive.extend(landing, {
  data: {
    email: 'user0@affinaty.com',
    password: 'test',
  },
}))
*/
