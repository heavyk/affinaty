const Path = require('path')
const magic = require('magic-string')

const cwd = process.cwd()

delete require.cache[__filename]
module.exports = translate


function translate (txt, options) {
  var file = Path.relative(cwd, this.src)
  var local = options.local
  var lang = options.lang

  switch (file) {
    case 'src/partials/header.html':
      if (lang === 'en') {
        txt = replace(txt, `Da tu opinión`, `Opinion`)
        txt = replace(txt, `Pide opinión`, `Poll`)
      }
      break

    case 'src/partials/foto-crop.html':
      if (local === 'mx')
        txt = txt.replace(`sí, quiero esta foto`, `sí guey, esta foto es chula`)
      break
  }
  return txt
}


function replace (s,a,b) {
	var x = 0
	var x1 = s.indexOf(a, x)
	if (x1 < 0) return s
	var R = '', L = s.length, AL = a.length
	while (x < L) {
		var o = s.substr(x, x1-x)
		R += o
		R += b
		x = x1 + AL
		x1 = s.indexOf(a, x)
		if (x1 < 0) break
	}
	R += s.slice(x)
	return R
}
