var rcu = require('rcu')
var builders = require('rcu-builders')
var postcss = require('postcss')
rcu.init(require('ractive'))

module.exports = ractive

function ractive (source, options) {
	var builder = builders[ options.type || 'amd' ]

	if (!builder) {
		throw new Error('Cannot convert Ractive component to "' + options.type + '". Supported types: ' + Object.keys(builders))
	}

	options.sourceMap = options.sourceMap !== false

	if (options.sourceMap) {
		options.sourceMapFile = this.dest
		options.sourceMapSource = this.src
	}

	var parsed = rcu.parse(source)
	var dup = {}
	for (var i = 0; i < parsed.modules.length; i++) {
		var m = parsed.modules[i]
		if (dup[m]) {
			console.warn(' * WARN:', this.src)
			console.warn(' * duplicate import:', m)
			parsed.modules.splice(i--, 1)
		}
		dup[m] = true
	}

	// perhaps this should go instead into rcu-builders
	// for now this is here, but soon, just use the custom postcss enabled rcu-builders.js
	// https://github.com/ractivejs/rcu-builders#building
	postcss(options.postcss).process(parsed.css).then(function (result) {
		result.warnings().forEach(function (warn) {
			console.warn(warn.toString())
		})
		parsed.css = result.css
	})

	return builder(parsed, options)
}

ractive.defaults = {
	accept: '.html',
	ext: '.js'
}
