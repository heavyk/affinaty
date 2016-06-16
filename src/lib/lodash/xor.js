import arrayFilter from './_arrayFilter.js';
import baseXor from './_baseXor.js';
import isArrayLikeObject from './isArrayLikeObject.js';
import rest from './rest.js';

'use strict';

/**
 * Creates an array of unique values that is the
 * [symmetric difference](https://en.wikipedia.org/wiki/Symmetric_difference)
 * of the given arrays. The order of result values is determined by the order
 * they occur in the arrays.
 *
 * @static
 * @memberOf _
 * @since 2.4.0
 * @category Array
 * @param {...Array} [arrays] The arrays to inspect.
 * @returns {Array} Returns the new array of filtered values.
 * @see _.difference, _.without
 * @example
 *
 * _.xor([2, 1], [2, 3]);
 * // => [1, 3]
 */
var xor = rest(function(arrays) {
  return baseXor(arrayFilter(arrays, isArrayLikeObject));
});

export default xor;
