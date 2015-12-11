
import router from './router'
import Modal from './partials/modal'

import assign from './lib/lodash/object/assign'

let _modal

export default function modal(component, opts) {
  opts = opts || {}
  let components = {}
  if (!(components[component] = this.components[component]))
    throw new Error(`requested component ${component} not a component`)
  if (_modal) _modal.teardown()
  let M = this.components.modal || Modal
  _modal = new M({
    components: components,
    partials: {
      modalContent: `<${component} />`,
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
