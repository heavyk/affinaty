'use strict'
const gobble = require('gobble')
const babel = require('rollup-plugin-babel')
const path = require('path')
const fs = require('fs')
const crypto = require('crypto')

const FILES = [
	'app.js',
	'screen.css',
]

const EXTERNAL_LIBS = [
	 'ractive',
	 'ractive-transitions-fade',
	 'moment',
	 'lie',
	 'crontabjs',
	 'spin.js',
	 'gemini-scrollbar',
	 'masonry-layout',
	 'dropzone', // this needs to be replaced by generic code
	 'chart.js',
	 'es6-map',
	 'lie',
	 'url',
	 'querystring',
	 'smart-app-banner',
	//  'engine.io-client',
]

const POSTCSS_PLUGINS = [
	require('postcss-import'),
	require('precss'),
	require('postcss-color-function'),
	require('autoprefixer-core', { browsers: ['last 2 versions'] }),
].concat(gobble.env() === 'production' ? [
	require('cssnano'),
] : [])

const BABEL_PLUGINS = [
	[require('babel-plugin-external-helpers-2')],
	[require('babel-plugin-transform-es2015-literals')],
	[require('babel-plugin-transform-es2015-function-name')],
	[require('babel-plugin-transform-es2015-arrow-functions')],
	[require('babel-plugin-transform-es2015-block-scoped-functions')],
	[require('babel-plugin-transform-es2015-object-super')],
	[require('babel-plugin-transform-es2015-shorthand-properties')],
	[require('babel-plugin-transform-es2015-sticky-regex')],
	[require('babel-plugin-transform-es2015-unicode-regex')],
	[require('babel-plugin-transform-es2015-constants')],
	[require('babel-plugin-transform-es2015-parameters')],
	[require('babel-plugin-transform-es2015-block-scoping')],
	// [require('babel-plugin-transform-es2015-typeof-symbol')],
	[require('babel-plugin-transform-es2015-template-literals'), { loose: true }],
	[require('babel-plugin-transform-es2015-classes'), { loose: true }],
	[require('babel-plugin-transform-es2015-computed-properties'), { loose: true }],
	[require('babel-plugin-transform-es2015-for-of'), { loose: true }],
	[require('babel-plugin-transform-es2015-spread'), { loose: true }],
	[require('babel-plugin-transform-es2015-destructuring'), { loose: true }],
	// [require('babel-plugin-transform-regenerator'), { async: false, asyncGenerators: false }],

	// optional
	[require('babel-plugin-transform-undefined-to-void')],
	[require('babel-plugin-transform-strict-mode')],
	// [require('babel-plugin-transform-es2015-duplicate-keys')],
	// [require('babel-plugin-transform-minify-booleans')],
	// [require('babel-plugin-transform-merge-sibling-variables')],
	[require('babel-plugin-transform-member-expression-literals')],
	[require('babel-plugin-transform-property-literals')],

	// debugger
	// [require('babel-plugin-transform-remove-console')],
	// [require('babel-plugin-transform-remove-debugger')],
]

gobble.cwd(__dirname)

var src = gobble('src')
	.transform(require('./gobble-livescript'), {bare: true})
	.transform(require('./gobble-ractive.js'), {
		type: 'es6',
		postcss: POSTCSS_PLUGINS,
	})

var bundles = {
	affinaty: src.transform('rollup', {
			entry: 'affinaty-web.js',
			// entry: 'affinaty-cpanel.js',
			dest: 'app.js',
			format: 'cjs',
			external: EXTERNAL_LIBS,
			plugins: [
				babel({
					exclude: 'node_modules/**',
					plugins: BABEL_PLUGINS,
					compact: false,
				})
			]
		})
		.transform('browserify', {
			entries: [ './app' ],
			dest: 'app.js',
			standalone: 'app',
			debug: false,
			// expose: { ractive: 'ractive/ractive-legacy.js' }  // <-- use ractive-legacy instead of modern build
			// expose: { ractive: 'ractive/ractive-runtime.js' }  // <-- use ractive-runtime instead of modern build
		})
		.transformIf(gobble.env() !== 'production', function (source, options) {
			return typeof source === 'string'
				? source.replace('deferred.reject(e)', 'console.error(e.stack) ; debugger ; deferred.reject(e)')
				: source
		}),
		// .moveTo( 'js' )
		// .transformIf(gobble.env() === 'production', 'uglifyjs')
	plugins: src.transform('rollup', {
			// TODO: if 'plugins/vertele.js' doesn't exist, it'll give you like this totally wack error message about not loading null
			entry: 'plugins/vertele.js',
			dest: 'plugins/plugin-vertele.js',
			// format: 'cjs',
			format: 'umd',
			external: EXTERNAL_LIBS,
			plugins: [
				babel({
					exclude: 'node_modules/**',
					plugins: BABEL_PLUGINS,
					compact: false,
				})
			]
		})
		// .transform('uglifyjs'),
		.transformIf(gobble.env() === 'production', 'uglifyjs'),
		// .copyTo( 'plugins/vertele.min.js' ),
		// .transform('browserify', {
		// 	entries: [ './plugins/plugin-vertele' ],
		// 	dest: 'plugin-vertele.js',
		// 	standalone: 'app',
		// 	debug: false
		// })
		// .transform('uglifyjs'),
		// .moveTo( 'plugins' )
	styles: gobble('files/styles')
		.transform('less', {
	    src: 'screen.less',
	    dest: 'screen.css',
	  })
		.transform('postcss', {
			plugins: POSTCSS_PLUGINS,
			src: 'screen.css',
		}),
		// .moveTo( 'css' )
	files: gobble('files'),
}

// var affinaty = gobble( obj_values(bundles) )
var affinaty = gobble( gobble.env() === 'production' ? obj_values(bundles) : bundles.plugins )

// .transform('uglifyjs')
.transformIf(gobble.env() === 'production', 'uglifyjs')
.transform(function hashFiles (source, options) {
	var file = path.basename(this.src)
	if (file === 'index.html') {
		var dir = path.dirname(this.src)
		var list = fs.readdirSync(dir)
		FILES.forEach(function (file) {
			if (!~list.indexOf(file)) {
				throw new Error(`missing file '${file}' in source dir`)
			}
		})
		FILES.forEach(function (file) {
			var txt = fs.readFileSync(`${dir}/${file}`)
			var hash = crypto.createHash('sha256').update(txt).digest('hex')
			console.log(file, '::', hash)
			source = source.replace(`/${file}`, `/${file}?h=${hash}`)
		})
	}
	return source
}, { accept: ['.html', '.js', '.css'] })

// var built
// if (gobble.env() === 'production') {
// 	built = gobble([
// 		affinaty.transform('uglifyjs'),
// 		// lib,
// 		// lib.transform('uglifyjs', { ext: '.min.js' })
// 	])
// } else {
// 	built = gobble([
// 		affinaty,
// 		// lib
// 	])
// }

// for future: build the website like this
if (!module.parent && false) {

  var builder = affinaty.build({
    dest: 'test-dir',
    force: true
  })
  builder.catch(function(e) {
    console.log('error:', e.stack)
  })
  builder.on('info', console.info.bind(console))
  builder.on('error', console.error.bind(console))
  builder.on('complete', function() {
    console.log('complete!', arguments)
    // built.serve()
  })
	builder.then(function () {
		console.log('builder.then')
	})

} else {
  module.exports = affinaty
}

// for (var i in require.cache) {
// 	if (require.cache.hasOwnProperty(i)) {
// 		// console.log(affinaty[i])
// 		console.log(i)
//
// 	}
// }

// console.log(require.cache)

/*
function delete_children(children) {
	for (var i = 0; i < children.length; i++) {
		var f = children[i]
		if (!require.cache[f]) continue
		var childrens_children = require.cache[f].children
		if (childrens_children.length) delete_children(childrens_children)
		console.log('deleting require.cache for: ' + f)
		delete require.cache[f]
	}
}

var watch_file = 'gobble-ractive.js'
var watcher = fs.watch(`./${watch_file}`, function (event) {
	console.log(`${watch_file} changed...`)
	// delete require.cache[]
	for (var i in require.cache) {
		// console.log(i)
		if (typeof i !== `string`) continue
		var f = path.basename(i)
		if (f === watch_file) {
			// console.log(affinaty[i])
			// console.log(require.cache[i])
			console.log('reloading...')
			delete_children([i])
			// console.log('found it!!', Object.keys(require.cache[i]))
			// console.log('found it!!', Object.keys(require.cache[i].children))
			// console.log('found it!!', require.cache[i].children)

		}
	}
	fs.appendFile('./gobblefile.js', '\n', function () {
		console.log('appended a \\n to gobblefile.js')
	})
})
*/


function obj_values (obj) {
	var arr = []
	for (var i in obj) {
		if (obj.hasOwnProperty(i)) arr.push(obj[i])
	}
	return arr
}

// TODO: run the build and then update gh-pages every commit :)

// TODO add prompter and run citadel
// todo do the gobbling in citadel. I shouldn't even need to open this.
