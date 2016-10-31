``import pluginBoilerplate from '../lib/plugins/plugin-boilerplate'``
``import h from '../lib/dom/hyper-hermes'``
``import { s } from '../lib/dom/hyper-hermes'``
``import ObservArray from '../lib/dom/observable-array'``
``import { value, input, attribute, transform, compute } from '../lib/dom/observable'``
# ``import xhr from '../lib/xhr'``
# ``import animate from '../lib/velocity/velocity'``


const doc = document
const IS_LOCAL = ~doc.location.host.index-of 'localhost'

const DEFAULT_CONFIG =
  lala: 1155

onload = !->
  body = doc.body

  # TODO: add a reset stylesheet
  body.append-child h \style '''
    #T {
      position:absolute;
      display:block;
    }
    #Tcont {
      display:block;
      padding: 2px 12px 3px 7px;
      margin:5px;
      background:#666;
      color:#fff;
      border: solid 1px #ccc;
      border-radius: 12px;
    }
    '''

  # body.append-child s \style '''
  #   '''
# /onload


const LALA = 1111

affinaties = ({config, G, set_config, set_data}) ->
  onload! # this is just a function that has the stuff needed for the loading

  G.E.frame.append-child \
    s \svg, width: G.width, height: G.height, ->
      in1 = attribute \
        in2 = h \input, type: \text, placeholder: 'enter some text'
      in1 (v) !->
        console.log \input, v
      return
        * s \foreignObject width: 200, height: 200,
            h \p, s: 'width: 100px', "some more text...???"
            in2
            transform in1, (v) -> "input: #{v}"
    #</svg>

plugin-boilerplate null, \testing, {}, {}, DEFAULT_CONFIG, affinaties
