``import each from '../lib/lodash/forEach'``
``import defaults from '../lib/lodash/defaultsDeep'``
``import h from '../lib/dom/hyper-hermes'``
``import CL from '../lib/dom/class-list'``
``import { attribute, value } from '../lib/dom/observable'``
``import floatingTip from '../lib/decorators/floating-tip'``
``import describeConeSection from '../lib/svg/describeConeSection'``

# TODO: write my own svg optimizer which uses ceil(num, 2) // for 6.01 2-digit precision
# ``import ceil from '../lib/lodash/ceil'``

const doc = document
# set the domain (to allow parent window modification)
doc.domain = doc.domain
console.info "set frame to: #{doc.domain}"

doc.body.style.padding = 0

const fetch = window.fetch or require \whatwg-fetch

const s = h.context (el) ->
  doc.createElementNS 'http://www.w3.org/2000/svg', el

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

empty-array = (num) ->
  a = new Array num
  for i til num
    a[i] = 0
  a

function vote-module (el, id, _config)
  const config = defaults {}, DEFAULT_CONFIG, _config
  const width = el.clientWidth || config.width || 300
  (options) <-! set_options

  # first: clear the element
  while e = el.childNodes.0
    el.removeChild e
  el.appendChild \
    s \svg width: svg_width, height: svg_height, !->

      return s \svg

function stats-module (el, id, _config)
  # TODO: if typeof _config is \string => fetch the config
  # set_config = value!
  const config = defaults {}, DEFAULT_CONFIG, _config
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
  const bar_x = 300 + icon_size + (icon_padding * 2)
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

  # TODO: set a loading indicator

  const URL = "http://affinaty.com:1155/api/#{config.type}-stats?_id=#{id}&ages=[#{AGES}]"
  fetch URL
    .then (res) -> res.json!
    .then (res) !->
      # console.log "data!", res.data
      calc res.data
    .catch (e) !->
      console.error "error processing...", e.stack


  !function calc (data)
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
  #/function calc (data)

  (options) <-! set_options

  # first: clear the element
  while e = el.childNodes.0
    el.removeChild e

  unless options
    # TODO: show loading box
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
      buttons = []
      window.set_panel = set_panel
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
      ]
      svg_els.push s \text,
        x: width - 10
        y: 40
        'font-size': 18
        'text-anchor': \end,
          panel_title

      const voting_x = 10
      const voting-width = 266 + 18
      const half-voting-width = voting-width / 2
      const voting-height = 42

      svg_els.push s \g.voting, null, ->
        els = []
        last_y = -voting-height + 79
        mouseenter = !->
          n = this.childNodes
          n.0.set-attribute \fill, '#009f00'
          n.0.set-attribute \stroke, '#007f00'
          n.1.set-attribute \fill, '#fff'
        mouseleave = !->
          n = this.childNodes
          n.0.set-attribute \fill, '#fff'
          n.0.set-attribute \stroke, '#fd270d'
          n.1.set-attribute \fill, '#666'
        for o in options
          els.push s \g.vote-button, on: { mouseenter, mouseleave }, s: { cursor: \pointer },
            s \rect,
              rx: 8
              ry: 8
              width: voting-width
              height: voting-height
              x: voting_x
              y: (last_y += voting-height + 8)
              stroke: '#fd270d'
              'stroke-width': 0.5
              # filter: 'url(#icon-filter)'
              fill: '#fff'
            s \text,
              x: half-voting-width + voting_x
              y: last_y + voting-height - 16
              'font-size': 14
              # 'stroke-width': 0.5
              'text-anchor': 'middle'
              fill: o.fg or '#666',
                o.text

        return els

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

        b.deactivate = !->
          n = this.childNodes
          fill n.0, '#9e9e9e'
          fill n.2, '#9e9e9e'

        buttons_translate "translate(#{((width / 2) - buttons.length * 33) } 10)"
        return buttons



      svg_els.push panels.0 = s \g.percent-stats, transform: "translate(0 #{bottom_panel_y})", ->
        percent-stats_els = []
        each options, (o, i) !->
          v = null
          last_y += option_height
          # ...
          percent-stats_els.push [
            * icons[i] =\
              s \g.icon, transform: "translate(#{300 + icon_padding} #{last_y + 6})",
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
                width: (v_bar_width[i] = value 0)
                height: bar_height
                x: bar_x
                y: last_y + 10
                fill: (v_bar_fill[i] = value o.fg || fg)
                # stroke: bar_stroke
                # 'stroke-width': bar_stroke-width
                rx: bar_rounding
                ry: bar_rounding
            * s \text.bar-label,
                'text-anchor': 'middle'
                fill: (v_label_fill[i] = value if v => '#fff' else '#333')
                x: (v_label_x[i] = value bar_x)
                y: last_y + 25,
                  v_label[i] = value ''
            * s \text.total,
                'text-anchor': 'end'
                y: last_y
                x: width - 5,
                  (v_totals[i] = value '-')
          ]

          (v_icon[i] = value o.icon) (ico) !->
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
            px = v / max * bar_max_px
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

      svg_els.push panels.1 = s \g.sex-stats, transform: "translate(#{(width - 300) / 2 } #{bottom_panel_y})", ->
        const start_angle = 45
        const num_planets = 2
        const gauge-size = 110
        const half-gauge = gauge-size / 2
        const gauge-padding = (sex-stats-width - (gauge-size * 2)) / 4


        function gauge (options = {})
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
              s \use fill: fg, 'xlink:href': '#'+options.icon, transform: "translate(#{x - 15} #{y + gauge-size - 10}) scale(2)"#, opacity: '.3'


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
          * gauge angles: angles.0, count: counts.0, text: "Mujeres", fg: SEX_COLOR.0, bg: '#ddd', icon: \mars, x: gauge-padding
          * gauge angles: angles.1, count: counts.1, text: "Hombres", fg: SEX_COLOR.1, bg: '#ddd', icon: \venus, x: sex-stats-width - gauge-padding - gauge-size

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

      svg_els.push panels.2 = s \g.age-stats, transform: "translate(#{(width - 300) / 2 } #{bottom_panel_y})", ->
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
        # this has a problem with i being always ages.length - so we make a closure using `each`
        # for i til ages.length
        #   age = ages[i]
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
              (v_rval[i] = value 0)
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
        s \text null, "province stats"
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

vertele-encuesta = (el, config) ->
  # s \g.vertele-encuesta, (el) ->
  #   stats-module el, config
  h \div.vertele-encuesta, null, (el) ->
    h \div.encuesta-options, s: {width: 300}, #, (el) ->
      vote-module el, config
    h \div.encuesta-stats, s: {width: 300}, #, (el) ->
      stats-module el, config

doc.body.style.background = '#fff'
affinaty =
  vertele: vertele-encuesta
  poll-stats: stats-module




# TODO: allow for global configuration
for e in document.querySelectorAll('div[data-affinaty-encuesta]')
  affinaty.poll-stats e, e.dataset.affinaty-encuesta


# el = doc.get-element-by-id \plugin-body
# affinaty.poll-stats el, '575fb8a7db984f6500ce1cdd'

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
