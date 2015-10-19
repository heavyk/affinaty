'use strict'

let fs = require('fs')
let Path = require('path')
let fS = require('co-fs-plus')
let genny = require('genny')

var Fs = require('co-fs-plus')
let gobbleProxy = require('http-proxy').createProxyServer({
  target: {
    host: 'localhost',
    port: 5678
  },
  ws: true
})
gobbleProxy.on('error', function (err) {
  console.error('proxy error', err)
})

let gobbler = require('http').createServer(function (req, res) {
  let url = req.url

  if (url !== '/'
    // this is mainly for dev purposes until koala-deployer is done
    && !(url.indexOf('/api') === 0
      || url.indexOf('/static') === 0
      || url.indexOf('/partials') === 0
      || url.indexOf('/views') === 0
      || url.substr(-3) === '.js'
      || url.substr(-4) === '.map'
      || url.substr(-4) === '.css'
      || url.substr(-4) === '.ttf'
      || url.substr(-4) === '.svg'
      || url.substr(-4) === '.png'
      || url.substr(-4) === '.jpg'
      || url.substr(-4) === '.eot'
      || url.substr(-5) === '.less'
      || url.substr(-5) === '.woff'
      || url.substr(-5) === '.jpeg'
      || url.substr(-5) === '.html'
      || url.substr(-6) === '.woff2'
    )
  ) {
    console.log("need redirect:", url)
    req.url = url = '/'
  }
  try {
    gobbleProxy.web(req, res)
  } catch(e) {}
})

gobbler.on('error', function (err) {
  console.log('gobbler-http err:', err)
})
gobbler.listen(1111, function (err) {
  if (err) {
    throw err
  } else {
    console.log('listening on port: ' + gobbler.address().port)
    console.log('  http://localhost:' + gobbler.address().port)
  }
})

// psy-gobbler
let local_psy = Path.resolve(__dirname + '/../node_modules/.bin/psy')
let local_dir = Path.resolve(__dirname + '/..')

let spawn = require('co-child-process')
genny.run(function* (resume) {
  yield spawn(local_psy, ['rm', 'gobbler'], {cwd: local_dir})
  let out = yield spawn(local_psy,
    ['start', '-n', 'gobbler', '--', local_dir + '/node_modules/.bin/gobble', '-p', '5678'], {cwd: local_dir})
  console.log('gobble started', out)
})

process.on('exit', () => {
  console.log('process: on exit')
  genny.run(function* (resume) {
    let out
    out = yield spawn(local_psy, ['stop', 'gobbler'], {cwd: local_dir})
    console.log('gobble stopped', out)
    out = yield spawn(local_psy, ['rm', 'gobbler'], {cwd: local_dir})
    console.log('gobbler removed', out)
  })
})
