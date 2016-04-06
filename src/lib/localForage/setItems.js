'use strict'

// original code here:
// https://github.com/thgreasi/localForage-setItems

import Promise from 'lie'
import executeCallback from './utils/executeCallback'
import serializer from './utils/serializer'

var globalObject = window

export function localforageSetItems (items, keyFn, valueFn, callback) {
  var localforageInstance = this
  var currentDriver = localforageInstance.driver()

  if (currentDriver === localforageInstance.INDEXEDDB) {
    return setItemsIndexedDB.call(localforageInstance, items, keyFn, valueFn, callback)
  } else if (currentDriver === localforageInstance.WEBSQL) {
    return setItemsWebsql.call(localforageInstance, items, keyFn, valueFn, callback)
  } else {
    return setItemsGeneric.call(localforageInstance, items, keyFn, valueFn, callback)
  }
}

function forEachItem (items, keyFn, valueFn, loopFn) {
  function ensurePropGetterMethod (propFn, defaultPropName) {
    var propName = propFn || defaultPropName

    if ((!propFn || typeof propFn !== 'function') &&
      typeof propName === 'string') {
      propFn = function (item) { return item[propName]; }
    }
    return propFn
  }

  var result = []
  // http://stackoverflow.com/questions/4775722/check-if-object-is-array
  if (Object.prototype.toString.call(items) === '[object Array]') {
    keyFn = ensurePropGetterMethod(keyFn, 'key')
    valueFn = ensurePropGetterMethod(valueFn, 'value')

    for (var i = 0, len = items.length; i < len; i++) {
      var item = items[i]
      result.push(loopFn(keyFn(item), valueFn(item)))
    }
  } else {
    for (var prop in items) {
      if (items.hasOwnProperty(prop)) {
        result.push(loopFn(prop, items[prop]))
      }
    }
  }
  return result
}

export function setItemsGeneric (items, keyFn, valueFn, callback) {
  var localforageInstance = this

  var itemPromises = forEachItem(items, keyFn, valueFn, function (key, value) {
    return localforageInstance.setItem(key, value)
  })
  var promise = Promise.all(itemPromises)

  executeCallback(promise, callback)
  return promise
}

export function setItemsIndexedDB (items, keyFn, valueFn, callback) {
  var localforageInstance = this

  var promise = new Promise(function (resolve, reject) {
    localforageInstance.ready().then(function () {
      // Inspired from @lu4 PR mozilla/localForage#318
      var dbInfo = localforageInstance._dbInfo
      var transaction = dbInfo.db.transaction(dbInfo.storeName, 'readwrite')
      var store = transaction.objectStore(dbInfo.storeName)

      var itemPromises = forEachItem(items, keyFn, valueFn, function (key, value) {
        // The reason we don't _save_ null is because IE 10 does
        // not support saving the `null` type in IndexedDB. How
        // ironic, given the bug below!
        // See: https://github.com/mozilla/localForage/issues/161
        if (value === null) {
          value = undefined
        }
        var request = store.put(value, key)

        return new Promise(function (resolve, reject) {
          request.onsuccess = resolve
          request.onerror = function () {
            reject(request.error)
          }
        })
      })

      Promise.all(itemPromises).then(function () {
        transaction.oncomplete = function () {
          resolve(items)
        }
      }).catch(reject)

      transaction.onabort = transaction.onerror = function (event) {
        reject(event.target)
      }

    }).catch(reject)
  })
  executeCallback(promise, callback)
  return promise
}

export function setItemsWebsql (items, keyFn, valueFn, callback) {
  var localforageInstance = this
  var promise = new Promise(function (resolve, reject) {
    localforageInstance.ready().then(function () {
      // Inspired from @lu4 PR mozilla/localForage#318
      var dbInfo = localforageInstance._dbInfo
      dbInfo.db.transaction(function (t) {
        var query = 'INSERT OR REPLACE INTO ' +
          dbInfo.storeName +
          ' (key, value) VALUES (?, ?)'

        var itemPromises = forEachItem(items, keyFn, valueFn, function (key, value) {
          return new Promise(function (resolve, reject) {
            serializer.serialize(value, function (value, error) {
              if (error) {
                reject(error)
              } else {
                t.executeSql(query, [key, value], function () {
                  resolve()
                }, function (t, error) {
                  reject(error)
                })
              }
            })
          })
        })

        Promise.all(itemPromises).then(function () {
          resolve(items)
        }, reject)
      }, function (sqlError) {
        reject(sqlError)
      } /*, function() {
                if (resolving) {
                    resolve(items)
                }
            }*/)
    }).catch(reject)
  })
  executeCallback(promise, callback)
  return promise
}
