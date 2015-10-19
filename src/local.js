'use strict'

import addGetItems from './lib/localForage/getItems'
import addSetItems from './lib/localForage/setItems'

let localforage = require('localforage')
addGetItems(localforage)
addSetItems(localforage)

localforage.config({
  name: 'Affinaty',
  storeName: 'affinaty',
})

export default localforage
