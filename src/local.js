'use strict'

import localforage from './lib/localForage/localforage'
import { localforageGetItems, getItemsIndexedDB, getItemsWebsql, getItemsGeneric } from './lib/localForage/getItems'
import { localforageSetItems, setItemsIndexedDB, setItemsWebsql, setItemsGeneric } from './lib/localForage/setItems'

var localforagePrototype = Object.getPrototypeOf(localforage)

localforagePrototype.getItems = localforageGetItems
localforagePrototype.getItems.indexedDB = function () {
  return getItemsIndexedDB.apply(this, arguments)
}
localforagePrototype.getItems.websql = function () {
  return getItemsWebsql.apply(this, arguments)
}
localforagePrototype.getItems.generic = function () {
  return getItemsGeneric.apply(this, arguments)
}

localforagePrototype.setItems = localforageSetItems
localforagePrototype.setItems.indexedDB = function () {
  return setItemsIndexedDB.apply(this, arguments)
}
localforagePrototype.setItems.websql = function () {
  return setItemsWebsql.apply(this, arguments)
}
localforagePrototype.setItems.generic = function () {
  return setItemsGeneric.apply(this, arguments)
}


localforage.config({
  name: 'Affinaty',
  storeName: 'affinaty',
})

export default localforage
