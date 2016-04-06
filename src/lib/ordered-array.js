
export function insert(element, array, comparer) {
  let location = locationOf(element, array, comparer) + 1
  array.splice(location, 0, element)
  return location
}

export function locationOf(element, array, comparer, start, end) {
  if (array.length === 0) return -1

  start = start || 0
  end = end || array.length
  var pivot = (start + end) >> 1

  var c = comparer(element, array[pivot])
  if (end - start <= 1) return c === -1 ? pivot - 1 : pivot

  switch (c) {
    case -1: return locationOf(element, array, comparer, start, pivot)
    case 0: return pivot
    case 1: return locationOf(element, array, comparer, pivot, end)
  }
}
