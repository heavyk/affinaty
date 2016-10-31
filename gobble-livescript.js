var path = require('path')
module.exports = livescript

function livescript (code, options) {
  // options = options || {}
  var compiled

  // options.sourceMap = true
  options.map = 'embedded' // 'linked'
  options.filename = path.basename(this.src)
  // options.outputFilename = this.dest // path.basename(this.dest)
  options.outputFilename = path.basename(this.dest)
  // options.sourceMapFile = this.dest + '.map'
  // options.sourceMapSource = this.src
  compiled = require('livescript').compile(code, options)
  // console.log('LS:', compiled)

  return {
    code: compiled.code,
    map: compiled.map
  }
}

livescript.defaults = {
  accept: '.ls',
  ext: '.js'
}
