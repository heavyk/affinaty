
import EE from '../drip/emitter'
import eq from '../lodash/isEqual'

function isCopy (other) {
	var i, l = this.length
	// if (this == null || other == null) throw new TypeError("cannot use null values")
	if (l !== other.length) return false
	for (i = 0; i < l; ++i) {
		if (hasOwnProperty.call(this, i) !== hasOwnProperty.call(other, i) || !eq(this[i], other[i])) return false
	}
	return true
};

function d (fn) {
	return {
		configurable: true, enumerable: false, writable: true,
		value: fn
	}
}

function ObservableArray (_v) {
	var arr = new EE(_v || [])
	var proto = Object.getPrototypeOf(arr)

	var pop = proto.pop
	var push = proto.push
	var reverse = proto.reverse
	var shift = proto.shift
	var sort = proto.sort
	var splice = proto.splice
	var slice = proto.slice
	var unshift = proto.unshift

	Object.defineProperties(arr, {
		pop: d(function () {
			var element;
			if (!this.length) return;
			element = pop.call(this);
			this.emit('change', {
				type: 'pop',
				value: element
			});
			return element;
		}),
		push: d(function (item/*, …items*/) {
			var result;
			if (!arguments.length) return this.length;
			result = push.apply(this, arguments);
			this.emit('change', {
				type: 'push',
				values: arguments
			});
			return result;
		}),
		reverse: d(function () {
			var tmp;
			if (this.length <= 1) return this;
			tmp = aFrom(this);
			reverse.call(this);
			if (!isCopy.call(this, tmp)) this.emit('change', { type: 'reverse' });
			return this;
		}),
		shift: d(function () {
			var element;
			if (!this.length) return;
			element = shift.call(this);
			this.emit('change', {
				type: 'shift',
				value: element
			});
			return element;
		}),
		sort: d(function (compareFn) {
			var tmp;
			if (this.length <= 1) return this;
			tmp = aFrom(this);
			sort.call(this, compareFn);
			if (!isCopy.call(this, tmp)) {
				this.emit('change', {
					type: 'sort',
					compareFn: compareFn
				});
			}
			return this;
		}),
		splice: d(function (start, deleteCount/*, …items*/) {
			var result, l = arguments.length, items;
			if (!l) return [];
			if (l <= 2) {
				if (+start >= this.length) return [];
				if (+deleteCount <= 0) return [];
			} else {
				items = slice.call(arguments, 2);
			}
			result = splice.apply(this, arguments);
			if ((!items && result.length) || !isCopy.call(items, result)) {
				this.emit('change', {
					type: 'splice',
					arguments: arguments,
					removed: result
				});
			}
			return result;
		}),
		unshift: d(function (item/*, …items*/) {
			var result;
			if (!arguments.length) return this.length;
			result = unshift.apply(this, arguments);
			this.emit('change', {
				type: 'unshift',
				values: arguments
			});
			return result;
		}),
		set: d(function (index, value) {
			var had, old, event;
			index = index >>> 0;
			if (this.hasOwnProperty(index)) {
				had = true;
				old = this[index];
				if (eq(old, value)) return;
			}
			this[index] = value;
			event = {
				type: 'set',
				index: index
			};
			if (had) event.oldValue = old;
			this.emit('change', event);
		})
	})

	return arr
}

export default ObservableArray
