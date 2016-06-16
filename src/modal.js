
import Modal from './partials/modal'

import assign from './lib/lodash/assign'

let _modal

export default function modal(component, opts) {
  opts = opts || {}
  let components = {}
  if (!(components[component] = this.components[component]))
    throw new Error(`requested component ${component} not a component`)
  if (_modal) _modal.teardown()
  let M = this.components.modal || Modal
  // TODO: use @this when upgrading to Ractive-0.8.0
  let o = ''
  for(var i in opts) {
    var v = opts[i]
    if (typeof v !== 'object')
    o += `${i}={{${JSON.stringify(v)}}} ` //.replace(/"/g, '\\"')
  }
  _modal = new M({
    // parent: this, // this doesn't work -- tries to resolve references in the parent... which doesn't work
    components: components,
    partials: {
      modalContent: `<${component} ${o}/>`,
      // modalFooter: opts.footer ? `<${opts.footer} />` : void 0,
      modalFooter: opts.footer ? opts.footer : void 0,
    },
    data: assign({modalName: component, parent: this}, opts),
  })
  router.once('dispatch', () => {
    if (_modal) _modal.teardown()
    // I want these to go to the side with a little x on tehm
    // like transitioned/minimized over the side
  })
  return _modal
}
