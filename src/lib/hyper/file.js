// knicked from https://github.com/dominictarr/hyperfile
import h from './hermes'

function select (ready) {
  return h('input', {type: 'file', onchange: function (ev) {
    var file = ev.target.files[0]
    ready(new FileReader(), file)
  }})

}

export default function asBuffer (onFile) {
  return select(function (reader) {
    reader.onload = function () {
      onFile(new Buffer(reader.result))
    }
    reader.readAsArrayBuffer(file)
  })
}

export function asDataURL (onFile) {
  return select(function (reader, file) {
    reader.onload = function () {
      onFile(reader.result)
    }
    reader.readAsDataURL(file)
  })
}
