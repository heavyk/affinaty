'use strict'

var metaphone = require('natural/lib/natural/phonetics/metaphone').process
var natural_stem = require('natural/lib/natural/stemmers/porter_stemmer').stem
var natural_stem_es = require('natural/lib/natural/stemmers/porter_stemmer_es').stem
var stopwords = require('natural/lib/natural/util/stopwords').words.concat(
  require('natural/lib/natural/util/stopwords_es').words
)


function words (str) {
  // return String(str).match(/\w+/g)
  return String(str).split(' ').filter(Boolean)
  // return String(str).match(/[a-zA-Z0-9]+/).filter(Boolean)
}


function stem (words) {
  var ret = []
  if (!words) return ret
  for (var i = 0, len = words.length; i < len; ++i) {
    ret.push(natural_stem(natural_stem_es(words[i])))
  }
  return ret
}


function stripStopWords (words) {
  var ret = []
  if (!words) return ret
  for (var i = 0, len = words.length; i < len; ++i) {
    if (~stopwords.indexOf(words[i])) continue
    ret.push(words[i])
  }
  return ret
}


function countWords (words) {
  var obj = {}
  if (!words) return obj
  for (var i = 0, len = words.length; i < len; ++i) {
    obj[words[i]] = (obj[words[i]] || 0) + 1
  }
  return obj
}


function metaphoneMap (words) {
  var obj = {}
  if (!words) return obj
  for (var i = 0, len = words.length; i < len; ++i) {
    obj[words[i]] = metaphone(words[i])
  }
  return obj
}


function metaphoneArray (words) {
  var arr = []
  var constant

  if (!words) return arr

  for (var i = 0, len = words.length; i < len; ++i) {
    constant = metaphone(words[i])
    if (!~arr.indexOf(constant)) arr.push(constant)
  }

  return arr
}


function metaphoneKeys (key, words) {
  return metaphoneArray(words).map(function (c) {
    return key + ':word:' + c
  })
}

function transform (str) {
  return metaphoneArray(stem(stripStopWords(words(str))))
}

export default {
  words,
  stem,
  stripStopWords,
  countWords,
  metaphoneMap,
  metaphoneArray,
  metaphoneKeys,
  transform,
}
