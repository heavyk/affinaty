/**
 * Meta-Decorator to use multiple decorators on a single HTML-element
 * usage: decorator="combine:{decorator1:[param1, param2], decorator2:param}"
 */

import clone from '../lodash/lang/cloneDeep'

function combine (node, data) {
  var decoratorName, decorator, parameters
  var instance = this
  var decorators = clone(data)

  for (decoratorName in decorators) {
    if ((decorator = instance.decorators[decoratorName])) {
      parameters = makeArray(decorators[decoratorName])
      parameters.unshift(node)
      decorators[decoratorName] = decorator.apply(instance, parameters)
    } else {
      delete decorators[decoratorName]
    }
  }

  return {
    teardown: function () {
      var decoratorName, decorator

      for (decoratorName in decorators) {
        decorator = instance.decorators[decoratorName]
        decorator.teardown && decorator.teardown()
      }
    },
    update: function (data) {
      var decoratorName, decorator, parameters

      for (decoratorName in decorators) {
        decorator = decorators[decoratorName]
        parameters = makeArray(data[decoratorName])
        decorator.update && decorator.update.apply(instance, parameters)
      }
    }
  }
}

export default combine
