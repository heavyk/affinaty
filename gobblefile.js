'use strict'
var gobble = require('gobble')

gobble.cwd(__dirname)
gobble.env('development')

if (gobble.env() === 'production') {
	// TODO: write this / remove this in the babelrc
	// maybe it's doable actually with uglifyjs
	babelWhitelist = babelWhitelist.concat([
		// for production env
		'minification.removeConsole',
		'minification.removeDebugger',
	])
}

var affinaty = gobble([
	gobble('src')
		.transform(require('./gobble-translator.js'), {lang: 'en', local: 'us'})
		.transform(require('./gobble-ractive.js'), {
			type: 'es6',
			postcss: [
				require('postcss-import'),
				require('precss'),
				require('postcss-color-function'),
				require('autoprefixer-core', { browsers: ['last 2 versions'] }),
				require('cssnano'),
			]
		})
		.transform('rollup-babel', {
			entry: 'main.js',
			dest: 'app.js',
			format: 'cjs',
			external: [
				'ractive',
				'moment',
				'provinces', // this needs to be moved to the server
				'gemini-scrollbar',
				'masonry-layout',
				'spin.js',
				'dropzone', // this needs to be replaced by generic code
				'easy-pie-chart',
				'chart.js',
			],
			strict: true
		})
		.transform('derequire')
		.transform('browserify', {
			entries: [ './app' ],
			dest: 'app.js',
			standalone: 'app',
			debug: false
		})
		.transformIf(gobble.env() !== 'production', function (source, options) {
			return typeof source === 'string'
				? source.replace('deferred.reject(e)', 'console.error(e.stack) ; debugger ; deferred.reject(e)')
				: source
		})
		.transformIf(gobble.env() === 'production', 'uglifyjs')
		// .transform('uglifyjs')

	, gobble('files/styles')
		.transform('less', {
	    src: 'screen.less',
	    dest: 'screen.css'
	  })
		.transform('postcss', {
			plugins: [
				require('postcss-import'),
				require('precss'),
				require('postcss-color-function'),
				require('autoprefixer-core', { browsers: ['last 2 versions'] }),
			].concat(gobble.env() === 'production' ? [
				require('cssnano'),
			] : []),
			src: 'screen.css'
		})

	, gobble('files')
])
.transformIf(gobble.env() === 'production', 'uglifyjs')

var built
if (gobble.env() === 'production') {
	built = gobble([
		affinaty.transform('uglifyjs'),
		// lib,
		// lib.transform('uglifyjs', { ext: '.min.js' })
	])
} else {
	built = gobble([
		affinaty,
		// lib
	])
}

// for future: build the website like this
if (!module.parent && false) {

  var builder = built.build({
    dest: 'build',
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

} else {
  module.exports = built
}

// TODO: run the build and then update gh-pages every commit :)

// TODO add prompter and run citadel
// todo do the gobbling in citadel. I shouldn't even need to open this.
