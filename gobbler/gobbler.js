'use strict'

var Path = require('path')
var fS = require('co-fs-extra')
var genny = require('genny')
var spawn = require('co-child-process')

var gobbleProxy = require('http-proxy').createProxyServer({
  target: {
    host: 'localhost',
    port: 5678
  },
  ws: true
})
gobbleProxy.on('error', function (err) {
  console.error('proxy error', err)
})

var gobbler = require('http').createServer(function (req, res) {
  var url = req.url

  if (url !== '/'
    // this is mainly for dev purposes until koala-deployer is done
    && !(url.indexOf('/api') === 0
      || url.indexOf('/static') === 0
      || url.indexOf('/partials') === 0
      || url.indexOf('/views') === 0
      || url.substr(-3) === '.js'
      || url.substr(-4) === '.map'
      || url.substr(-4) === '.css'
      || url.substr(-4) === '.ico'
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

// psy-gobbler
var pkg_dir = Path.join(__dirname, '..')
var local_psy = Path.join(pkg_dir, 'node_modules', '.bin', 'psy')
var local_gobble = Path.join(pkg_dir, 'node_modules', '.bin', 'gobble')
var pkg_path = Path.join(pkg_dir, 'package.json')
var cfg_path = Path.join(pkg_dir, '.config.json')

function readJson (path, cb) {
  fS.readFile(path, 'utf-8', function (err, txt) {
    if (err) return cb(null, {})
    try {
      cb(null, JSON.parse(txt))
    } catch (e) {
      cb(e)
    }
  })
}

genny.run(function* (resume) {
  // first check to see if npm install needs to be run
  var pkg = yield readJson(pkg_path, resume())
  var h_deps = require('crypto').createHash('sha256').update(JSON.stringify([pkg.devDependencies, pkg.dependencies])).digest('hex')
  var cfg = yield readJson(cfg_path, resume())
  if (cfg.h_deps !== h_deps) {
    cfg.h_deps = h_deps
    console.log('deps changed. installing...')
    yield spawn('npm', ['install'], {cwd: pkg_dir})
    yield fS.outputJson(cfg_path, cfg)
  }

  try {
    yield spawn(local_psy, ['rm', 'gobbler'], {cwd: pkg_dir})
  } catch (e) {}
  try {
    var out = yield spawn(local_psy,
      ['start', '-n', 'gobbler', '--', local_gobble, '-p', '5678'], {cwd: pkg_dir})
  } catch (e) {}
  console.log('gobble started', out)
  gobbler.listen(1111, function (err) {
    if (err) {
      throw err
    } else {
      console.log('listening on port: ' + gobbler.address().port)
      console.log('  http://localhost:' + gobbler.address().port)
    }
  })
})

var onexit = function () {
  gobbler.close()
  genny.run(function* (resume) {
    var out
    try {
      out = yield spawn(local_psy, ['stop', 'gobbler'], {cwd: pkg_dir})
      out = yield spawn(local_psy, ['rm', 'gobbler'], {cwd: pkg_dir})
    } catch (e) {}
  })
}

process.on('SIGINT', onexit)
process.on('exit', onexit)
