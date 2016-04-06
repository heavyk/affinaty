'use strict'

// original code here:
// https://github.com/thgreasi/localForage-getItems

import Promise from 'lie'
import executeCallback from './utils/executeCallback'
import serializer from './utils/serializer'

var globalObject = window

export function localforageGetItems (keys, callback) {
  var localforageInstance = this
  var currentDriver = localforageInstance.driver()

  if (currentDriver === localforageInstance.INDEXEDDB) {
    return getItemsIndexedDB.call(localforageInstance, keys, callback)
  } else if (currentDriver === localforageInstance.WEBSQL) {
    return getItemsWebsql.call(localforageInstance, keys, callback)
  } else {
    return getItemsGeneric.call(localforageInstance, keys, callback)
  }
}

export function getItemsGeneric (keys, callback) {
  var localforageInstance = this
  var promise = new Promise(function (resolve, reject) {
    var itemPromises = []

    for (var i = 0, len = keys.length; i < len; i++) {
      itemPromises.push(getItemKeyValue.call(localforageInstance, keys[i]))
    }

    Promise.all(itemPromises).then(function (keyValuePairs) {
      var result = {}
      for (var i = 0, len = keyValuePairs.length; i < len; i++) {
        var keyValuePair = keyValuePairs[i]

        result[keyValuePair.key] = keyValuePair.value
      }
      resolve(result)
    }).catch(reject)
  })
  executeCallback(promise, callback)
  return promise
}

export function getItemsIndexedDB (keys, callback) {
  var localforageInstance = this
  function comparer (a, b) {
    return a < b ? -1 : a > b ? 1 : 0
  }

  var promise = new Promise(function (resolve, reject) {
    localforageInstance.ready().then(function () {
      // Thanks https://hacks.mozilla.org/2014/06/breaking-the-borders-of-indexeddb/
      var dbInfo = localforageInstance._dbInfo
      var store = dbInfo.db.transaction(dbInfo.storeName, 'readonly')
        .objectStore(dbInfo.storeName)

      // Initialize IDBKeyRange; fall back to vendor-prefixed versions if needed.
      var IDBKeyRange = IDBKeyRange || globalObject.IDBKeyRange || globalObject.webkitIndexedDB ||
        globalObject.mozIndexedDB || globalObject.OIndexedDB ||
        globalObject.msIndexedDB

      var set = keys.sort(comparer)

      var keyRangeValue = IDBKeyRange.bound(keys[0], keys[keys.length - 1], false, false)
      var req = store.openCursor(keyRangeValue)
      var result = {}
      var i = 0

      req.onsuccess = function ( /*event*/) {
        var cursor = req.result; // event.target.result

        if (!cursor) {
          resolve(result)
          return
        }

        var key = cursor.key

        while (key > set[i]) {
          // The cursor has passed beyond this key. Check next.
          i++

          if (i === set.length) {
            // There is no next. Stop searching.
            resolve(result)
            return
          }
        }

        if (key === set[i]) {
          // The current cursor value should be included and we should continue
          // a single step in case next item has the same key or possibly our
          // next key in set.
          var value = cursor.value
          if (value === undefined) {
            value = null
          }

          result[key] = value
          // onfound(cursor.value)
          cursor.continue()
        } else {
          // cursor.key not yet at set[i]. Forward cursor to the next key to hunt for.
          cursor.continue(set[i])
        }
      }

      req.onerror = function ( /*event*/) {
        reject(req.error)
      }
    }).catch(reject)
  })
  executeCallback(promise, callback)
  return promise
}

export function getItemsWebsql (keys, callback) {
  var localforageInstance = this
  var promise = new Promise(function (resolve, reject) {
    localforageInstance.ready().then(function () {
      var dbInfo = localforageInstance._dbInfo
      dbInfo.db.transaction(function (t) {
        var queryParts = new Array(keys.length)
        for (var i = 0, len = keys.length; i < len; i++) {
          queryParts[i] = '?'
        }

        t.executeSql('SELECT * FROM ' + dbInfo.storeName +
        ' WHERE (key IN (' + queryParts.join(',') + '))', keys,
          function (t, results) {
            var result = {}

            var rows = results.rows
            for (var i = 0, len = rows.length; i < len; i++) {
              var item = rows.item(i)
              var value = item.value

              // Check to see if this is serialized content we need to
              // unpack.
              if (value) {
                value = serializer.deserialize(value)
              }

              result[item.key] = value
            }

            resolve(result)
          },
          function (t, error) {
            reject(error)
          })
      })
    }).catch(reject)
  })
  executeCallback(promise, callback)
  return promise
}

function getItemKeyValue (key, callback) {
  var localforageInstance = this
  var promise = localforageInstance.getItem(key).then(function (value) {
    return {
      key: key,
      value: value
    }
  })
  executeCallback(promise, callback)
  return promise
}
