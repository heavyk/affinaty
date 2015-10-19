
// originally:
// https://github.com/stewartml/ractive-validator

let moment = require('moment')
let Promise = require('promise')

function RactiveValidator () {
  var ref
  switch (arguments.length) {
    case 3:
      this.basePath = arguments[0], this.model = arguments[1], this.rules = arguments[2]
      this.basePath = this.basePath + '.'
      break
    case 2:
      this.rules = arguments[1]
      if (typeof arguments[0] === 'string') {
        this.basePath = arguments[0] + '.'
      } else {
        this.basePath = ''
        this.model = arguments[0]
      }
      break
    case 1:
      this.rules = arguments[0]
      this.basePath = ''
      break
    default:
      throw new Error('wrong number of arguments')
  }
  this.validators = RactiveValidator.validators
  this.errorSuffix = 'Msg'
  this.enabled = true
  if (((ref = this.model) != null ? ref.observe : void 0) != null) {
    this.observeModel()
  }
}

RactiveValidator.prototype.observeModel = function () {
  var j, len, ref, results1, rulepath
  ref = this.rules
  results1 = []
  for (j = 0, len = ref.length; j < len; j++) {
    rulepath = ref[j]
    results1.push(this.model.observe(rulepath, (function (_this) {
      return function (newValue, oldValue, keypath) {
        if (_this.enabled) {
          return _this.validateKeypath(newValue, keypath, result, _this.rules[rulepath])
        }
      }
    })(this), {
      init: false
    }))
  }
  return results1
}

RactiveValidator.prototype.enable = function (value) {
  var j, keypath, len, ref, results1
  this.enabled = value
  ref = this.rules
  results1 = []
  for (j = 0, len = ref.length; j < len; j++) {
    keypath = ref[j]
    results1.push(this.model.set(this.basePath + keypath + this.errorSuffix))
  }
  return results1
}

RactiveValidator.prototype.validate = function (model) {
  var keypath, p, promises, ref, result, rules
  result = {
    valid: true,
    model: model || this.model,
    errors: new ObjectModel(),
    data: new ObjectModel(),
    groups: [],
    immediate: model != null
  }
  if (!(result.model.get && result.model.set)) {
    result.model = new ObjectModel(result.model)
  }
  if (!result.model.expandKeypath) {
    result.model.expandKeypath = ObjectModel.prototype.expandKeypath
  }
  promises = []
  ref = this.rules
  for (keypath in ref) {
    rules = ref[keypath]
    p = this.validateWildcardKeypath(this.basePath + keypath, result, rules)
    if (p != null ? p.then : void 0) {
      promises.push(p)
    }
  }
  if (promises.length) {
    return Promise.all(promises).then((function (_this) {
      return function () {
        return {
          valid: result.valid,
          errors: result.errors.model,
          data: result.data.get(_this.basePath.substring(0, _this.basePath.length - 1))
        }
      }
    })(this))
  } else {
    return {
      valid: result.valid,
      errors: result.errors.model,
      data: result.data.get(this.basePath.substring(0, this.basePath.length - 1))
    }
  }
}

RactiveValidator.prototype.validateWildcardKeypath = function (keypath, result, rules) {
  var j, len, p, path, paths, promises
  paths = result.model.expandKeypath(keypath)
  promises = []
  for (j = 0, len = paths.length; j < len; j++) {
    path = paths[j]
    p = this.validateKeypath(result.model.get(path), path, result, rules)
    if (p != null ? p.then : void 0) {
      promises.push(p)
    }
  }
  if (promises.length) {
    return Promise.all(promises)
  }
}

RactiveValidator.prototype.validateKeypath = function (value, keypath, result, rules) {
  var coda, coerced, fn, r, rule, ruleValue
  coerced = void 0
  fn = (function (_this) {
    return function (i, rules) {
      var coda, ref, rule, ruleValue, validation, validator
      ref = rules[i], rule = ref.rule, ruleValue = ref.ruleValue
      if (!_this.validators.hasOwnProperty(rule)) {
        if (typeof ruleValue === 'function') {
          validator = ruleValue
        } else {
          throw new Error('validator ' + rule + ' not defined')
        }
      } else {
        validator = _this.validators[rule]
      }
      validation = validator.call(_this, value, ruleValue, result)
      if (validation.skip) i = rules.length - 1
      coda = function (validation) {
        if (validation.valid) {
          if (!result.immediate) {
            result.model.set(keypath + _this.errorSuffix, void 0)
          }
          if (typeof validation.coerced !== 'undefined') {
            coerced = validation.coerced
          }
          if (i < rules.length - 1) {
            return fn(i + 1, rules)
          }
        } else {
          result.valid = false
          result.errors.set(keypath, validation.error)
          if (!result.immediate) {
            result.model.set(keypath + _this.errorSuffix, validation.error)
          }
        }
      }
      if (validation.then) {
        return validation.then(coda)
      } else {
        return coda(validation)
      }
    }
  })(this)
  r = fn(0, (function () {
    var results1
    results1 = []
    for (rule in rules) {
      ruleValue = rules[rule]
      results1.push({
        rule: rule,
        ruleValue: ruleValue
      })
    }
    return results1
  })())
  coda = function () {
    if (result.valid) {
      return result.data.set(keypath, typeof coerced !== 'undefined' ? coerced : value)
    }
  }
  if (r != null ? r.then : void 0) {
    return r.then(coda)
  } else {
    return coda()
  }
}

RactiveValidator.validators = {
  required (value, required, result) {
    var group, groupName, groupValue, match, ref
    result.required = required
    if (required) {
      if (typeof required === 'string') {
        ref = required.match(/([^\.]+)=(.+)/) || [], match = ref[0], groupName = ref[1], groupValue = ref[2]
        if (!match) {
          throw new Error('invalid require rule: ' + required)
        }
        group = result.groups[groupName]
        if ((value == null) || value === '') {
          if (group === groupValue) {
            return {
              valid: false,
              error: 'required'
            }
          } else {
            return {
              valid: true
            }
          }
        } else {
          if (group === void 0) {
            result.groups[groupName] = groupValue
            return {
              valid: true
            }
          } else if (group === groupValue) {
            return {
              valid: true
            }
          } else {
            return {
              valid: false,
              error: 'not required'
            }
          }
        }
      } else {
        if ((value == null) || value === '') {
          return {
            valid: false,
            error: 'required'
          }
        } else {
          return {
            valid: true
          }
        }
      }
    } else {
      if ((value == null) || value === '' || typeof value === 'object' && !value.length) {
        return {
          valid: true,
          skip: true
        }
      } else {
        return {
          valid: true
        }
      }
    }
  },
  password (value, otherField, result) {
    if (value === result.model.get(otherField)) {
      return {
        valid: true
      }
    } else {
      return {
        valid: false,
        error: 'passwords must match'
      }
    }
  },
  moment (value, format) {
    var coerce, m, ref
    if (moment == null) {
      throw new Error('need moment.js library for moment validator')
    }
    if (typeof format !== 'string') {
      ref = format, format = ref.format, coerce = ref.coerce
    }
    if ((value == null) || value === '') {
      return {
        valid: true
      }
    }
    m = moment.utc(value, format, true)
    if (m.isValid()) {
      if (coerce === true) {
        return {
          valid: true,
          coerced: m
        }
      } else if (coerce === 'date') {
        return {
          valid: true,
          coerced: m.toDate()
        }
      } else if (typeof coerce === 'string') {
        return {
          valid: true,
          coerced: m.format(coerce)
        }
      } else {
        return {
          valid: true
        }
      }
    } else {
      return {
        valid: false,
        error: 'must be ' + format
      }
    }
  },
  type (value, type, result) {
    if (value == null) {
      return {
        valid: true
      }
    }
    if (type === 'string') {
      if (typeof value !== 'string') {
        return {
          valid: false,
          error: 'must be a string'
        }
      } else {
        return {
          valid: true
        }
      }
    } else if (type === 'integer') {
      if (value === '') {
        return {
          valid: true,
          coerced: null
        }
      } else if (/^(\-|\+)?([0-9]+)$/.test(value)) {
        return {
          valid: true,
          coerced: Number(value)
        }
      } else if ((typeof value === 'number' && (value % 1) !== 0) || (typeof value !== 'number' && result.immediate)) {
        return {
          valid: false,
          error: 'must be a whole number'
        }
      } else {
        return {
          valid: true,
          coerced: Number(value)
        }
      }
    } else if (type === 'decimal') {
      if (value === '') {
        return {
          valid: true,
          coerced: null
        }
      } else if ((typeof value !== 'number' && result.immediate) || ((value != null) && value !== '' && !/^(\-|\+)?([0-9]+(\.[0-9]+)?)$/.test(value))) {
        return {
          valid: false,
          error: 'must be a decimal'
        }
      } else {
        return {
          valid: true,
          coerced: Number(value)
        }
      }
    } else if (type === 'boolean') {
      if (value === '') {
        return {
          valid: true,
          coerced: null
        }
      } else if ((typeof value !== 'boolean' && result.immediate) || ((value != null) && value !== '' && !/^(true|false)$/.test(value))) {
        return {
          valid: false,
          error: 'must be a boolean'
        }
      } else {
        return {
          valid: true,
          coerced: value === 'true' || value === true
        }
      }
    } else if (type === 'array') {
      if (Array.isArray(value)) {
        return {
          valid: true
        }
      } else {
        return {
          valid: false,
          error: 'must be an array'
        }
      }
    } else if (type === 'id') {
      if (/^[a-f\d]{24}$/.test(value)) {
        return {
          valid: true
        }
      } else {
        return {
          valid: false,
          error: 'must be an id'
        }
      }
    } else {
      throw new Error('unknown data type ' + type)
    }
  },
  positive (value, type) {
    if (value >= 0) {
      return {
        valid: true
      }
    } else {
      return {
        valid: false,
        error: 'must be positive'
      }
    }
  }
}

function ObjectModel (model) {
  this.model = model || {}
}

ObjectModel.prototype.get = function (keypath) {
  var paths, results
  if (!keypath) {
    return this.model
  }
  paths = this.expandKeypath(keypath)
  results = paths.map((function (_this) {
    return function (keypath) {
      var child, object, ref
      ref = _this.getObj(_this.model, keypath), object = ref.object, child = ref.child
      return object[child]
    }
  })(this))
  if (paths.length > 1) {
    return results
  } else {
    return results[0]
  }
}

ObjectModel.prototype.set = function (keypath, value) {
  var child, j, len, object, paths, ref, results1
  paths = this.expandKeypath(keypath)
  results1 = []
  for (j = 0, len = paths.length; j < len; j++) {
    keypath = paths[j]
    ref = this.getObj(this.model, keypath), object = ref.object, child = ref.child
    results1.push(object[child] = value)
  }
  return results1
}

ObjectModel.prototype.expandKeypath = function (keypath, paths) {
  var k, match, path, ref, remainder, start
  paths = paths || []
  ref = keypath.match(/^(([^\*]+)\.)?\*(\..*)?$/) || [], match = ref[0], start = ref[1], path = ref[2], remainder = ref[3]
  if (match) {
    for (k in this.get(path)) {
      this.expandKeypath(start + k + remainder, paths)
    }
  } else {
    paths.push(keypath)
  }
  return paths
}

ObjectModel.prototype.getObj = function (obj, keypath) {
  var child, match, parent, pos, ref, remainder
  pos = keypath.indexOf('.')
  if (pos === -1) {
    return {
      object: obj,
      child: keypath
    }
  } else {
    ref = keypath.match(/^([^\.]+)\.(([^\.]+).*)$/), match = ref[0], parent = ref[1], remainder = ref[2], child = ref[3]
    if (!obj.hasOwnProperty(parent)) {
      obj[parent] = isNaN(parseInt(child)) ? {} : []
    }
    return this.getObj(obj[parent], remainder)
  }
}

// TODO - import all the validators from actionhero
//  or, perhaps, it'd be better to just ask the server for the function signature
let validators = RactiveValidator.validators
validators.min = function (value, min) {
  return value != null && typeof value.length !== 'undefined' && value.length < min
    ? { valid: false, error: 'minimum of '+ min + 'characters'}
    : typeof value === 'number' && value < min
      ? { valid: false, error: 'must be at least '+ min}
      : { valid: true }
}
validators.max = function (value, max) {
  return value != null && typeof value.length !== 'undefined' && value.length > max
    ? { valid: false, error: 'maximum of '+ max + 'characters'}
    : typeof value === 'number' && value > max
      ? { valid: false, error: 'must be maximum '+ max}
      : { valid: true }
}
validators.email = function (value) {
  return typeof value === 'string' && value.indexOf('@') >= 1 && value.lastIndexOf('.') >= 4
    ? { valid: true }
    : { valid: false, error: 'must be a valid email'}
}

export default RactiveValidator
