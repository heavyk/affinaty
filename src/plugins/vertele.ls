``import each from '../lib/lodash/forEach'``
``import defaults from '../lib/lodash/defaultsDeep'``
``import h from '../lib/dom/hyper-hermes'``
``import CL from '../lib/dom/class-list'``
``import ObservArray from '../lib/dom/observable-array'``
``import { attribute, value } from '../lib/dom/observable'``
``import floatingTip from '../lib/decorators/floating-tip'``
``import describeConeSection from '../lib/svg/describeConeSection'``
``import xhr from '../lib/xhr'``

# TODO: write my own svg optimizer which uses ceil(num, 2) // for 6.01 2-digit precision
# ``import ceil from '../lib/lodash/ceil'``


const doc = document
const IS_LOCAL = ~doc.location.host.index-of 'localhost'

onload = !->
  if IS_LOCAL
    # set the domain (to allow parent window modification)
    doc.domain = doc.domain
    console.info "set frame to: #{doc.domain}"
    style = doc.body.style
    style.background = '#fff'
    style.'font-family' = 'Helvetica Neue,Helvetica,Arial,sans-serif'
    style.padding = 0

  for e in document.querySelectorAll('div[data-affinaty-profile]')
    vertele-profile e, e.dataset.affinaty-profile

  for e in document.querySelectorAll('div[data-affinaty-encuesta]')
    vertele-encuesta e, e.dataset.affinaty-encuesta


# if this script was added in the header, wait for it, else load it soon(tm)
unless doc.body
  window.addEventListener \DOMContentLoaded, onload, false
else set-timeout onload, 1

const s = h.context (el) ->
  doc.createElementNS 'http://www.w3.org/2000/svg', el

const API_ROOT = if localStorage.host === 'local'
  "http://localhost:1155/api"
else "http://affinaty.com:1155/api"

const DEFAULT_CONFIG =
  type: \poll
  winning_icon: 'star',
  bar:
    fg: '#FB7868'
    bg: '#f6f6f6'
    winning_fg: '#fd270d'

const DEBATE_OPTIONS =
  * fg: '#2e8034', text: "Muy de acuerdo", icon: 'mas-mas'
  * fg: '#5a9727', text: "De acuerdo", icon: 'mas'
  * fg: '#cc4d41', text: "En desacuerdo", icon: 'woa'
  * fg: '#bb0217', text: "Muy en desacuerdo", icon: 'woa-woa'

const PROVINCE_LIST =
  A: 'Alicante'
  AB: 'Albacete'
  AL: 'Almería'
  AV: 'Ávila'
  B: 'Barcelona'
  BA: 'Badajoz'
  BI: 'Vizcaya'
  BU: 'Burgos'
  C: 'A Coruña'
  CA: 'Cádiz'
  CC: 'Cáceres'
  CE: 'Ceuta'
  CO: 'Córdoba'
  CR: 'Ciudad Real'
  CS: 'Castellón'
  CU: 'Cuenca'
  GC: 'Las Palmas'
  GI: 'Girona'
  GR: 'Granada'
  GU: 'Guadalajara'
  H: 'Huelva'
  HU: 'Huesca'
  J: 'Jaén'
  L: 'Lleida'
  LE: 'León'
  LO: 'La Rioja'
  LU: 'Lugo'
  M: 'Madrid'
  MA: 'Málaga'
  ML: 'Melilla'
  MU: 'Murcia'
  NA: 'Navarra'
  O: 'Asturias'
  OR: 'Ourense'
  P: 'Palencia'
  PM: 'Baleares'
  PO: 'Pontevedra'
  S: 'Cantabria'
  SA: 'Salamanca'
  SE: 'Sevilla'
  SG: 'Segovia'
  SO: 'Soria'
  SS: 'Guipúzcoa'
  T: 'Tarragona'
  TE: 'Teruel'
  TF: 'Santa Cruz de Tenerife'
  TO: 'Toledo'
  V: 'Valencia'
  VA: 'Valladolid'
  VI: 'Álava'
  Z: 'Zaragoza'
  ZA: 'Zamora'

empty-array = (num) ->
  a = new Array num
  for i til num
    a[i] = 0
  a

function stats-module (el, id, _config, _data)
  {config, set_config, set_data} = plugin-boilerplate el, id, _config, _data

  const width = el.clientWidth || config.width || 300
  const movil = window.is-mobile
  const num_planets = 2

  const bar_prefs = config.bar || {}
  const bar_height = bar_prefs.height || 20
  const bar_rounding = bar_prefs.rounding || 5
  const bar_stroke = bar_prefs.stroke || '#333'
  const bar_stroke-width = bar_prefs.stroke-width || 0.5
  const option_height = config.option_height || 50
  const icon_size = config.icon_size || 30
  const icon_padding = config.icon_padding || 5
  const fg = bar_prefs.fg || '#FB7868'
  const bg = bar_prefs.bg || '#f6f6f6'
  const winning_fg = bar_prefs.winning_fg
  const winning_icon = config.winning_icon
  const sex-stats-width = 300

  const AGES = config.ages or [ 18, 25, 35, 45 ]
  const COLORS = ['#f2d767', '#58176e', '#5e8cb4', '#d53084', '#e96b18']
  const COLORS_GREY = ['#c9c9c9', '#575757', '#777777', '#848484', '#9e9e9e']
  const SEX_COLOR = ['#D41A79', '#3CA0BB']

  # disabled because of supid voting hack...
  # const bar_x = icon_size + (icon_padding * 2)
  const bar_x = icon_size + (icon_padding * 2)
  const bar_max_px = width - bar_x

  const bottom_panel_y = 60
  const ages_len = AGES.length + 1

  # observables
  svg_height = value 400
  svg_width = value width

  # set values to display
  set_options = value!
  set_ranges = value!
  set_totals = value!
  set_total = value!
  set_planets = value!
  set_province_stats = value!

  load_data = !->
    # TODO: set a loading indicator
    xhr url: "#{API_ROOT}/#{config.type}-stats?_id=#{id}&ages=[#{AGES}]", (err, res) !->
      if err => return console.error "error processing...", err
      set_data res.data

  set_data (data) !->
    unless data => return
    if data.totals
      set_totals data.totals
      if data.options => set_options data.options
      return
    const options = data.options or DEBATE_OPTIONS
    const len = options.length
    total = 0
    totals = empty-array len
    planets = empty-array num_planets
    percents = empty-array len
    ages = AGES ++ '>'
    ranges = new Array ages.length
    for age, i in ages
      pr = r if i > 0
      r = age
      sum = 0
      for gender til num_planets
        for pos til 4
          k = age + '-' + gender + pos
          if t = data[k]
            totals[pos] += t
            planets[gender] += t
            sum += t

      ranges[i] = sum
      total += sum

    totals.reverse!

    set_options options
    set_planets planets
    set_total total
    set_totals totals
    set_ranges ranges
  #!set_data

  (options) <-! set_options

  # first: clear the element
  while e = el.childNodes.0
    el.removeChild e

  unless options
    # TODO: show loading box
    console.log "returning..."
    return

  const len = options.length

  v_bar_width = new Array len
  v_bar_fill = new Array len
  v_label = new Array len
  v_label_x = new Array len
  v_label_fill = new Array len
  v_totals = new Array len
  v_icon = new Array len
  v_rval = new Array ages_len
  v_rval_graph = new Array ages_len

  # window.v = {
  #   v_bar_width
  #   v_bar_fill
  #   v_label
  #   v_label_x
  #   v_label_fill
  #   v_totals
  #   v_icon
  #   v_rval
  #   v_rval_graph
  # }

  # element lists
  icons = new Array len

  el.appendChild \
    s \svg width: svg_width, height: svg_height, !->
      last_y = -option_height / 2
      svg_height (((len+1) * option_height) + last_y) + bottom_panel_y
      panels = new Array 4
      panel_title = value ''
      set_panel = value 'percent'
      # set_panel = value 'province'
      window.set_panel = set_panel

      buttons = []
      svg_els = [
        s \style, """
        g.button {
          cursor: pointer;
        }
        """
        s \defs,
          s 'filter#icon-filter', x: -1, y: -1, width: '300%', height: '300%',
            s \feOffset, result: \offOut, in: \SourceGraphic, dx: 0, dy: 2
            s \feGaussianBlur, result: \blurOut, in: \offOut, stdDeviation: 3
            s \feBlend, in: \SourceGraphic in2: \blurOut, mode: \normal
          s 'path#star',
            fill: '#ff3000',
            transform: 'scale(.3)  translate(-6 0)'
            d: 'M19.93 38.12c.07-.354-.054-.718-.312-.972L7.84 25.664 24.11 23.3c.36-.05.67-.273.83-.597l7.28-14.75 7.277 14.75c.164.324.473.547.825.598L56.6 25.665 44.813 37.148c-.25.254-.375.618-.31.973l2.782 16.204-14.558-7.644c-.156-.086-.336-.133-.508-.133-.176 0-.352.047-.512.133l-14.554 7.644zm44.24-14.913c-.64-1.96-2.38-3.426-4.427-3.727l-15.62-2.27-6.99-14.15C36.204 1.17 34.324 0 32.22 0c-2.102 0-3.992 1.172-4.914 3.055L20.318 17.21l-15.63 2.27c-2.038.3-3.78 1.766-4.417 3.727-.644 2.004-.12 4.152 1.387 5.617l11.31 11.02-2.67 15.558c-.35 2.04.505 4.145 2.18 5.364 1.665 1.195 3.95 1.375 5.77.418l13.973-7.348 13.965 7.348c.793.41 1.676.625 2.554.625 1.16 0 2.273-.36 3.226-1.044 1.668-1.22 2.523-3.325 2.172-5.364l-2.664-15.558 11.305-11.02c1.502-1.465 2.03-3.613 1.39-5.617'
          s 'path#check',
            transform: 'scale(-.01 .01) rotate(180) translate(-200 -1600)'
            d: 'M1671 970q0 -40 -28 -68l-724 -724l-136 -136q-28 -28 -68 -28t-68 28l-136 136l-362 362q-28 28 -28 68t28 68l136 136q28 28 68 28t68 -28l294 -295l656 657q28 28 68 28t68 -28l136 -136q28 -28 28 -68z'
          s 'path#xx',
            transform: 'scale(-.009 .009) rotate(180) translate(200 -1700)'
            d: 'M1298 214q0 -40 -28 -68l-136 -136q-28 -28 -68 -28t-68 28l-294 294l-294 -294q-28 -28 -68 -28t-68 28l-136 136q-28 28 -28 68t28 68l294 294l-294 294q-28 28 -28 68t28 68l136 136q28 28 68 28t68 -28l294 -294l294 294q28 28 68 28t68 -28l136 -136q28 -28 28 -68 t-28 -68l-294 -294l294 -294q28 -28 28 -68z'
          s 'path#mars',
            transform: 'scale(-.009 .009) rotate(180) translate(200 -1700)'
            d: 'M1472 1408q26 0 45 -19t19 -45v-416q0 -14 -9 -23t-23 -9h-64q-14 0 -23 9t-9 23v262l-382 -383q126 -156 126 -359q0 -117 -45.5 -223.5t-123 -184t-184 -123t-223.5 -45.5t-223.5 45.5t-184 123t-123 184t-45.5 223.5t45.5 223.5t123 184t184 123t223.5 45.5 q203 0 359 -126l382 382h-261q-14 0 -23 9t-9 23v64q0 14 9 23t23 9h416zM576 0q185 0 316.5 131.5t131.5 316.5t-131.5 316.5t-316.5 131.5t-316.5 -131.5t-131.5 -316.5t131.5 -316.5t316.5 -131.5z'
          s 'path#venus',
            # 'horiz-adv-x': 1280
            transform: 'scale(-.009 .009) rotate(180) translate(200 -1700)'
            d: 'M1152 960q0 -221 -147.5 -384.5t-364.5 -187.5v-260h224q14 0 23 -9t9 -23v-64q0 -14 -9 -23t-23 -9h-224v-224q0 -14 -9 -23t-23 -9h-64q-14 0 -23 9t-9 23v224h-224q-14 0 -23 9t-9 23v64q0 14 9 23t23 9h224v260q-150 16 -271.5 103t-186 224t-52.5 292 q11 134 80.5 249t182 188t245.5 88q170 19 319 -54t236 -212t87 -306zM128 960q0 -185 131.5 -316.5t316.5 -131.5t316.5 131.5t131.5 316.5t-131.5 316.5t-316.5 131.5t-316.5 -131.5t-131.5 -316.5z'
        s \text,
          x: width - 5
          y: 35
          'font-size': 14
          'text-anchor': \end,
            panel_title
      ]

      # const voting_x = 10
      # const voting-width = 266 + 18
      # const half-voting-width = voting-width / 2
      # const voting-height = 42

      # svg_els.push s \g.voting, null, ->
      #   els = []
      #   last_y = -voting-height + 79
      #   mouseenter = !->
      #     n = this.childNodes
      #     n.0.set-attribute \fill, '#009f00'
      #     n.0.set-attribute \stroke, '#007f00'
      #     n.1.set-attribute \fill, '#fff'
      #   mouseleave = !->
      #     n = this.childNodes
      #     n.0.set-attribute \fill, '#fff'
      #     n.0.set-attribute \stroke, '#fd270d'
      #     n.1.set-attribute \fill, '#666'
      #   for o in options
      #     els.push s \g.vote-button, on: { mouseenter, mouseleave }, s: { cursor: \pointer },
      #       s \rect,
      #         rx: 8
      #         ry: 8
      #         width: voting-width
      #         height: voting-height
      #         x: voting_x
      #         y: (last_y += voting-height + 8)
      #         stroke: '#fd270d'
      #         'stroke-width': 0.5
      #         # filter: 'url(#icon-filter)'
      #         fill: '#fff'
      #       s \text,
      #         x: half-voting-width + voting_x
      #         y: last_y + voting-height - 16
      #         'font-size': 14
      #         # 'stroke-width': 0.5
      #         'text-anchor': 'middle'
      #         fill: o.fg or '#666',
      #           o.text
      #
      #   return els

      buttons_translate = value 'translate(90 10)'
      svg_els.push s \g.buttons, transform: buttons_translate, ->
        fill = (el, fill) !-> el.set-attribute \fill, fill
        btn_outline = -> s \path fill: '#9e9e9e' d: "m 109.60458,88.33043 c 0.35027,13.64453 -11.913926,25.89283 -25.554996,25.543 -19.95894,-0.0485 -39.92267,0.0978 -59.87857,-0.0744 -13.28532,-0.68659 -24.3242598,-13.1839 -23.5664298,-26.41881 0.0485,-19.64193 -0.0978,-39.28866 0.0744,-58.92754 C 1.3668042,15.17242 13.849574,4.1180363 27.085784,4.8734593 c 19.64225,0.04856 39.28929,-0.09785 58.92849,0.07451 13.41306,0.690775 24.484036,13.3929807 23.590266,26.7364807 0,18.882 0,37.76401 0,56.64601 z"
        btn = -> s \path fill: '#fff' stroke: '#DCDCDC' 'stroke-width': 1.11 'stroke-miterlimit': 10 d: "m 109.60458,84.03343 c 0.3474,13.646 -11.905866,25.91561 -25.554996,25.57 -19.95894,-0.0487 -39.92269,0.098 -59.87857,-0.0746 -13.42095,-0.6931 -24.4608098,-13.42279 -23.5664298,-26.76239 0.0485,-19.53632 -0.0977,-39.07743 0.0744,-58.6107 0.68687,-13.27967 13.1750898,-24.32167667 26.4067998,-23.56531067 19.64225,0.04851 39.28928,-0.09774 58.92849,0.07443 C 99.423754,1.3519923 110.49977,14.04536 109.60454,27.38742 c 0,18.882 0,37.76401 0,56.64601 z"
        mouseenter = !-> this.childNodes.1.set-attribute \fill, '#eee'
        mouseleave = !-> this.childNodes.1.set-attribute \fill, '#fff'

        const inc_x = 50
        start_x = -inc_x
        buttons.push b = \
        s \g.button, id: \button-percent, transform: "translate(#{start_x += inc_x} 0) scale(.3)", filter: 'url(#icon-filter)', on: {mouseenter, mouseleave, click: !-> set_panel \percent },
          btn_outline, btn
          s \path fill: '#9e9e9e' d: "m 29.75655,23.86555 c 0,-0.849 -0.414,-1.641 -1.117,-2.107 -0.707,-0.472 -1.604,-0.566 -2.377,-0.246 l -10.715,4.381 c -1.412,0.582 -2.35,1.965 -2.35,3.501 l 0,47.625 c 0,2.083 1.697,3.776 3.775,3.776 l 9.014,0 c 2.084,0 3.77,-1.693 3.77,-3.776 l 0,-53.154 z"
          s \path fill: '#9e9e9e' d: "m 53.14655,57.15555 c 0,-0.283 -0.418,-0.549 -1.119,-0.703 -0.713,-0.162 -1.604,-0.191 -2.381,-0.086 l -10.715,1.47 c -1.42,0.194 -2.346,0.655 -2.346,1.174 l 0,20.521 c 0,0.696 1.699,1.266 3.771,1.266 l 9.012,0 c 2.076,0 3.777,-0.569 3.777,-1.266 l 0,-22.376 10e-4,0 z"
          s \path fill: '#9e9e9e' d: "m 76.62555,57.15555 c 0,-0.283 -0.42,-0.549 -1.119,-0.703 -0.713,-0.162 -1.604,-0.191 -2.381,-0.086 l -10.715,1.47 c -1.42,0.194 -2.346,0.655 -2.346,1.174 l 0,20.521 c 0,0.696 1.697,1.266 3.771,1.266 l 9.01,0 c 2.078,0 3.779,-0.569 3.779,-1.266 l 0,-22.376 0.001,0 z"
          s \path fill: '#9e9e9e' d: "m 99.92055,45.33655 c 0,-0.427 -0.422,-0.822 -1.135,-1.056 -0.699,-0.239 -1.59,-0.286 -2.363,-0.124 l -10.717,2.199 c -1.426,0.291 -2.346,0.988 -2.346,1.758 l 0,30.784 c 0,1.048 1.686,1.897 3.779,1.897 l 8.998,0 c 2.088,0 3.783,-0.85 3.783,-1.897 l 0,-33.561 0.001,0 z"

        b.activate = !->
          n = this.childNodes
          fill n.0, '#f00'
          for b from 2 til n.length
            fill n[b], '#f00'

        b.deactivate = !->
          n = this.childNodes
          fill n.0, '#9e9e9e'
          for b from 2 til n.length
            fill n[b], '#9e9e9e'

        buttons.push b = \
        s \g.button id: \button-sex, transform: "translate(#{start_x += inc_x} 0) scale(.3)", filter: 'url(#icon-filter)', on: {mouseenter, mouseleave, click: !-> set_panel \sex },
          btn_outline, btn
          s \path fill: '#9e9e9e', d: "m 51.80255,69.81655 c 10.177,-4.919 14.42,-17.124 9.482,-27.254 -4.93,-10.142 -17.16,-14.375 -27.337,-9.456 -10.177,4.919 -14.42,17.112 -9.49,27.246 3.302,6.783 9.879,10.913 16.917,11.438 l 0,9.635 -7.332,0 0,4.453 7.332,0 0,7.1 4.457,0 0,-7.1 7.328,0 0,-4.453 -7.328,0 0,-9.784 c 2.022,-0.293 4.035,-0.887 5.971,-1.825 m -21.691,-12.189 c -3.412,-7.023 -0.473,-15.48 6.585,-18.889 7.046,-3.405 15.525,-0.469 18.934,6.554 3.424,7.031 0.484,15.483 -6.568,18.881 -7.043,3.416 -15.53,0.484 -18.951,-6.546"
          s \path fill: '#777777', d: "m 69.11255,35.63355 c -10.912,-2.951 -22.113,3.485 -25.027,14.37 -2.912,10.893 3.554,22.099 14.459,25.054 10.904,2.951 22.105,-3.484 25.027,-14.362 1.943,-7.283 -0.313,-14.71 -5.293,-19.72 l 10.646,-12.258 1.67,9.284 4.53,-0.816 -2.807,-15.53 -16.464,-1.262 -0.358,4.587 10.081,0.778 -10.76,12.407 c -1.723,-1.107 -3.629,-1.976 -5.704,-2.532 m 8.397,23.414 c -2.029,7.545 -9.784,12.007 -17.349,9.955 -7.55,-2.043 -12.041,-9.818 -10.013,-17.348 2.029,-7.557 9.791,-12.014 17.341,-9.966 7.558,2.043 12.048,9.813 10.021,17.359"
          s \path fill: '#9e9e9e', d: "m 51.66555,62.53055 c -0.793,0.625 -1.654,1.186 -2.604,1.644 -0.996,0.484 -2.025,0.808 -3.062,1.042 1.095,1.962 2.543,3.697 4.229,5.216 0.526,-0.202 1.057,-0.366 1.574,-0.616 1.557,-0.751 2.922,-1.722 4.188,-2.78 -1.77,-1.189 -3.257,-2.713 -4.325,-4.506 z"

        b.activate = !->
          unless set_planets! => load_data!
          n = this.childNodes
          fill n.0, '#f00'
          fill n.2, SEX_COLOR.0
          fill n.3, SEX_COLOR.1
          fill n.4, SEX_COLOR.0

        b.deactivate = !->
          n = this.childNodes
          fill n.0, '#9e9e9e'
          fill n.2, '#9e9e9e'
          fill n.3, '#777'
          fill n.4, '#9e9e9e'

        buttons.push b = \
        s \g.button id: \button-age, transform: "translate(#{start_x += inc_x} 0) scale(.3)", filter: 'url(#icon-filter)', on: {mouseenter, mouseleave, click: !-> set_panel \age },
          btn_outline, btn
          s \path fill: '#848484' d: "m 66.08055,41.38055 9.87,-13.583 c -9.511,-6.755 -22.289,-8.317 -33.585,-2.969 -0.949,0.452 -1.865,0.945 -2.753,1.472 l 8.706,14.326 c 0.396,-0.232 0.807,-0.453 1.229,-0.652 5.555,-2.632 11.838,-1.885 16.533,1.406"
          s \path fill: '#9e9e9e' d: "m 72.22055,60.15755 15.892,5.674 c 2.751,-7.956 2.52,-16.95 -1.371,-25.159 -2.43,-5.126 -6.002,-9.343 -10.265,-12.499 l -9.873,13.59 c 2.033,1.544 3.735,3.586 4.901,6.049 1.91,4.025 2.041,8.434 0.716,12.345"
          s \path fill: '#777777' d: "m 44.79155,66.37255 -12.353,11.471 c 9.644,10.186 25.094,13.53 38.459,7.197 8.208,-3.887 14.089,-10.7 16.995,-18.6 l -15.893,-5.674 c -1.465,3.824 -4.342,7.112 -8.335,9.004 -6.539,3.101 -14.09,1.512 -18.873,-3.398"
          s \path fill: '#9e9e9e' d: "m 26.67155,69.48955 c 1.426,2.941 3.229,5.579 5.326,7.879 l 12.352,-11.469 c -0.959,-1.068 -1.791,-2.277 -2.467,-3.618 l -15.211,7.208 z"
          s \path fill: '#777777' d: "m 47.76455,40.96255 -8.704,-14.326 c -14.133,8.755 -19.789,26.854 -12.667,42.267 l 15.208,-7.203 c -3.437,-7.557 -0.698,-16.388 6.163,-20.738"

        b.activate = !->
          unless set_ranges! => load_data!
          n = this.childNodes
          fill n.0, '#f00'
          for b from 2 til n.length
            fill n[b], COLORS[b - 2] #'#f00'

        b.deactivate = !->
          n = this.childNodes
          fill n.0, '#9e9e9e'
          for b from 2 til n.length
            fill n[b], COLORS_GREY[b - 2] #'#f00'

        buttons.push b = \
        s \g.button id: \button-province, transform: "translate(#{start_x += inc_x} 0) scale(.3)", filter: 'url(#icon-filter)', on: {mouseenter, mouseleave, click: !-> set_panel \province },
          btn_outline, btn
          s \path 'fill-rule': 'evenodd' 'clip-rule': 'evenodd' fill: '#9e9e9e' d: "m 20.410204,40.6036 1.012,-0.0288 0.973,0.0447 c 4.12528,1.96313 10.49231,-0.79998 13.00025,3.1975 -3.75483,3.55406 -3.15318,8.74609 -3.97934,13.43264 -2.98391,1.46068 -3.63363,2.5558 -1.80291,5.42486 1.15762,5.15787 -1.44381,10.10712 -1.72119,15.0667 6.14291,0.36323 6.9339,7.76478 11.64307,10.27417 4.59816,-2.72757 9.34649,-7.69779 15.45205,-5.28779 6.62192,1.03274 9.64427,-6.56224 15.27907,-8.28208 -0.43502,-4.25576 5.99511,-7.08049 4.48316,-11.67727 -4.97008,-4.62945 2.15492,-9.47093 3.96997,-13.93888 3.04977,-5.12966 10.31587,-4.6283 13.20462,-10.08935 2.12211,-6.56145 -4.89634,-3.85209 -8.49437,-4.35677 -4.70381,-4.34804 -10.19423,0.86702 -15.31838,-2.43473 -6.43343,-3.51374 -13.82916,-3.87205 -20.99827,-3.68436 -8.56788,0.66582 -16.77729,-2.66892 -25.30309,-2.32869 -8.26787,0.86583 -0.17691,10.09371 -1.39964,14.66805 z"

        b.activate = !->
          n = this.childNodes
          fill n.0, '#f00'
          fill n.2, '#d00'
          unless stats = set_province_stats!
            xhr url: "#{API_ROOT}/#{config.type}-location-stats?_id=#{id}", (err, res) !->
              if err => return console.error "error processing...", err
              set_province_stats res.data

        b.deactivate = !->
          n = this.childNodes
          fill n.0, '#9e9e9e'
          fill n.2, '#9e9e9e'

        buttons_translate "translate(#{(30 + (width / 2) - buttons.length * 33) } 10)"
        return buttons



      svg_els.push panels.0 = s \g.percent-stats, transform: "translate(0 #{bottom_panel_y})", ->
        percent-stats_els = []
        each options, (o, i) !->
          v = null
          last_y += option_height
          percent-stats_els.push [
            * icons[i] =\
              s \g.icon, transform: "translate(#{icon_padding} #{last_y + 6})",
                s \rect,
                  stroke: '#ccc'
                  fill: '#fff'
                  'stroke-width': 1
                  filter: 'url(#icon-filter)'
                  width: icon_size
                  height: icon_size
                  rx: bar_rounding
                  ry: bar_rounding
            * s \text.option-text,
                'font-size': 12
                x: bar_x
                y: last_y,
                  o.text
            * s \rect.bar-shadow,
                width: width - bar_x
                height: bar_height
                x: bar_x
                y: last_y + 10
                fill: o.bg || bg
                rx: bar_rounding
                ry: bar_rounding
            * s \rect.bar,
                width: (v_bar_width[i] := value 0)
                height: bar_height
                x: bar_x
                y: last_y + 10
                fill: (v_bar_fill[i] := value o.fg || fg)
                # stroke: bar_stroke
                # 'stroke-width': bar_stroke-width
                rx: bar_rounding
                ry: bar_rounding
            * s \text.bar-label,
                'text-anchor': 'middle'
                fill: (v_label_fill[i] := value if v => '#fff' else '#333')
                x: (v_label_x[i] := value bar_x)
                y: last_y + 25,
                  v_label[i] := value ''
            * s \text.total,
                'text-anchor': 'end'
                y: last_y
                x: width - 5,
                  (v_totals[i] := value '-')
          ]

          (v_icon[i] := value o.icon) (ico) !->
            icon = icons[i]
            icon.style.display = if ico => '' else 'none'
            if ico
              ic = CL icon
              unless ic.contains ico
                ic.add ico
                # clear previous icon use xlink:hrefs
                while icon.childNodes.length > 1 => icon.removeChild icon.childNodes.1
                # then, add appropriate icon graphics
                switch ico
                | \mas-mas =>
                  icon.appendChild s \use fill: (o.fg || '#fcc'), 'xlink:href': '#check', transform: 'translate(8 0)'
                  icon.appendChild s \use fill: (o.fg || '#fcc'), 'xlink:href': '#check', transform: 'translate(8 10)'
                | \mas =>
                  icon.appendChild s \use fill: (o.fg || '#fcc'), 'xlink:href': '#check', transform: 'translate(8 5)'
                | \woa =>
                  icon.appendChild s \use fill: (o.fg || '#fcc'), 'xlink:href': '#xx', transform: 'translate(7 5)'
                | \woa-woa =>
                  icon.appendChild s \use fill: (o.fg || '#fcc'), 'xlink:href': '#xx', transform: 'translate(7 -1)'
                  icon.appendChild s \use fill: (o.fg || '#fcc'), 'xlink:href': '#xx', transform: 'translate(7 11)'
                | \star =>
                  icon.appendChild s \use fill: (o.fg || '#fcc'), 'xlink:href': '#star', transform: 'translate(7 5)'
                | otherwise =>
                  console.error "unknown icon: #{ico}"


        set_totals (totals) !->
          unless totals => return
          sum = max = 0
          for v in totals
            max = v if v > max
            sum += v
          for v, i in totals
            px = if max > 0 => v / max * bar_max_px else 0
            bar_percent = px / bar_max_px
            v_bar_width[i] px
            v_totals[i] v
            v_bar_fill[i] if winning_fg and v is max => winning_fg else options[i].fg or fg
            v_label[i] "#{Math.round v / sum * 100}%"
            v_label_x[i] if bar_percent > 0.07 => 0 + bar_x + (px / 2) else 15 + bar_x + px
            v_label_fill[i] if bar_percent > 0.07 => '#fff' else '#000'
            v_icon[i] if winning_icon and v is max => winning_icon else options[i].icon

        return percent-stats_els
      # end g.percent-stats

      svg_els.push panels.1 = s \g.sex-stats, transform: "translate(#{(width - 300) / 2 } #{bottom_panel_y + (((option_height * len) - 110) / 2)})", ->
        const start_angle = 45
        const num_planets = 2
        const gauge-size = 110
        const half-gauge = gauge-size / 2
        const gauge-padding = (sex-stats-width - (gauge-size * 2)) / 4


        gauge = (options = {}) ->
          x = options.x || 0
          y = options.y || 0
          fg = options.fg || '#000'
          bg = options.bg || '#ddd'

          const mid_x = x + half-gauge
          const mid_y = y + half-gauge

          els =
            * s \path.gauge-empty, fill: bg
            * s \path.gauge, fill: fg#, filter: 'url(#icon-filter)'
            * s \path.gauge-empty, fill: bg

          if start_angle
            for e in els
              e.set-attribute \transform, "rotate(#{start_angle} #{mid_x} #{mid_y})"

          if options.count
            els.push \
              s \text.count, fill: fg, 'text-anchor': 'middle', 'font-size': 20, x: mid_x, y: mid_y + 10,
                options.count

          # TODO: icon
          if options.text
            els.push \
              s \text.name, x: mid_x, y: y + gauge-size + 20, fill: fg, 'text-anchor': 'middle', 'font-size': 20,
                options.text

          if options.icon
            els.push \
              ico = s \use fill: fg, 'xlink:href': '#'+options.icon, transform: "translate(#{x - 15} #{y + gauge-size - 10}) scale(1.5)"#, opacity: '.3'
            set-timeout ->
              bbox = ico.getBBox!
              ico.set-attribute \transform, "translate(#{x - 2 + half-gauge - (bbox.width / 2)} #{y + 20}) scale(1.5)"
            , 0


          if options.angles
            options.angles (a) !->
              els.0.style.display = if a.0 >= 360 => 'none' else ''
              els.0.setAttribute \d, describe-cone-section mid_x, mid_y, half-gauge - 11, half-gauge - 9, 0, a.0
              els.0.setAttribute \angle, "0 -> #{a.0}"
              els.1.setAttribute \d, describe-cone-section mid_x, mid_y, half-gauge - 15, half-gauge - 5, a.0, a.1
              els.1.setAttribute \angle, "#{a.0} -> #{a.1}"
              els.2.style.display = if a.2 >= 360 => 'none' else ''
              els.2.setAttribute \d, describe-cone-section mid_x, mid_y, half-gauge - 11, half-gauge - 9, a.2, 360
              els.2.setAttribute \angle, "#{a.2} -> 360"
          return els
          #/function gauge

        angles =
          * value [0,0,0]
          * value [0,0,0]
        counts =
          * value 0
          * value 0
        gauges =
          * gauge angles: angles.0, count: counts.0, text: "Mujeres", fg: SEX_COLOR.0, bg: '#ddd', icon: \venus, x: gauge-padding
          * gauge angles: angles.1, count: counts.1, text: "Hombres", fg: SEX_COLOR.1, bg: '#ddd', icon: \mars, x: sex-stats-width - gauge-padding - gauge-size

        set_planets (planets) !->
          unless planets => return
          sum = prev = 0
          for v in planets => sum += v
          for v, i in planets
            els = gauges[i]
            deg = if sum => v / sum * 360 else 0
            # console.log 'planets.'+i, v, '/', sum, '->', deg
            angles[i] ([prev, prev += deg, prev])
            counts[i] v

        return gauges
      # end g.sex-stats

      svg_els.push panels.2 = s \g.age-stats, transform: "translate(#{(width - 300) / 2 } #{bottom_panel_y + (((option_height * len) - 120) / 2)})", ->
        const legend-width = 100
        const graphic-width = if movil => 100 else 130
        const legend-padding-vert = 5
        const legend-padding-horiz = 10
        const half-legend-width = legend-width / 2
        const legend-height = 20
        const mid = graphic-width / 2
        const r1 = mid - (if movil => 30 else 40)
        const r2 = mid - 5
        const text-width = 10 * 4 # 12px font-size (estimated 10px each) * max 4 digits ("100%") = 40
        const mid_x = legend-width + (legend-padding-horiz * 3) + text-width + mid
        const mid_y = mid + 10

        ages = AGES ++ '<'
        els = []
        last_y = 15
        var pr, r
        each ages, (age, i) !->
          pr := r if i > 0
          r := age
          label = (if r is '<' => "> #{pr}" else (if pr => "#{pr}-" else '< ') + r) + ' años'

          els.push s \rect,
            rx: 3
            ry: 3
            width: legend-width
            height: legend-height
            x: legend-padding-horiz
            y: last_y
            # stroke: '#e3e3e3'
            # 'stroke-width': 0.5
            # filter: 'url(#icon-filter)'
            fill: COLORS[i]

          els.push s \text,
            x: legend-padding-horiz + half-legend-width
            y: last_y + legend-height - 4
            'font-size': legend-height - 4
            'text-anchor': 'middle'
            fill: '#fff',
              label

          els.push s \text,
            'font-size': legend-height - 4
            x: legend-padding-horiz + legend-width + 10
            y: last_y + legend-height - 4,
              (v_rval[i] := value 0)
          last_y += legend-height + legend-padding-vert

          els.push v_rval_graph[i] = s \path.gauge,
            title: label
            'font-size': 12
            fill: COLORS[i]
            # filter: 'url(#icon-filter)'
            stroke: config.stroke || '#fff'
            'stroke-width': 1
            'stroke-linecap': \square,
              (el) !-> floating-tip el, -> label + ': ' + v_rval[i]!

        set_ranges (ranges) !->
          unless ranges => return
          total = prev = 0

          for v in ranges => total += v
          for v, i in ranges
            percent = if total > 0 => v / total else 0
            deg = percent * 360
            v_rval_graph[i].set-attribute \d, (describe-cone-section mid_x, mid_y, r1, r2, prev, prev += deg)
            v_rval[i] "#{Math.round percent * 100}%"
        return els
      # end g.age-stats

      svg_els.push panels.3 = s \g.province-stats, transform: "translate(0 #{bottom_panel_y})", ->
        var stats, total
        const COLORS = config.map_colors || <[#ff0000 #dd0000 #bb0000 #990000 #770000]>

        provinces = {
          M: s \path.province d: 'm 315.34375,118 c -3.02078,1.46275 -4.6838,3.67662 -6.71875,6.25 -2.57897,1.26529 -6.01761,2.41259 -5.28125,5.75 -0.64116,2.97979 -1.5937,3.63778 -4.09375,3.34375 -1.02416,1.9381 -4.25958,4.73661 -2.625,6.5 -4.62402,0.76984 -2.91882,-1.22604 -5.03125,2.625 0.23834,2.11213 -0.54324,4.75643 -0.5,5.78125 -3.40052,-1.23616 -3.21324,2.43183 -4.3125,3.59375 -3.03323,-1.54056 -1.27023,-0.14637 -2.65625,2.15625 -1.19523,2.22024 0.17105,3.46964 2.40625,1.4375 1.92145,0.72752 3.14846,-5.36536 3.84375,-2.15625 -0.0119,3.54551 2.78928,2.72308 3.84375,0.46875 0.98487,-0.15315 2.06417,-1.36682 2.65625,1.21875 2.5249,-0.63733 3.23451,-0.53532 4.78125,1.4375 1.32651,0.99579 2.40784,0.0982 4.3125,1.65625 1.66554,0.2142 3.81971,1.89512 5.78125,1.46875 2.79796,1.82484 1.37637,2.98997 -0.5,4.78125 -1.80606,-0.0855 -1.68904,2.04454 -1.90625,2.15625 -1.21743,0.40977 -0.36421,0.39303 -2.15625,0.5 -1.15727,0.96504 -3.66996,1.11884 -0.25,2.625 1.79845,-2.47205 5.43824,-2.78283 6.25,-4.3125 1.41111,-0.73054 4.76095,-2.53255 4.0625,-2.15625 1.90966,0.32396 2.91428,1.14577 3.84375,-1.21875 2.41158,1.20102 3.60627,1.78459 5.53125,-0.21875 0.3172,0.60765 3.93106,1.53153 4.0625,-0.96875 -2.19979,-1.67286 -0.18364,-1.51335 -0.9375,-3.125 -0.0905,-0.76424 -0.045,-6.10166 -2.40625,-2.875 -2.15225,2.2792 -0.18232,-3.01705 0.46875,-4.09375 0.36773,-1.36488 0.32367,-3.43182 -1.6875,-3.59375 1.45545,-3.74555 -2.85284,-3.08122 -2.625,-4.3125 -1.38408,-1.28994 -2.67066,-3.08004 -1.90625,-3.375 -1.10758,-2.46607 -1.38606,-1.70058 -2.90625,-1.4375 -1.23093,-1.55451 1.47684,-3.41907 -1.1875,-4.5625 -1.10494,-0.66918 0.74252,-2.92546 1.1875,-4.0625 -0.91951,-0.55762 0.7131,-2.97388 1.4375,-4.8125 -1.90526,-1.72251 -0.11018,-3.26668 -2.875,-3.84375 -0.0398,-1.43798 -1.44831,-1.99356 -1.90625,-2.625 z m -22.8125,19.4375 c -3.57944,2.10278 3.88591,0.94813 0,0 z m 28.3125,1.6875 c 0.938,0.61345 -0.93503,1.30241 0,0 z'
          SG: s \path.province d: 'm 315.81928,101.4335 c 0.16137,3.15546 4.32783,0.64991 3.83991,4.08029 2.30796,0.54671 2.78508,0.35009 2.15995,2.8802 -0.11046,2.19315 5.77981,2.79408 3.11993,5.04034 -0.7691,1.13889 -2.30489,0.65286 -4.55989,0.96007 -0.70523,-1.19748 -0.29394,2.49127 -2.39995,2.8802 -1.72907,0.78552 -5.3764,1.00836 -6.47985,4.08028 -2.17983,0.54992 -3.07761,4.62256 -6.23986,4.32029 -2.6013,1.62501 -1.80403,6.22368 -3.35992,7.44052 -3.14854,-0.84422 -3.38063,1.96502 -5.27988,3.84026 -3.83751,-1.22812 -4.61986,2.86377 -7.91981,2.16014 0.25413,-3.49988 -1.55038,-5.60812 -2.39995,-8.16055 -2.59093,1.25642 -0.4724,-1.57362 -1.67996,-2.64019 0.12912,-2.47559 -1.94662,-3.89282 -3.35992,-6.00041 -2.17465,-0.65847 -1.666,-3.09783 -0.95998,-5.04034 3.83963,0.80429 0.32869,-1.81667 3.35992,-3.60025 0.0326,-1.66863 0.48919,-2.91517 2.87994,-1.4401 1.83299,1.3e-4 -0.3689,-2.86417 -0.47999,-4.32031 2.81699,-0.6433 4.206,-1.67568 7.43983,-1.92013 1.76685,-0.0802 6.44155,-1.25284 8.15981,-2.40016 0.37693,-1.48176 1.62842,-3.982455 3.83991,-0.72005 0.96865,1.47854 3.39097,3.64161 2.39994,0.48003 1.55004,-1.67364 1.04659,5.71897 2.15995,1.68013 0.10663,-2.53844 3.61883,-3.70854 4.79989,-3.60026 0.10338,-0.0524 0.90751,-0.52268 0.95998,0 z'
          SA: s \path.province d: 'm 262.30052,116.31453 c 2.26245,-1.88794 1.97456,2.40889 3.35992,0.72005 3.11962,1.09368 -0.18647,3.52955 1.43996,5.52037 2.90779,0.63716 -0.94636,4.05009 0.47999,4.3203 0.1382,0.87983 -2.41814,2.74829 -1.67996,4.56032 -1.91004,3.20369 -5.31842,4.11409 -6.95984,6.00041 0.67646,1.95731 -1.64482,3.20355 -3.59991,3.12021 -0.74525,-0.9388 -1.71767,3.21616 1.91995,0.72006 0.0407,1.85445 -0.83708,4.5106 -2.63994,4.5603 0.0635,3.25259 -2.16425,-1.27302 -1.67996,-1.20007 -2.89679,0.59577 -4.23044,2.96663 -3.59992,5.28036 -2.4151,3.67992 -3.35874,1.67182 -4.0799,-0.24003 -1.81566,-0.3846 -2.43509,3.41999 -4.5599,2.16016 -1.01118,-1.16487 -3.04671,-4.1594 -3.59991,-3.36023 0.68749,-1.17094 -0.044,-1.15881 -1.19998,-2.40016 -0.32108,-0.2917 -1.86918,-2.23224 -3.59991,-2.40017 -1.50502,0.6746 -3.62394,3.03111 -5.27988,3.1202 -1.97648,1.75432 -5.04455,2.23251 -5.51987,5.04036 -2.90523,0.83146 -3.47504,0.1817 -5.27988,0.72004 -1.29185,1.33501 -5.24974,-1.12379 -2.15995,-3.1202 3.85326,-0.92083 -2.87416,-4.36004 0.47999,-6.72047 2.04919,-2.80959 -2.33853,-3.00992 0.93975,-6.43999 -0.67057,-3.01793 -0.86106,-4.60126 -0.45976,-7.961 2.08694,0.14306 -1.24156,-2.11315 -0.95998,-4.08027 -3.1348,-3.33846 -1.40531,-3.22272 1.67996,-3.84027 2.34351,-1.88697 1.18397,-4.18602 3.59992,-5.52038 -0.0183,-1.4611 3.17508,-3.22783 4.0799,-2.16015 2.71931,-1.04647 2.00135,-2.17694 4.79989,-1.4401 3.17751,-0.14649 5.49836,2.77226 8.6398,3.84027 2.09433,-1.97941 3.55845,0.19893 3.83991,1.92013 1.00996,-1.85294 1.62636,1.48164 2.63994,-0.72005 -1.15216,-5.00206 4.06941,-0.15122 6.47985,-2.40016 2.42519,0.2051 4.51449,1.5338 6.71985,2.40016 -1.12066,2.96264 3.062,-2.50424 2.87993,1.92012 1.95066,0.40438 3.21278,1.61807 2.87994,-1.92012 z'
          AV: s \path.province d: 'm 267.3404,118.47468 c 1.69838,0.22269 4.2582,-1.78027 5.27988,0 2.42555,1.59465 3.57854,2.74286 5.03988,0 4.10636,-1.4209 0.34791,3.79807 4.07991,4.3203 1.27213,2.18375 3.48063,3.83766 2.87993,6.24042 0.70396,1.85799 0.27736,1.84771 2.15995,2.8802 0.58429,2.22075 2.30714,4.12559 1.91996,7.20049 2.82023,0.0644 4.71504,-0.63498 5.27987,-2.16014 3.3903,-1.43651 2.01857,3.8481 2.15996,3.1202 -4.43151,-0.10965 -2.36911,-0.9009 -4.5599,2.64019 0.1517,2.23032 -0.24842,4.09958 -0.47999,4.80033 1.15218,1.38198 -4.86038,-0.001 -3.59992,3.36024 -0.27409,3.01064 -3.7705,-1.78804 -2.63993,1.20007 -0.92609,1.81122 -0.19831,3.66851 -2.63994,4.56032 -2.6569,0.88979 -2.11993,-3.16114 -2.87994,-3.12022 -1.79013,0.2474 -3.65297,0.11252 -3.35992,1.92013 -2.03082,1.12766 -3.38067,2.65588 -4.3199,4.08029 -2.0772,1.2896 -1.88647,-2.92713 -3.83991,-0.72006 -1.32368,1.7393 -3.59543,2.98135 -5.27988,0.96007 -4.12791,1.32222 -3.79857,-4.87185 -3.11993,-6.24043 -3.06481,0.30551 -4.76285,4.40425 -8.15981,1.4401 0.82223,-2.1023 -4.99834,-2.29961 -2.87993,-4.3203 2.25534,-1.442 -0.30472,-4.49652 3.11992,-5.52037 2.83792,-2.27959 0.75837,3.34807 3.35993,1.20007 -0.004,-1.09881 2.31546,-1.09733 2.15995,-3.60024 2.37602,-3.32399 -4.63577,1.21296 -2.15995,-1.92013 -0.16481,-1.05066 2.658,0.31038 3.35992,-1.20009 1.32868,-1.03733 0.73751,-3.28726 2.15995,-3.60025 3.10527,-1.11148 5.99559,-4.25005 5.75987,-6.72046 1.5999,-1.70079 1.35704,-2.1552 1.19997,-3.60024 2.6509,-1.64908 -1.06271,-3.04762 -0.71998,-5.04035 -0.24385,-1.17644 1.58645,-0.52638 0.71998,-2.16014 z'
          CC: s \path.province d: 'm 212.62166,151.59694 c 1.85463,1.69005 2.72705,1.59486 4.79989,0.24003 0.0427,1.43868 4.27039,0.40564 4.79989,-1.20009 0.49764,-2.67819 4.65212,-2.83981 6.23986,-4.08027 1.02168,-1.73612 3.51368,-2.74991 5.03988,-2.64019 1.63781,1.454 2.15728,1.90033 3.35992,2.88019 1.86057,0.84742 -2.09456,2.45021 1.67996,2.8802 0.34645,1.65282 3.96336,4.17116 4.79989,0.72006 2.69947,-1.90451 2.06926,0.87702 3.59992,1.92013 2.18081,-1.46882 4.09646,2.24319 5.03988,2.8802 3.30253,2.77428 4.59231,-2.11543 7.91982,-1.68012 -2.30902,1.87539 0.43353,5.06893 -0.71998,6.24043 0.11221,3.17477 -1.27512,6.58557 -1.43997,9.36064 3.59997,-1.54567 3.59933,1.23782 2.39995,3.60026 0.0965,4.10504 4.21468,-2.29845 4.79988,0.72003 -0.17066,1.51289 1.14028,3.99098 -0.71998,6.00043 -2.42821,1.06929 4.5804,7.33821 3.59992,5.52037 1.6311,2.48035 4.5957,4.34539 1.19997,5.04035 -3.29859,-2.95755 -3.51652,4.21491 -8.08144,1.87115 -4.29264,-2.41137 -0.62503,5.96393 -4.87826,6.2894 -2.22491,-0.15884 -2.73608,-2.91631 -4.5599,-2.16014 -2.53319,0.92307 1.01283,3.29544 -1.43996,4.3203 -3.16164,1.50274 -5.42314,-3.67378 -8.15981,-0.48003 -2.19915,8.2e-4 -2.70053,0.61651 -4.3199,1.4401 0.78985,-4.30048 -2.44099,-1.35665 -3.83992,0.96006 -0.93009,-0.86531 -5.27731,-1.7877 -5.51987,-4.08029 0.43298,-3.29518 -2.66759,-0.58942 -4.55989,-1.6801 -3.40064,-0.23903 -3.18068,0.93547 -5.51988,-1.20009 -1.74981,1.4407 -6.8875,-0.14677 -4.55989,-2.8802 2.23552,-1.8399 -0.21166,-5.23578 -2.15995,-5.28036 -1.97716,1.15888 -7.13422,-4.33067 -5.75987,-0.48003 2.19052,0.43783 -2.02603,5.77267 -1.91995,1.4401 3.53979,-0.95188 -3.43332,-1.81801 -2.15995,1.4401 1.72898,0.1248 -3.29939,3.73716 -3.59992,-0.24003 -2.80707,-1.39682 1.61604,-5.6628 -1.67996,-6.48043 -1.64592,-0.17739 -0.77329,-2.08417 -3.11993,-2.8802 -0.46523,-1.29045 -2.8707,-3.42509 -2.39995,-5.04036 3.68874,1.27272 6.94809,1.2883 10.31977,0.72006 2.88093,1.35639 7.48467,0.16817 6.71984,-3.12022 0.2186,-2.60835 0.77421,-3.05229 2.87993,-4.5603 0.0281,-1.61423 0.52619,-3.88628 1.67997,-6.00042 -1.20785,-1.23406 -2.10384,-4.82672 -4.07991,-4.32029 -0.96015,-0.6008 -0.89643,-5.41995 1.43997,-5.04036 0.34214,-1.17167 2.55446,0.18572 2.87993,-0.96007 z'
          TO: s \path.province d: 'm 259.90057,159.5175 c 2.8823,-0.23593 4.21794,2.045 5.99986,0.96006 1.2445,-1.34208 4.17939,-4.08685 4.07991,-0.48003 3.02502,-0.41606 2.72726,-3.32975 5.51987,-4.08029 0.71763,-1.91397 1.21839,-2.29073 3.35992,-2.40016 1.81536,-0.91184 0.20673,4.08688 2.87994,2.88019 2.2993,-0.39822 3.38744,0.46032 5.99986,-1.20007 0.61644,-0.78723 2.76447,-5.44866 2.63994,-1.4401 0.37213,3.20495 2.81722,1.95232 3.83991,0 1.01925,-0.18967 2.05585,-1.36827 2.63994,1.20008 2.55327,-0.60765 3.22739,-0.55378 4.79989,1.44009 1.29431,0.99729 2.4371,0.1354 4.3199,1.68013 1.69496,0.17682 3.7821,1.906 5.75987,1.4401 2.81525,1.79649 1.38744,3.01108 -0.47999,4.80032 -1.81146,-0.0815 -1.73996,2.06037 -1.91996,2.16016 -1.20571,0.3474 -0.38367,0.44072 -2.15995,0.48003 -0.73878,0.8345 -3.54089,1.28648 -1.19997,1.92013 1.95683,0.5147 5.92184,-2.37937 6.71984,-3.60025 1.25924,-0.41359 4.41838,-3.01459 4.07991,-2.16014 0.85902,-0.11416 2.38878,0.95808 3.83991,0 0.2976,-3.19855 3.14512,1.49638 4.07991,-0.48005 1.66607,0.18946 3.15075,-2.7851 2.39994,1.4401 1.41812,1.33877 3.11551,2.95931 1.67996,5.28037 0.1275,1.3867 2.91751,4.01892 3.36927,6.27781 1.41218,2.69536 3.72131,3.86765 2.63059,6.92309 -0.34882,1.77703 -0.4413,6.46524 -3.11992,4.56032 -2.98353,-0.47842 -6.60014,-2.71446 -8.8798,0.24001 0.56771,3.21149 -4.9453,0.0506 -5.51987,4.32031 -2.61389,2.7795 -5.46129,0.78162 -7.91982,2.64017 -2.51821,-1.49414 -4.79829,2.04014 -7.43983,-1.20007 1.57072,-3.36469 -5.60031,-1.90804 -4.55989,-2.16015 -1.91264,0.31068 1.26678,-4.21415 0.47999,-4.08029 1.95094,-0.25091 1.54491,-2.73144 1.91995,-4.80033 -4.42435,-1.05334 -3.38059,2.93381 -6.71984,3.84026 -2.46957,0.92368 -6.45837,-3.88344 -6.47985,0 -1.81711,-1.34205 -0.60597,-4.32007 -1.91996,-2.8802 -1.36531,0.32001 -1.75106,3.58114 -4.3199,3.60026 -4.74263,2.54418 -1.91006,0.68264 -3.11993,-2.40016 -2.63118,-3.16786 -4.97492,-0.28207 -5.27988,3.1202 -0.82829,4.36439 -3.14979,-2.95977 -4.79989,-2.40016 -1.96584,-2.47815 -4.84945,-4.13382 -2.39994,-6.72047 1.42964,-2.00906 0.0156,-3.9822 -0.23999,-5.76039 -1.78314,1.52055 -5.51912,2.62732 -4.07991,-1.4401 3.28504,-3.39982 -4.16353,-0.6696 -2.67832,-3.40833 2.14832,-2.35086 -0.13985,-6.53177 2.19833,-8.11245 z'
          CR: s \path.province d: 'm 296.125,182.09375 c -0.16941,5.96217 -6.70528,3.24336 -9.09375,2.15625 -1.94293,3.57488 -0.65938,-1.89784 -2.40625,-1.6875 -0.40398,1.31121 -1.93028,1.8236 -2.875,4.0625 -3.59665,-0.89153 -1.2543,4.44388 -3.84375,5.0625 -2.24121,2.0174 2.67585,5.68892 2.15625,6.71875 -3.20752,-3.0759 -7.35541,-0.26945 -6.25,3.34375 3.09508,3.75919 -4.2065,-0.69956 -2.89593,1.89424 -0.7782,4.34046 5.05425,2.00488 3.14593,5.54326 -1.54398,-0.0703 -3.96782,1.34945 -3.84375,4.09375 -1.45684,2.95898 -3.29803,2.54601 0,4.3125 3.91361,-1.34863 1.89899,2.87854 4.5625,3.59375 3.03082,0.70457 4.03644,1.94966 6.25,3.625 1.54815,1.32314 3.95745,2.05975 5.28125,4.5625 2.09505,0.28223 4.64933,2.75409 5.5,1.90625 -0.26034,-3.84451 5.75214,0.0651 7.6875,-0.71875 2.89261,0.63457 6.26367,0.65858 7.1875,-1.90625 3.07418,0.22975 6.97238,2.07019 8.15625,-0.71875 0.71175,2.84759 5.72462,1.80313 5.53125,-0.96875 2.77569,-1.54421 7.0641,3.45692 9.84375,-0.5 2.60326,5.49883 1.60093,-0.37201 4.8125,0.5 1.74709,1.03079 2.52216,-1.19574 3.59375,-1.21875 1.53894,-1.06133 1.36942,-2.32357 1.4375,-5.03125 1.74291,1.40665 5.64852,-4.69611 2.15625,-6 -3.32276,-0.71942 -1.11024,-5.93141 -5.03125,-5.75 -3.2389,-1.77898 2.37417,-4.14952 1.1875,-6.71875 -3.69174,-3.30832 5.62693,-6.70579 1.4375,-10.34375 -0.13389,-5.06613 -2.01237,0.49552 -3.84375,-0.71875 0.24381,-1.18766 0.0164,-2.4972 -0.9375,-3.8125 -0.96872,-1.4021 -2.8728,1.26296 -5.0625,-0.25 -1.73279,-2.33476 -7.58956,-1.68928 -7.4375,1.4375 -2.2847,0.0809 -5.31623,1.75884 -6.9375,4.5625 -2.64609,0.0974 -4.20909,0.23737 -6.5,1.1875 -1.99044,-1.28729 -5.62938,1.98112 -6.96875,-1.4375 0.3353,-3.33285 -4.23352,-1.05148 -5.03125,-2.15625 -1.42514,0.56584 -0.20974,-5.22833 1.6875,-3.84375 -0.32385,-1.27409 2.696,-4.67 -0.25,-4.5625 -0.94454,0.49981 -1.64073,0.25022 -2.40625,-0.21875 z m 36,47.03125 c -0.34344,0.46129 0.82915,0.26011 0,0 z m -58.0625,-46.5625 c -2.41174,2.34613 -3.8784,9.29843 0.71875,6.71875 3.00358,-0.43 2.61018,-1.74436 2.875,-4.09375 -0.56571,-1.41235 -2.15836,-2.00087 -3.59375,-2.625 z'
          BA: s \path.province d: 'm 279.58012,186.87937 c 1.11412,2.45814 -2.24944,4.66081 -2.10454,6.50517 -0.0939,2.18473 5.35516,6.44958 0.90456,4.05556 -3.27034,-2.00077 -6.48645,3.14705 -3.59991,5.04034 -0.31151,3.23166 -5.38531,-2.49559 -3.83991,1.92013 0.25377,3.59198 5.3585,1.58517 2.87993,5.28036 -4.41285,-1.59063 -2.53174,6.78865 -6.23986,6.24043 -1.86073,1.3826 -5.56196,-1.31568 -3.83991,1.92013 -1.48303,0.52128 -1.47803,0.6179 -3.59991,2.40017 -0.92712,2.30327 -3.35252,0.14448 -3.35993,2.16015 -0.40608,0.98925 -2.37394,2.36846 -4.0799,4.08029 -1.13799,-1.19904 -3.65469,2.61841 -1.67996,3.60024 -1.44109,2.33497 2.5182,4.22149 0.23999,7.68052 -0.5884,1.4996 -4.25616,2.14646 -5.75987,3.36023 -1.5584,-0.98352 0.9756,-3.8193 1.19997,-2.88019 0.14766,-2.53423 -3.40065,-0.79311 -4.3199,-0.72004 -1.04014,-0.1906 -4.37085,2.38146 -2.87993,3.84026 -0.79515,2.16021 -2.32686,3.98417 -4.79989,3.1202 -2.2974,-0.15075 -3.60236,2.89371 -5.03988,1.20009 -1.88782,-0.32511 -4.86291,-1.10734 -4.79989,-3.84026 -3.24195,-1.24037 -2.50577,1.03456 -4.07991,1.68011 -1.66179,-1.88631 -3.48466,0.681 -3.35992,-2.8802 -1.51681,-1.85338 -3.93944,-0.47234 -5.03988,-1.20007 -1.69163,-0.0508 -1.00792,-1.83871 -1.43997,-3.36023 -3.95123,-0.59035 -4.50222,-2.71219 -7.43983,-0.48004 -1.34541,1.40663 -3.22689,-1.50167 -3.11993,-3.60025 -2.17504,-1.70173 -3.97571,-7.00347 -5.51987,-7.2005 2.10251,-1.7688 -0.79642,-1.74543 1.43997,-4.56031 1.98844,-1.82663 0.26849,-3.84573 1.43996,-6.48044 2.06241,-1.96548 4.8781,-3.69447 6.47985,-5.28036 0.25734,-2.03494 3.16031,-4.82343 3.11993,-7.44052 1.3229,-5.01568 -6.16977,-0.88697 -5.27988,-4.08027 0.77807,-2.47327 -4.13216,-1.69523 -3.11992,-4.56032 0.67126,-0.82171 4.52856,-2.89231 2.39994,-3.36022 0.467,-3.07403 5.49046,-1.7555 2.39995,-0.48004 0.666,3.73184 4.56797,-2.43536 1.19997,-2.64019 1.66799,-2.20014 4.63369,2.52346 7.19983,1.4401 1.66725,0.37723 3.7463,4.19339 0.95998,5.76041 -0.77641,2.80052 3.45334,2.98142 5.03988,2.16014 2.37106,1.99373 2.23554,1.16465 5.51988,1.20009 1.69051,1.16602 4.70257,-1.51193 4.55989,1.20007 -0.60376,3.18374 4.60406,2.44358 5.03988,4.80033 1.22291,-1.18113 4.71723,-5.77716 4.31991,-2.16014 -0.40736,3.51212 2.93783,-2.61178 2.63993,0.24001 3.72134,-3.24816 5.64974,-0.095 8.8798,-0.48004 3.49236,0.77334 0.57818,-3.04826 1.91996,-3.84026 2.27224,-1.35951 2.30084,1.37779 4.55989,1.68013 3.50454,0.6795 2.42606,-5.28336 3.83991,-6.72048 2.6784,2.46412 6.86771,0.18345 7.43983,-2.16013 2.38482,2.94942 4.1799,-2.04409 5.75987,0.72004 1.04554,0.56017 2.54954,-0.90861 3.59991,-0.96007'
          GC: s \path.province d: 'm 174.46875,313.125 -0.25,0.25 -0.46875,0.46875 0.21875,0.46875 0,0.25 0.25,0 0.25,-0.25 0.21875,0.25 0.75,-0.96875 -0.75,-0.46875 -0.21875,0 z m 0.21875,5.03125 -0.21875,0.25 0,0.46875 -0.25,0.25 0,0.46875 -0.25,0.25 0.25,0.25 -0.25,0.25 -0.46875,0.21875 -0.25,0.25 0.25,0.25 0.25,0 0,0.21875 0.21875,-0.21875 0.25,0 0.46875,-0.25 0.25,0 0.25,-0.25 0.25,-0.46875 0,-0.25 0.21875,-0.25 0,-0.21875 0.25,0.21875 0,-0.21875 0,-0.25 -0.25,-0.46875 -0.46875,0 -0.5,-0.5 z m 1.46875,2.1875 -0.25,0.46875 -0.71875,0.25 0,0.46875 -0.25,0.25 -0.46875,0.9375 -0.25,0.5 0,0.9375 -0.25,0.25 -0.21875,0.46875 -0.71875,0.5 -0.96875,-0.71875 -0.46875,-0.25 -0.5,0.46875 -0.21875,0 -0.5,0.5 -0.21875,0 0,-0.25 -0.5,0 -0.21875,0 0,0.25 -0.25,0.21875 -0.5,0.25 0,0.5 -0.46875,0 -0.25,0 -0.21875,0.46875 -0.5,-0.25 -0.21875,0.25 -0.96875,0.25 -0.25,0.21875 -0.46875,0.25 -1.1875,0.96875 -0.25,0.21875 -0.46875,0.96875 0,0.96875 0,0.46875 0,0.25 0,0.21875 0,0.5 0,0.46875 0,0.5 -0.25,0.21875 -0.25,0.25 -0.25,0.25 -0.21875,0.21875 0,0.25 -0.5,0.25 -0.21875,0.21875 0.21875,0.5 0,0.46875 0,0.25 0.5,-0.25 0.21875,0 0.25,0 0.25,0.25 0.25,-0.25 0.21875,0 0.5,0.25 0.46875,-0.25 0.25,0.46875 0.21875,0.5 0.5,-0.5 0,-0.21875 0.46875,-0.5 0.25,-0.21875 0,-0.5 0.46875,-0.71875 1.1875,-0.71875 0.96875,0 0.25,0 0.96875,0 0.21875,-0.21875 0.96875,-0.5 0.25,-0.21875 0.21875,-0.25 0.5,-0.25 0.46875,0 0.25,-0.25 0.46875,0 0.46875,-0.46875 0.25,0 0,-0.25 0.25,0 0.21875,-0.21875 0.75,-0.5 0.21875,0 0,-0.21875 0.25,0 0,-0.25 0,-0.25 0.46875,0 0,-0.21875 0,-0.25 -0.21875,-0.46875 0.21875,-0.5 0,-0.21875 0.25,-0.25 0.25,-0.96875 0,-0.71875 -0.25,0 0,-0.25 -0.25,-0.21875 0,-0.71875 0.71875,-0.71875 0.5,-0.25 0.21875,-0.46875 -0.21875,0 0.21875,-0.71875 0,-0.71875 0,-0.25 -0.46875,0 0,-0.25 -0.25,0 -0.46875,-0.46875 -0.25,0 -0.21875,-0.46875 z M 161.5,340 l -0.96875,0.5 -0.21875,-0.25 -0.25,0 -0.25,0.46875 -0.21875,-0.21875 -0.5,0.21875 -0.21875,0.25 -0.25,-0.25 0,0.25 -0.25,0 -0.21875,0 -0.25,0.25 -0.25,0 0,0.21875 -0.21875,0.5 -0.25,-0.25 -0.25,0 0,0.25 0,0.46875 0.25,0.25 -0.25,0.21875 0.25,0.25 -0.25,1.21875 -0.25,0 0,0.46875 -0.21875,0.25 -0.25,0.71875 0.25,0.71875 -0.25,0.46875 -0.25,0.25 -0.46875,0.46875 0,0.46875 -0.25,0 0,0.5 -0.21875,0 0,0.71875 -0.5,0.71875 0,0.46875 -0.46875,0.71875 -1.6875,1.4375 0,0.5 0,0.21875 -0.21875,0.5 -0.25,0.21875 0.25,0 0,0.25 0,0.25 -0.25,0 0,0.96875 -0.25,0.21875 -0.21875,0.71875 -0.96875,0.5 0,0.21875 -0.25,0.71875 0,0.25 0,0.25 -0.25,0.46875 0.25,0.71875 0,0.25 0,0.46875 -0.25,0.96875 -0.21875,0.71875 -1.4375,1.1875 -1.21875,0.96875 -0.21875,0.25 -1.21875,0.71875 -0.71875,0.21875 -0.46875,0.5 -1.9375,0.46875 -0.9375,0 -0.25,0 -0.25,0 -0.21875,0 -0.25,0 -0.46875,-0.25 0,0.25 -0.25,0 0.25,0.25 0,0.46875 -0.25,0.25 -0.25,0.25 -0.21875,0.21875 0.21875,0 0.25,-0.21875 0.71875,-0.25 0.46875,0.25 1.9375,0.71875 0.46875,0 0.71875,0.21875 0.25,-0.21875 1.4375,0.46875 0.46875,-0.25 0.5,-0.9375 0.71875,-0.5 0.71875,-1.1875 0.21875,-0.25 0.25,-0.25 0.25,-0.46875 0.21875,0 0.25,-0.46875 0.25,-0.5 0.21875,-0.21875 0.5,0 0.21875,-0.25 1.46875,0 0,-0.46875 0.46875,0.21875 0.25,-0.21875 0.21875,-0.25 0.25,0 0.46875,0 0.5,-0.25 0,0.25 0.71875,-0.25 0,-0.21875 0.21875,0.21875 0.25,-0.21875 0.71875,0 0.71875,-0.25 0.25,-0.25 0,0.25 0.71875,-0.46875 0.25,-0.25 1.1875,0 0.46875,-0.25 0.71875,-0.71875 0.25,-0.96875 0.25,-0.21875 0.21875,0.21875 0,-0.21875 0,-0.25 0,-0.25 0,-0.46875 0.25,-0.46875 0,-0.5 0.25,0 0,-0.21875 0.21875,-0.25 0,-0.46875 0,-0.25 0.5,-0.46875 0.21875,-0.96875 0,-0.25 0.25,0.25 0,-0.5 0,-0.21875 0,-0.5 -0.25,-0.21875 -0.21875,-0.25 0,-0.25 0.21875,-0.21875 0,-0.25 0,-0.46875 -0.46875,-0.71875 0.46875,-0.71875 0.25,0 0.25,-0.25 0,-0.25 0.25,-0.71875 0,-0.25 0,-0.21875 0.46875,-0.5 -0.25,-0.21875 0,-0.25 0,-0.46875 0.25,-0.71875 -0.25,-0.5 0.25,-0.21875 -0.25,-0.96875 -0.21875,-1.6875 0.21875,-0.71875 -0.21875,-0.46875 0,-0.25 -0.25,-0.46875 -0.5,0 -0.21875,-0.25 -0.25,-0.25 0.25,-0.21875 -0.25,-0.25 -0.25,0.25 0,-0.25 L 161.5,340 z m -54.46875,23.28125 -0.5,0.5 -0.21875,0 0,0.21875 0.21875,0.25 0,0.46875 -0.46875,0.5 -0.71875,0.21875 -0.46875,-0.46875 -0.25,0.25 -0.25,-0.5 -0.21875,0 -0.5,-0.21875 0,0.21875 -0.46875,-0.46875 -0.25,0 0,0.25 -0.21875,0 -0.25,0.21875 -0.5,0 -0.71875,0 -0.21875,0 -0.5,0 -0.21875,-0.21875 -0.25,0.21875 0,-0.46875 -0.25,0 -0.21875,0 0.21875,-0.25 -0.21875,-0.21875 -0.25,0 0,-0.25 L 98.875,364 l -0.25,-0.21875 -0.46875,0.46875 -0.5,-0.25 0,-0.21875 -0.21875,0 -0.25,0.21875 -0.25,0 -0.21875,-0.21875 0,0.21875 0.46875,0.5 -0.25,0.21875 0,0.25 0,0.25 -0.21875,0.46875 0.21875,0 -0.21875,0.25 0,0.21875 -0.25,0.25 0.25,0.25 0,0.46875 -0.5,0.5 -0.46875,0.21875 0,0.5 -0.5,0.21875 -0.71875,0.25 0,0.25 -0.21875,0.21875 -0.71875,0.5 -0.5,0 -0.21875,0 -0.25,0.21875 0.25,0.25 -0.25,0.71875 -0.25,0 0,0.25 -0.21875,0.46875 0.21875,0.96875 -0.21875,1.1875 0,0.25 0.46875,0.71875 0.71875,1.4375 0.46875,0.96875 0.25,0.21875 0.25,0.25 0.21875,0.25 0.5,0 0,0.25 0.21875,0.21875 0.25,0.25 0.25,0 0.21875,0.25 0.25,0 -0.25,0.21875 0.5,0.25 0.46875,0.25 0,0.21875 0.25,-0.21875 0,0.21875 0.46875,0.5 0.25,0.21875 0.25,-0.21875 0.21875,0 0.5,0.21875 0.71875,0.25 0.21875,0 0.5,0.46875 0.9375,0 0.25,-0.21875 0.25,-0.71875 0.21875,-0.25 0.96875,-0.25 0.5,-0.46875 0.46875,0 0.46875,-0.46875 1.6875,-0.25 0.71875,-0.25 0.25,-0.46875 -0.25,-0.25 0.25,-0.71875 0.21875,-0.25 0.25,0 0.25,-0.21875 0.21875,0 0.25,-0.25 0,-0.46875 0.25,-0.25 -0.25,0 -0.25,0 0,-0.46875 0.25,-0.5 0,-0.71875 0,-0.46875 0.5,-0.25 0.46875,0.25 -0.25,-0.25 0,-0.21875 -0.46875,-0.25 0,-0.25 0,-0.21875 0,-0.25 -0.25,0 0,-0.25 0.25,-0.25 0,-0.21875 0.46875,-0.25 -0.21875,-0.25 0,-0.21875 -0.25,-0.25 0.25,0 -0.5,-0.25 0,-0.46875 -0.25,-0.25 -0.71875,-0.21875 0,-0.5 0,-0.21875 -0.21875,-0.25 0.21875,-0.46875 -0.21875,-0.5 0.21875,-0.71875 -0.21875,-0.71875 -0.25,0 0,-0.25 0,-0.21875 0,-0.25 0,-0.25 0.25,0 0,0.25 0,0.46875 0.21875,-0.71875 0,-0.21875 0.25,-0.25 0,-0.25 0,-0.46875 -0.46875,-0.25 z'
          TF: s \path.province d: 'm 18.21875,334.71875 0,0.25 0,0.25 -0.21875,0 -0.5,0.21875 -0.46875,0.5 -0.5,0 0.25,0.21875 -0.25,0 0,0.25 -0.21875,0.25 0,0.21875 -0.5,0.25 -0.21875,0 0,0.25 -0.25,0.25 0,0.9375 -0.25,0.25 0.5,0.71875 0.21875,0.25 0.25,0.21875 0,0.25 0.25,0.46875 0,0.25 0.21875,1.1875 0,0.25 0.25,0.25 0.25,0.46875 0.25,0.25 0.71875,1.1875 0,0.25 0,0.46875 0.21875,0.25 0.25,0.25 0,0.46875 0.46875,0 0.25,0.96875 0.25,0 0,0.21875 0,0.25 0.21875,0.46875 -0.21875,0 0.21875,0.25 0,0.96875 0.25,0.46875 -0.25,0.25 0.25,0.25 0.25,0.46875 0.21875,0 0,0.25 0.5,0.21875 0.21875,-0.21875 0.5,-1.6875 0.46875,-0.25 0.25,-0.46875 0.21875,0 0.25,-0.96875 0.96875,-1.1875 0,-0.5 0.25,-0.21875 0,-0.25 0,-0.71875 0.21875,-0.25 L 24,344.09375 l 0,-0.46875 0,-0.25 -0.25,-0.25 0.25,-0.25 -0.25,0 0,-0.21875 -0.25,-0.5 0.25,-0.21875 0,0.21875 0.25,-0.46875 0,-0.25 0.21875,-0.46875 0.71875,-0.46875 0,-0.5 0.25,-0.21875 0,-0.25 -0.25,0 0,-0.71875 -0.46875,0 -0.25,-0.46875 0,-0.5 L 24,337.625 l 0,-0.5 -0.25,-0.46875 0,-0.25 0,-0.25 -0.25,0 0,-0.21875 0,-0.25 -0.46875,-0.25 -0.25,0 -0.46875,0 -0.25,0.25 -1.1875,0 -0.25,0.25 -0.25,-0.25 -0.71875,-0.25 -0.21875,0 -0.5,-0.21875 0,-0.25 -0.46875,-0.25 0,0.25 -0.25,-0.25 z m 62.15625,12 -0.46875,0.5 -1.4375,0.46875 -0.71875,-0.25 -0.5,0 -0.46875,-0.46875 0,0.25 -0.46875,0 -0.25,0.21875 0,-0.21875 -0.25,0.21875 -0.21875,-0.21875 -0.5,0.21875 0,-0.46875 -0.21875,0 -0.25,0.25 -0.25,0.71875 -0.46875,0.21875 -0.25,0 -0.21875,0.25 -0.71875,-0.25 -0.5,0.5 0,0.21875 -0.46875,0.25 -0.25,0.25 0,0.46875 -0.25,0.25 -0.21875,0.46875 -0.5,0.5 0,0.21875 -0.21875,-0.21875 0,0.21875 -0.25,0 0,0.25 0,0.25 -0.25,0 0,0.21875 -0.21875,0 0,0.25 0,0.25 -0.5,0.21875 L 68.875,352.5 l -0.25,0 -0.25,0.71875 -0.71875,0.21875 -0.46875,0 -0.25,-0.21875 0,0.21875 -0.21875,0 -0.25,0.25 -0.25,0 -0.21875,0 0,0.25 -0.25,0 -0.25,0.21875 -0.25,0 -0.21875,0 -0.25,0.25 -0.71875,-0.25 -0.46875,0.25 -0.25,-0.25 -0.25,0 -0.21875,-0.21875 -0.25,0.21875 0,-0.21875 -0.25,0.21875 0,-0.21875 -0.21875,0.46875 -0.25,0 -0.25,0 0,0.25 -0.21875,0 -0.5,0 -0.21875,0 -0.25,0.25 -0.25,0 0,-0.25 -0.21875,0.25 -0.5,0.21875 -0.46875,-0.21875 0,0.21875 -0.25,0 -0.71875,0 -0.46875,-0.21875 -0.25,0 -0.46875,-0.5 -0.5,0 -0.21875,0 -0.5,0.5 -0.21875,0 -0.25,0.21875 -0.25,0.25 -0.21875,-0.25 -0.25,0.25 -0.46875,0 -0.25,0.25 -0.25,0.21875 0,0.5 0.25,0 0.25,0.21875 0.46875,0.25 0,0.25 0.46875,0.46875 0,0.46875 0.25,0 0.46875,0.5 -0.21875,0.21875 0.21875,0.25 0.25,0.25 0.46875,0.21875 0,0.5 -0.21875,0.21875 0,0.25 0,0.25 0.21875,0.25 0,0.46875 0,0.46875 0.25,0.25 0,0.25 0.25,0 0.21875,0.46875 0.25,0 0.25,0.25 0,0.71875 0.9375,1.65625 0.25,0 0,0.25 0.25,0 0,0.25 0.21875,0 0,0.21875 0.5,0.5 0.25,0 0,0.96875 0,0.46875 0.21875,0 0.25,0 0.25,0.25 0.21875,0.46875 0,0.25 0,0.71875 0.25,0.21875 0.25,0.25 0.46875,0 0.25,-0.25 0.21875,0 0.25,-0.21875 0.25,0.21875 0.21875,0 0.25,0 0,-0.21875 0.25,0 0.21875,-0.25 0.96875,-0.46875 1.4375,0 0.5,0.21875 0.21875,-0.21875 0,-0.25 0,-0.25 0.25,0 0,-0.21875 0.25,0 0.21875,-0.5 0.25,0 0,-0.21875 0.25,0 0.21875,-0.5 0.25,0 0.25,-0.46875 0.21875,-0.25 0.25,-0.46875 0.46875,-0.25 0,-0.25 0.25,-0.21875 0.25,-0.25 0.21875,0 0,-0.25 0,-0.21875 0.25,0 0.25,-0.25 -0.25,-0.25 0,-0.21875 0.25,0 0,-0.25 0,-0.25 0,-0.21875 0,-0.25 0.21875,-0.25 0,-0.21875 0,-0.25 0.5,-0.71875 0,-0.46875 0.96875,-1.46875 0,-0.46875 L 73.4375,358 l 0,-0.46875 0,-0.46875 -0.25,-0.5 0,-0.71875 0.25,0 0,-0.71875 0.46875,-0.21875 0.46875,-0.5 0.25,-0.25 0.25,0 0.46875,-0.21875 0.46875,-0.5 0.25,-0.21875 0.46875,-0.5 0.25,-0.46875 L 77.5,352 l 0.25,-0.46875 -0.25,0 0,-0.25 0.5,-0.46875 0.46875,-0.25 0,0.25 0.25,-0.25 0.46875,-0.21875 -0.25,0.21875 0.5,-0.21875 0.21875,-0.5 0.5,0 0,-0.21875 0.71875,-0.25 0.46875,0 0,-0.5 0.25,0 0.21875,0 0,-0.46875 0.25,-0.25 0,-0.21875 0,-0.25 0,-0.25 -0.25,-0.21875 -0.21875,0 0.21875,-0.25 -0.9375,-0.25 -0.5,0 z m -39.59375,14.40625 -0.25,0.25 -0.21875,0 -0.25,0 -0.25,0 -0.21875,0.25 -0.25,0 -0.25,0.21875 0,0.25 -0.21875,0.25 -0.25,0.46875 0,0.46875 -0.25,0.25 -0.21875,0.25 0,0.21875 0.21875,0.5 -0.21875,0.46875 0,0.71875 0.21875,0.25 0,0.46875 0.25,0 0.46875,0.25 0,0.71875 0.25,0.46875 0.46875,0 0.25,0 0,0.5 0.71875,0 0,0.46875 0.46875,0 0.5,0.25 0.46875,-0.25 0.5,0 0.71875,0.25 0,-0.25 0.46875,0 0.25,-0.46875 0.21875,0.21875 0,-0.21875 0.25,0 0.46875,-0.5 0.25,0 0,-0.21875 0.46875,-0.5 0.5,-0.21875 0.21875,-0.5 0.25,0 0.25,-0.25 -0.25,-0.21875 0,-0.5 0.25,0 -0.25,-0.46875 0,-0.25 -0.25,-0.21875 0,-0.25 -0.21875,0 0,-0.46875 -0.25,0 -0.46875,-0.25 -0.5,-0.25 0,-0.21875 -0.46875,0 0,-0.25 0,-0.25 -0.25,0.25 -0.21875,0 -0.25,-0.25 0,-0.21875 -0.25,-0.25 0,-0.25 -0.21875,0 -0.25,0 -0.25,0 -0.46875,-0.21875 -0.25,0.21875 0,-0.21875 L 42,361.84375 41.75,361.625 l -0.5,-0.5 -0.46875,0 z m -24,14.40625 -0.25,0.25 -0.46875,0 -0.25,0 -0.21875,0.46875 -0.5,0 -0.21875,0.25 -0.25,0 0.25,0.46875 0,0.46875 -0.25,0 -0.46875,0.5 -0.5,0.46875 -0.46875,0.5 -0.46875,0 L 12,379.125 l -0.5,0 -1.1875,-0.21875 -0.25,-0.25 0,-0.25 -0.25,0 -0.46875,0.25 -0.25,0.25 -0.21875,0.21875 0,0.25 0,0.46875 -0.25,0.25 0,0.46875 0.46875,0.5 0.71875,0 2.65625,0.46875 0.71875,0.71875 0.25,0.25 0.21875,0.21875 0,0.25 0.25,0.46875 0.46875,0 0.25,0.5 0.46875,0 0.25,-0.5 0,-0.9375 0.25,-0.25 0,-0.46875 0.21875,0 0,-1.21875 0.5,-0.21875 0.46875,0 0.25,-0.25 0,-0.25 0.71875,-0.9375 -0.25,-0.25 0.25,-0.25 0.25,-0.46875 0.21875,0 0.5,-0.71875 0,-0.25 -0.5,-0.46875 0.25,0 -0.25,-0.25 L 18,376 l 0,-0.21875 -0.5,0 0,-0.25 -0.71875,0 z'
          C: s \path.province d: 'm 195.09375,8.3125 c -0.8129,2.078781 -5.17978,1.799689 -3.84375,3.34375 -2.72717,-0.983344 0.0557,1.666059 -1.90625,1.21875 -1.09705,-0.0662 -0.1885,-0.66299 0.25,-1.6875 0.328,-0.04552 0.25985,-1.150249 0.21875,-2.625 -2.27926,0.297735 -2.37439,2.921597 -5.75,2.15625 -1.20143,1.528648 0.35679,1.948183 -0.71875,2.625 -0.57598,-1.600168 -2.23626,1.757038 -3.59375,0.96875 0.11565,1.197162 -2.7936,2.784323 -3.84375,1.90625 1.22659,1.454517 -0.67764,1.591848 -0.46875,3.375 -1.25955,1.124671 2.52611,0.371716 2.625,-0.25 0.34937,0.831925 1.52828,0.491828 2.40625,-0.71875 0.67268,-0.08679 -1.49071,3.241351 -2.87505,1.6875 -1.42913,0.246085 -2.63342,0.51698 0,1.6875 0.38065,0.08906 3.67628,-0.140916 1.1875,0.9375 -0.8307,1.440148 0.78136,3.715986 -1.1875,2.15625 0.48057,-1.790126 -3.90821,-3.364559 -2.65625,-1.1875 -0.71138,2.74718 -2.29627,-0.476197 -1.6875,-0.71875 -0.60401,0.60996 -1.85259,-0.0031 -3.09375,1.6875 -2.10173,1.797815 -3.68787,-0.268439 -6.5,1.6875 -1.37139,0.0252 -3.20542,-2.22903 -3.84375,-2.40625 0.21377,1.768764 -1.98971,-0.02429 -2.375,1.6875 -1.19867,-0.06878 -2.28593,1.074452 -0.75,1.90625 -0.21406,1.416338 -1.44265,0.980327 -2.15625,0.71875 -0.94778,1.706408 -2.55538,1.585986 -3.84375,0.96875 -1.53883,-0.114671 -3.06002,3.728862 -0.9375,2.15625 0.80147,-0.139559 -0.85696,3.05811 -1.6875,1.1875 -0.63409,0.384487 -1.17934,2.05349 -2.15625,2.40625 1.02488,1.714467 0.7706,3.196006 -0.71875,4.8125 1.06907,2.372912 0.71569,0.964028 1.90625,-0.25 2.24152,0.179806 0.76763,2.427277 1.6875,-0.46875 1.05645,2.025796 1.44989,1.922302 0.71875,3.59375 1.72191,0.481243 0.7194,2.623391 0,2.625 0.65055,1.75885 1.97702,3.357971 2.65625,0.96875 -0.68868,-0.705439 1.27136,-0.870276 2.15625,0 0.61627,-0.321943 1.55186,0.0083 2.62505,-1.6875 0.42486,1.951413 -1.265,1.520159 -2.625,3.375 -2.08112,0.480363 -2.33538,5.431454 -3.84375,6.46875 2.73101,-0.375344 0.0522,3.656307 2.625,1.9375 0.26702,-2.28451 2.7001,-1.43508 2.15625,-3.125 1.60888,-2.853785 1.5396,1.234549 2.1875,-0.25 0.88129,-0.105693 -0.003,-3.409679 1.4375,-1.4375 0.10102,2.098401 2.8704,-0.458949 3.34375,-1.6875 2.00919,-0.992926 3.30457,0.315567 4.5625,-1.90625 1.16774,0.350587 4.30681,1.730659 4.8125,-0.5 0.77418,0.374914 3.25525,-0.590421 1.65625,-2.15625 1.49345,-0.875694 1.03101,1.97674 3.125,0.25 0.77587,1.348555 0.98709,-1.558225 2.65625,-0.46875 1.22011,0.100298 2.33744,0.416974 3.59375,0.71875 2.75753,-1.209103 5.34816,-5.161649 3.125,-9.125 1.00097,-2.048392 -0.16681,-6.490453 0.71875,-8.40625 1.60656,-1.27258 1.31599,-4.704618 2.40625,-5.28125 2.16616,0.900023 2.77868,-2.085105 3.34375,-3.59375 0.92552,-1.53353 -0.14682,-2.91807 1.4375,-3.375 -1.13413,-1.820393 1.43648,-1.657682 0.5,-3.59375 -0.0798,-0.725889 1.31286,-3.2802446 1.1875,-4.3125 l -0.25,0 z m -38.40625,45.125 c -0.40363,-0.300513 -0.2276,0.725502 0,0 z m -4.0625,3.34375 c -0.23605,0.370678 0.86164,0.942702 0,0 z M 145.90625,35.1875 c 0.28993,-1.714827 -0.74929,0.09914 0,0 z m 2.625,-4.3125 c 0.82915,-0.26011 -0.34344,-0.461294 0,0 z m 21.84375,-6.5 c 0.90299,-0.58475 -0.80545,0.07175 0,0 z m 7.9375,-4.5625 c -0.68689,-0.284518 0.28452,0.686887 0,0 z m 4.5625,-7.1875 c 0.75658,-0.275258 -0.34331,-0.439345 0,0 z'
          LE: s \path.province d: 'm 218.62152,71.671455 c 1.25048,-0.791907 2.3616,-3.293761 1.19997,-4.56031 -1.64577,-0.754364 -2.8652,-1.547532 -1.91995,-3.12021 1.60785,-2.257054 -2.74519,-3.059518 -4.07991,-3.12022 -1.28495,1.340209 -3.97591,-0.113204 -3.11993,-1.92013 1.99889,-0.2091 -0.30418,-3.83277 2.15996,-3.36023 -1.34556,-1.573214 -0.76762,-3.307326 1.19997,-3.84026 0.28902,-0.423777 3.36259,-0.866452 3.59991,-3.12022 -0.70196,-2.132905 1.86647,-1.737656 0.24,-3.84026 3.18331,1.877398 2.56109,0.438369 5.75987,0 1.7115,0.132599 5.43738,0.604528 6.47985,-0.72005 -1.7805,-2.394627 0.36209,-0.980472 1.19997,-2.8802 1.21817,-2.32725 1.61451,-0.932063 3.35992,-0.48003 1.37296,2.007682 3.01665,-1.636564 4.3199,0.24001 1.99744,0.949326 1.66873,-3.33117 3.83991,-0.72004 2.11966,-1.942634 1.71887,3.623341 3.83991,2.40016 0.13233,1.965957 4.46222,1.882029 4.31991,-0.96007 1.12256,-2.305495 4.06275,0.03405 5.51987,0.24002 1.56879,-0.744377 4.13821,-0.471376 5.27988,-2.40016 1.81037,-0.06676 4.44862,0.633383 6.23985,-0.48004 1.71696,0.197529 2.42042,-1.195331 3.11993,-3.12021 2.4761,1.133784 2.92157,-2.566328 5.75987,-1.92013 1.07883,1.545291 0.71421,3.040412 0.95998,4.56031 1.27447,1.839541 4.92334,3.39906 1.19997,5.28036 -0.52611,2.665788 -1.65031,4.355173 -3.35992,5.52038 1.57615,2.237241 -2.99418,4.717082 0.47998,5.28036 -0.11671,2.588878 -1.79059,6.743038 -0.23999,8.6406 -1.7101,2.265926 0.0542,4.601929 -1.67996,5.04034 -2.74459,0.67208 0.23566,1.098943 -0.47999,3.36023 -2.61211,-0.65839 -3.124,2.880053 -4.07991,0 -1.63687,0.484484 -4.56538,0.419195 -4.79989,1.68012 0.96589,2.013754 -3.12893,2.221472 -2.39994,1.68012 -3.40696,-2.590602 -0.87012,3.807093 -2.15995,4.80033 1.49736,3.490357 -3.27258,2.341163 -3.59992,-0.24002 -1.3068,-0.99535 -2.08007,3.102888 -2.39994,0.48003 -1.56449,0.21189 -1.87546,-4.288003 -3.11993,-1.92013 -2.2601,0.458892 -2.50827,-1.514638 -4.3199,0.24002 -1.68029,-3.127269 -2.75156,0.306857 -4.5599,-1.4401 -3.77881,-1.741185 -8.07607,0.463614 -9.83977,-2.8802 -1.73521,-0.02612 -4.58923,0.568852 -5.51987,0.48003 -1.4586,-1.564339 -5.19671,-0.308954 -6.95984,-1.92013 0.70729,-0.228481 -1.40562,-0.800179 -1.43997,-0.96007 z m 44.63897,0.72005 c -3.73088,0.0532 -0.0429,3.15024 0,0 z'
          PO: s \path.province d: 'm 158.62291,69.991345 c 1.42439,-1.474151 0.91907,-0.08425 1.67996,-1.20008 1.50245,-0.396801 0.99553,-1.060077 2.87993,-1.68012 0.81613,0.790518 1.24304,-2.641004 0.23999,-2.40016 -0.53294,1.055125 -0.7442,2.440775 -2.63993,2.64018 0.26632,-0.94467 -2.07688,0.937495 -2.15995,0.72005 -0.17943,-0.135258 -3.64627,0.88494 -2.15995,-1.4401 0.02,-2.038785 1.81588,2.34684 1.19997,-1.20008 -1.34406,-1.973846 2.32687,0.978817 2.63994,-1.68012 0.86366,-1.045466 2.45825,-2.031368 2.63994,-2.16015 -1.21383,-0.911989 -2.0906,0.0061 -3.59992,1.20008 -1.67049,-0.869213 -2.7742,0.534773 -2.87993,-1.92013 0.35914,-1.924651 -2.34595,-0.460593 -1.91996,-1.92013 1.88717,0.168905 2.10476,-1.997998 2.63994,0.24002 -1.21043,1.437638 0.75391,0.201208 0.95998,0.72005 -0.66719,-1.880024 0.92584,-1.452914 0.23999,-2.16015 0.3898,-0.05289 -1.03358,-2.38495 0,-1.68012 -0.71647,-1.363139 1.25887,-1.112622 1.43997,-1.68011 0.12391,-0.691033 1.55535,-3.269521 2.39994,-4.3203 1.98757,-1.009285 3.33115,0.29257 4.5599,-1.92013 1.14593,0.391099 4.31825,1.705032 4.79989,-0.48003 0.76406,0.338074 3.2363,-0.541315 1.67996,-2.16015 1.4417,-0.913032 1.02698,1.960821 3.11993,0.24001 0.74013,1.335166 0.9739,-1.521886 2.63994,-0.48003 1.02213,0.581516 2.68886,-0.347199 3.11992,0.96007 3.56008,-1.834317 1.48417,0.974209 2.63994,3.36023 3.31944,1.23718 2.22982,2.13971 1.43997,5.04034 -0.0513,2.683718 -3.21138,1.801496 -4.07991,3.36024 -1.75283,-0.440093 -3.98742,-1.549278 -5.27987,-0.72005 -1.80902,0.759099 -2.92432,2.703327 -5.03989,2.40016 1.78029,2.395636 0.17838,6.327635 2.63994,7.44051 -1.68562,2.731464 2.94232,3.421289 2.63994,3.12022 -1.0603,0.905138 0.81481,2.735001 -1.67996,3.84026 -2.75852,0.132866 -3.9905,3.102234 -7.19984,1.68011 -1.93523,0.846411 -5.85312,-0.110076 -6.47985,2.8802 -2.68827,1.11662 -4.05856,3.454434 -6.71984,4.80033 -0.60026,-1.204096 0.21094,-4.464776 -0.24,-5.76039 0.81363,-1.346039 -1.09491,-4.576557 1.67997,-4.56032 1.76793,1.452866 -0.92468,-1.536184 1.19997,-1.92013 -0.66489,-1.096906 0.92298,-0.06533 0.95998,-1.20008 z m -0.95998,-2.8802 0.23999,0 -0.23999,0 z'
          OR: s \path.province d: 'm 218.62152,71.671455 c 0.49194,2.36369 -2.01791,-0.06386 -3.11993,1.92014 -1.98031,1.15209 -2.65556,3.354431 -3.59991,3.84026 -2.53542,1.927277 2.41605,1.891123 0.47999,4.08028 -0.47865,2.514181 -2.99342,2.425155 -4.5599,0.24002 -3.56974,0.200591 0.39591,4.433716 -4.0799,4.80033 -2.21707,1.449046 -3.81126,-0.05454 -5.27988,2.16015 0.90845,-1.50963 -2.45441,-3.886187 -2.63994,-1.68012 -2.82318,1.497702 -2.90547,-0.708456 -2.15995,-1.68012 -2.43936,0.01571 -4.23486,-1.890641 -6.47985,-0.24001 -3.47253,3.486358 -1.52388,-3.308869 -3.11993,-1.20008 -0.9508,1.691338 -3.04013,1.643448 -4.3199,3.12021 -1.57422,0.81129 -4.0322,0.581037 -3.59992,-2.40017 -2.90973,-0.03116 0.7003,-5.526043 2.87994,-5.52037 1.09322,-4.353486 -4.59927,-0.534084 -2.87994,-5.28037 1.13067,-0.44469 0.1528,-2.851253 0.95998,-3.60024 -0.30317,-0.46752 -4.52732,-0.344681 -2.63994,-3.12022 -2.4643,-1.113295 -0.86198,-5.050243 -2.63994,-7.44051 2.49096,0.365691 3.92816,-2.578279 6.23986,-2.8802 1.01689,0.396573 4.39414,1.86648 4.79989,0.24002 2.93452,-1.148869 3.18306,1.52872 2.87993,1.92013 -0.008,0.941659 2.94203,1.907345 4.3199,1.68012 -1.36181,1.073593 -0.69038,0.832949 1.43997,1.92013 1.57485,2.223901 2.99064,1.799624 5.03988,2.64018 3.64857,-1.395444 5.5774,-2.580072 8.39981,-0.24002 1.18894,2.290924 1.18702,3.760492 2.63994,0.48004 0.49058,-2.038072 2.40345,-3.18298 3.59991,-4.56032 2.30596,1.487497 3.48631,-1.422582 5.99987,1.20009 2.93684,0.03466 -1.48041,4.114351 1.43996,4.32029 2.82357,0.683192 1.57371,4.27436 0,5.28036 z'
          VA: s \path.province d: 'm 269.03125,70.9375 c -1.87931,3.602094 -3.92931,-0.372448 -4.34375,2.90625 1.2554,1.186324 -1.79364,1.255717 -2.625,0.9375 -2.91831,-1.72275 -0.26551,4.278368 -1.6875,5.0625 -0.26368,2.932955 5.34337,3.68922 1.4375,6 3.23286,0.983835 -2.00192,5.131679 1.6875,4.78125 -2.83521,1.667723 -3.84842,3.229434 -2.625,4.8125 2.11593,1.287819 -0.2655,3.969967 2.625,4.3125 -2.32653,1.5666 3.24107,2.76552 -0.25,3.59375 -3.36103,1.29968 -1.15388,2.4175 -1.65625,4.5625 -0.22787,3.5391 2.03686,6.61417 -0.71875,8.15625 1.24686,1.06272 3.5923,-1.39877 3.59375,1.21875 1.47551,-0.69083 3.5825,2.56293 6,0.46875 2.25181,-0.70785 4.5492,3.81861 6.21875,2.15625 0.96456,-1.71035 3.8842,-2.83372 5.53125,-2.40625 -0.60575,-1.41291 0.75543,-3.54087 2.15625,-4.53125 -2.52252,-2.17726 2.24616,-1.33456 3.125,-0.5 -0.0437,-1.38456 -2.54013,-4.85042 -0.25,-4.5625 2.60415,-1.95526 5.61617,-1.44366 9.625,-2.625 1.48029,-0.15774 4.92018,-1.08075 5.25,-2.40625 1.6139,-3.094208 -2.07085,-2.49614 -0.9375,-5.53125 -2.14702,-2.243653 0.51636,-3.654786 -1.9375,-4.3125 -0.47639,-1.02801 -4.63339,-1.739186 -5.5,-0.46875 -2.54503,0.991615 -3.86682,0.299433 -6.96875,0.71875 0.5359,-1.678476 2.17942,-3.609361 -0.46875,-2.15625 -0.90503,0.434153 -3.01542,-0.221532 -3.375,-2.40625 -1.91411,-3.05411 -4.54903,5.787895 -5.53125,0.46875 -0.79503,-2.524365 -3.14677,-3.510538 -5.03125,-1.90625 -1.46862,-2.60765 2.25765,-3.409113 1.21875,-5.78125 2.40535,-0.743906 0.48892,-5.089741 -1.21875,-3.8125 -1.98521,-0.444681 -0.0988,-3.022845 -0.46875,-4.8125 -0.82302,-2.336741 -0.92945,2.162311 -2.875,-1.9375 z m 32.625,28.8125 c 0.46129,0.34344 0.26011,-0.829146 0,0 z M 262.0625,72.40625 c -1.19672,3.248604 3.08249,-0.152879 0,0 z m -5.53125,6.9375 c 1.08636,2.156665 0.3801,4.507871 2.15625,5.28125 0.79967,-3.347267 0.0779,-2.045342 -1.90625,-5.03125 l -0.25,-0.25 z'
          ZA: s \path.province d: 'm 256.54065,79.351985 c 1.06019,2.16897 0.38855,4.50177 2.15995,5.28036 -0.94058,-2.998068 2.14799,-3.518617 4.0799,-1.44009 2.30784,1.420614 -1.44864,1.891897 -0.23999,5.04034 -1.57356,2.37811 2.12509,2.28752 -0.47999,3.60025 -3.74787,1.55944 -0.71844,2.80604 -0.23999,4.80033 -1.0884,2.67777 2.37629,2.14766 1.19997,4.320295 0.49164,0.46641 2.86332,2.36433 -0.24,2.64018 -3.16836,1.50137 -0.005,2.55348 -1.43996,5.52039 1.48896,3.2646 0.9653,5.63776 -0.24,7.20049 1.61573,-1.14506 1.7917,3.77102 -0.47999,2.16015 -1.30036,-0.15501 -2.85606,-4.41077 -4.0799,-0.72006 0.15622,-3.03472 -3.72439,-1.87799 -5.27988,-4.08027 -2.42546,1.66164 -5.84186,0.0153 -7.91982,0.48003 0.39238,2.10252 -1.14226,4.37984 -2.15995,1.92013 -1.4386,2.15076 -0.77792,-3.39948 -3.83991,-1.68011 -1.98096,2.04012 -3.73525,-2.33963 -5.99986,-2.16015 -0.90868,-1.40275 -4.6471,-0.32624 -4.79989,-1.68011 1.59088,-0.86344 2.99049,-2.13306 2.63994,-3.36025 1.85093,0.36951 2.32406,-0.57681 2.63994,-2.40016 1.55211,-2.15403 1.6662,-2.60172 3.83991,-5.040345 -1.90015,-3.12138 -6.58277,-6.26939 -9.35978,-3.60024 -2.21187,-1.94451 -1.34289,-2.46284 -1.67997,-4.08028 0.29685,-1.82337 1.7033,-3.174307 0.95998,-5.04035 -1.94494,0.07926 1.24553,-5.003424 -2.39994,-2.64018 -3.88735,2.469899 -5.11602,-5.31868 -6.47985,-0.48003 -2.39777,0.982654 -6.43771,-1.326719 -3.59992,-3.36024 -2.18632,-1.45807 -2.16435,-2.024697 -0.71998,-3.60024 0.56574,-0.496706 2.39007,-3.091783 3.59991,-4.3203 3.74726,1.678111 1.09836,-1.759211 3.83991,-0.48003 0.90296,2.287764 5.73688,0.707349 7.19984,2.40016 0.97311,0.271659 4.94621,-1.114094 5.99986,0 2.38055,3.440293 7.34417,-0.177477 10.55976,3.36023 1.56138,-3.27486 2.15399,1.872816 4.3199,-0.24001 0.80435,-0.723243 3.27135,2.012306 3.59991,-0.24002 2.24241,0.497201 1.8519,3.041265 3.11993,3.36023 1.49093,0.06051 0.54926,-1.921508 1.67996,-1.68011 l 0.24,0.24001 z'
          LU: s \path.province d: 'm 194.62208,10.227235 c 1.29654,-0.272996 1.84647,-0.594632 2.39994,0.96007 0.29423,0.415446 0.0153,3.538609 0.95998,1.20008 0.0252,-1.275303 1.81067,-2.09674 2.39994,-1.20008 1.26126,-0.470813 0.70038,1.712884 1.91996,0.96007 0.94731,0.740657 2.92707,1.981521 2.87993,3.12021 1.07577,1.429426 2.83375,2.621482 1.91996,2.8802 -0.18948,0.42401 1.89645,-0.827389 2.87993,0.48003 2.10607,-0.244284 3.31587,-0.614279 3.83991,0.72005 -1.07633,2.845273 -1.94968,4.89035 -4.55989,4.3203 -0.71709,1.838544 1.12689,1.203561 1.19997,2.8802 -0.11591,2.645896 2.72335,1.503928 1.67996,4.32029 1.53706,2.066814 3.11421,1.382074 2.87994,4.3203 1.57953,2.115354 2.78579,-3.156923 3.59991,-0.72005 2.04588,2.34732 -2.6521,3.715022 -3.35992,3.60025 -0.22194,1.318086 -2.20516,2.417282 -0.47999,3.36023 -0.41151,-2.903962 1.31009,0.243883 2.87993,0.72005 1.4469,3.546286 0.7042,3.704233 -0.0202,5.239912 0.98578,1.447903 -1.0645,3.121356 -2.85971,4.360748 -0.0562,-0.60374 -3.47586,0.854879 -2.63994,2.40016 1.84147,1.557429 -1.88011,1.489856 -0.23999,3.84027 -1.835,1.109454 -0.8404,4.874619 -3.83991,5.76039 -0.7505,1.337255 -1.38555,5.763186 -2.63994,2.8802 0.66496,-2.329276 -3.13417,-3.004848 -4.5599,-3.12022 -1.63088,1.321317 -5.4182,1.518836 -6.95984,1.20009 -1.2665,-1.530345 -3.94058,-2.888976 -4.79989,-3.36023 2.21828,-0.666053 -0.0373,-0.763911 -1.67996,-0.96007 -2.76957,-1.449612 -1.03541,-1.148048 -1.91995,-2.8802 -0.3082,-1.529597 1.71566,-5.141433 1.67996,-6.48044 -4.15987,-0.327687 -1.75057,-5.249332 -3.35993,-5.28037 0.78147,-1.737893 4.14718,-4.247875 2.39995,-7.92054 0.69353,-2.452407 -1.53578,-5.943228 0.6816,-8.928724 -1.25487,-1.063206 2.56867,-3.718496 1.23836,-5.232246 1.98693,-0.145156 2.7813,-0.869402 3.59991,-2.64018 1.80706,-2.155969 -0.18199,-4.130977 1.91996,-4.56032 -0.89504,-1.850757 0.69913,-1.902839 0.71998,-3.36023 -0.66915,-0.954058 0.34801,-0.967368 0.24,-2.8802 z'
          O: s \path.province d: 'm 213.82163,19.107845 c -0.22924,-0.790713 2.94973,-0.64901 2.63994,-0.96006 1.99459,0.178625 2.00535,0.131014 4.5599,0.72005 0.6939,-0.853992 3.19554,0.712741 4.79989,-0.48004 0.42761,1.1368 2.80836,1.273409 4.3199,0.96007 0.94628,-0.416203 3.48162,0.55861 4.55989,0 1.24342,-0.182371 2.13379,-1.400825 3.35992,-0.96007 0.27632,1.129838 1.8059,0.651958 2.87994,1.4401 2.91904,-2.04901 3.57524,0.110827 5.03988,-1.4401 0.28826,-0.834638 2.05985,-1.291145 2.87994,-2.40016 0.12909,0.487413 1.97983,0.981437 1.91995,1.92013 -0.11743,1.488013 3.49434,1.785887 2.39995,1.92013 -0.5854,0.6152 0.57737,0.377689 0,0.72005 1.27858,0.581111 0.91065,-0.55547 4.3199,0 1.86344,0.168002 5.39067,-0.05561 5.03988,0.48004 1.97867,0.142353 3.36548,1.470331 4.79989,2.88019 2.42777,-0.701322 3.83391,0.740416 6.95984,0.72005 2.58869,0.317526 3.70646,1.244925 5.03988,1.20009 1.91587,0.775349 3.67394,1.361157 5.99986,1.68011 1.1424,-0.415472 3.3048,0.230113 1.67997,1.4401 0.42824,1.317725 0.86697,4.887327 -1.67997,2.64018 -1.17565,0.3221 -2.06146,1.585943 -3.59991,1.20008 -0.24862,1.790843 -1.09758,3.629808 -3.11993,3.36023 -1.51138,-0.635504 -1.68334,-3.772323 -4.3199,-1.44009 -0.54587,2.408611 -3.73166,-0.05704 -3.59992,2.40016 -0.28137,2.752911 -2.51575,1.175358 -3.83991,2.16015 -1.06505,1.131795 -3.89186,-0.115163 -5.03988,0.24002 -1.09176,2.014479 -3.74411,1.599104 -5.27988,2.40016 -1.54988,-0.346006 -5.10132,-2.832119 -5.75987,0.48003 -0.96574,3.293291 -4.97108,0.475249 -5.27988,-0.24001 -1.33068,-1.897536 -1.43159,-2.462094 -3.59991,-2.64018 -1.2377,-0.509285 -2.27358,3.389879 -3.59992,0.96006 -1.85468,0.852077 -2.61315,0.940854 -4.5599,0.24002 -1.25796,-2.727718 -2.2268,1.243723 -3.59991,1.92013 -2.30439,-0.946416 2.13989,2.448169 -1.67996,2.40016 -2.26986,0.456249 -5.30794,-1.31386 -7.19984,0.48004 -1.42459,1.685276 -3.28988,-1.926517 -3.83991,-3.84027 -2.50504,-0.978193 -2.46923,-2.131229 -2.87993,-0.24001 -1.4457,-1.645992 0.68293,-1.851527 0.71998,-3.36023 1.02123,0.398211 6.1746,-2.165778 2.63994,-4.08028 0.4511,-0.153694 -3.66602,3.763496 -3.11993,0 0.64853,-2.199596 -3.47175,-1.276579 -2.39994,-4.56032 -0.75695,-0.799576 -2.4434,-1.869293 -1.91996,-4.08028 -2.19698,1.12252 -1.26833,-3.213353 0.23999,-1.4401 1.52624,-0.826395 2.48366,-2.383545 3.11993,-4.80033 z'
          B: s \path.province d: 'm 477.57555,67.831195 c 2.33561,-1.282972 3.96236,0.10082 6.47985,0 -0.2857,1.997179 -2.08749,2.454624 0,3.36023 1.35929,1.699774 -2.52343,2.838224 -1.43996,0.96007 -2.90522,-1.031141 0.92257,2.137241 0.47998,1.68011 2.31409,0.286309 1.98779,0.562798 3.83992,0.96007 1.92762,-0.75232 1.58295,-0.567294 3.35992,-0.96007 1.8902,-0.06873 0.84422,1.965432 3.11993,0.72005 1.66607,-0.131756 1.36008,3.196276 3.35992,1.4401 0.99853,0.537172 1.82762,2.530444 0.71998,3.12022 0.59691,1.689889 -1.83245,0.412963 -1.19997,2.40016 1.9814,-0.800398 1.26976,2.772157 -0.95998,2.16015 -0.63648,1.35818 -2.87154,-0.875108 -1.91995,1.92013 0.75668,2.756197 3.72142,0.605056 4.55989,2.64018 1.49076,2.01204 3.82727,2.23782 5.51987,0.72005 1.01372,-0.07571 4.92265,-0.192983 3.35993,3.12022 0.15366,1.30797 -5.80917,3.75303 -5.99986,3.84026 -3.5789,2.14351 -5.76399,4.372845 -8.8798,5.760395 -0.96987,1.32883 -2.70445,6.11776 -1.91996,2.88019 0.0264,0.94014 -1.24503,1.76279 -0.71998,1.68013 -0.55443,4.28262 -8.05892,3.35949 -9.11979,4.80033 -2.07642,0.32209 -4.12282,1.59188 -3.59992,1.20008 -2.66692,1.5052 -2.3649,-0.49842 -3.59991,-0.48003 -3.17889,-1.61784 0.98926,-0.30873 0,-1.92013 0.91242,-1.35673 -1.46681,0.1657 -1.67996,-2.40017 1.17558,-2.06617 -3.1211,-1.58622 -2.63994,-2.40016 -0.29941,-0.93856 0.37062,-3.27084 -1.19998,-3.60026 -3.01183,-0.74886 -1.45741,-2.285435 -0.71998,-2.400165 0.47909,-1.52604 -1.04157,-1.14633 -2.39994,-2.40016 2.26429,-1.21746 2.9645,-0.7579 1.67996,-3.12022 -1.64111,-0.48405 0.47464,-1.9793 -0.24,-4.08028 1.39581,-1.778469 2.14207,1.95536 2.15995,0 1.27345,1.27673 2.22949,0.85668 3.35993,-0.48003 -0.60816,-1.148155 2.21366,-3.04696 -0.24,-3.60025 -2.20722,0.446803 2.0407,-1.636249 1.43997,-2.64018 -0.64745,-2.751239 1.28184,0.01123 1.91995,-1.92013 -0.37041,-1.203659 -1.20671,0.789461 -1.91995,-0.24002 -0.51293,-1.353362 1.33948,0.218771 0.95998,-1.92013 -1.88486,0.497771 1.91608,-2.356407 0.23999,-2.40016 -1.01884,-1.140086 2.53973,-3.725749 0,-3.36023 -1.60486,-1.435376 0.33636,-2.88769 -1.19997,-3.84027 1.00226,-0.02084 3.36344,-0.601158 5.03988,-1.20008 z m -3.11993,17.04117 c 0.93346,0.695437 0.21712,-0.739075 0,0 z m 8.6398,-9.36064 c 1.64897,-1.361298 -1.34011,-0.828579 0,0 z m -9.59977,32.882265 c -0.85333,0 0.8533,0 0,0 z'
          P: s \path.province d: 'm 288.9375,41.1875 c -2.93726,2.626088 -6.68056,-0.265748 -9.84375,2.65625 -0.49448,2.619106 -1.67401,4.370709 -3.34375,5.5 1.5369,2.272461 -2.99491,4.725232 0.46875,5.28125 -0.0981,2.554261 -1.77855,6.722395 -0.25,8.65625 -1.66827,2.218339 0.0428,4.582277 -1.65625,5.03125 -2.74824,0.656932 0.21356,1.091454 -0.5,3.34375 -3.20498,-0.295933 -1.87395,5.004166 -2.15625,5.53125 1.31203,0.805334 3.35412,0.05002 2.875,2.875 -0.13394,1.574484 -1.44824,3.965432 -2.625,5.78125 0.53175,2.838166 3.48468,-1.05421 4.78125,1.90625 0.7537,3.559158 2.55917,3.80435 4.34375,0.71875 2.22256,-1.935443 3.29981,4.763677 4.3125,2.40625 2.07643,-0.133024 3.40672,-0.638121 1.77163,1.269293 -0.12072,3.289254 3.82496,-0.717016 5.41587,1.136957 1.72503,-1.91235 4.0229,-1.27787 6.25,-0.96875 2.81044,2.790306 1.0725,-0.526595 0.96875,-2.625 1.06919,-0.421735 3.68103,-2.496128 4.78125,-3.84375 2.63895,-1.980537 -1.54649,-0.797871 -3.34375,0.21875 0.53666,-2.155034 3.34114,-4.600676 -0.5,-3.84375 -3.16099,1.022541 0.16173,-2.76523 -0.9375,-2.15625 -1.13419,-2.026285 -4.7961,0.130073 -3.125,-3.34375 -2.15918,-2.008776 -1.45085,-4.559922 -2.40625,-6.5 0.62369,-2.113113 -1.43567,-0.964235 -1.6875,-2.875 -0.83779,-3.085035 3.80788,-0.320192 2.40625,-3.34375 -0.56113,-0.754155 -2.1931,-2.671439 -0.96875,-3.125 -0.24811,-0.623987 0.70489,-1.998892 0.25,-3.84375 -1.22501,-1.848403 1.79908,-0.383657 3.125,-2.65625 1.21357,-1.296769 3.63717,0.545076 2.15625,-2.15625 -2.91401,-0.0047 -2.26451,-1.774528 -0.71875,-2.375 -0.55694,-1.898245 -3.83472,1.923416 -2.875,-2.40625 -0.15104,-3.597387 -4.61822,-1.93469 -5.28125,-5.28125 -0.60896,-0.200188 -0.94652,-1.092209 -1.6875,-0.96875 z m 13.1875,9.375 c -1.24228,1.426221 -0.72944,4.198782 0.5,1.65625 -0.14166,-0.510561 0.43097,-1.76838 -0.5,-1.65625 z m -7.4375,3.59375 c 1.40199,0.185244 -0.39787,1.05213 0,0 z m 5.28125,23.28125 c -2.84209,0.502841 0.87927,2.022344 0.25,0.25 l -0.25,-0.25 z m 0.25,1.1875 c -0.12906,0.7678 0.7678,-0.129064 0,0 z m 0.96875,1.21875 c -0.24208,0.560466 0.59415,0.761399 0,0 z m 0.21875,0.71875 c -0.74658,0.90257 0.19225,0.33065 0,0 z'
          Z: s \path.province d: 'm 366.69811,85.352395 c -0.31789,-2.835785 2.79659,-0.380379 4.79989,0.48004 2.16399,-1.077279 4.55301,2.897217 7.43983,1.4401 2.61265,1.65e-4 2.77241,-3.842078 4.3199,-6.00042 -1.54037,-0.04454 -3.54638,-2.789649 -2.63994,-5.04034 -1.86219,-2.295764 1.49958,-5.279305 1.43996,-7.44051 -2.31297,-0.706423 3.64586,-4.643335 1.19998,-5.52038 1.47657,-2.504305 2.4595,-1.4246 4.0799,-3.84027 -1.86354,-1.151247 1.50681,-1.975821 3.35992,-2.16014 -1.04492,-2.497564 3.38043,-1.371842 3.35993,-3.84027 0.55582,1.415464 2.06577,2.634236 0.23999,4.08028 0.0646,3.212109 0.66426,2.745439 0,5.04035 -0.28379,0.346058 2.44245,1.727608 0.95998,2.64018 -0.72481,1.763638 3.84613,2.141097 1.67996,3.36023 -0.47389,1.592225 -2.99258,4.921566 -1.19997,5.04035 -0.90774,-2.546334 3.81618,0.356042 3.32154,-3.888383 -0.94887,-2.941345 1.47049,-1.480906 0.99836,0.288133 -0.0612,2.490484 -0.6946,5.941023 -0.24,7.20049 -0.50012,1.531329 0.62701,3.400659 -1.19997,4.08028 -0.25276,-3.318681 -3.68157,2.693677 -1.43996,2.8802 2.71465,1.65314 5.98196,0.297302 7.67982,3.12022 0.19478,1.467957 3.39453,1.950184 2.63994,4.80033 0.23468,1.76706 -0.0218,2.0414 1.43996,2.64018 1.84488,-0.02475 3.5244,1.96257 3.83992,3.36023 1.8398,2.438965 5.05704,0.52822 5.75986,2.400155 1.42352,2.29907 1.98781,6.84929 4.07991,8.16057 -0.0498,-1.82462 1.1076,0.12981 3.59992,0.24002 1.4143,-1.89482 2.91288,-1.63166 4.55989,-3.12021 3.64177,-0.32416 4.06959,2.7206 4.07991,5.04034 1.98634,3.04529 -2.46649,2.39259 -1.67996,5.28036 -2.09109,1.17214 -4.14133,2.0378 -2.39995,3.84027 -2.71089,-0.87085 -5.72682,2.3023 -6.71984,-0.24003 -1.00941,-3.2773 -5.89032,-2.54426 -7.67983,-4.80032 -2.14805,-2.11743 -3.66089,-0.8077 -5.75986,-3.36023 -0.0895,-0.84534 -2.7146,-2.55464 -4.3199,-2.16015 -0.70555,1.59019 4.3455,7.65 -0.24,2.40017 -3.29313,-1.87348 -1.07397,4.04223 -1.67996,5.04034 -1.25175,4.17757 -2.88814,0.54025 -3.83991,0.72005 -0.2234,2.62882 -2.98142,3.16782 -3.83991,0.48004 0.58482,3.65376 -5.52957,3.35639 -2.39995,-0.24003 -1.24457,2.99267 -4.81928,-2.48091 -4.55989,0.96007 -3.5542,-0.3837 -3.93497,1.066 -5.27988,3.60025 -2.43404,0.56144 -1.26805,-2.78161 -3.35992,-0.72006 -1.33581,1.56499 -1.30089,3.74291 -3.11993,4.3203 -4.77357,3.50066 -6.85245,-5.07913 -11.03975,-5.7604 -1.9508,-3.2036 -4.62656,-1.0959 -7.43983,-2.64017 -2.08966,-0.95012 -2.69906,-6.6036 -0.71998,-7.92054 0.0585,-3.2777 2.39704,-3.40539 3.35992,-0.48003 2.95523,-0.8643 2.3807,-2.11661 1.19998,-4.80033 0.28564,-2.64334 -1.4994,-4.746985 1.91995,-4.320305 1.07073,-2.34847 4.85145,-2.74187 3.59992,-5.28036 -2.41861,-0.80642 -0.36901,-4.12088 -1.43997,-5.52038 -0.66613,-1.474286 -0.58781,-2.380968 -0.71998,-3.84027 z'
          HU: s \path.province d: 'm 399.09375,46 c -2.25908,0.818772 -2.79144,2.775779 -2.875,4.78125 -0.0729,2.107236 -2.02262,2.32664 -1.90625,4.5625 2.18893,0.297736 -0.42411,3.253353 0,4.5625 1.40407,1.133996 -1.19167,3.531408 0.9375,3.375 1.14578,2.145391 -1.62773,2.331728 1.6875,4.0625 1.17189,0.130594 -1.44113,3.412961 -1.6875,5.0625 -0.69421,2.595339 1.29888,-1.646899 2.875,0 1.22768,-1.663999 0.49671,-6.724888 1.6875,-3.375 0.75053,2.244187 -0.70094,6.784261 0,8.15625 -0.50296,1.514158 0.61469,3.378814 -1.1875,4.09375 -0.28487,-3.320272 -3.68826,2.704166 -1.4375,2.875 2.70001,1.650467 6.01042,0.313895 7.65625,3.125 0.27382,1.466355 3.38086,1.949418 2.65625,4.78125 0.23328,1.778593 0.002,2.049648 1.4375,2.65625 1.82959,-0.02964 3.50344,1.911565 3.84375,3.34375 1.80676,2.43142 5.0458,0.539415 5.75,2.40625 1.43014,2.28698 1.98064,6.86337 4.09375,8.15625 0.1654,-1.81492 0.57582,0.16661 4.0625,0.25 1.14914,-2.42058 3.04194,-2.22495 5.33825,-3.11415 3.39716,0.79491 1.15761,-3.06797 4.03675,-4.07335 2.66038,-3.245035 -2.36809,-2.342198 -2.15625,-4.5625 -2.08148,-1.890169 0.85289,-4.685927 2.375,-5.28125 1.41296,-1.030907 2.58492,-3.071612 4.09375,-3.84375 1.87238,-1.48025 -0.63752,-2.935058 -0.25,-4.09375 1.30147,-0.771047 2.75327,-2.580319 2.65625,-3.84375 1.36782,-4.596828 0.43889,-6.93492 2.40625,-11.28125 -0.24554,-0.812314 -0.68148,-2.795568 -0.71875,-2.15625 -0.14701,-1.174437 -1.72972,-3.372703 -1.6875,-4.78125 1.51878,0.16296 0.89192,-2.286592 1.90625,-4.34375 -2.44175,-0.316583 -2.28698,-4.46954 -5.5,-3.59375 -1.54811,-0.477533 -5.08714,1.163516 -6,-0.25 -2.05636,-0.951894 -2.33264,3.238155 -4.09375,-0.21875 -1.96633,-1.321983 -3.52989,0.477222 -5.28125,0.71875 -2.16726,1.516615 -4.43538,0.284179 -5.5,-0.96875 -0.98121,-2.550415 -3.07463,-2.139102 -4.8125,-3.59375 -1.7898,-2.142121 -3.88941,2.978444 -6.25,0.71875 -1.32378,-1.392334 -2.14801,3.334276 -2.875,0.25 -1.31603,-0.157621 -2.34043,-3.261481 -4.5625,-3.125 -0.62596,-0.589217 0.45024,-1.255727 -0.71875,-1.4375 z M 395.5,73.59375 c -0.12906,0.7678 0.7678,-0.129064 0,0 z M 389.25,64 c -2.89788,2.114482 4.24311,3.805837 0,0 z'
          GI: s \path.province d: 'm 510.21875,58.71875 c -1.59323,1.599792 -3.71149,0.371493 -4.5625,2.875 -1.90685,-0.678373 -5.19791,1.353506 -3.375,2.625 -0.7137,1.039709 -3.83495,0.308161 -4.78125,0.96875 -2.2482,-0.715961 -2.87369,-2.415973 -5.75,-2.625 -1.96861,-1.490038 -3.59189,0.533431 -5.53125,0.21875 -0.66853,2.749197 -5.52689,4.49175 -5.53125,0 -1.55442,-0.804312 -3.11529,-1.914548 -5.75,-2.15625 -2.9021,-0.55179 -0.37795,3.261209 1.1875,2.65625 -0.69748,3.01589 2.34045,0.760503 1.21875,3.125 -0.36058,2.530967 3.17842,-0.260093 4.5625,1.4375 2.92179,-1.42366 1.84419,1.835963 1.1875,2.375 0.11206,0.798749 2.47363,1.87612 0.25,2.90625 -2.6442,-0.107312 1.45157,1.650636 2.40625,0.9375 -0.50505,1.661413 3.53476,-0.100646 3.34375,0 0.0974,-0.462721 3.47727,-0.701176 2.40625,1.21875 2.31162,-2.500207 3.13984,0.953735 4.3125,1.1875 1.79724,-1.50781 3.05066,2.068166 1.4375,2.65625 1.28586,0.970489 -2.58546,1.676544 -0.46875,2.15625 1.66331,0.483177 0.30034,2.749218 -1.4375,2.40625 -0.83842,0.97313 -3.50497,-0.319436 -1.4375,2.375 0.40786,2.221522 3.53629,0.14083 4.0625,2.15625 1.6076,1.54363 3.12792,2.826393 5.28125,0.71875 0.38895,0.27643 5.24828,-0.786468 3.375,2.40625 0.78785,2.221388 2.57746,-1.854712 4.3125,-1.1875 1.43047,-0.985 2.84832,-2.942575 3.84375,-3.375 0.64785,0.1777 1.43412,-3.186351 3.125,-3.09375 1.73579,-1.560794 1.99601,-2.989531 2.375,-5.0625 -2.60501,-0.711207 0.056,-5.422452 -2.625,-5.5 -1.87405,0.78479 -2.66893,-7.00503 0.25,-5.78125 0.55331,1.279678 2.22109,-0.228092 2.375,0.25 0.0495,-0.258921 0.62294,-1.831242 0.71875,-1.9375 -0.0269,-1.184087 1.49074,-1.109316 -0.46875,-1.90625 -1.33906,0.542651 -1.82519,-0.847864 -2.625,0 -2.05548,-1.113227 -0.54571,-3.013037 -1.21875,-3.84375 -1.96884,1.79443 -2.91617,-1.061273 -4.5625,-0.71875 -0.6937,-0.678811 -1.28176,0.501915 -1.90625,-0.46875 z M 482.375,72.875 c -1.2757,-1.934316 -0.11034,-0.362162 0,0 z m -1.1875,-12.96875 c -1.82966,2.705493 2.84001,2.900217 0,0 z'
          SO: s \path.province d: 'm 366.69811,85.592415 c -0.39696,2.577314 2.64772,4.40247 0.23999,6.96048 2.337,1.9717 2.61527,2.98996 1.19998,5.28036 -2.12492,1.02932 -3.70591,2.504425 -5.27988,2.880195 0.86235,1.88506 0.37418,5.03221 1.67996,6.96049 -1.98763,2.01501 -3.13284,1.03597 -4.3485,-1.00253 -1.30774,0.71529 -1.37078,3.63408 -2.61134,5.08281 -0.98746,4.55517 3.3507,5.38768 3.35992,8.64059 0.78707,2.38356 -3.00265,-1.04407 -4.79989,0.48003 -2.05571,1.93764 -4.54263,0.47855 -6.47985,0.96007 -2.0824,-1.32457 -2.51578,-3.62765 -5.03988,-3.36023 -0.49907,-2.10203 0.42741,-2.38139 -1.91996,-3.36023 -2.20983,-2.74643 -4.20758,0.90567 -6.23985,-1.92013 -0.37597,-3.59706 -2.47026,0.14286 -4.5599,0 -3.19077,0.89961 -7.11353,-1.15952 -8.87979,-3.36023 -3.11681,-0.62135 0.87113,-4.87235 -2.39995,-3.84028 -1.42575,-2.12353 -1.91453,-2.68408 -4.55989,-3.36023 -1.35257,-2.973555 1.08026,-2.749795 2.15995,-1.68011 1.29376,-1.777755 1.07624,-3.501435 3.11992,-4.560315 -0.0202,-2.50918 3.62651,-1.76769 2.39995,-4.56031 -0.11236,0.30471 -0.38327,-4.740266 1.19997,-1.68012 1.59677,2.79777 2.99207,2.81231 4.3199,0 0.1945,-2.161826 2.96207,-0.3573 3.35992,-3.12021 0.94437,-1.142345 1.73607,-3.915789 4.07991,-3.84026 2.82014,-0.0832 0.58877,-4.46938 3.83991,-3.84027 1.87696,1.457323 -3.22289,5.211791 0.71998,4.3203 2.10274,1.841965 4.66951,-0.274242 5.03989,-1.68012 0.53758,-2.02519 0.56942,-2.168609 2.39994,-2.64018 1.13978,-1.453201 5.83795,-1.439727 5.99986,1.4401 1.66115,-1.64144 4.90693,-0.518294 3.11993,1.4401 1.64071,1.680482 0.61209,4.474248 3.59992,4.08028 2.15908,1.729383 3.52053,0.528259 5.27988,-0.72005 z'
          L: s \path.province d: 'm 442.28125,47.1875 c -2.01926,0.805071 -0.32809,3.002789 -1.1875,3.84375 -0.64637,0.238583 1.75885,2.391031 0.46875,3.34375 0.62906,1.280589 2.17179,2.631329 2.90625,3.375 -0.22767,2.437056 -1.29658,4.994351 -1.4375,4.3125 -0.63253,1.406336 1.90954,3.704628 1.1875,4.5625 0.80428,0.963444 0.60398,1.227525 0.71875,2.65625 -1.62173,4.17206 -0.91302,6.458833 -2.15625,11.03125 0.13162,1.386256 -1.83564,2.707786 -2.875,4.09375 0.79908,0.251063 2.07529,3.175256 0,3.59375 -1.37862,1.282746 -2.2403,3.574047 -4.5625,4.0625 -0.24959,1.096718 -4.0975,3.592229 -1.21875,5.28125 0.41714,1.452857 4.48937,1.623543 1.6875,5.0625 -2.15473,0.47307 -2.75504,4.20915 -1.1875,5.28125 -0.79712,2.4148 2.02199,5.58677 2.875,1.65625 0.98489,1.47622 2.55114,0.45778 4.0625,0.71875 1.77947,1.16603 4.27893,-0.92434 5.53125,-1.1875 2.30936,-1.14658 2.73914,-0.43568 5.28125,-1.1875 0.88488,-1.04369 3.03858,-3.21995 3.59375,-4.5625 -2.80129,-2.75923 2.69025,1.25007 3.125,-1.4375 -1.34714,-3.673689 4.22276,-3.288288 6.71875,-3.125 -0.0657,-1.827885 -2.18845,-2.600121 0.71875,-2.875 1.08775,-1.08202 -2.20946,-2.756377 -0.96875,-3.375 -0.0546,-1.368513 0.35981,-5.020215 1.9375,-2.625 -0.10822,-0.877192 1.81552,1.428072 2.625,0 1.71956,0.312552 0.92855,-2.683282 1.9375,-2.90625 -0.29711,-2.557234 -2.79205,-0.623391 -0.5,-2.625 1.98039,-0.507365 -0.16898,-2.99375 1.6875,-2.875 1.3991,1.001962 0.97997,-2.337678 0.5,-0.5 -2.3379,-0.231602 -0.90389,-1.11598 -0.5,-0.9375 0.60932,-1.139911 -0.92652,-2.273008 1.21875,-3.375 -1.97895,-1.064056 0.30334,-2.035395 0.21875,-3.84375 -2.88444,0.131714 -0.89135,-1.910114 -1.65625,-3.34375 -1.73197,-0.747698 4.63405,-0.04667 4.3125,-2.15625 0.76578,-2.242295 -0.58156,-1.634149 -0.96875,-2.65625 -0.0931,-2.34345 -3.69441,-1.254988 -2.875,-4.5625 -1.61368,0.916715 -2.1196,1.482833 -4.09375,2.65625 -0.61156,-0.426356 -3.86706,2.358226 -4.3125,-0.5 0.32943,-2.166708 -0.49452,-2.948473 -0.46875,-4.5625 0.36794,-2.023754 -2.10387,-4.919766 -3.375,-5.75 -1.79897,1.009465 -3.23237,-0.660627 -4.78125,0.96875 -1.54187,-2.510894 -3.31814,-3.377348 -5.78125,-3.125 -1.52705,0.05589 -2.93639,-0.682526 -5.03125,-1.6875 -1.38082,0.69933 -2.16408,-0.773105 -3.375,-0.71875 z m 30,28.5625 c 2.46541,-0.07237 -0.13186,1.061438 0,0 z m 2.1875,8.875 c 0.71397,0.740425 0.26623,0.289956 0,0 z'
          PM: s \path.province d: 'm 551.96875,152.8125 0.25,0.21875 0,0.5 -0.25,0.21875 0,0.25 -0.25,0.25 L 551.5,154 l -0.25,0.25 -0.25,0 -0.46875,-0.5 -0.25,0.25 -0.21875,0 0,0.25 -0.25,0 -0.46875,0 -0.25,0.21875 -0.46875,0 -0.25,-0.21875 -0.71875,0.21875 0,-0.21875 -0.25,0 0,0.21875 -0.21875,0 0,0.25 0,0.25 -0.25,-0.25 -0.25,0 0,-0.25 -0.21875,0 -0.25,0 -0.25,0 0,0.25 -0.25,0 -0.21875,-0.25 -0.25,0.25 -0.71875,0 0,0.25 -0.25,0 -0.21875,0 -0.25,0.46875 -0.25,0.25 0.25,0.21875 -0.25,0.25 -0.21875,0 0,0.71875 0.21875,0 -0.21875,0.25 0.21875,0 0.25,0 0.25,0 0.21875,0 0.5,0 -0.25,0.21875 0,0.5 0.25,0 -0.25,0.21875 0.25,0.25 0,0.25 -0.25,0.46875 0,0.25 0,0.25 -0.25,0.46875 0.25,0.25 L 545,160 l 0.5,0 0.46875,0 0.5,0 0.21875,-0.25 0,0.25 0.25,0 0,-0.25 0.25,0 0.21875,-0.21875 0.5,0 0.21875,-0.25 0.25,0 0.25,0 0.21875,0 0.25,0 0.25,0.25 0.46875,0 0.25,0 0.21875,0.21875 0.25,0 0.46875,0 0.96875,0.5 0.5,0.21875 0.21875,0.25 0.5,0.46875 0.9375,0.5 0.25,-0.25 0,0.25 0.25,0.21875 0.21875,0 0.25,0.25 0.25,0 0.21875,0 0.25,0.25 0.46875,0.46875 0.25,0 0.25,0 0,0.25 0.21875,-0.25 0,0.25 0.25,-0.25 0,0.25 0.25,0 0.21875,0.46875 0.25,-0.25 0.71875,0.25 0.71875,-0.25 0.25,-0.46875 0,-0.25 0,-0.46875 0.25,0 0,-0.25 -0.25,-0.46875 -0.25,0 0.5,-0.25 -0.25,-0.21875 -0.25,0 0,-0.25 -0.71875,-0.25 0,-0.21875 0,-0.25 0.5,0.25 0.21875,0 0,0.21875 0.25,0 0,0.25 0.25,0.25 0.46875,-0.25 -0.46875,0 0,-0.25 -0.25,-0.21875 0,-0.25 -0.25,0 -0.21875,-0.46875 -0.25,0 0,-0.25 0,-0.46875 -0.25,0 -0.21875,-0.25 0,-0.25 0.21875,-0.25 0,-0.21875 -0.21875,0 -0.25,-0.25 -0.25,0 0.25,-0.25 -0.5,0 0.25,-0.46875 0.25,-0.25 -0.25,0 0,-0.21875 -0.25,0 0,-0.25 0.5,0 -0.25,-0.25 -0.46875,0 -0.5,0.25 -0.46875,0 0,-0.25 -0.25,0 -0.21875,-0.21875 0,0.21875 0.21875,0.5 -0.21875,-0.25 -0.25,-0.46875 0.25,-0.5 -0.25,0 0,-0.46875 -0.25,0 -0.21875,0.46875 -0.25,0 -0.25,-0.21875 0.25,-0.25 -0.25,0 -0.21875,0 0,-0.25 0.21875,0 -0.21875,-0.21875 0.21875,-0.25 -0.21875,0 0,-0.25 0.21875,0 -0.21875,-0.21875 -0.25,0 -0.25,0 -0.21875,0 0,0.46875 0.21875,0.25 0,0.46875 -0.21875,0.25 -0.25,0.21875 -0.25,-0.46875 0.25,0 0,-0.96875 -0.25,0 0,0.25 -0.46875,0 0,0.46875 -0.25,-0.46875 -0.21875,0 0,-0.25 0,-0.21875 0,-0.25 0,-0.25 0,-0.21875 -0.25,0 -0.25,0 z m 1.9375,2.15625 0,-0.25 -0.25,0.25 0.25,0 z m 4.5625,2.15625 0,0.21875 0,0.25 0.21875,0 0,-0.25 -0.21875,-0.21875 z M 524.375,160 l -0.96875,0.46875 -0.71875,0.96875 -0.21875,-0.25 0,0.25 -0.25,0 -0.25,0 -0.21875,0 0.21875,-0.25 -0.21875,0 -0.25,0.5 -0.5,0.21875 -0.21875,0 -0.25,0 0.25,-0.46875 -0.71875,0.25 0,-0.5 -0.25,0.5 0,-0.25 -0.96875,0.46875 -0.21875,0.25 0,0.46875 -0.25,0 -0.46875,0 0,-0.21875 -0.5,0 0,-0.25 -0.21875,0.25 -0.25,0.46875 -0.25,0.25 -0.21875,-0.25 0,0.25 -0.25,0.21875 -0.25,-0.21875 -0.46875,0.21875 -0.25,0.71875 -0.71875,0.25 -0.25,0.5 -0.21875,-0.25 -0.5,0.46875 -0.21875,0 -0.5,-0.21875 0,0.21875 0.25,0.25 -0.25,0 -0.21875,-0.25 -0.25,0.25 -0.25,-0.25 0,0.25 0,0.46875 -0.21875,0 0,0.25 -0.5,0.25 -0.21875,0 -0.25,0.21875 -0.25,0 -0.46875,0.25 -0.25,0.46875 -0.21875,0 -0.25,0.5 0.25,0 0,0.21875 -0.25,0 0,-0.21875 -0.25,0 -0.25,0.21875 -0.21875,0.96875 -0.5,0.25 -0.21875,0.21875 0,-0.21875 -0.25,0.46875 -0.25,0 0,0.5 -0.71875,0.46875 -0.21875,0.46875 -0.96875,0.96875 -0.46875,0 -0.5,-0.25 -0.21875,0.5 -0.25,0 -0.25,0.46875 -0.21875,0.46875 -0.25,0 -0.25,0 0,0.25 -0.46875,0.46875 -0.71875,0.5 -0.5,0.21875 0,0.25 -0.21875,0.25 -0.5,0.21875 0,0.25 -0.46875,0 -0.46875,0.25 -0.25,0.25 0,0.46875 -0.25,0 0,0.46875 0.25,0.25 -0.25,0.46875 0.25,0 0,0.25 0.25,0.25 0.21875,-0.25 0.25,0.46875 0.25,0 0.21875,0 -0.21875,0.25 -0.25,0 0.25,0.25 0.21875,0 0,0.46875 0.5,-0.25 0,-0.46875 0.46875,0 0,0.46875 0.25,0 0,-0.21875 0.21875,0.21875 0.25,-0.21875 -0.25,0 0.5,-0.25 0.46875,0.46875 0,0.25 0.5,0 -0.25,0.25 -0.25,0 -0.25,0 0,0.21875 0.25,0 -0.25,0.25 0.25,0.25 0.25,0 0.25,0 0,0.46875 0,0.25 0,0.21875 0.46875,-0.21875 0.25,0.21875 0,0.25 0.71875,0.25 0,-0.25 0,-0.46875 0,-0.25 0.21875,-0.25 0,-0.21875 0.25,0 -0.25,-0.5 0,-0.21875 0.5,-0.25 -0.25,0 0,-0.46875 0.25,0 0.21875,-0.25 0.5,0 0,-0.25 0.46875,0.25 0,-0.25 0.25,-0.46875 0.21875,-0.25 0.5,0.25 0.21875,0 -0.21875,-0.25 0.21875,0 0,-0.21875 0,-0.25 0,-0.25 0.25,0 0.25,0 0.71875,0.25 0.71875,0.25 0,0.21875 0.25,0 0.46875,0.5 0.25,0 0.46875,0.21875 0.46875,0.5 0,0.46875 0,0.25 -0.21875,0.21875 -0.25,0.5 -0.25,0.21875 0.96875,1.21875 -0.25,1.1875 0,0.25 0.5,0.46875 0.46875,0.5 0.71875,0.71875 0.46875,-0.25 0.25,0.25 0.46875,0.21875 0.25,-0.21875 0.25,-0.25 0.96875,0.25 0.21875,-0.25 0.96875,0.25 0.71875,-0.25 0.46875,0 0.25,0 0.71875,0.46875 0.46875,0.5 0,0.46875 -0.21875,0 0,0.46875 0.21875,0 0.25,-0.21875 0.25,0.21875 0.21875,0 0.25,0.25 0,0.5 0.25,0.21875 0.46875,0.25 0,0.25 0.25,0.21875 0.46875,0 0.5,-0.21875 0.21875,-0.71875 0.25,0 0.25,-0.5 0.21875,0 0.25,-0.46875 0,-0.25 0.25,0.25 0.46875,-0.5 -0.25,0 0.25,-0.21875 0.25,0 0.46875,0 0.25,0 0,-0.25 0.21875,0 0.25,-0.25 0,-0.21875 -0.25,-0.25 0.25,0 0.25,0 0.46875,-0.25 -0.25,0 0,-0.21875 0,-0.25 0.25,0.25 0.25,0.21875 0,-0.21875 0.25,0 0,-0.25 -0.25,0 0,-0.25 0.25,0 0.21875,-0.21875 0.25,-0.25 0,-0.25 0,-0.21875 0,-0.5 0.25,0 0,-0.21875 0.21875,0 0,-0.25 -0.21875,0 0.21875,-0.5 0.25,-0.46875 0,-0.46875 0,-0.25 0,-0.25 0,-0.21875 0.25,-0.5 0,-0.21875 0,-0.25 0.21875,0 0,-0.25 0,-0.21875 0.5,-0.5 0,-0.21875 0.21875,0 0.25,-0.5 0.25,-0.21875 -0.25,0 0.25,-0.25 0.46875,-0.25 0.25,0 0,-0.21875 0.21875,0 0,-0.25 0,-0.25 0.25,-0.46875 0.46875,0 0.25,-0.25 -0.25,0 -0.21875,0 -0.25,-0.25 0,-0.46875 0.25,-0.46875 0,-0.5 0.21875,-0.46875 0.25,0 0.46875,0 0.5,0 0,-0.96875 0.46875,0 -0.25,-0.46875 0.25,-0.25 -0.25,0 0,-0.21875 0,-0.25 0,-0.25 0,-0.46875 0.5,-0.5 0,0.25 0.25,-0.25 -0.25,-0.21875 -0.5,0 -0.21875,0 0.21875,-0.25 -0.21875,0 0.21875,-0.46875 0,-0.25 0,-0.25 -0.21875,0.25 -0.5,0 -0.21875,-0.25 -0.25,0 -0.25,0 -0.21875,-0.21875 0,-0.25 -0.71875,0.25 -0.25,-0.25 -0.25,-0.25 -0.21875,-0.21875 -0.5,-0.25 -0.46875,0.25 0,0.21875 0.25,0.25 -0.25,0.46875 -0.46875,0 -0.25,0.25 -0.46875,0.46875 -0.25,0 -0.25,0.25 -0.21875,0.25 -0.25,-0.25 0,0.25 -0.71875,0 -1.4375,-0.71875 -1.4375,-0.71875 -0.71875,-0.96875 -0.25,-0.71875 0,-0.71875 0.25,-0.25 0.21875,0 0.25,0.25 0.96875,-0.46875 0.46875,-0.75 -0.25,0 0,-0.46875 0,-0.25 0,-0.21875 -0.46875,0.21875 0,0.25 -0.25,-0.25 -0.21875,0.25 -0.25,0.25 -0.25,0.21875 -0.21875,-0.21875 -0.25,0.21875 -0.25,0 -0.21875,0.25 -0.25,0 -0.46875,-0.46875 -0.25,-0.71875 0,-0.5 0,-0.21875 0.25,-0.25 0.21875,0.25 0.25,0 0.25,0.21875 0,-0.46875 0.46875,-0.25 0,-0.46875 0.25,0 0.21875,0.25 0.25,0 0.71875,-0.71875 0.25,0 0,-0.25 0.21875,0.25 0.25,-0.25 0.25,-0.46875 0.21875,-0.25 -0.71875,0.25 -0.46875,0.21875 -0.25,0 0.25,-0.21875 0,-0.25 z m 0.46875,3.125 0.5,-0.25 -0.25,-0.25 -0.25,0.25 0,0.25 z m 3.84375,18.21875 0,0.5 0.25,0 0,-0.25 -0.25,-0.25 z m -28.3125,-2.625 -0.25,0 0,0.25 0.25,0 0,-0.25 z M 558.21875,160 l 0.25,0.25 -0.25,0 0,-0.25 z m -59.03125,16.3125 -0.5,0.25 -0.21875,0.46875 -0.5,0.5 0.5,0 0.21875,-0.5 0.25,-0.21875 0.25,-0.5 z m 20.375,15.375 0,0.21875 0,0.25 0.25,0 0,-0.25 0.25,-0.21875 -0.25,0 -0.25,0 z m -0.21875,0.9375 0,0.25 0,0.25 0,0.25 -0.25,0 0,0.21875 -0.25,0 -0.46875,-0.71875 0.25,0.5 -0.25,0 0,0.21875 0,0.25 0.25,0 0.21875,0.25 0.25,0.21875 0.25,0 0.21875,0 0.25,0 -0.25,-0.46875 0.25,0 0,-0.25 -0.25,0 0,-0.21875 0.25,-0.25 0.25,0.25 0.21875,-0.5 -0.21875,0 -0.5,-0.25 -0.21875,0 z m -0.25,0.75 0,-0.25 -0.25,0 -0.21875,0 0.46875,0.25 z m -44.15625,3.8125 -0.46875,0.25 -0.25,0 -0.25,0 0.25,0.46875 -0.46875,0 -0.25,-0.21875 0,0.21875 -0.25,0 -0.21875,-0.21875 0,0.21875 -0.25,0 0,0.25 -0.5,0 0,0.25 0.25,0 -0.46875,0.21875 0,0.25 -0.25,-0.25 -0.25,-0.21875 -0.21875,0 0,0.21875 0,0.5 -0.25,-0.25 -0.25,0.25 -0.21875,-0.25 0,0.25 -0.5,0.46875 -0.46875,0 0,-0.46875 -0.25,0 -0.21875,0.46875 -0.25,0.5 -0.25,0 -0.21875,0 0,0.21875 -0.25,0.25 -0.71875,0.71875 0,0.25 0,0.21875 0.25,0.25 -0.25,0 0,0.25 -0.25,0.21875 0.25,0.25 -0.25,0 0.5,0.25 -0.25,0 0.25,0.21875 0.21875,0 0,0.5 -0.21875,0 -0.5,-0.25 -0.21875,0 -0.25,0.25 -0.25,-0.25 0,0.25 -0.25,0 -0.21875,0 0,-0.25 -0.25,0.25 -0.25,-0.25 0,0.46875 -0.21875,0 -0.25,0.25 0.25,0 0,0.25 0.21875,0 0,0.21875 0.25,0.25 0,0.25 0,0.25 -0.25,0 -0.21875,0.21875 0,0.25 0,0.71875 0.21875,0.25 0,0.21875 0,0.25 0,0.25 0.5,0 0.21875,0.21875 0.25,0.5 0,-0.25 0.5,-0.71875 0.46875,0 0.46875,0 0.25,0.46875 -0.25,0.25 0.25,0 0.25,-0.46875 0.21875,0.21875 0,0.25 0.25,-0.46875 0.25,0.21875 0,-0.21875 0.21875,0 0.5,0.21875 0.46875,0.71875 0,0.5 0.25,0 0.21875,-0.5 0.25,0.25 0.25,0.25 0,-0.71875 0,-0.5 0,-0.21875 0,-0.25 0.21875,-0.71875 0.25,-0.71875 0.46875,0.25 0.25,-0.5 -0.25,0 0,-0.21875 0.25,0.21875 0.25,0 0,-0.21875 0.25,0 0.21875,0.21875 0.25,0 0,-0.21875 0.25,0 0,-0.25 0.21875,0 0,-0.25 0.5,-0.25 0,-0.46875 0.21875,0 0.25,0 0.25,0 0,-0.25 -0.5,0 0.5,-0.21875 0,-0.25 0,-0.25 0,-0.46875 0.21875,-0.25 0.25,0.25 0,-0.46875 0.25,0 0.21875,0 0.5,0 0,-0.5 0,-0.21875 0.21875,0 0,-0.25 0.25,0 0,-0.46875 0.25,0 0,-0.25 0.21875,0.25 0.25,0 0,-0.25 0,-0.25 -0.46875,0 0.21875,-0.21875 -0.71875,-0.5 0,-0.21875 0,-0.25 0,-0.25 0.25,0 0.25,-0.25 -0.25,0 0,-0.21875 0,-0.25 -0.25,-0.25 -0.71875,0 -0.21875,0.25 -0.25,0 0,-0.25 -0.46875,-0.21875 -0.25,0 0.25,-0.25 0,-0.25 -0.25,0 z m -2.15625,8.40625 0,0.25 0.25,0 -0.25,-0.25 z m 0.96875,4.3125 0,0.25 0,0.25 0.21875,0.25 0,-0.5 -0.21875,-0.25 z m -1.6875,0.5 0,0.25 -0.25,0.21875 0.25,0.25 0.21875,-0.25 0,0.25 0.25,0 -0.46875,-0.71875 z m 0.46875,1.6875 -0.25,0.71875 -0.21875,0.21875 -0.25,-0.21875 0,0.21875 -0.25,0 -0.21875,-0.21875 -0.25,0.71875 -0.25,0 0.25,0.21875 0.25,0.5 -0.25,0.21875 -0.25,0.25 0.25,0.96875 0,0.71875 0,0.25 0.25,0 0.46875,-0.25 0.46875,-0.71875 0.25,-0.25 0.25,-0.25 0,-0.21875 0.71875,-0.25 0.71875,0.25 0.71875,0.46875 0.71875,0.46875 1.1875,0 0.5,-0.46875 0,-0.25 0,-0.21875 -0.5,-0.71875 -0.46875,0.21875 -0.71875,0.71875 -0.96875,-0.46875 -0.71875,-0.71875 0,-0.25 -0.21875,-0.46875 0,-0.25 -0.25,0.25 -0.25,0 0,-0.25 -0.21875,-0.21875 -0.5,-0.71875 z'
          T: s \path.province d: 'm 436.05651,111.5142 c 1.2306,-1.51933 1.48174,-3.14204 3.59992,-0.72005 1.51058,-3.00084 2.88779,1.66025 4.79989,-0.96006 1.43807,-0.56575 3.09975,-0.43494 4.46171,-1.9147 0.41875,0.16695 4.62827,0.72952 4.17809,-1.44553 1.45818,-1.06333 3.8107,-3.19059 2.15995,-4.32031 -0.24282,-0.18313 4.54175,1.66823 3.59991,-0.96007 -0.52382,-1.601065 1.12551,-2.177855 3.11993,-2.880195 3.11901,1.47795 3.57683,-0.93793 5.51987,0 0.078,1.1042 -2.68714,1.61428 -0.95997,2.880195 2.48773,-0.10683 1.91191,2.40856 2.15995,3.36023 -0.83245,1.86514 2.24161,0.23433 2.87993,2.16016 -0.80504,1.01747 0.9425,3.28534 1.67996,2.40017 0.97858,2.5754 -2.54983,0.67681 -0.95998,2.40016 2.92716,0.11355 1.75302,2.08149 -1.67996,2.40017 -3.14265,1.20738 -5.43939,2.56223 -8.3998,3.12021 -0.87524,1.15043 0.21414,-0.58945 -1.19998,0.72004 -0.56462,1.60073 -1.71313,1.06538 -3.83991,1.4401 -4.18105,0.42797 -6.98645,6.45392 -8.3998,7.92055 -0.75455,1.64022 -4.02969,2.80117 -1.67997,4.56031 3.19783,0.57466 -2.66252,-2.53808 1.67997,0 2.29917,2.16576 4.24461,1.73687 0.28038,4.3001 -0.98787,1.59862 -6.18134,6.14742 -5.32027,3.62044 -0.024,-0.66052 2.53963,-0.28749 3.39001,-1.61274 1.7771,-2.8542 -4.27538,0.46515 -4.10999,-0.0674 -0.9362,0.69623 -2.18135,5.24268 -4.79989,3.12022 1.14495,-3.56223 -6.29752,-1.33979 -5.27988,-4.80033 0.12025,-1.69237 -1.82054,-2.14167 -3.35992,-2.64017 -0.19724,-0.65318 2.43407,-1.23581 2.87993,-3.12022 -0.001,-1.79502 -1.36589,-3.48942 0,-5.28036 1.48761,-1.36645 -1.20822,-2.8167 0,-3.36023 -2.0248,-0.0358 -1.1684,-1.43695 -2.15995,-2.16016 -1.37767,-3.51007 3.12825,-1.45768 2.87994,-4.80032 0.98104,-1.66228 1.83029,-1.48732 2.87993,-3.36023 z'
          TE: s \path.province d: 'm 374.61793,126.63524 c 4.52381,1.29871 3.99139,-2.509 5.99986,-3.36023 0.17988,-1.71999 1.91207,-3.11461 2.39994,-1.4401 2.91321,2.04507 1.70187,-2.65022 3.83991,-3.36023 2.85898,2.52572 2.78741,-3.38854 5.27988,0.24001 3.80539,-2.20755 -0.51951,2.42241 3.11993,1.92013 1.91386,-3.35076 1.3049,-1.58584 4.07991,-0.72004 0.7655,-2.79679 2.01304,-3.08135 2.87993,-0.96007 4.12483,-0.63432 1.13776,-4.70501 2.39994,-5.28036 -1.79505,-7.3086 6.29829,4.80631 2.39995,-2.16015 -3.66037,-1.81385 2.17369,-3.46053 2.63994,-0.72005 1.07104,-0.41018 2.51794,3.83379 4.3199,2.40017 1.94358,2.41697 6.10729,3.50919 9.11979,4.80033 1.44881,3.87513 2.17048,2.01867 5.27988,2.40016 3.71637,-0.73539 1.70072,1.4277 4.0799,1.4401 -0.93835,0.69799 1.69464,2.77895 -0.47999,4.3203 -1.15671,1.74857 2.07648,3.69467 -0.47999,5.28036 -0.12275,2.14427 -2.80833,1.07497 -1.91995,2.64017 -3.26185,0.69255 -3.9139,1.25981 -5.99986,0.24002 -3.0348,0.21764 -4.82102,-4.79882 -5.99986,-0.48003 0.0836,1.55468 -1.93901,4.04951 -3.11993,2.64019 -3.16521,-0.0408 -0.86198,3.91037 1.19997,2.88019 -0.20457,2.34639 -0.007,3.78989 0.71998,5.28037 -2.30876,0.69819 -2.81387,1.45654 -0.23999,3.60023 0.83589,0.99152 -2.4035,1.92791 -2.15995,3.12023 -1.16822,-0.42146 -0.33099,1.01982 -1.7628,2.56244 -2.55959,1.35118 -4.56151,-0.67436 -4.71705,3.19795 -0.49624,1.65719 -1.87028,4.15529 -1.91996,4.08027 -1.7497,1.7853 -4.19742,1.10703 -4.79989,3.36023 -2.32114,0.69578 -1.60885,3.1249 0,4.56032 -2.54526,2.93365 -4.05491,-0.0364 -3.35992,-1.92013 0.007,-2.52212 -5.74052,-1.87323 -6.71985,-1.4401 -2.95619,-0.76277 0.39711,-2.14839 1.43997,-3.84026 -1.29081,-2.33354 -4.03026,-1.36843 -5.51987,-2.40016 -0.4046,-1.48505 -2.76154,-5.46471 -2.15995,-0.96007 -2.01588,2.53829 -5.02599,-1.80933 -4.6624,-1.30321 -2.43939,-0.2809 -3.7355,-1.76197 -6.13735,-3.73714 -3.00809,-1.02481 -0.20475,-0.22863 -2.87994,-3.36023 -0.73103,-1.24391 -2.52875,-1.56705 -0.47998,-3.12021 3.7883,-1.07044 0.46671,-8.50003 5.03988,-5.04035 3.26355,-1.58165 0.72029,-5.6866 1.67996,-8.16056 0.72275,-3.61495 -3.42713,-2.76462 -2.39994,-7.20049 z'
          SS: s \path.province d: 'm 369.81804,31.588705 c -1.61648,-0.215628 -2.04068,2.734742 -3.11993,2.8802 -0.9786,1.254281 -1.24074,-0.853168 -1.43997,0.96007 -0.24738,-0.787507 -1.46868,-0.976294 -0.95998,1.92013 0.78635,2.136467 -1.86891,2.722522 -3.11992,3.84026 0.266,2.741069 -0.94933,3.322197 -2.63994,5.04035 -2.54304,-0.05243 -3.37326,-0.59067 -3.83992,1.68011 -1.68454,-0.318286 -3.84924,-2.901058 -6.47985,-2.40016 -2.19853,-0.719717 -3.41467,1.122791 -4.0799,-1.4401 2.04457,-0.803218 1.85167,-2.647365 1.91995,-3.84026 1.44734,-0.792475 1.26862,-3.799314 0.95998,-4.80033 0.96692,-0.603581 2.93337,-2.168469 2.15995,-4.08028 1.00499,-0.751627 4.14244,1.563782 5.51987,0 2.03804,0.880825 3.36364,0.944803 5.75987,-0.48004 1.80266,0.201511 2.19813,-0.750069 3.59992,-0.72005 0.63313,-0.08792 4.05723,-3.86932 3.83991,-1.4401 -0.42175,0.960877 1.93455,0.961252 1.91996,2.8802 z'
          S: s \path.province d: 'm 314.84375,23.1875 c -1.36902,1.084791 -4.1423,1.267113 -4.53125,2.40625 0.38118,2.288486 -1.03806,-1.213944 -0.96875,1.1875 -1.46148,1.6084 -1.11334,-0.561882 -1.21875,-0.9375 1.62333,-0.552851 0.94858,-2.837526 -0.46875,-1.46875 -2.93017,0.260877 -5.77467,1.974037 -7.6875,1.9375 -2.18642,1.418137 -4.69666,1.554754 -7.1875,1.4375 -1.32756,-0.484215 -3.0457,0.176903 -4.5625,-0.25 -2.32784,1.707636 -0.067,2.519569 -1.1875,5.0625 -1.68983,-2.357281 -3.37518,0.696587 -5.28125,0.21875 -0.24799,1.788937 -1.14972,3.644266 -3.125,3.375 -1.40708,-0.105237 -1.20526,2.332322 -0.25,3.34375 2.99228,0.503444 1.2155,3.898815 4.09375,2.875 2.29845,1.000565 5.2068,-1.463498 7.4375,-0.71875 1.8322,1.169835 2.15757,4.111579 5.03125,3.375 0.94717,2.095686 1.0057,6.530926 3.125,4.09375 1.90352,1.754735 -2.53209,1.375367 0.25,3.09375 1.82387,0.309902 2.69732,1.885624 3.34375,-0.21875 1.24643,-3.818171 0.29898,2.869458 2.40625,1.1875 0.99982,-1.331113 5.25607,-0.06426 3.34375,-3.59375 -0.18174,-3.220667 -2.45137,2.381665 -1.90625,-1.21875 -1.06568,-1.237344 1.20714,-0.08641 2.15625,-1.65625 -1.47972,-2.567191 -3.04417,2.128549 -3.34375,0.71875 -3.75932,-1.245683 1.57379,-5.346246 3.34375,-6 -0.91363,-2.006431 2.43975,-0.0474 3.125,-1.9375 1.34895,-0.664014 2.25918,-4.5616 3.84375,-1.65625 2.4688,-0.01501 6.64235,2.3417 4.78125,-2.1875 -1.24783,-2.299106 2.91385,-1.655203 2.65625,-3.59375 1.87861,-0.107084 4.24733,-0.318493 4.0625,0 4.05416,-0.719541 -0.14401,-3.424743 -0.46875,-4.0625 -3.15648,-0.762278 -3.41969,-0.877556 -6.25,-0.96875 -0.19591,-0.458399 -2.81799,-0.463291 0,-0.71875 0.48393,-1.838775 -3.04225,-1.700996 -3.09375,-2.65625 -0.28701,-0.678069 -0.81601,0.0427 -1.46875,-0.46875 z m -17.5,28.09375 c -0.26011,-0.829146 -0.46129,0.343443 0,0 z m 12.25,-26.40625 c 0.2276,0.725502 0.40363,-0.300513 0,0 z m 14.875,8.15625 c -2.46294,0.350407 0.0546,4.729559 0,1.4375 0.51497,-0.353467 0.78654,-1.09597 0,-1.4375 z m -19.6875,15.125 c 0.34655,-0.336442 0.32811,0.430906 0,0 z m -5.53125,2.625 c 1.92066,-0.39931 -0.20869,3.357309 0,0 z'
          BU: s \path.province d: 'm 324.46875,35.90625 c -2.6743,2.25681 -5.85113,3.542702 -9.625,1.6875 -1.07465,-1.243832 -2.60061,-0.694045 -3.34375,1.1875 -1.1753,1.838245 -2.67049,1.551583 -4.3125,1.9375 0.96497,2.0828 -4.94371,2.341497 -4.3125,6 1.34875,2.254664 5.21755,-2.772726 4.3125,0.46875 -1.95803,0.272422 -2.29953,1.146812 -1.4375,2.40625 0.74645,-1.433106 2.1073,-1.271258 2.15625,2.15625 -2.18093,-0.206812 -3.03739,2.395012 -5.03125,1.1875 -2.16529,0.328252 -3.71978,1.255968 -4.8125,0.96875 -1.56431,0.924598 -3.07027,2.678105 -4.3125,2.15625 1.07414,1.386362 0.29379,3.089893 0.21875,4.5625 -1.05551,-0.01576 0.54258,1.60626 -0.21875,2.65625 2.81734,1.380441 0.49959,2.727995 -0.96875,2.875 -1.62776,2.688918 1.84192,1.785595 1.4375,3.34375 0.50638,2.057494 0.49099,4.519461 1.90625,6.71875 -0.17523,2.399463 0.71058,3.17242 2.65625,2.90625 3.43942,1.569784 -1.11694,1.17878 0.96875,3.59375 2.27617,-1.626101 4.72299,0.107174 1.65625,2.15625 -0.94059,3.401781 4.71162,-2.967314 4.09375,0.96875 -2.58882,-0.308425 -2.78222,3.683118 -6,3.59375 -0.35783,1.999708 2.79035,4.050972 0.25,5.75 2.32478,0.658739 0.93597,5.149 1.90625,4.8125 1.56438,1.31179 4.7387,3.1561 5.75,5.03125 0.7976,-0.2358 1.44314,-3.74821 1.46875,-0.25 1.06626,3.61555 1.02964,-0.79613 2.375,-1.90625 1.73124,-2.47641 5.16439,-0.12253 4.5625,-2.65625 1.54839,-0.15637 3.04317,1.60686 3.125,-0.71875 0.35784,-1.562227 1.94666,-2.262838 2.40625,-3.8125 1.03817,-1.45121 3.40541,-1.679743 2.40625,-4.34375 -0.42385,-2.865652 0.39873,-2.041387 2.375,-0.21875 1.42754,4.083435 2.9664,-2.231321 3.84375,-2.1875 1.8737,0.20079 2.77124,-1.50713 3.375,-3.09375 1.61478,-2.03874 2.11503,-6.298972 -1.21875,-4.8125 -1.63073,-1.318765 -3.57982,-3.681556 -3.34375,-5.03125 2.26429,-2.099399 -1.45211,-5.670744 1.6875,-6.25 -2.12962,-1.724792 -0.66209,-3.285045 0,-0.25 0.9455,-2.464593 -0.98645,-4.175696 -0.5,-5.5 0.2711,-2.332985 -2.75809,-0.377254 -0.21875,-3.125 0.78285,-1.520218 0.0138,-3.081906 2.625,-2.40625 0.94234,0.405472 5.22904,1.223036 3.125,-0.25 0.50678,-3.211569 -3.30032,-1.884496 -3.84375,-3.84375 -1.25766,-0.77694 -1.30937,-1.169039 -3.84375,-0.71875 0.85542,-1.576268 -0.40162,-3.048726 1.4375,-4.78125 -2.5175,-0.8171 -2.93528,4.07335 -4.95674,0.366578 -0.60299,-1.567007 1.61048,-4.242208 3.05049,-2.772828 0.12873,1.630031 5.40826,2.199826 5.28125,-0.46875 -2.08614,-1.149177 -2.0365,-2.80121 -5.28125,-2.65625 1.08041,-0.107702 0.48335,-3.869224 0.46875,-3.59375 -1.96428,-1.097627 1.99123,-3.652784 -1.90625,-2.875 -0.38477,0.448 -1.0642,-1.17538 -1.4375,-0.96875 z M 305.5,48.375 c -0.0355,-0.613294 -0.88611,0.19139 0,0 z m -0.375,-0.125 c -0.19552,-0.204975 -0.094,0.410787 0,0 z m -0.0937,-0.03125 c 0.0841,-0.245801 -0.68324,0.04922 0,0 z m -0.25,-1.03125 c -0.72527,0.513837 0.21187,1.06353 0,0 z m -7.4375,3.59375 c -0.92465,0.76921 1.56676,0.480564 0,0 z m 1.90625,0 c -0.38635,2.217793 1.74441,0.186625 0,0 z m 37.9375,1.4375 c -2.11616,3.218733 0.841,2.448322 1.90625,5.28125 2.71143,-0.757152 4.87446,0.567999 6.7187,0.96875 3.54916,-1.670922 -3.80843,-1.35275 -1.1875,-2.875 1.73839,-1.841662 -0.0232,-2.306809 -1.4375,-2.15625 -1.47417,-0.816598 -4.23009,-1.371589 -5.99995,-1.21875 z m -42.5,1.9375 c -0.53115,1.127686 1.39656,-0.04607 0,0 z'
          BI: s \path.province d: 'm 339.59375,25.34375 c -1.55037,2.440713 -4.56767,-0.156609 -6,1.6875 0.10179,0.433602 -3.52696,1.888128 -1.6875,3.34375 -0.69284,0.824471 -2.64204,-2.85165 -3.125,-0.46875 -1.51179,0.50393 -2.2036,3.46568 -4.09375,1.9375 -1.71834,0.312343 -2.41234,-0.06007 -4.0625,1.90625 -2.15588,-0.516118 -1.34309,3.875691 -0.5,4.5625 2.37112,-0.648032 4.43867,-3.348797 5.78125,-1.4375 2.23403,-0.662151 3.78005,2.917782 5.75,-0.25 0.50583,-2.61487 4.1088,2.091449 1.4375,3.375 2.50806,2.953969 6.75414,2.760432 9.375,2.875 0.918,-0.507428 -0.76999,-3.340785 3.34375,-2.65625 2.14641,-0.490404 1.03354,-3.562059 1.4375,-4.78125 -0.20759,-0.538026 3.34885,-1.930185 1.6875,-3.84375 0.75998,-1.264612 -1.51743,-2.382879 -2.875,-2.875 -1.9499,-0.628202 -3.52951,-1.447477 -5.53125,-1.6875 -0.3528,-0.38357 -0.85013,-1.159119 -0.9375,-1.6875 z m -15.125,7.6875 C 325.4223,34.923262 323.1021,37.156857 323.5,34 c -0.99947,-0.871455 0.78511,-0.493517 0.96875,-0.96875 z m 6.9375,2.15625 c 0.95528,0.586583 -0.76078,0.575346 0,0 z m -0.71875,6.96875 c -2.89826,1.310731 1.51575,3.651319 2.15625,1.4375 -2.13849,-0.185593 -0.39835,-1.454104 -2.15625,-1.4375 z m 1.9375,2.15625 c 1.10598,0.131455 1.48365,-0.912095 0,0 z'
          LO: s \path.province d: 'm 334.77884,83.432265 c 0.7279,-4.519141 -3.87122,-0.7066 -4.55989,-4.56031 -1.33091,-1.403079 -2.28629,-2.525573 -0.47999,-4.56031 -2.03478,-2.799182 1.43951,-4.273146 -0.47999,-5.52038 -0.0931,-3.920365 1.71135,3.239476 1.19997,-0.96007 0.77429,-2.554441 -1.59712,-2.776816 -0.47999,-5.04035 -2.90601,0.47283 0.10954,-1.326135 0.47999,-2.88019 -2.13686,-2.222661 2.93335,-1.645091 4.07991,-0.72005 1.40111,-0.292018 3.0166,-0.686874 3.11993,1.4401 -0.98509,3.166625 1.73345,-1.704423 2.63994,-1.20009 2.65996,2.147042 -0.125,4.806566 3.11993,5.04035 0.74067,0.16546 1.41342,0.758233 2.63993,0 0.82401,-1.881104 2.26859,0.920178 5.03989,0.72005 0.85733,1.819971 1.99581,-1.005245 3.11993,1.20008 1.24629,0.0701 1.89228,1.912711 3.59991,0.96007 2.33733,-1.086148 0.7989,4.923889 3.59992,2.16015 1.95993,-0.09963 2.06713,1.35749 3.59992,2.16014 1.24799,1.594424 1.51372,1.989825 2.87993,3.12022 1.34592,0.807308 4.09566,0.446074 3.59992,1.92013 0.87932,2.37462 -2.55253,1.821826 -3.83991,1.20008 -1.76939,2.108002 -3.74516,5.02948 -0.95998,5.7604 1.2217,1.282352 -3.20178,5.64097 -5.03989,2.40016 -1.68381,0.890587 -3.39034,-1.03335 -2.87993,-2.64018 -2.67273,-1.416243 1.81213,-4.406693 -2.87993,-3.12021 -1.97967,1.224038 -2.23598,-3.373638 -5.27988,-1.68012 -1.79843,0.05271 -2.67709,1.416608 -3.83991,1.4401 -0.0314,1.547566 -0.99305,3.570592 -2.63994,4.08028 -1.941,-0.10371 -6.28303,0.218512 -3.59992,-2.64018 1.72974,-3.39883 -3.53335,-2.123096 -2.15995,0.48003 -0.43577,0.55362 -2.25949,2.465422 -3.59992,1.4401 z m -0.47998,-23.76163 c -0.94363,-0.28011 0.386,1.616113 0,0 z m -1.67997,-0.24002 c -1.28326,0.974345 0.61693,0.589478 0,0 z'
          VI: s \path.province d: 'm 331.40625,35.1875 c -0.76078,0.575346 0.95528,0.586583 0,0 z m 0.5,0.46875 c -0.0266,3.641595 -4.19932,1.120901 -4.3125,2.40625 -0.98885,1.911081 1.25531,1.948918 0.21875,4.5625 -1.1996,1.778841 3.0096,0.657172 3.59375,-0.25 0.38411,1.712171 3.36756,1.276479 0.71875,2.40625 -2.86613,-0.215695 2.90805,2.083027 -0.71875,2.875 -3.56004,1.532034 -4.42263,-3.557551 -6.46875,-0.71875 -2.37232,3.343558 1.73887,4.327847 2.875,2.65625 2.12112,-2.687754 0.75281,1.271339 -0.21875,2.15625 0.80033,2.096883 1.19105,2.007998 2.875,1.6875 0.93933,0.953495 1.38356,1.411331 2.875,2.40625 2.28837,-0.578074 1.81842,2.41158 3.59375,3.59375 1.32156,0.3752 -0.35441,3.898984 1.90625,1.1875 2.37604,-4.197438 2.83801,2.625887 3.125,3.125 0.97017,1.771155 5.67453,-0.687921 2.875,0.96875 2.5309,-0.951487 1.21826,-0.681753 3.84375,-0.5 1.65589,0.323798 2.02266,-2.636766 1.4375,-4.0625 -0.74371,0.911052 -4.13533,0.545335 -1.90625,-1.21875 2.41717,-3.308035 2.03926,1.075623 4.09375,-0.71875 2.86408,-0.293842 -1.75297,-3.037163 1.1875,-3.84375 0.29885,-0.796269 1.44642,-3.912735 1.1875,-5.75 -1.00622,-1.444076 -3.95611,-3.335846 -6.46875,-3.125 -2.23722,-0.677006 -3.41368,1.114709 -4.09375,-1.4375 1.79184,-0.542696 2.47955,-3.130697 1.46875,-3.59375 -4.83517,-1.570227 -1.49331,2.984262 -3.375,2.15625 -2.57633,0.484587 -6.71487,0.07311 -9.125,-2.625 2.09483,-1.456567 0.18341,-4.218611 -1.1875,-4.34375 z m 5.28125,16.5625 c 1.61518,-0.02408 4.62001,0.294732 6,1.21875 1.41432,-0.150559 3.17589,0.314588 1.4375,2.15625 -2.62093,1.52225 4.73666,1.204078 1.1875,2.875 -1.13054,-0.07538 -3.38698,-1.42606 -5.03125,-1.1875 -1.84912,0.853162 -3.54315,-2.612689 -4.5625,-2.90625 0.88784,-0.340821 0.20125,-1.451364 0.96875,-2.15625 z m -4.8125,7.21875 c -0.47051,1.762123 1.01854,-0.305949 0,0 z m 1.9375,0 c -1.08167,0.779796 0.60172,1.656718 0,0 z'
          NA: s \path.province d: 'm 369.81804,31.588705 c 2.45908,-1.971635 3.04932,0.982361 3.83991,1.68012 1.36221,-0.192952 1.35941,-2.942088 3.59991,-0.96007 3.78094,-0.584223 2.85987,4.047235 2.15996,5.52038 -2.06561,1.529979 -2.58213,4.161083 1.43996,4.56031 -0.48642,-2.472189 3.8529,-5.981814 1.43997,-1.68011 1.9989,0.343578 6.82271,2.061095 5.75987,1.92013 1.42099,0.174196 3.62893,1.89459 5.99986,2.40016 0.77364,-0.499046 3.63145,0.470469 5.03988,-0.72004 2.31107,2.786464 -2.97572,1.223631 -1.91995,4.08028 -2.3187,0.957203 0.0558,4.539821 -2.39995,4.80033 -0.68399,0.958985 -2.18825,2.244055 -4.07991,2.64018 1.61523,3.430137 -4.57533,0.337675 -3.59991,3.12021 -0.39639,-0.423042 -0.59731,3.139621 -2.39995,2.64018 -1.97071,1.465233 -0.33031,3.546265 -2.87993,6.00041 0.69793,1.722417 -0.63554,3.178976 -1.43997,5.7604 -0.4037,2.653081 -0.2635,4.654461 1.19998,6.72046 3.22002,0.7696 0.16406,3.541908 -0.47999,5.7604 -1.11715,2.297489 -5.38639,2.165719 -7.19984,0.24001 -1.92311,-0.512529 -3.74149,-0.536985 -5.75986,-1.92013 -2.16497,0.09392 -4.36745,-2.444448 -1.43997,-4.80033 1.53612,-2.581996 2.91793,0.06847 5.27988,-1.4401 -0.35726,-1.490217 -0.85349,-3.153114 -2.87994,-2.40016 -1.44847,-1.804477 -3.07068,-0.881343 -2.87993,-3.12022 -1.31632,-0.524564 -3.88837,-3.314057 -3.35992,-2.64018 -2.86997,-0.141684 -3.55953,1.02163 -3.83991,-2.40016 -1.49781,-0.113264 -3.45219,0.677232 -3.83992,-0.72005 -1.38937,-0.896234 -2.55344,-1.489098 -3.35992,-0.72005 -1.81704,-0.723547 -2.62875,-2.118555 -1.43997,-3.84026 0.14463,-3.588153 -1.20255,-0.701024 -2.87993,-1.4401 -1.00139,-1.542702 3.51122,-4.287022 3.35992,-2.16015 1.40977,0.338787 3.14624,-0.946801 1.91996,-2.64018 -1.38068,-1.913387 2.55757,-0.753102 0.95998,-3.36023 2.24668,-2.267082 -0.1447,-4.714399 1.91995,-6.00042 -0.0143,-1.059572 3.58567,0.893877 3.83991,-1.68011 2.85806,0.175565 0.30934,-4.491878 3.11993,-4.3203 1.17206,-1.125126 2.47423,-2.01035 1.67996,-4.56031 0.009,-2.615028 1.17196,0.632879 1.19998,-1.20008 -0.0832,-0.225418 0.83568,0.611227 1.19997,-0.24002 1.79893,-0.890227 0.93169,-2.713958 3.11993,-2.8802 z'
          GU: s \path.province d: 'm 325.89905,112.47427 c 2.97405,0.7145 5.47538,1.69305 8.15981,0 2.29108,-3.18199 1.75562,2.66369 4.79989,1.92013 1.72755,-2.1626 4.19291,2.44878 5.99986,1.20008 -1.89288,2.40762 0.87269,3.1869 2.15995,3.60024 1.30145,2.20797 2.93933,3.56073 5.27988,2.40016 2.27788,1.32726 5.23812,-1.78998 7.19983,-0.96006 3.27798,3.28947 -0.3128,-3.1003 3.59992,-2.64017 1.96872,-0.0368 3.74747,2.10296 5.99986,3.36023 1.78161,2.58139 6.55434,4.37758 5.51988,7.92053 2.03152,1.85643 3.1629,3.55946 1.91995,6.48045 1.45646,2.18933 0.37251,7.79658 -3.11993,5.52039 -1.2124,0.56547 -1.34438,5.64447 -3.83991,6.72046 -0.56402,1.14905 -2.36338,-0.23904 -2.15995,-1.92013 -1.14261,-0.66637 -0.53016,-3.75452 -2.63994,-5.28037 -0.61894,0.35589 -3.4489,0.2086 -4.55989,-1.92013 -2.38006,-0.56349 -4.03825,1.64805 -6.23986,0.96007 0.50843,4.39113 -2.01841,0.41256 -3.59992,0.96006 1.54322,2.99264 0.19633,2.42017 -1.67996,3.36023 -2.92645,-1.41075 -2.43568,0.82091 -1.19997,3.60024 -1.55297,0.24306 -3.15678,-1.57568 -5.03988,-0.24001 -1.06536,-0.62766 -0.10118,2.36217 -1.43997,1.20008 -1.05022,0.88903 -1.83871,-3.31279 -2.63994,-0.24001 -1.20411,2.12571 0.88332,5.62562 -0.71998,8.40057 -1.47233,3.21028 -4.61321,0.55107 -5.51987,0.24002 0.11798,1.50962 -1.44856,2.44234 -2.15996,0.96007 -0.65555,-0.97904 0.0517,-6.57345 -2.63993,-3.36023 -2.12017,2.27837 -0.20329,-3.04208 0.47998,-4.08029 0.30316,-1.30638 0.37081,-3.46787 -1.67996,-3.60024 1.454,-3.7281 -2.83611,-3.09289 -2.63994,-4.3203 -0.23194,-1.41887 -2.5032,-2.20071 -0.95997,-4.08029 -1.05293,2.57378 -2.21198,-3.19512 -2.87994,-0.72005 -1.37001,0.0869 -1.74839,-0.90461 -0.95998,-2.64017 1.21437,-1.51576 -3.30357,-1.76541 -1.19997,-3.12022 -0.18744,-1.66498 1.9952,-2.6272 0.71999,-3.84026 0.37314,-0.49127 2.86286,-3.81291 0.95997,-5.28037 0.6963,-1.74665 -1.71527,-1.4335 -2.15995,-3.36023 -2.97521,-2.07947 1.24378,-1.47023 1.67996,-3.60024 2.81332,-0.73857 -0.54659,-3.26087 3.59992,-1.68011 1.71428,-0.37597 1.98256,-0.16664 3.59992,-1.92013 z'
          CS: s \path.province d: 'm 440.6164,141.75628 c -1.05282,2.57742 -0.73149,2.09957 -1.67996,3.36023 -1.09385,2.46848 -3.12267,6.51441 -5.03988,8.16056 -1.03244,1.66536 -4.36916,5.12166 -4.07991,6.72046 -1.46682,1.03754 -3.97543,2.78182 -3.59991,4.5603 0.14845,-0.0371 -2.27824,5.38052 -3.11993,4.80034 -1.24155,2.93656 -3.56486,7.24886 -5.99986,4.08027 -1.96586,-3.87028 -4.22504,0.61803 -5.03989,1.4401 -1.36998,2.16251 -2.99697,-5.82387 -4.3199,-0.96006 -2.78172,1.73464 -2.44769,-5.89797 -5.03988,-2.64017 -1.58349,-2.09809 -5.57907,-5.2955 -1.91996,-6.72048 0.60247,-2.2532 3.05019,-1.57493 4.79989,-3.36023 0.34819,-0.0955 1.32382,-2.59307 1.91996,-4.08027 0.0171,-4.30968 2.60495,-1.4305 5.12272,-3.52252 0.63585,-1.61286 0.45076,-2.52235 1.35713,-2.23787 -0.12416,-0.80488 2.47053,-2.76954 2.39994,-2.64019 -1.69023,-2.13773 -3.0594,-3.21097 -0.71998,-3.84027 1.75148,-0.84606 -0.92848,-1.91664 0,-3.60023 0.27437,-2.13966 -0.42411,-1.99623 -2.15995,-2.16016 -1.48828,-1.84982 0.15057,-3.23236 1.91996,-2.16014 3.00885,-0.44345 0.97433,-5.48412 4.55989,-5.04035 -0.0981,3.16411 4.87397,1.29693 5.27988,3.12022 0.88705,0.0875 5.45058,-1.96614 5.99986,-0.96008 2.48758,0.95383 1.02758,2.5349 2.39994,4.08028 2.25006,0.39744 5.0275,0.68469 4.79989,3.12023 0.78052,-0.13178 1.37942,0.61688 2.15995,0.48003 z'
          V: s \path.province d: 'm 384.9375,156.15625 c -0.51226,1.79087 -0.9295,3.97839 -3.125,2.875 -3.25209,-0.85713 0.71934,4.11087 1.6875,5.03125 3.41156,0.78828 6.92038,0.91153 8.625,-2.15625 -1.28639,-2.31212 -4.01234,-1.36338 -5.5,-2.375 0.40135,-1.21111 -2.18739,-1.90364 -1.6875,-3.375 z m 7.1875,9.125 c -0.69256,0.98386 -3.00521,-0.25413 -4.0625,2.15625 1.45183,3.80467 -2.39283,7.00734 -2.15625,10.09375 -3.8559,-1.48825 -5.21035,3.90592 -6.71875,5.28125 -0.77041,0.07 0.34964,2.37143 -0.25,3.34375 -1.28691,2.06418 1.66988,1.98547 1.1875,3.125 0.65862,-0.50136 0.70369,1.61387 1.21875,0.96875 0.93108,-0.65573 0.76259,-0.19273 2.15625,0.46875 1.50906,0.95296 3.20704,0.97737 4.8125,1.1875 2.14624,-0.3633 1.52996,4.53259 0.21875,6.5 -3.67812,3.59496 -0.17949,5.77864 1.9375,8.875 2.53345,1.86074 6.11996,-2.46584 6.71875,1.4375 0.74842,2.88542 -0.15015,5.65564 3.59375,6.46875 1.21512,0.76123 3.21359,-2.20854 4.0625,0.25 2.4469,0.051 3.02307,2.9938 6,-0.46875 1.1444,-1.33727 -4.47604,-0.56364 -1.65625,-2.40625 3.31227,-0.48712 5.68905,-1.32507 7.90625,-3.375 2.60956,1.47304 4.58626,-0.4783 6.71875,0 1.43483,-0.37076 3.76441,1.1012 0.96875,-1.4375 -3.04595,-3.23614 -4.6169,-5.65093 -5.75,-10.3125 1.70508,-1.20586 -2.35619,-5.28589 -2.50625,-7.69624 -1.16999,-3.35445 -0.6778,-4.16345 0.31875,-7.89751 0.46441,-2.39395 4.735,-5.42674 1.98076,-7.41657 -1.95533,-0.0881 -3.09029,-4.38639 -5.32451,-1.70843 -0.12091,1.85988 -2.50536,3.85491 -3.375,1.1875 -0.83107,-4.57585 -4.13225,4.04601 -4.5625,-1.1875 -0.39578,-5.25952 -2.85372,1.54154 -4.0625,-3.125 -1.76125,-0.50222 -4.57207,2.55269 -4.09375,-1.1875 0.5027,-3.15025 -2.18245,-3.05832 -5.28125,-3.125 z m 24,20.40625 c -0.17714,0.66228 1.29502,0.71008 0,0 z'
          AB: s \path.province d: 'm 339.81873,224.32194 c 0.68422,-0.2306 -0.74285,-4.75161 0.95998,-3.36022 3.58726,-1.0505 3.5202,-6.51685 0,-7.2005 -0.87159,-2.23355 -1.06036,-4.60872 -3.59992,-5.04035 -3.26355,-1.34483 2.26402,-4.00512 1.19997,-6.0004 -3.13344,-3.06776 2.71843,-5.69419 2.39995,-8.88062 -0.68544,-1.653 3.84663,-2.13715 5.51987,-1.4401 2.73824,-2.06325 5.44793,6.75894 6.95984,1.4401 0.94821,3.26448 3.37936,1.28736 5.03988,0.24001 3.88123,1.31427 3.77771,0.036 2.87994,-2.16014 -0.13603,-3.47991 3.10651,3.56224 5.99986,0.96007 3.89117,2.71158 6.94841,-2.89931 11.03974,-4.08029 2.15233,-1.51459 3.08395,0.14135 2.39995,0.48003 -0.277,0.65599 1.40444,1.61979 0.95998,1.20009 0.80691,-1.42285 0.35712,0.0482 1.91995,0.24001 1.46764,0.97015 3.24135,0.94749 4.79989,1.20009 2.14721,-0.41074 1.54595,4.50108 0.23999,6.48045 -3.66276,3.58349 -0.19304,5.78953 1.91996,8.8806 2.55045,1.88493 6.14252,-2.49658 6.71985,1.4401 1.98723,2.69865 -1.57352,5.749 0.95997,8.40059 -3.69026,5.38349 -5.58784,-3.39783 -9.83977,-1.92014 -2.39666,3.654 -7.5851,0.45891 -6.95984,6.72046 -3.48391,1.86426 2.21071,8.41198 -2.63994,9.60065 -1.70974,2.70603 -5.27765,1.32308 -5.03988,-0.96006 -0.44601,0.55139 -3.13074,-0.90714 -2.87994,0.72006 -2.38462,1.65622 -5.55992,3.85579 -8.6398,2.40016 -1.67537,3.23993 -5.88612,3.38226 -6.23985,7.4405 -1.75505,3.45737 -4.46211,4.42748 -6.95984,2.40017 -4.58718,-0.54797 0.19846,-3.62486 0.95998,-5.28036 0.24725,-2.31544 0.34593,-3.47477 -1.19998,-5.28037 0.89529,-2.44123 -1.23111,-3.3822 -2.87993,-4.32029 0.70472,-1.89388 -0.35358,-4.9069 -3.11993,-2.8802 -1.18141,0.1532 -1.98886,-0.91135 -2.87993,-1.4401 z'
          MU: s \path.province d: 'm 394.77746,218.80156 c 1.93291,3.38825 -0.23809,7.58335 -1.67996,9.12064 -0.85311,4.35965 7.10275,5.01833 2.63994,10.56072 -2.33068,3.67846 2.74054,7.17478 4.32689,10.56772 2.25832,1.45301 5.37585,3.55989 4.07292,4.31329 -1.37387,-2.10492 -1.71857,1.68018 -2.87994,2.64019 -1.13824,2.5317 5.90961,5.04741 3.59992,2.64018 -0.006,-0.82882 0.0301,-3.28379 -0.47999,-4.56031 0.23004,0.15706 1.02442,1.19916 0.47999,2.40016 -0.0212,2.93087 2.83854,3.01018 0.23999,4.56031 -2.82459,1.29043 -3.84041,0.25865 -5.99986,2.16015 -1.75675,-0.74942 -1.00954,-0.48535 -1.67996,-1.4401 -0.61416,-1.23702 -0.24899,1.50406 -2.63994,0.24002 -2.34742,-0.26657 -1.42766,2.67046 -2.87993,1.92013 -0.34119,0.50755 -1.84834,-2.78539 -3.59992,-0.96007 -1.53925,0.14822 -3.71381,-3.6e-4 -4.55989,2.40017 -3.6227,0.78947 -1.44929,4.21578 -5.03989,3.84026 -1.00546,0.79805 -2.61474,2.39286 -4.79989,-0.24001 -3.94602,-1.00231 -5.56428,-1.77274 -7.8096,-6.5441 -1.53217,-1.67011 -2.52999,-4.75602 -1.79018,-7.37686 0.0533,-2.81268 1.6447,-5.17575 -2.15995,-4.5603 -1.24326,-0.17717 -3.21451,-0.16131 -5.03988,-1.68012 -2.56226,-2.03435 -5.55665,-5.45977 -1.19997,-7.68054 0.47586,-4.12563 4.73648,-4.54184 6.71984,-7.68052 3.27549,2.56447 7.41876,-2.12608 8.6398,-2.64017 0.98879,-0.65719 2.10892,-0.27125 2.87994,0.48003 -0.19254,3.37165 4.87747,0.92206 6.47985,-0.96007 -0.1965,-4.53809 -0.66685,-8.17539 1.36222,-11.84363 2.88526,0.10512 6.60223,-5.57694 9.87914,-2.02921 0.7465,0.777 1.76267,2.1369 2.91831,2.35204 z'
          CU: s \path.province d: 'm 378.45784,156.6373 c 3.12867,-0.23936 1.4765,3.33011 3.59991,6.0004 0.87538,2.96988 6.38292,1.30408 7.19984,1.92013 -0.0701,1.71611 -1.7383,3.93202 -1.19997,7.20051 -2.07709,4.1093 -1.8045,6.29954 -6.47985,6.96047 -0.42285,3.40846 -3.53933,3.67088 -2.63994,5.04035 0.7396,1.21858 -1.09476,3.79702 0.23999,4.08027 -2.95018,2.15701 -7.20026,5.2336 -10.55976,6.00042 -3.45723,0.003 -6.07608,-2.82184 -7.67982,-2.64019 0.38795,2.22427 2.35165,4.22755 -1.91995,3.12022 -2.01103,-0.56815 -4.6339,3.6626 -5.51988,-0.24002 -1.58624,4.01329 -4.05587,-1.97092 -6.47985,-1.92013 -2.66588,-1.21574 -5.01678,1.71156 -7.19983,-0.24001 -0.0727,-5.31468 -2.50798,1.09777 -4.07991,-0.96006 1.12616,-1.45936 -0.46873,-2.46365 -0.71998,-3.60026 -1.76032,-0.79492 0.47314,-6.1799 -0.24,-7.92053 -2.72995,-2.65161 -3.1272,-6.60672 -5.99986,-9.36066 -0.56642,-0.22761 2.12939,-5.03364 -0.95998,-4.32029 -2.88595,-3.91205 2.44427,-2.63989 2.87994,-5.04035 -2.13032,-1.31636 -1.02418,-3.15781 1.19997,-1.6801 -0.72789,-3.55631 1.15953,-1.39227 3.35992,-0.24003 2.52651,-1.69265 3.7477,-3.39482 2.87994,-6.96047 -0.25932,-0.9774 -0.26743,-4.636 1.67996,-4.56032 -0.39393,2.19867 3.29758,1.85543 1.67996,0.48003 0.79187,-0.73348 3.03486,-0.91353 4.79989,-0.24001 2.65705,1.78748 -1.35551,-4.41004 0.71998,-3.84026 1.15841,1.12733 3.53105,-0.0172 4.3199,-0.96007 -2.34177,-3.53229 1.14778,-0.89867 2.15995,-0.96006 -0.006,-3.23394 2.97785,-0.82652 4.5599,-3.12023 2.31319,-1.15684 4.98137,4.53087 6.23985,1.68013 2.76207,2.19191 2.01534,4.90129 3.35993,6.72046 0.3646,1.325 3.01579,2.22113 3.83991,3.84027 1.0487,3.34346 -0.15766,0.71995 2.87993,3.1202 1.54988,0.75211 2.46848,3.79661 4.07991,2.64019 z'
          A: s \path.province d: 'm 427.41671,209.44093 c 3.62259,0.20986 3.18195,0.86308 5.99986,2.40016 -1.5566,0.8135 3.37337,3.17966 0,2.64017 -0.52478,1.63088 -3.93124,2.81717 -3.83991,4.08029 -1.73362,-0.3763 -4.6509,1.13808 -4.07991,3.36023 -0.90682,2.11449 -3.34115,0.45717 -4.3199,1.92013 -3.42132,0.87489 -7.17441,3.49418 -6.71984,6.72046 -2.91232,0.13113 -1.32179,0.59037 -2.87994,0.96006 -0.3081,2.6866 0.57784,6.94415 -2.63994,5.7604 -2.78354,2.46397 -0.59473,9.71245 -2.87993,8.88061 -0.92715,1.78159 -1.80888,3.68151 -2.63994,5.04035 -4.23054,-1.73731 -7.1674,-7.22706 -8.6398,-11.52079 4.75529,-4.20018 -0.0231,-8.14422 -1.67996,-10.56073 -0.0152,-2.80283 3.97501,-5.43757 1.91996,-9.60065 1.83205,-0.81608 3.04189,-3.39065 2.63993,-6.00042 1.71244,0.26836 3.74339,2.88889 5.03989,1.20009 1.65665,-0.79358 2.29916,0.54155 4.0799,1.20007 0.10511,3.32286 7.10086,-3.04971 2.63994,-1.6801 -2.98565,-1.49606 1.64607,-2.24451 3.11993,-2.40017 1.67747,-0.67546 3.6255,-1.68291 5.03989,-2.8802 2.77903,2.043 4.33935,-0.36188 6.47985,0 1.74215,0.60545 1.80046,-0.0843 2.63993,0.24001 l 0.71999,0.24003 z'
          CO: s \path.province d: 'm 267.82039,215.92136 c 1.2729,1.74239 3.37972,1.35764 5.27988,2.16016 -1.10236,3.76189 4.98295,3.20883 5.51987,5.04035 2.64833,1.56275 3.44635,2.78759 5.75987,3.84026 1.60455,3.05109 5.44276,3.82495 7.19983,4.5603 2.27245,0.39828 0.9703,1.26137 2.15995,2.8802 -0.54973,2.22722 1.93052,3.34838 1.19997,6.00042 -2.26722,0.75415 -1.23932,2.05515 -2.39994,2.40017 -0.19335,1.29085 -1.49535,2.52794 -0.71999,6.24042 -2.56759,3.1345 1.23105,6.99965 1.19998,6.24043 0.49943,2.62474 1.9028,3.43578 0,5.76039 2.05792,-0.35657 1.9172,2.35858 3.11993,2.64018 0.56793,1.36053 1.70051,3.26069 1.67996,2.40017 -0.3503,0.93824 4.39867,4.77335 0,3.60025 -1.56148,0.84026 -3.06856,2.59596 -5.27988,2.64018 0.44704,1.95691 -2.13016,7.15727 -3.11993,5.52038 -2.25598,-0.13771 -0.89082,-3.38423 -2.87993,-3.36023 -2.6818,0.97504 -1.35162,2.28529 -4.07991,2.64018 -2.58825,1.26169 -1.32961,-2.26451 -3.59992,-1.68012 -0.55676,-2.39261 -0.50709,-1.44977 -0.47999,-2.8802 -0.63857,-0.34698 -1.41441,-1.73159 -2.39994,-0.24001 -2.26539,0.67384 -2.27775,-2.92739 -3.35992,-3.12022 0.8782,-1.4552 -2.81706,-2.45468 -1.67996,-3.84026 -2.50551,-0.39481 0.67852,-3.82415 -1.43997,-4.56031 0.10418,1.19722 -0.74638,-6.60542 -3.83991,-3.60025 -0.55635,1.6866 0.48016,2.22933 -1.19997,0 0.91592,2.52174 -2.21489,-0.0148 -4.5599,2.40016 -2.86266,1.52311 -3.20952,2.71082 -4.79989,0 0.10052,-0.41963 -0.54924,-1.00711 0.47999,-2.40016 0.54805,0.5796 2.58056,0.14908 2.87993,-0.96007 -0.1932,-2.02137 -1.56489,-3.23492 -1.43996,-5.04034 -4.27673,-0.72812 0.17643,-3.91445 -3.83991,-5.28036 -0.35394,-1.7763 -1.54276,-5.1451 -3.35993,-6.48044 1.83784,-0.87112 2.8207,-4.85628 1.43997,-6.24043 -1.2605,-1.39138 0.39422,-3.09373 -1.19997,-4.08029 0.73595,-3.77668 3.14359,-2.01702 4.55989,-4.5603 2.07885,-1.17332 1.60878,-1.95389 2.87994,-3.36023 1.96245,1.41166 3.4744,-2.68811 4.79989,-2.64019 0.81479,0.10871 1.13165,-1.33353 1.43996,-2.40016 -3.94339,0.42321 5.28167,-0.0292 4.07991,-0.24003 z'
          J: s \path.province d: 'm 340.05872,224.56197 c 2.02629,2.61203 6.40754,-1.43854 5.99986,2.88019 -1.62589,2.63453 3.49393,1.3022 2.63994,4.08027 -0.65353,2.09831 2.05716,2.99851 1.43997,5.04036 -0.13598,2.20399 -2.67482,5.2436 -4.3199,6.24043 -1.35305,0.27007 -0.41546,5.13041 -3.35992,4.3203 -1.85533,0.30899 -3.93751,2.66159 -4.3199,4.5603 -1.62526,2.72912 -3.77436,5.09995 -2.39995,7.44051 -2.71618,0.76129 -2.80886,4.13746 -4.3199,2.16015 -1.42683,0.98244 -2.98917,0.82992 -5.03988,-0.96007 -3.27313,-0.74977 -3.09981,2.88972 -6.47985,3.12022 -2.25463,-0.68259 -4.62604,-3.2244 -5.51988,0 -1.79286,0.8436 -5.03322,2.94041 -6.95983,3.12021 -1.74049,0.046 -0.6301,5.13067 -4.31991,4.08028 -3.33996,1.10412 -3.57504,-3.15185 -5.75986,-4.3203 1.50155,-1.00041 -1.38864,-1.39084 -0.95998,-2.64018 -1.8216,-0.40729 -1.2482,-2.73163 -2.87993,-2.64018 -0.80126,-1.13228 2.26009,-3.48044 -0.71999,-4.80033 1.93174,-2.55969 -4.40558,-2.75146 -0.95998,-6.96047 -0.85963,-3.74732 0.68745,-5.01641 0.47999,-6.48044 1.43357,-0.21477 0.48793,-1.09243 1.67996,-1.92013 2.43639,-1.07819 0.0805,-4.33142 -0.47998,-5.28037 0.65488,-2.48439 -1.00666,-2.90368 -0.71999,-3.84026 -3.0618,-1.51817 1.1499,-3.17109 3.11993,-1.68012 2.7503,0.26351 7.50749,1.85124 10.07977,-0.24001 0.70148,-3.04976 5.83387,0.89822 7.67982,-0.48003 0.66354,-4.19129 2.57079,2.38571 5.03988,0 1.6041,-0.79695 2.01462,-4.4162 4.5599,-2.16016 3.60838,2.58002 7.16169,-2.77892 8.8798,1.92013 -0.30845,-0.5115 2.22664,-3.54899 4.0799,-1.68011 0.84097,-1.17325 2.08184,-1.26536 3.11993,-2.40016 0.24591,-0.13439 0.12473,-1.26975 0.71998,-0.48003 z'
          H: s \path.province d: 'm 230.62125,246.64347 c 0.0886,1.58423 2.86832,0.57029 0.47998,2.8802 1.66814,1.44648 1.06956,4.27931 -0.47998,2.8802 -1.83401,-1.84334 -1.0589,3.59986 -2.39995,1.92014 -0.72596,-2.12838 -7.54519,0.9801 -7.43983,0.96006 -0.27357,1.92341 -2.8273,1.9797 -1.67996,4.08028 0.55189,-0.62526 1.44823,-0.2138 3.59992,0 0.76236,1.27426 0.6643,3.96476 2.15995,5.28036 1.88798,2.8803 -0.12503,2.35912 -0.95998,4.56031 -0.87747,1.14448 1.71715,3.33826 0,5.28037 0.50236,2.10784 0.1226,3.99528 0,5.28036 -1.4247,2.17491 -1.28916,7.27623 0.47999,8.64059 -0.76131,4.29844 -1.71503,5.78321 -3.50174,0.24546 -3.14214,-5.75281 -12.46693,-10.7677 -16.17781,-11.76625 -3.26177,-2.93572 -5.97555,-1.53047 -10.79975,-1.92013 -2.48754,1.75532 -4.66618,0.94087 -4.55989,-2.64018 -0.23055,-2.62932 -0.10173,-5.68586 -0.71999,-7.2005 0.6539,-2.82068 -3.22499,-4.58008 -0.71998,-6.24043 0.6888,-1.62508 1.82097,-2.85154 2.15995,-5.04033 0.56532,-2.81486 4.37264,-2.81666 5.27988,-6.48046 1.56756,-1.98147 0.006,-4.6416 2.63994,-4.5603 3.23391,1.66951 1.76919,-2.88082 4.3199,-0.96007 0.57441,0.86068 2.91006,0.71181 2.63994,-1.68012 0.63474,-2.24167 1.60889,-2.59992 0.95998,-3.84027 1.48208,-3.39236 5.63467,1.85054 5.51987,0.72006 -1.84622,2.00874 1.36329,2.43337 1.67996,2.64018 1.19714,-0.0423 5.14429,-0.74806 4.55989,2.88019 0.54199,-0.14498 2.98135,0.99318 4.07991,0.72006 -1.11608,-2.09278 3.76145,-2.68916 3.35992,0.48004 1.90231,1.60947 3.97079,1.27545 5.51988,2.88018 z'
          SE: s \path.province d: 'm 265.90043,258.88431 c -2.19751,-1.11568 2.0245,-3.84195 3.11993,-0.48003 -0.19147,3.6458 1.45724,1.61272 0.95998,4.3203 -0.10193,1.66269 0.26449,2.90985 1.19997,3.12021 0.0413,2.22494 2.31608,2.67935 1.91996,3.84027 0.56596,1.67393 2.26067,3.52023 3.35992,2.16014 0.89502,-0.63224 2.43098,0.8139 1.67996,1.4401 0.46444,0.0563 1.02973,1.99788 -0.23999,2.40017 -3.55972,-1.18049 1.19916,3.15408 -2.87994,3.12021 -1.21714,1.69312 -2.17895,-3.38853 -2.63994,-0.24001 -0.97085,1.70551 -2.47528,-1.34706 -2.63994,0.72005 2.72961,2.46192 -3.19966,3.6596 -3.83991,5.04034 -2.94131,-0.6303 -3.22612,2.27769 -5.99986,3.36023 -1.54133,-3.02059 -3.06998,-4.00601 -4.07991,-1.92013 -1.65681,2.34731 -4.13726,2.19748 -2.39994,-0.24002 2.37168,-3.51818 -4.37313,-2.21062 -1.19997,0 -0.58786,1.76121 -3.16893,1.78159 -2.15995,3.84027 -2.17699,-1.44791 -2.87574,-3.8642 -5.03989,-2.16015 -1.28532,1.9593 -7.01907,-0.50452 -6.47985,4.08028 -3.8044,-0.35425 -7.45437,-1.13866 -11.03974,-2.64018 -3.92083,-0.0675 -4.9229,-1.2216 -4.20089,-5.28299 -1.42462,-3.46772 2.3015,-4.6056 0.60097,-6.95785 0.89701,-2.57061 0.19552,-4.55043 0,-6.48045 -0.39196,-1.78431 2.16252,-1.95699 1.67996,-3.84026 -1.25426,-2.04174 -2.8025,-4.5066 -2.39994,-6.48045 -2.76531,-1.06432 -3.45094,-0.0632 -4.5599,-0.72005 0.15919,-1.90995 2.5182,-2.40453 1.91996,-3.84026 1.88227,-0.12534 7.60427,-2.8626 7.67982,-0.48003 1.94133,0.26521 0.61951,-4.06271 2.63994,-2.16015 1.90355,1.37482 1.30339,-1.92548 0.23999,-3.12021 2.69027,-2.20474 -0.87552,-0.88033 -0.47998,-2.8802 1.88114,-2.44335 5.65944,-1.10408 7.67982,-2.64017 1.74255,-1.81654 -0.3344,-2.9992 1.67996,-4.56033 1.06519,-2.01543 2.40595,-1.49343 3.83991,-2.16014 1.31776,-0.25196 3.07306,-0.26164 2.87993,0.96007 -0.37147,-0.15668 -2.99941,2.16372 -0.95997,3.36023 2.25841,-2.94051 5.0685,-2.14857 6.47985,1.20007 0.38371,2.51994 1.08911,3.34725 2.87993,4.80033 -0.0243,1.38034 -0.9953,3.28427 1.91996,3.84027 -0.21933,2.06466 1.9433,3.51981 1.19997,6.00041 -1.11745,-0.0632 -2.63086,-0.10586 -3.35992,0.96006 0.39995,1.25053 -0.2187,1.24408 1.67996,3.12022 0.96476,0.32064 5.58662,-4.20401 7.19983,-2.8802 1.57814,0.33374 0.10374,-2.58311 1.67996,0.48003 l 0.47999,0 z m 1.67996,2.64019 c -0.33097,-2.77422 -2.82016,-2.01354 -0.47999,-0.72005 -0.9002,0.19861 0.86543,1.38816 0.47999,0.72005 z'
          GR: s \path.province d: 'm 353.25842,244.72335 c 1.60099,1.81543 6.24087,5.41983 1.67996,5.7604 -0.058,3.63079 0.20442,5.45589 -0.95998,8.8806 1.12905,2.70796 -3.8145,0.56737 -1.43997,3.60024 1.26577,2.57079 -0.72098,2.08827 -2.87993,2.64019 -1.13402,1.89617 -4.81401,2.66792 -5.75987,5.52037 -0.33678,2.0293 -0.9956,3.92085 -0.71998,6.48045 -1.64791,-1.00356 -3.95997,-0.2647 -3.83991,-1.92013 -3.28098,-2.21819 -2.58603,2.2146 -3.59992,3.36023 -1.44785,1.54561 -2.22849,4.84759 -4.3199,2.64018 -0.84234,2.18426 3.93898,5.71713 -0.23999,6.72046 0.79257,1.31779 -2.62418,1.33131 -0.24,2.8802 0.10231,1.8173 -3.20669,5.20153 -4.55989,5.04035 -4.05656,-0.92962 -5.91758,2.32099 -9.83978,2.16014 -1.55565,-1.3511 -3.74879,-2.27828 -6.23985,-1.44009 -1.75693,0.19125 -4.02156,0.64234 -3.11993,-2.16015 0.37755,-1.24314 -2.20701,-3.60923 -3.35992,-2.8802 -1.29878,-1.79662 -5.60143,-0.90452 -7.19984,-4.08028 -2.62623,-0.41945 -5.5632,-2.4451 -5.75986,-4.80033 0.0273,-2.84163 -2.81262,-5.00122 0.95997,-6.48045 -0.39064,-3.02371 1.35698,-5.17955 3.59992,-5.28036 2.38641,-3.74899 5.73586,0.6036 9.35979,-0.96006 1.66169,0.0946 1.37731,-4.64434 2.63994,-3.60025 2.65033,-1.46575 6.61225,-2.07693 7.67982,-4.80033 2.23052,-1.26138 4.15575,2.98062 6.95984,0.72005 1.50507,-2.12235 3.70312,-3.59709 6.23985,-1.20008 1.9754,1.42667 2.65008,-1.17373 4.3199,0.24001 0.21073,-0.86707 4.77406,-2.77044 2.63994,-4.80033 1.0225,-2.59458 2.89517,-5.2816 4.3199,-8.16055 1.11071,-0.0795 2.10933,-2.57137 3.59992,-1.68011 3.19932,-1.06027 0.64489,-6.07044 4.3199,-4.08029 1.99848,0.23009 3.43353,2.08343 5.75987,1.68012 z'
          AL: s \path.province d: 'm 376.53788,270.88514 c -2.58781,1.63118 -5.23595,5.98826 -6.23985,8.16056 -0.20036,3.52541 -2.60131,7.67693 -2.39995,8.40058 0.37594,1.66044 -3.59933,2.26166 -3.11993,3.84026 0.28713,1.75101 -3.24807,2.51547 -1.91995,3.84026 -1.83398,0.28483 -2.4127,3.09825 -4.5599,1.92014 -1.88076,-5.05511 -6.27468,-3.29643 -8.87979,-4.3203 0.5741,0.15533 -5.0151,0.82245 -4.79989,4.56031 -1.96938,2.36809 -5.56253,2.16273 -6.23986,0.72005 -2.59918,-0.47743 -5.09975,-2.1743 -8.15981,-1.4401 -6.48582,-0.48959 3.08736,-3.48763 0.47999,-5.52038 -1.74401,-1.68606 1.21804,-1.49985 1.19997,-3.12021 2.97389,-0.81864 -1.3012,-4.22105 -0.47999,-5.7604 0.40261,-0.3559 3.41883,0.94452 3.11993,-2.16015 3.12838,-0.65627 0.58089,-5.37232 3.83991,-4.80033 1.61077,1.14096 1.27539,1.83664 3.35992,1.92014 2.69565,1.57057 0.83774,-3.73309 1.91996,-4.80033 0.29003,-3.18604 4.69085,-5.69783 6.95984,-6.72046 2.11135,-0.41534 2.59119,-1.01711 1.91995,-2.8802 -1.57098,-3.2097 3.08575,-0.54697 1.67997,-5.28037 2.13273,-1.91547 -0.63267,-4.99173 1.19997,-6.96046 2.36446,-1.56401 4.20388,-0.64551 6.23985,0.24 1.11617,-0.27075 4.6017,-0.60572 2.87994,2.40018 -0.89298,3.18016 -0.5718,7.03938 1.43996,9.12061 2.33886,4.3434 3.73124,6.20067 7.68681,6.48744 1.01204,0.67679 2.1306,1.08965 2.87295,2.15316 z'
          MA: s \path.province d: 'm 289.41989,278.56567 c 2.08197,2.11268 0.4134,6.92391 3.35992,7.20049 1.70311,2.42402 4.30574,2.51159 5.99986,4.08028 2.59768,0.56687 4.35078,1.96037 5.75987,2.16015 2.30123,0.028 3.37589,3.37609 2.15995,4.56031 -2.53522,-1.12168 -6.01573,1.20988 -8.6398,-0.24001 -2.85524,1.94947 -8.15529,0.89716 -11.75973,1.20008 -0.19733,-1.09277 -2.33207,6.01309 -5.75987,5.52038 -1.26287,2.77808 -4.12095,4.4469 -7.96801,2.67854 -3.84807,-0.57203 -7.25371,2.47817 -11.23154,3.32187 -2.16577,2.00374 -2.04754,5.04262 -4.79989,3.36023 -0.052,-3.38329 -2.6019,-5.77476 -3.35992,-8.40058 -2.50899,-0.32545 -3.2331,1.95281 -5.51988,0.96007 -1.3204,-3.68842 3.21506,0.97947 4.07991,-2.64018 0.2403,-2.17359 5.90085,-2.76996 4.79989,-4.56032 2.92527,-3.07427 -2.43965,-5.51258 1.91995,-7.44051 1.33758,0.679 4.09307,4.11698 5.27988,0.24002 1.33593,-1.28798 0.46724,-4.01757 -0.47999,-5.52038 1.01016,-0.96311 3.36687,-0.79295 4.79989,-2.16015 2.98165,-1.06456 2.04109,-3.06519 1.91996,-4.32029 0.77234,-0.073 2.23599,1.4378 2.39994,-0.72005 1.50338,-1.41375 1.33241,3.14383 3.11993,0.72005 3.17371,-0.54162 -0.88408,-3.77928 2.39995,-3.12022 1.73738,-0.31503 2.7112,0.62516 3.11992,1.92013 2.08419,-0.0353 3.49662,-0.9958 3.83992,-1.68011 0.26583,-1.18468 4.16469,-1.69786 2.63993,0.72005 1.45148,0.56971 1.93035,1.91628 1.91996,2.16015 z'
          CE: s \path.province d: 'm 254.1407,329.20914 c 1.32639,-0.10627 1.69994,1.39809 2.63994,0.72005 2.5885,-1.02266 -3.54032,2.75416 -2.63994,-0.72005 z'
          ML: s \path.province d: 'm 334.77884,355.85097 c -2.49021,0.0209 -0.49239,-3.65134 0,-0.96006 0.2913,-0.18657 -0.73728,0.23762 0,0.96006 z'
          CA: s \path.province d: 'm 263.26049,285.52614 c 1.56992,1.4584 1.38639,3.8853 0.47999,5.28037 -2.24339,5.00698 -5.35579,-3.96811 -7.19983,1.4401 1.67811,1.75779 0.0676,4.62481 0.23999,6.24042 -2.05572,2.13558 -4.97499,1.86158 -5.99986,5.04035 -1.1736,0.22137 -5.16887,-0.30935 -2.63994,1.20008 2.24093,1.96532 3.50797,-2.6163 5.51987,0 0.40052,2.4272 3.1269,4.75601 2.87994,7.92055 4.84052,-1.15275 -1.70463,4.52245 -0.71999,6.96047 -2.00874,-3.24901 -4.54847,1.12551 -3.35992,0.72005 -0.0596,-0.154 0.30326,1.29591 -0.23999,2.8802 -2.9063,0.0324 -5.49808,4.1757 -6.71985,0.24002 -2.35531,-1.40044 -5.21362,-0.37553 -6.23985,-3.36023 -1.75451,-4.01759 -4.75311,-1.21376 -6.71985,-3.12022 -1.44345,-3.87242 -3.13583,-3.9635 -4.55989,-7.20049 -1.26857,-1.831 -2.88029,-6.32937 -3.59992,-6.48045 1.57895,-0.58282 0.64271,0.49199 1.67996,0.96007 -0.40683,4.61104 5.18011,-2.272 0.95998,0.24002 -0.56469,-1.16758 0.86177,-3.22627 -1.67996,-4.3203 -3.11555,-0.19774 -4.03102,-1.53067 -4.79989,-5.04035 0.39647,-1.19362 4.55514,-2.05878 2.87993,-5.04034 1.90339,-4.43708 6.91404,0.40566 10.31976,0.72005 4.45854,1.3526 4.50324,-1.05403 7.63944,-2.86 3.34866,1.74912 3.72987,-2.98622 5.80025,-0.98027 1.43735,0.37661 2.24185,3.63855 3.35993,0.72005 1.31261,-1.12483 1.72727,-2.63364 0.95997,-4.08028 3.8059,-1.78758 1.547,4.12318 1.43997,3.36023 0.6389,2.06561 2.79645,-1.7148 3.83991,-2.16015 1.46002,-2.40937 2.51943,5.62026 5.03989,1.68012 0.58282,0.0739 0.9028,-1.72836 1.43996,-0.96007 z'
        }

        set_province_stats (data) !->
          stats := {}
          total := 0
          max = 0
          for key, v of data
            [c, p, pos] = key.split '|'
            if c is \ES and p
              stats[p] = (stats[p]+v) || v
              total += v
          stats_rank = []
          stats_positions = {}
          for p, v of stats
            if v > max => max = v
            if stats_positions[v]
              stats_positions[v].push p
            else
              stats_positions[v] = [p]

          stats_rank = for v, p of stats_positions => {p, v}
          stats_rank.sort (a, b) -> if a.v > b.v => -1 else if a.v < b.v => 1 else 0
          for r, i in stats_rank
            for _p in r.p
              p = provinces[_p]
              p.set-attribute \fill, if i >= COLORS.length
                "rgb(#{Math.round (v / max) * 255},0,0)"
              else COLORS[i]

        province-list = []
        each provinces, (p, code) !->
          province-list.push p
          floating-tip p, ->
            count = stats[code] || 0
            "#{PROVINCE_LIST[code]}: #{count} (#{if total => Math.round count / total * 100 else 0}% de #{total})"

        s \g.map transform: "scale(.4)", province-list
      # end g.province-stats

      set_panel (panel) !->
        panel_title switch panel
        | \percent => "Total"
        | \sex => "Sexo"
        | \age => "Edad"
        | \province => "Provincia"

        for e, i in panels
          contains = CL e .contains "#{panel}-stats"
          old-display = e.style.display
          e.style.display = if contains => '' else 'none'
          if contains
            buttons[i]?activate!
          else if old-display is ''
            buttons[i]?deactivate!


      return svg_els
    # end svg

  # set-interval window.recalc = !->
  # set-timeout \window.recalc = !->
  #   totals = for i til len => Math.round Math.random! * 1000
  #   total = 0
  #   for i in totals => total += i
  #   percent = Math.random!
  #   set_planets [(Math.round total * percent), (Math.round total * (1 - percent))]
  #   set_ranges (for i til AGES.length+1 => Math.round Math.random! * 100)
  #   set_totals totals
  #
  # , 1000

  return el
#/function stats-module

plugin-boilerplate = (el, id, _config, _data) ->
  const config = defaults {}, _config, DEFAULT_CONFIG

  el._id = id
  unless set_data = el.set_data
    set_data = el.set_data = value!
  unless set_config = config.config
    set_config = config.config = value config

    # add necessary styles (TODO: separate file, dude)
    el.parentNode.append-child h \style """
    .vertele-encuesta div.block {
      display: inline-block;
    }
    .vertele-encuesta div.option-text:hover {
      background: \#009f00;
      color: \#fff;
    }
    .vertele-encuesta div.option-text {
      border: 1px solid \#ccc;
      border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25);
      text-shadow: 0 -1px 0 rgba(0,0,0,.25);
      border-radius: 6px;
      background: \#fffefe;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
      text-decoration: none;
      margin: 0 0 6px;
      padding: 12px 8px;
      font-size: 14px;
      font-weight: 300;
      line-height: 1.42857143;
      text-align: center;
      cursor: pointer;
      outline: none;
      box-shadow: inset 0 1px 0 hsla(0,0%,100%,.2),0 1px 2px rgba(0,0,0,.05);
    }
    \#T {
      position:absolute;
      display:block;
    }
    \#Tcont {
      display:block;
      padding: 2px 12px 3px 7px;
      margin:5px;
      background:\#666;
      color:\#fff;
      border: solid 1px \#ccc;
      border-radius: 12px;
    }
    """

  # remove all children
  while e = el.childNodes.0
    el.removeChild e

  if _data
    set_data _data

  return {config, set_config, set_data}

vertele-profile = (el, id, _config, _data) ->
  {config, set_config, set_data} = plugin-boilerplate el, id, _config, _data

  xhr url: "#{API_ROOT}/#{config.type}*?creator=#{id}&limit=2&sort=+created", (err, res) !->
    if err => return console.error "error processing...", err
    set_data res.data

  els = new ObservArray
  set_data (data) !->
    unless data => return
    for d in data
      els.push h \div.encusta, null, (el) ->
        vertele-encuesta el, d._id, config, d

  el.append-child \
    h \div.affinaty-profile, null, -> els


vertele-encuesta = (el, id, _config, _data) ->
  {config, set_config, set_data} = plugin-boilerplate el, id, _config, _data

  set_title = value ''

  # it'd be a good idea to have a global observable with the current options so that fetching options / data can happen at the same time
  # pass around a pipeline between the functions (actually, use the root element as the anchor for the pipeline)
  # http://localhost:1155/api/poll-stats?_id=55c7435702b8a95e007d6288&ages=[18,25,35,45]
  el.append-child \
    h \div.vertele-encuesta,
      h \h3.destacada, null, set_title
      h \div.block, s: {'text-align': 'center', 'width': '50%'},
        s \svg width: 150, height: 36, s: {margin: '20px 0'},
          s \g, transform: 'scale(.7)', fill: '#fd270d',
            # ¿Qué Opinas?
            s \path, d: "m 8.78904,16.36714 q 0.29297,-0.9375 0.82032,-1.42578 0.54687,-0.48828 1.1914,-0.48828 0.6836,0 1.19141,0.29297 0.52734,0.29297 0.52734,0.95703 0,1.32813 -0.33203,2.38281 -0.33203,1.03516 -0.87891,1.91407 -0.54687,0.85937 -1.25,1.58203 -0.68359,0.72265 -1.42578,1.38672 -0.72265,0.66406 -1.42578,1.32812 -0.68359,0.66406 -1.23047,1.40625 -0.54687,0.74219 -0.8789,1.62109 -0.33203,0.85938 -0.33203,1.95313 0,0.9375 0.19531,1.5625 0.19531,0.60547 0.54687,0.97656 0.35157,0.3711 0.82032,0.52735 0.46875,0.15625 1.03515,0.15625 0.54688,0 1.13281,-0.19532 0.58594,-0.21484 1.13282,-0.54687 0.5664,-0.33203 1.03515,-0.74219 0.46875,-0.42969 0.80078,-0.85937 0.27344,-0.3711 0.625,-0.52735 0.35157,-0.15625 0.6836,-0.15625 0.37109,0 0.72265,0.17578 0.35157,0.17578 0.60547,0.48828 0.27344,0.3125 0.42969,0.72266 0.15625,0.39063 0.15625,0.85938 0,0.21484 -0.0781,0.44921 -0.0586,0.23438 -0.21485,0.44922 -0.58594,0.87891 -1.38672,1.5625 -0.80078,0.6836 -1.73828,1.15235 -0.91797,0.44922 -1.93359,0.68359 -0.9961,0.23438 -1.95313,0.23438 -1.1914,0 -2.5,-0.3711 Q 3.57422,35.48824 2.48047,34.68746 1.40625,33.86714 0.70313,32.63667 0,31.38667 0,29.64839 0,27.57808 0.48828,26.11324 0.97656,24.64839 1.75781,23.55464 2.55859,22.46089 3.53516,21.64058 4.51172,20.80074 5.48828,20.01949 6.46484,19.21871 7.32422,18.37886 8.20313,17.51949 8.78906,16.36714 Z M 8.10545,8.6913596 q 0,-0.0781 0.0195,-0.39062 0.0195,-0.3125 0.11719,-0.72266 0.11719,-0.41016 0.33203,-0.85937 0.23437,-0.46875 0.64453,-0.85938 0.41016,-0.39062 1.03516,-0.64453 0.625,-0.25391 1.52343,-0.25391 0.72266,0 1.3086,0.19532 0.58594,0.17578 0.99609,0.5664 0.42969,0.3711 0.66406,0.97656 0.23438,0.58594 0.23438,1.42579 0,0.70312 -0.21484,1.38671 -0.19532,0.6640704 -0.625,1.1914104 -0.42969,0.52734 -1.11329,0.83984 -0.68359,0.3125 -1.62109,0.3125 -1.62109,0 -2.46094,-0.82031 Q 8.10542,10.2148 8.10542,8.6913596 Z"
            s \path, d: "m 49.41404,15.46871 q 0,2.28515 -0.41015,4.84375 -0.39063,2.53906 -1.21094,5.05859 -0.80078,2.51953 -2.05078,4.86328 -1.25,2.34375 -2.94922,4.21875 -1.69922,1.85547 -3.86719,3.10547 -2.14844,1.25 -4.78515,1.58203 0.91796,0.91797 1.62109,1.77734 0.72266,0.85938 1.40625,1.52344 0.68359,0.6836 1.42578,1.09375 0.74219,0.41016 1.69922,0.41016 0.9375,0 1.81641,-0.48828 0.89843,-0.48828 1.62109,-1.07422 0.83984,-0.6836 1.60156,-1.58203 0.21485,-0.15625 0.41016,-0.17578 0.19531,-0.0195 0.3125,-0.0195 0.50781,0.0977 0.85937,0.39063 0.35157,0.29297 0.54688,0.70312 0.21484,0.41016 0.29297,0.85938 0.0976,0.46875 0.0976,0.85937 0,0.50782 -0.11718,0.70313 -0.0977,0.21484 -0.19532,0.3125 -0.0195,0.0195 -0.35156,0.35156 -0.33203,0.35156 -0.9375,0.85938 -0.58594,0.50781 -1.42578,1.09375 -0.82031,0.60547 -1.83594,1.093749 -0.99609,0.50781 -2.14844,0.83984 -1.13281,0.33203 -2.36328,0.33203 -1.48437,0 -2.51953,-0.5664 Q 34.92181,47.871089 34.17962,46.97265 33.45696,46.09375 32.96868,45 32.49993,43.92578 32.10931,42.89062 31.71868,41.85546 31.36712,40.97656 31.01556,40.11718 30.54681,39.66796 27.57806,39.14062 25.46868,37.69531 23.35931,36.25 22.01165,34.16015 q -1.34766,-2.08984 -1.97266,-4.70703 -0.625,-2.61719 -0.625,-5.46875 0,-2.65625 0.48828,-5.46875 0.50782,-2.8125 1.48438,-5.46875 0.99609,-2.67578 2.46094,-5.0390604 1.48437,-2.36328 3.4375,-4.14063 1.95312,-1.79687 4.375,-2.83203 Q 34.10149,-3.9098643e-7 36.99212,-3.9098643e-7 q 2.91015,0 5.21484,1.11327999098643 2.30469,1.11328 3.90625,3.14453 1.60156,2.01172 2.44141,4.88281 0.85937,2.8515604 0.85937,6.3281304 z M 32.49998,34.99996 q 1.48438,0 2.75391,-0.60547 1.28906,-0.625 2.36328,-1.67969 1.07422,-1.05469 1.93359,-2.48047 0.87891,-1.44531 1.5625,-3.06641 0.6836,-1.64062 1.19141,-3.3789 0.50781,-1.75781 0.83984,-3.45703 0.33203,-1.71875 0.48828,-3.30078 0.15625,-1.60157 0.15625,-2.89063 0,-2.22656 -0.39062,-4.12109 -0.39063,-1.9140704 -1.19141,-3.3007804 -0.80078,-1.40625 -2.01172,-2.1875 -1.21093,-0.78125 -2.85156,-0.78125 -1.66016,0 -3.22266,0.91796 -1.5625,0.91797 -2.92968,2.48047 -1.36719,1.5625 -2.5,3.6132804 -1.13282,2.05079 -1.95313,4.33594 -0.80078,2.28516 -1.25,4.64844 -0.44922,2.36328 -0.44922,4.53125 0,2.30469 0.50782,4.27734 0.50781,1.95313 1.46484,3.39844 0.95703,1.42578 2.34375,2.24609 1.38672,0.80079 3.14453,0.80079 z"
            s \path, d: "m 64.17967,18.76949 q 0,0.52734 -0.11719,1.44531 -0.11719,0.89844 -0.3125,1.99219 -0.17578,1.07422 -0.39062,2.22656 -0.21485,1.15234 -0.41016,2.14844 -0.17578,0.99609 -0.29297,1.75781 -0.11719,0.74219 -0.11719,1.03516 0,0.54687 0.0195,1.01562 0.0195,0.44922 0.11719,0.80078 0.0977,0.33203 0.29297,0.52735 0.21484,0.17578 0.60547,0.17578 0.42969,0 1.03516,-0.21485 0.625,-0.21484 1.30859,-0.5664 0.70312,-0.3711 1.42578,-0.82032 0.72266,-0.46875 1.36719,-0.97656 0.66406,-0.50781 1.1914,-0.99609 0.54688,-0.50781 0.87891,-0.9375 0,0.64453 0,1.17187 0.0195,0.52735 0.0195,1.01563 0,0.46875 0,0.97656 0.0195,0.50781 0.0195,1.13281 -0.42968,0.42969 -1.07422,0.91797 -0.625,0.48828 -1.40625,0.97656 -0.76171,0.48829 -1.64062,0.9375 -0.85938,0.44922 -1.73828,0.80079 -0.87891,0.33203 -1.73828,0.54687 -0.85938,0.19531 -1.60157,0.19531 -0.74218,0 -1.26953,-0.29297 -0.52734,-0.29296 -0.91797,-0.82031 -0.37109,-0.52734 -0.64453,-1.25 -0.2539,-0.74219 -0.44922,-1.64062 -0.70312,0.91797 -1.48437,1.69922 -0.78125,0.76171 -1.60156,1.32812 -0.80078,0.56641 -1.64063,0.89844 -0.82031,0.3125 -1.60156,0.3125 -0.64453,0 -1.21094,-0.21485 -0.5664,-0.21484 -1.01562,-0.72265 -0.42969,-0.50781 -0.6836,-1.32813 -0.2539,-0.83984 -0.2539,-2.07031 0,-1.50391 0.35156,-3.82812 0.37109,-2.32422 0.89844,-5.3125 0.0391,-0.29297 0.13672,-0.78125 0.11718,-0.50782 0.29296,-1.09375 0.19532,-0.58594 0.46875,-1.19141 0.27344,-0.60547 0.64454,-1.09375 0.37109,-0.48828 0.85937,-0.80078 0.50781,-0.3125 1.13281,-0.33203 1.03516,0.0391 1.48438,0.27343 0.44922,0.21485 0.44922,0.54688 -0.17578,1.03516 -0.39063,2.30469 -0.19531,1.26953 -0.41015,2.55859 -0.21485,1.28906 -0.41016,2.51953 -0.19531,1.21094 -0.35156,2.16797 -0.15625,0.95703 -0.25391,1.54297 -0.0781,0.58594 -0.0781,0.60547 0,0.35156 0.0586,0.68359 0.0781,0.3125 0.21484,0.56641 0.13672,0.2539 0.35157,0.41015 0.21484,0.15625 0.50781,0.15625 0.42969,0 0.8789,-0.21484 0.44922,-0.23437 0.83985,-0.64453 0.41015,-0.42969 0.72265,-1.03516 0.3125,-0.625 0.46875,-1.40625 l 1.9336,-9.92187 q 0.0977,-0.46875 0.78125,-0.78125 0.70312,-0.33203 1.58203,-0.33203 0.99609,0 1.58203,0.35156 0.58594,0.35156 0.58594,0.89844 z"
            s \path, d: "m 74.99998,36.24996 q -1.83594,0 -3.22266,-0.66407 -1.36718,-0.66406 -2.28515,-1.77734 -0.91797,-1.13281 -1.38672,-2.59766 -0.44922,-1.48437 -0.44922,-3.10547 0,-1.09375 0.21484,-2.30468 0.21485,-1.23047 0.64454,-2.40235 0.44921,-1.17187 1.11328,-2.22656 0.66406,-1.07422 1.54297,-1.875 0.89843,-0.82031 1.99218,-1.28906 1.11328,-0.48828 2.46094,-0.48828 1.09375,0 2.03125,0.35156 0.9375,0.35156 1.62109,0.99609 0.70313,0.625 1.09375,1.52344 0.39063,0.89844 0.39063,2.01172 0,1.21094 -0.60547,2.42187 -0.58594,1.21094 -1.64062,2.28516 -1.05469,1.07422 -2.51954,1.91406 -1.44531,0.83985 -3.14453,1.3086 0.29297,0.52734 0.56641,0.8789 0.29297,0.35157 0.58594,0.54688 0.29297,0.19531 0.60547,0.27344 0.33203,0.0781 0.70312,0.0781 1.17188,0 2.46094,-0.46875 1.30859,-0.46875 2.53906,-1.17187 1.23047,-0.70313 2.32422,-1.52344 1.09375,-0.83985 1.85547,-1.58203 l 2.51953,2.61718 q -1.71875,1.77735 -3.65234,3.14454 -0.83985,0.58593 -1.81641,1.15234 -0.95703,0.56641 -2.03125,1.01562 -1.05469,0.42969 -2.20703,0.70313 -1.13281,0.25391 -2.30469,0.25391 z m -2.59766,-9.17969 q 0.70313,0 1.52344,-0.35156 0.83985,-0.3711 1.54297,-0.9375 0.72266,-0.56641 1.21094,-1.23047 0.48828,-0.66407 0.48828,-1.28907 0,-0.8789 -0.33203,-1.44531 -0.3125,-0.5664 -0.78125,-0.5664 -0.83985,0 -1.44531,0.3125 -0.58594,0.3125 -0.9961,0.82031 -0.39062,0.48828 -0.64453,1.13281 -0.23437,0.625 -0.37109,1.26953 -0.11719,0.64453 -0.15625,1.25 -0.0391,0.60547 -0.0391,1.03516 z m 2.71485,-14.96094 q 0.11719,-0.25391 0.33203,-0.76172 0.21484,-0.52734 0.48828,-1.17187 0.29297,-0.6640704 0.60547,-1.4257804 0.33203,-0.76172 0.66406,-1.50391 0.76172,-1.75781 1.66016,-3.78906 0.2539,-0.66407 0.76172,-0.95703 0.52734,-0.29297 1.09375,-0.29297 0.50781,0 1.01562,0.19531 0.50781,0.19531 0.89844,0.54687 0.41016,0.35157 0.66406,0.83985 0.25391,0.48828 0.25391,1.07422 0,0.91797 -0.72266,1.89453 -0.37109,0.50781 -0.85937,1.13281 -0.46875,0.60547 -0.9961,1.28906 -0.50781,0.66407 -1.05468,1.3281304 -0.52735,0.66406 -1.01563,1.26953 -0.48828,0.58594 -0.89844,1.07422 -0.39062,0.48828 -0.625,0.78125 -0.33203,0.39062 -0.66406,0.5664 -0.33203,0.15625 -0.66406,0.15625 -0.46875,0 -0.80078,-0.35156 -0.33203,-0.37109 -0.33203,-0.95703 0,-0.21484 0.0391,-0.44922 0.0586,-0.23437 0.15625,-0.48828 z"
            s \path, d: "m 106.40623,21.62105 q 0.56641,1.13281 0.83984,2.40234 0.29297,1.25 0.29297,2.40235 0,1.15234 -0.2539,2.32422 -0.25391,1.17187 -0.74219,2.26562 -0.46875,1.09375 -1.17188,2.05078 -0.68359,0.95703 -1.58203,1.66016 -0.8789,0.70312 -1.93359,1.11328 -1.05469,0.41016 -2.24609,0.41016 -1.71875,0 -2.94922,-0.74219 -1.21094,-0.76172 -1.99219,-1.97266 -0.78125,-1.21094 -1.15234,-2.73437 -0.35157,-1.52344 -0.35157,-3.08594 0,-2.14844 0.64453,-4.00391 0.64454,-1.875 1.83594,-3.24218 1.21094,-1.38672 2.94922,-2.16797 1.73828,-0.80078 3.90625,-0.80078 1.85547,0 3.47656,0.58593 1.6211,0.56641 3.02735,1.54297 1.42578,0.95703 2.63672,2.20703 1.23046,1.25 2.28515,2.57813 l -0.37109,2.7539 q -0.52735,-0.70312 -1.42578,-1.52343 -0.89844,-0.82032 -1.91407,-1.60157 -0.99609,-0.78125 -1.97265,-1.46484 -0.97656,-0.70312 -1.67969,-1.17187 l -0.15625,0.21484 z m -6.03516,10.87891 q 0.66407,0 1.28907,-0.66407 0.625,-0.68359 1.09375,-1.69922 0.46875,-1.03515 0.74218,-2.26562 0.29297,-1.25 0.29297,-2.38281 0,-0.89844 -0.13672,-1.66016 -0.13671,-0.78125 -0.41015,-1.34766 -0.27344,-0.5664 -0.70313,-0.89843 -0.42968,-0.33203 -1.03515,-0.33203 -0.80078,0 -1.52344,0.68359 -0.72266,0.68359 -1.26953,1.75781 -0.54688,1.05469 -0.85938,2.34375 -0.3125,1.28906 -0.3125,2.48047 0,0.82031 0.15625,1.54297 0.15625,0.72266 0.48828,1.26953 0.33204,0.52734 0.87891,0.85938 0.54688,0.3125 1.30859,0.3125 z"
            s \path, d: "m 119.41404,32.77339 q 1.97266,0 3.59375,-0.39062 1.6211,-0.39063 2.92969,-1.05469 1.32813,-0.66406 2.38281,-1.54297 1.07422,-0.89844 1.9336,-1.91406 l 0.21484,4.47266 q -0.625,0.76171 -1.52344,1.48437 -0.8789,0.70313 -1.93359,1.25 -1.05469,0.52734 -2.22656,0.85938 -1.15235,0.3125 -2.28516,0.3125 -0.13672,0 -0.35156,-0.0391 -0.19531,-0.0391 -0.70313,-0.13672 -0.50781,-0.0976 -1.46484,-0.2539 -0.9375,-0.17578 -2.55859,-0.41016 l 0,0.35156 q 0,3.55469 -0.60547,6.44532 -0.58594,2.91015 -1.58203,4.96093 -0.9961,2.050789 -2.28516,3.164069 -1.28906,1.11328 -2.67578,1.11328 -1.11328,0 -1.85547,-0.54688 -0.74219,-0.54687 -1.17188,-1.48437 -0.44921,-0.91797 -0.625,-2.167969 -0.19531,-1.23047 -0.19531,-2.61719 0,-0.80078 0.25391,-1.8164 0.2539,-0.9961 0.68359,-2.10938 0.42969,-1.09375 0.97656,-2.24609 0.52735,-1.13282 1.09375,-2.20703 1.32813,-2.5 3.02735,-5.15625 0.21484,-1.52344 0.42969,-3.125 0.23437,-1.60157 0.5664,-3.10547 0.35156,-1.50391 0.85938,-2.85157 0.52734,-1.34765 1.32812,-2.34375 0.82031,-0.99609 1.95313,-1.58203 1.13281,-0.58593 2.73437,-0.58593 1.19141,0 2.22656,0.33203 1.03516,0.3125 1.81641,1.03515 0.78125,0.72266 1.23047,1.875 0.44922,1.13282 0.44922,2.79297 0,1.32813 -0.39063,2.57813 -0.39062,1.23047 -1.23047,2.36328 -0.82031,1.13281 -2.10937,2.1289 -1.26953,0.97657 -3.02734,1.75782 l 0.11718,0.41015 z m -2.46093,-1.97265 q 1.17187,-0.58594 2.01171,-1.3086 0.85938,-0.72265 1.46485,-1.54297 0.625,-0.82031 1.01562,-1.69921 0.39063,-0.87891 0.625,-1.79688 0.0977,-0.42969 0.11719,-0.99609 0.0391,-0.58594 -0.11719,-1.09375 -0.13672,-0.50782 -0.50781,-0.85938 -0.35156,-0.37109 -0.99609,-0.37109 -0.72266,0 -1.26953,0.41015 -0.54688,0.39063 -0.95704,1.07422 -0.39062,0.6836 -0.66406,1.6211 -0.2539,0.9375 -0.42969,2.01172 -0.15625,1.07421 -0.23437,2.24609 -0.0586,1.15234 -0.0586,2.30469 z m -6.79688,14.0625 q 0,0.15625 0.0586,0.50781 0.0781,0.35156 0.23438,0.70312 0.15625,0.35157 0.41016,0.625 0.2539,0.27344 0.625,0.27344 0.33203,0 0.54687,-0.37109 0.21484,-0.35156 0.35156,-0.95703 0.13672,-0.60547 0.19532,-1.36719 0.0586,-0.76172 0.0976,-1.5625 0.0391,-0.80078 0.0391,-1.5625 0.0195,-0.76172 0.0586,-1.36719 0.0586,-1.05469 0.0781,-1.79687 0.0391,-0.72266 0.0586,-1.21094 0.0195,-0.54688 0.0391,-0.91797 -0.37109,0.64453 -0.72266,1.48438 -0.35156,0.85937 -0.66406,1.77734 -0.3125,0.91797 -0.56641,1.83594 -0.2539,0.91797 -0.44921,1.69922 -0.17579,0.80078 -0.29297,1.36718 -0.0977,0.58594 -0.0977,0.83985 z"
            s \path, d: "m 140.03904,32.0898 q -0.70312,0.64453 -1.75781,1.38672 -1.03516,0.72265 -2.24609,1.34765 -1.21094,0.60547 -2.48047,1.01563 -1.25,0.41016 -2.38281,0.41016 -1.01563,0 -1.71875,-0.27344 -0.6836,-0.29297 -1.11329,-0.80078 -0.42968,-0.50782 -0.625,-1.23047 -0.17578,-0.74219 -0.17578,-1.6211 0,-1.23046 0.27344,-2.85156 0.29297,-1.64062 0.70313,-3.3789 0.41015,-1.75782 0.85937,-3.4961 0.46875,-1.73828 0.82031,-3.20312 0.13672,-0.50782 0.54688,-0.85938 0.41015,-0.37109 0.91797,-0.58594 0.52734,-0.23437 1.07422,-0.33203 0.5664,-0.11718 1.01562,-0.11718 0.82031,0 1.11328,0.3125 0.29297,0.29296 0.29297,0.80078 0,0.42968 -0.19531,1.25 -0.19531,0.80078 -0.48828,1.83593 -0.29297,1.01563 -0.625,2.20704 -0.33203,1.17187 -0.625,2.36328 -0.29297,1.17187 -0.48828,2.30468 -0.19532,1.11329 -0.19532,2.01172 0,0.87891 0.19532,1.40625 0.19531,0.50782 0.80078,0.50782 0.70312,0 1.5625,-0.48829 0.85937,-0.48828 1.73828,-1.17187 0.8789,-0.70313 1.71875,-1.44531 0.83984,-0.74219 1.48437,-1.26953 l 0,3.96484 z m -8.73047,-20.07813 q 0,-0.44921 0.19532,-1.01562 0.19531,-0.56641 0.625,-1.0546904 0.44922,-0.50781 1.17187,-0.83984 0.74219,-0.35156 1.83594,-0.35156 0.68359,0 1.28906,0.15625 0.60547,0.15625 1.05469,0.48828 0.44922,0.3125 0.70312,0.8398404 0.27344,0.52734 0.27344,1.25 0,0.66406 -0.21484,1.28906 -0.21485,0.625 -0.6836,1.11328 -0.46875,0.48829 -1.1914,0.80079 -0.70313,0.29296 -1.69922,0.29296 -1.71875,0 -2.53906,-0.80078 -0.82032,-0.82031 -0.82032,-2.16797 z"
            s \path, d: "m 138.63279,32.16792 q 0,-1.28906 0.15625,-2.96875 0.15625,-1.69921 0.39063,-3.4375 0.23437,-1.75781 0.52734,-3.3789 0.29297,-1.6211 0.56641,-2.77344 0.21484,-0.89844 0.82031,-1.50391 0.625,-0.60546 1.67969,-0.60546 1.05469,0 1.46484,0.64453 0.41016,0.64453 0.41016,1.71875 0,0.29297 -0.0586,0.80078 -0.0586,0.48828 -0.15625,1.09375 -0.0781,0.58594 -0.17578,1.23047 -0.0976,0.625 -0.19531,1.17187 -0.0781,0.52735 -0.13672,0.9375 -0.0586,0.39063 -0.0586,0.52735 l 0.39062,0 q 0.11719,-0.21485 0.3711,-0.6836 0.2539,-0.48828 0.58593,-1.11328 0.33204,-0.625 0.70313,-1.30859 0.39062,-0.70313 0.72266,-1.32813 0.33203,-0.64453 0.60546,-1.13281 0.27344,-0.48828 0.41016,-0.72266 0.625,-1.05468 1.42578,-1.44531 0.80078,-0.39062 1.77735,-0.39062 0.97656,0 1.54296,0.82031 0.58594,0.82031 0.58594,2.26562 0,0.21485 -0.0976,0.72266 -0.0781,0.50781 -0.21485,1.21094 -0.13672,0.70312 -0.3125,1.54297 -0.15625,0.83984 -0.29297,1.71875 -0.13672,0.8789 -0.23437,1.73828 -0.0781,0.85937 -0.0781,1.58203 0,1.21094 0.29297,1.99219 0.3125,0.78125 0.95703,0.78125 0.29297,0 0.66407,-0.17579 0.39062,-0.17578 0.82031,-0.44921 0.44922,-0.29297 0.89844,-0.66407 0.46875,-0.37109 0.91796,-0.76172 1.03516,-0.91796 2.16797,-2.07031 l 0.33203,4.375 -0.97656,0.74219 q -0.80078,0.60547 -1.64062,1.21094 -0.82032,0.60547 -1.71875,1.09375 -0.89844,0.46875 -1.875,0.78125 -0.97657,0.29297 -2.05078,0.29297 -1.07422,0 -1.81641,-1.54297 -0.72266,-1.5625 -0.72266,-4.55078 0,-1.17188 0.15625,-2.51954 0.15625,-1.36718 0.39063,-2.92968 l -0.3125,0 -5.11719,10.15625 q -0.39062,0.80078 -0.87891,1.09375 -0.48828,0.29297 -1.13281,0.29297 -0.80078,0 -1.28906,-0.33204 -0.48828,-0.35156 -0.76172,-0.91796 -0.25391,-0.58594 -0.35156,-1.3086 -0.0781,-0.74219 -0.0781,-1.52344 z"
            s \path, d: "m 177.18748,31.4648 q -0.44922,0.625 -1.21094,1.46484 -0.74218,0.83985 -1.67968,1.60157 -0.9375,0.76171 -2.01172,1.28906 -1.07422,0.52734 -2.14844,0.52734 -1.28906,0 -2.14844,-0.82031 -0.85937,-0.83984 -1.48437,-2.42188 -0.46875,0.54688 -1.15235,1.11329 -0.68359,0.5664 -1.5039,1.03515 -0.80078,0.44922 -1.67969,0.74219 -0.87891,0.29297 -1.75781,0.29297 -0.9375,0 -1.83594,-0.3711 -0.87891,-0.39062 -1.5625,-1.09375 -0.68359,-0.72265 -1.09375,-1.73828 -0.41016,-1.03515 -0.41016,-2.32422 0,-1.46484 0.41016,-3.00781 0.41016,-1.54297 1.13281,-3.00781 0.72266,-1.48438 1.69922,-2.79297 0.99609,-1.30859 2.16797,-2.28516 1.17187,-0.97656 2.46094,-1.54296 1.30859,-0.58594 2.65625,-0.58594 0.44922,0 0.70312,0.17578 0.25391,0.17578 0.41016,0.41016 0.17578,0.21484 0.33203,0.42968 0.15625,0.21485 0.39062,0.3125 0.23438,0.0977 0.46875,0.13672 0.25391,0.0195 0.50782,0.0195 0.21484,0 0.42968,0 0.23438,-0.0195 0.44922,-0.0195 0.29297,0 0.54688,0.0586 0.2539,0.0586 0.44922,0.2539 0.19531,0.19531 0.29297,0.54688 0.11718,0.35156 0.11718,0.95703 0,0.9375 -0.19531,2.08984 -0.19531,1.13281 -0.42969,2.34375 -0.23437,1.19141 -0.42968,2.40235 -0.19532,1.1914 -0.19532,2.26562 0,0.91797 0.15625,1.44531 0.17578,0.50782 0.72266,0.50782 0.41016,0 0.85937,-0.19532 0.44922,-0.21484 0.89844,-0.54687 0.46875,-0.33203 0.91797,-0.74219 0.46875,-0.42969 0.87891,-0.87891 0.95703,-1.05468 1.93359,-2.38281 l 0.9375,4.33594 z m -16.67969,-1.54297 q 0,0.48828 0.0586,0.95703 0.0781,0.44922 0.2539,0.82031 0.17578,0.35157 0.46875,0.58594 0.29297,0.21485 0.74219,0.21485 0.72266,0 1.30859,-0.625 0.58594,-0.625 1.01563,-1.50391 0.42969,-0.87891 0.68359,-1.81641 0.27344,-0.9375 0.35157,-1.5625 l 1.1914,-5.74218 q -0.80078,0 -1.5625,0.41015 -0.76172,0.39063 -1.44531,1.07422 -0.66406,0.68359 -1.23047,1.5625 -0.56641,0.87891 -0.97656,1.85547 -0.41016,0.95703 -0.64453,1.93359 -0.21485,0.97657 -0.21485,1.83594 z"
            s \path, d: "m 174.25779,28.74996 q 1.09375,-0.9375 1.77735,-1.5625 0.68359,-0.625 1.17187,-1.13282 0.48828,-0.52734 0.87891,-1.05468 0.41015,-0.52735 0.95703,-1.25 0.54687,-0.72266 1.32812,-1.75782 0.78125,-1.05468 2.03125,-2.61718 0.25391,-0.35157 0.56641,-0.6836 0.3125,-0.33203 0.68359,-0.58594 0.39063,-0.27343 0.83985,-0.42968 0.46875,-0.17578 1.03515,-0.17578 0.9375,0 1.44532,0.21484 0.50781,0.19531 0.74218,0.48828 0.23438,0.29297 0.27344,0.625 0.0391,0.3125 0.0391,0.54688 0,0.46875 -0.37109,1.03515 -0.37109,0.56641 -0.82031,1.09375 -0.44922,0.52735 -0.85938,0.97656 -0.39062,0.42969 -0.44922,0.64454 0,0.60546 0.0781,1.11328 0.0977,0.48828 0.23437,0.97656 0.15625,0.46875 0.3125,1.01562 0.15625,0.52735 0.29297,1.23047 0.15625,0.70313 0.23438,1.6211 0.0977,0.91797 0.0977,2.16797 0.70313,-0.46875 1.50391,-0.83985 0.82031,-0.39062 1.69922,-0.80078 0.87891,-0.41016 1.79687,-0.89844 0.9375,-0.50781 1.875,-1.21093 l 0.0195,4.375 q -1.21094,0.9375 -2.8125,1.75781 -1.58204,0.82031 -3.33985,1.44531 -1.73828,0.625 -3.53515,0.99609 -1.77735,0.35157 -3.37891,0.35157 -1.15234,0 -2.14844,-0.21485 -0.99609,-0.21484 -1.75781,-0.66406 -0.74219,-0.46875 -1.21094,-1.21094 -0.46875,-0.74218 -0.5664,-1.79687 -0.27344,0.0586 -0.54688,0.0781 -0.25391,0.0195 -0.50781,0.0195 -0.3125,0 -0.58594,-0.0195 -0.27344,-0.0195 -0.46875,-0.13672 -0.19531,-0.13671 -0.3125,-0.41015 -0.11719,-0.29297 -0.11719,-0.82031 0,-0.46875 0.23438,-0.85938 0.23437,-0.41016 0.54687,-0.72266 0.3125,-0.3125 0.625,-0.54687 0.3125,-0.23438 0.46875,-0.37109 z m 2.5,2.5 q 0.23438,0 0.50782,0.29296 0.29296,0.29297 0.66406,0.64454 0.37109,0.35156 0.85937,0.64453 0.48828,0.29297 1.11328,0.29297 0.76172,0 1.25,-0.25391 0.50782,-0.25391 0.80079,-0.66406 0.29296,-0.42969 0.41015,-0.97657 0.11719,-0.5664 0.11719,-1.17187 0,-0.52734 -0.0781,-1.07422 -0.0586,-0.54687 -0.17578,-1.03516 -0.0976,-0.50781 -0.23437,-0.9375 -0.11719,-0.44921 -0.21485,-0.76171 l -5.01953,5 z"
            s \path, d: "m 203.14451,24.84371 q -0.29297,0.9375 -0.83984,1.42578 -0.52735,0.48828 -1.17188,0.48828 -0.68359,0 -1.21093,-0.29297 -0.50782,-0.29297 -0.50782,-0.95703 0,-1.75781 0.56641,-3.04688 0.58594,-1.30859 1.44531,-2.32422 0.85938,-1.03515 1.85547,-1.89453 1.01563,-0.85937 1.875,-1.77734 0.85938,-0.91797 1.42578,-1.99219 0.58594,-1.09375 0.58594,-2.53906 0,-0.82031 -0.3125,-1.38672 -0.29297,-0.5664104 -0.78125,-0.9179704 -0.46875,-0.37109 -1.05469,-0.52734 -0.58594,-0.17578 -1.17187,-0.17578 -0.44922,0 -0.9375,0.27343 -0.48828,0.27344 -0.91797,0.64454 -0.42969,0.3710904 -0.74219,0.7812504 -0.3125,0.39062 -0.39062,0.625 -0.33204,0.41015 -0.76172,0.60546 -0.41016,0.17579 -0.85938,0.17579 -0.37109,0 -0.74219,-0.19532 -0.35156,-0.19531 -0.625,-0.52734 -0.27343,-0.35156 -0.44921,-0.80078 -0.17579,-0.46875 -0.17579,-1.0156304 0,-0.42968 0.29297,-0.89843 0.58594,-0.87891 1.38672,-1.5625 0.80078,-0.6836 1.71875,-1.13282 0.9375,-0.46875 1.9336,-0.70312 0.99609,-0.23438 1.97265,-0.23438 1.19141,0 2.5,0.39063 1.3086,0.37109 2.38281,1.1914 1.09375,0.80079 1.79688,2.05079 0.70312,1.25 0.70312,2.9687504 0,2.07031 -0.48828,3.53515 -0.48828,1.46485 -1.28906,2.5586 -0.78125,1.09375 -1.75781,1.93359 -0.97656,0.82031 -1.95313,1.62109 -0.97656,0.78125 -1.85547,1.64063 -0.8789,0.85937 -1.44531,1.99219 z m 0.6836,7.67578 q 0,0.0781 -0.0195,0.39062 -0.0195,0.3125 -0.13671,0.72266 -0.0977,0.41015 -0.33204,0.8789 -0.21484,0.44922 -0.625,0.83985 -0.41015,0.39062 -1.03515,0.64453 -0.625,0.25391 -1.52344,0.25391 -0.72266,0 -1.30859,-0.17579 -0.58594,-0.19531 -1.01563,-0.5664 -0.41015,-0.39063 -0.64453,-0.97656 -0.23437,-0.60547 -0.23437,-1.44532 0,-0.70312 0.19531,-1.36718 0.21484,-0.6836 0.64453,-1.21094 0.42969,-0.52735 1.11328,-0.83985 0.68359,-0.3125 1.62109,-0.3125 1.6211,0 2.46094,0.82032 0.83985,0.82031 0.83985,2.34375 z"
        (el) !->
          click = !-> window.open "http://affinaty.com/#{config.type}/#{id}", '_blank'
          els = new ObservArray
          set_data (data) !->
            unless data => return
            # TODO: remove the pop when you fix the set_data function being called multiple times
            while els.length => els.pop!
            set_title data.text
            if options = data.options
              for o in options
                els.push h \div.option-text, on: {click}, o.text
          return els
      h \div.block, null, (el) !->
        stats-module el, id, config, _data

window.affinaty =
  vertele: vertele-encuesta
  poll-stats: stats-module


# affinaty.poll-stats el, '575fb8a7db984f6500ce1cdd', {
#   # winning_icon: 'star',
#   bar:
#     fg: '#f00'
#     bg: '#ccc'
#     winning_fg: '#0f0'
# }

# require! \parse-svg-path
# require! \normalize-svg-path
# require! \serialize-svg-path
# require! \svg-path
#
# el = doc.get-element-by-id \check
# bb = el.getBBox!
# console.log \bb, bb
#
# window.ss = ss = svg-path el.get-attribute \d
# # window.ss = ss = svg-path 'M1671 970q0 -40 -28 -68l-724 -724l-136 -136q-28 -28 -68 -28t-68 28l-136 136l-362 362q-28 28 -28 68t28 68l136 136q28 28 68 28t68 -28l294 -295l656 657q28 28 68 28t68 -28l136 -136q28 -28 28 -68z'
# # ss.translate -200, -1600
# # ss.rotate 180
# # ss.scale -0.01, 0.01
# ss.translate (if bb.x > 0 => -bb.x else bb.x) - (bb.width / 2), (if bb.y > 0 => -bb.y else bb.y) - (bb.height / 2)
# ss.rotate 180
# scale = 1 / bb.width * 14
# console.log \scale, scale
# ss.scale scale, scale
# console.log ss.to-string!
# el.set-attribute \d, ss.to-string!
# el.set-attribute \transform, 'scale(-.01 .01)'
