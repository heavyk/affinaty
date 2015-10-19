
let codemirror = Ractive.components.codemirror = Ractive.extend({
  template: '<textarea></textarea>',
  isolated: true,
  onrender() {
    let self = this
    let textarea = this.find('textarea')

    let theme = this.get('theme') || 'paraiso-dark'
    let mode = this.get('mode') || 'htmlmixed'
    if (mode === 'html') mode = 'htmlmixed'
    if (mode === 'json') mode = { name: 'javascript', json: true }

    let updating = false

    let CodeMirror = require('codemirror')
    let modes = {
      livescript: require('codemirror/mode/livescript/livescript.js'),
      javascript: require('codemirror/mode/javascript/javascript.js'),
      handlebars: require('codemirror/mode/handlebars/handlebars.js'),
      htmlmixed: require('codemirror/mode/htmlmixed/htmlmixed.js'),
      // brainfuck: require('codemirror/mode/brainfuck/brainfuck.js'),
      pegjs: require('codemirror/mode/pegjs/pegjs.js'),
      sass: require('codemirror/mode/sass/sass.js'),
      css: require('codemirror/mode/css/css.js'),
    }

    let themes = [
      'paraiso-light',
      'paraiso-dark',
      'monokai',
    ]

    let editor = CodeMirror.fromTextArea(textarea, {
      mode: mode,
      // theme: 'paraiso-light',
      theme: theme,
      lineNumbers: true
    })

    window.ed = editor

    editor.on('change', () => {
      if (updating) return
      updating = true
      this.set('value', editor.getValue())
      updating = false
    })

    this.observe('value', (val) => {
      if (updating) return
      updating = true
      editor.setValue(val)
      updating = false
    })

    this.observe('mode', (mode) => {
      if (mode === 'html') mode = 'htmlmixed'
      if (mode === 'json') mode = { name: 'javascript', json: true }
      // console.log('mode:', mode)
      editor.setOption('mode', mode)
    })

    this.once('teardown', () => {
      editor.toTextArea()
    })
  }
})

export default codemirror
