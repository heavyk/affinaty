
export function insert (d, array, comparer) {
  let pos = posOf(d, array, comparer) + 1
  if (pos === array.length) array.push(d)
  else array.splice(pos, 0, d)
  return pos
}

export function insert_d (d, array, exists, comparer) {
  let pos = posOf(d, array, comparer) + 1
  if (pos === array.length) array.push(d)
  else array.splice(pos, 0, d)
  // update all exists values if they're greater than pos
  for (var i in exists) if (exists[i] >= pos) exists[i]++
  // set exists
  exists[d._id] = pos
  return pos
}

export function remove_d (id, array, exists, _pos) {
  let pos = _pos === void 0 ? exists[id] : _pos
  if (pos !== void 0) {
    // possible optimization here, if pos == 0, then unshift, else if pos == array.length - 1 then pop, else:
    array.splice(pos, 1)
    exists[id] = void 0
    for (let i in exists) {
      if (exists[i] > pos) exists[i]--
    }
  }

  return pos
}

export function posOf (d, array, comparer, start, end) {
  if (array.length === 0) return -1

  start = start || 0
  end = end || array.length
  var pivot = (start + end) >> 1

  var c = comparer(d, array[pivot])
  if (end - start <= 1) return c === -1 ? pivot - 1 : pivot

  switch (c) {
    case -1: return posOf(d, array, comparer, start, pivot)
    case 0: return pivot
    case 1: return posOf(d, array, comparer, pivot, end)
  }
}
