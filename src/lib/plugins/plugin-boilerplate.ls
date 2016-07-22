``import defaults from '../lodash/defaultsDeep'``
``import { value } from '../dom/observable'``

parse-json = (s) ->
  try
    return if typeof s is \string
      JSON.parse s
    else s
  catch => return {}

plugin-boilerplate = (el, id, _config, _data, DEFAULT_CONFIG) ->
  const config = defaults {}, (parse-json _config), DEFAULT_CONFIG

  el._id = id
  unless set_data = el.set_data
    set_data = el.set_data = value!
  unless set_config = config.config
    set_config = config.config = value config

  # remove all children
  while e = el.childNodes.0
    el.removeChild e

  if _data
    set_data _data

  {config, set_config, set_data}


``export { parseJson }``
``export default pluginBoilerplate``
