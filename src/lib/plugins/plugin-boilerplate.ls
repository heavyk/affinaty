``import defaults from '../lodash/defaultsDeep'``
``import { value } from '../dom/observable'``
``import { ResizeSensor } from '../dom/css-element-queries'``
``import h from '../dom/hyper-hermes'``
``import { s } from '../dom/hyper-hermes'``


parse-json = (s) ->
  try
    return if typeof s is \string
      JSON.parse s
    else s
  catch => return {}

plugin-boilerplate = (frame, id, _config, _data, DEFAULT_CONFIG, _onload) ->
  const config = defaults {}, (parse-json _config), DEFAULT_CONFIG
  const doc = document
  const body = doc.body
  const IS_LOCAL = ~doc.location.host.index-of 'localhost'
  if IS_LOCAL
    # set the domain (to allow parent window modification)
    # doc.domain = doc.domain
    # console.info "set frame to: #{doc.domain}"
    # for pages without a stylesheet - like local, we set a default font and color
    # TODO: need information whether the "plugin" has a stylesheet
    style = body.style
    style.background = '#fff'
    style.'font-family' = 'Helvetica Neue,Helvetica,Arial,sans-serif'
    style.padding = style.margin = 0

  unless frame
    body.append-child frame =\
      h \div.frame, s: { position: \absolute, left: 0, top: 0, width: '100%', height: '100%', overflow: \hidden }

  mutation-observer = new MutationObserver (mutations) !->
    for m in mutations
      for n in m.removed-nodes
        if n is frame
          # console.log 'removed! - TODO: call h.cleanup()'
          frame.cleanup!

  mutation-observer.observe body, {+child-list}


  G = {}
  G.E = E = {frame, doc.body, window} # elements
  G.T = T = {} # text
  G.S = S = {} # streams
  G.C = C = {} # config
  G.O = O = {} # occurance / occasion (events)
  G.D = D = {} # data (not really necessary)

  G.s = s.context!
  G.h = h.context!
  G.s.context = s.context
  G.h.context = h.context

  window.G = G

  # TODO: get device orientation
  # https://crosswalk-project.org/documentation/tutorials/screens.html
  G.width = value _width = frame.client-width || config.width || 300
  G.height = value _height = frame.client-height || config.height || 300

  frame._id = id
  unless set_data = frame.set_data
    set_data = frame.set_data = value!

  let _cleanup = frame.cleanup
    frame.cleanup = !->
      mutation-observer.disconnect!
      if p = frame.parent-node
        p.remove-child frame
      G.h.cleanup!
      G.s.cleanup!
      _cleanup! if typeof _cleanup is \function

  G.cleanup = frame.cleanup

  # unless set_config = config.config
  #   set_config = config.config = value config
  # set_config = value config
  unless set_config = frame.set_config
    set_config = frame.set_config = value config
    set_config (config) !->
      # every config item creates a G entry
      console.log "setting config:", config
      for k, v of config
        # console.log k, \=, v
        if typeof (o = G[k]) is \undefined
          G[k] = value v
        else o v

  args = {config, G, set_config, set_data}

  # onload
  let onload = _onload
    loader = !->
      # remove all children
      while e = frame.childNodes.0
        frame.removeChild e

      # set data if data is supplied
      if _data
        set_data _data


      # remove all text/comment children from the body... (the crap)
      i = 0
      while el = body.child-nodes[i]
        if el.node-name.0 is '#' # or el._id is id
          body.remove-child el
        else i++

      if typeof onload is \function
        onload args

      resize = new ResizeSensor frame, !->
        G.width _width = frame.client-width
        G.height _height = frame.client-height
        # console.log 'resize!', frame.client-width, frame.client-height
      h.cleanup-funcs.push !->
        resize.detach!

    # if this script was added in the header, wait for it, else load it soon(tm)
    if doc.body => set-timeout loader, 1
    else window.addEventListener \DOMContentLoaded, loader, false

  args


``export { parseJson }``
``export default pluginBoilerplate``
