'use strict'
var gobble = require('gobble')
var babel = require('rollup-plugin-babel')

gobble.cwd(__dirname)

var affinaty = gobble([
	gobble('src')
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
		.transform('rollup', {
			entry: 'main.js',
			dest: 'app.js',
			format: 'cjs',
			external: [
				 'ractive',
				 'ractive-transitions-fade',
				 'moment',
				 'spin.js',
				 'gemini-scrollbar',
				 'masonry-layout',
				 'dropzone', // this needs to be replaced by generic code
				 'easy-pie-chart',
				 'chart.js',
				 'es6-map',
				 'lie',
				 'engine.io-client',
			],
			plugins: [
				babel({
					// "presets": [ "es2015-rollup" ],
					exclude: 'node_modules/**',
					plugins: [
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
						// [require('babel-plugin-transform-minify-booleans')],
						// [require('babel-plugin-transform-merge-sibling-variables')],
						[require('babel-plugin-transform-member-expression-literals')],
						[require('babel-plugin-transform-property-literals')],

						// debugger
						// [require('babel-plugin-transform-remove-console')],
						// [require('babel-plugin-transform-remove-debugger')],
					],
					"compact": false
				})
			]
		})
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
		// .transformIf(gobble.env() === 'production', 'uglifyjs')

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
// if (!module.parent && false) {
//
//   var builder = built.build({
//     dest: 'build',
//     force: true
//   })
//   builder.catch(function(e) {
//     console.log('error:', e.stack)
//   })
//   builder.on('info', console.info.bind(console))
//   builder.on('error', console.error.bind(console))
//   builder.on('complete', function() {
//     console.log('complete!', arguments)
//     // built.serve()
//   })
//
// } else {
  // module.exports = built
  module.exports = affinaty
// }

// TODO: run the build and then update gh-pages every commit :)

// TODO add prompter and run citadel
// todo do the gobbling in citadel. I shouldn't even need to open this.
