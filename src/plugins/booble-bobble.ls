``import pluginBoilerplate from '../lib/plugins/plugin-boilerplate'``
# ``import pluginLoader from '../lib/plugins/plugin-loader'``
``import defaults from '../lib/lodash/defaultsDeep'``
``import each from '../lib/lodash/forEach'``
``import get from '../lib/lodash/get'``
``import shuffle from '../lib/lodash/shuffle'``
``import random from '../lib/lodash/random'``
``import isEqual from '../lib/lodash/isEqual'``
``import h from '../lib/dom/hyper-hermes'``
``import { s } from '../lib/dom/hyper-hermes'``
``import CL from '../lib/dom/class-list'``
``import ObservArray from '../lib/dom/observable-array'``
``import { value, attribute, transform, compute } from '../lib/dom/observable'``
``import floatingTip from '../lib/decorators/floating-tip'``
``import describeConeSection from '../lib/svg/describeConeSection'``
``import xhr from '../lib/xhr'``
``import animate from '../lib/velocity/velocity'``
``import '../lib/velocity/velocity.ui'``
# ``import $ from '../lib/velocity/jquery-shim'``

/*
TODO: initial steps
 - figure out a way to separate it into a few different .ls files
 - compile css into plugins/###.css
 - compile js into plugins/###.js using rollup (instead of gobble)
  - use an elixir process to run node in the background

TODO: game
 - add a menu
  - restart game
  - stats
  - adjust settings
 - when the difficulty is less than x, set the box color slightly different for the right answer
 - style the game up into purple color scheme
 - add physics to the boobles
  - allow for the player to drag the boobles around
  - give the appearance of them falling out of the sky and bouncing in. (scale --++**+-)
 - change the colors based on difficulty level
 - have a modifier which adjusts the rate of advancement of the difficulty level (difficulty ramp up)
 - difficulty increases the width of possible circles (eg. from very very small to large)
 - as the difficulty increases, increase the animation speed
*/

/*
TODO: code
 - make observable versions:
  - always call
  - only call when changed
  - call with value and previous value
 - import a lot of the code from the svg ui library and make them components (instead of using HTML elements)
 - component / code modification
  - import SVG-Edit to edit components
  - observable function text editor
   - implement an AST based graphical code editor (translates to js)
  - hash server for asset lookup
*/

# const doc = document
# const IS_LOCAL = ~doc.location.host.index-of 'localhost'

const DEFAULT_CONFIG =
  difficulty: 2
  difficulty_mult: 1
  min_area: 0.2
  max_area: 0.8
  # randomize: true

# TODO: extract all of this out to the plugin-loader.
#  - include hashes for the styles (and use xhr to download them)
#  - preprocess the styles on the "server"
#   - send all style hashes required to the server and merge styles using postcss
#  - {s, h} = plugin-loader { style: '...', svg_style: '...' }, onload = !->
# TODO: make this into 'poem'
#  - add nodejs to the app and run it as a server (custom compile crosswalk for each required platform to do so)
onload = ({G}) !->
  body = G.E.body
  # TODO: add a reset stylesheet
  # floating-tip style (needs to be extracted out to the element)
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

  # modal style (TODO: extract this out)
  body.append-child h \style '''
    .close-headerless {
      position: absolute;
      top: 0;
      right: 0;
      width: 40px;
      height: 40px;
      padding: 5px 0 0 5px;
      font-size: 20px;
    }
    .share-dialog .close-headerless,
    .foto .close-headerless {
      font-size: 20px;
      color: #fff;
      text-shadow: 2px 0 0 #f00, -2px 0 0 #f00, 0 2px 0 #f00, 0 -2px 0 #f00, 1px 1px #f00, -1px -1px 0 #f00, 1px -1px 0 #f00, -1px 1px 0 #f00;
    }
    .share-dialog .close-headerless {
      font-size: 14px;
      width: 24px;
      height: 24px;
      padding: 0;
    }

    .modal-background {
      position: fixed;
      top: 0; left: 0; width: 100%; height: 100%;
      background-color: rgba(0,0,0,0.5);
      /*padding: 0.5em;*/
      text-align: center;
      z-index: 100;
      box-sizing: border-box;
    }

    .modal-outer {
      position: relative;
      width: 100%;
      height: 100%;
      z-index: 100;
    }

    .modal-close {
      display: inline-block;
      background: #fd270d;
      color: #ffffff;
      /* font-size: 15px; */
      font-weight: 100;
      cursor: pointer;
      position: absolute;
      right: 5%;
      top: 5%;
    }

    .modal {
      position: relative;
      background-color: white;
      box-shadow: 0 0 5px rgba(0,0,0,0.8);
      margin: 0 auto;
      display: inline-block;
      max-width: 96%;
      max-height: 100%;
      overflow-y: auto;
      box-sizing: border-box;
      border-radius: 8px;
      /* border: solid 1px #9a9a9a; */
      text-align: left;
    }

    .modal-button {
      text-align: center;
      background-color: rgb(70,70,180);
      color: white;
      padding: 0.5em 1em;
      display: inline-block;
      cursor: pointer;
    }

    .modal-footer {
      position: fixed;
      bottom: 26px;
      color: #fff;
      text-align: center;
      width: 100%;
    }

    .modal h1 {
      margin: 0;
      color: #fff;
      border-bottom: 1px solid #fe8172;
      text-align: center;
      background-color: #FF3300;
      font-size: 15px;
      text-overflow: ellipsis;
      overflow-y: hidden;
      white-space: nowrap;
      min-height: 20px;
    }
    '''

  body.append-child s \style '''
    text {
      text-anchor: middle;
      font-size: 22px;
      /* this only works in chrome */
      /* alignment-baseline: central; */
      dominant-baseline: central;
    }
    text.score {
      fill: #333;
    }
    g.option text {
      font-size: 60px;
    }
    g.option {
      cursor: pointer;
    }
    #button-menu line {
      fill: #9e9e9e;
    }
    '''
# /onload


svg-modal = (G, opts, fn) ->
  # TODO: add fade-in and fade-out for the background
  opts = opts || {}
  h = G.h.context!
  E = G.E
  ctx = h: h, s: ->
    console.log \here!
    (ctx.s = G.s.context!).apply this, &

  # TODO: utilize the css resizer... this is shit
  resize = !->
    if inner
      inner.style.top = ((outer.client-height - inner.client-height) / 2) + 'px'

  close = !->
    h.cleanup!
    if cleanup = ctx.s.cleanup => cleanup!
    window.remove-event-listener \resize, resize
    animate modal-background, {opacity: 0}, opts.fade-out || 133ms
      .then !-> modal-background.parent-node.remove-child modal-background

  click = (e) !->
    target = e.target
    if target is modal-background
      or target is outer
      or close-button.contains target
        e.stop-immediate-propagation!
        close!
    # else console.log "not close"


  close_inner = opts.close-button || '✖'

  modal-background =\
  h \div.modal-background, s: {opacity: 0},
    outer =\
    h \div.modal-outer, c: opts.name, capture: touchstart: click,
      inner =\
      h \div.modal,
        # header
        if opts.header is false
          close-button =\
          h \div.close-headerless.close,# on: touchstart: click,
            close_inner
        else
          h \h1 null,
            opts.header
            close-button =\
            h \div.modal-close.close,# on: touchstart: click,
              close_inner

        # inner
        if typeof fn is \function
          fn ctx
        else if typeof opts.inner is \function
          opts.inner ctx
        else opts.inner

        # footer
        if typeof opts.footer is \function
          opts.footer ctx
        else opts.footer

  # TODO: use the css-resize
  E.window.add-event-listener \resize, resize, false

  set-timeout !->
    (opts.parent || E.body).append-child modal-background
    animate modal-background, {opacity: [1, 0]}, opts.fade-in || 133ms
    resize!
  , 100

  {resize, close}


booble-bobble = ({config, G, set_config, set_data}) !->
  E = G.E
  onload {G}


  # TODO:
  #  - add events
  #  - add stream channels
  #  - add elements
  #  - add text formatting functions (for translations n stuff)

  G.area = compute [G.width, G.height], (w, h) -> w * h

  G.difficulty (n) !->
    if n <= 1
      G.difficulty 2

  G.min_boobles = compute [G.difficulty, G.difficulty_mult], (difficulty, mult) ->
    Math.round difficulty * 2 * mult
  G.max_boobles = compute [G.difficulty, G.difficulty_mult, G.min_boobles], (difficulty, mult, min) ->
    Math.max min+1, Math.round difficulty * 3 * mult
  G.num_options = compute [G.difficulty, G.min_boobles, G.max_boobles], (difficulty, min_boobles, max_boobles) ->
    num_options = if difficulty > 10 => 8
    else 6
    if (max = max_boobles - min_boobles) < num_options
      num_options = max
    num_options
  G.retries = value 3
  G.bonus_retries = compute [G.difficulty, G.difficulty_mult], (difficulty, mult) ->
    Math.round difficulty / 5 * mult
  G.min_r = compute [G.min_boobles, G.max_boobles, G.min_area, G.area], (min, max, min_area, area) ->
    n = ((min + max) / 2)
    v1 = Math.sqrt (area * min_area) / (n * n)
    # v2 = Math.round _width / 240
    # console.log \min_r, n, v1, v2
    # v2
    Math.round v1
  G.max_r = compute [G.min_boobles, G.max_boobles, G.min_area, G.area], (min, max, max_area, area) ->
    n = ((min + max) / 2)
    v1 = Math.sqrt (area * max_area) / (n * n)
    # v2 = Math.round _width / 240
    # console.log \max_r, n, v1, v2
    v2 = v2 * 3
    # v2
    Math.round v1

  set_boobles = value!
  set_superlative = value!
  set_score = value ''
  score_delta = value!
  num_wins = value 0
  num_loss = value 0



  retry = (el) !->
    el.style.display = \none
    # unfortunately, this will change the option count, so we should save the difficulty into another place first
    # G.difficulty G.difficulty! - (G.difficulty_mult! * 0.5)
    set_superlative text: "try again...", p: fill: '#c22'
    G.retries G.retries! - 1

  # set-interval ->
  #   set_superlative {
  #     zone: \score.retries
  #     text: "+3"
  #     scale: 1
  #     d: 2000
  #     a:
  #       scale: 2
  #       # translate-y: -10
  #     p:
  #       fill: '#33f'
  #       'font-size': 5
  #   }
  # , 2000

  again = (mode) !->
    now = Date.now!
    delta = now - score_delta!
    switch mode
    | \win =>
      set_superlative text: "yay!", p: fill: '#00f'
      num_wins num_wins! + 1
      G.difficulty G.difficulty! + (G.difficulty_mult! * 0.5)
      retry_bonus = G.bonus_retries!
      if retry_bonus > 0
        console.log "bonus:", retry_bonus
        set_superlative zone: \score.retries, text: (if retry_bonus >= 0 => '+' else '-') + retry_bonus, p: fill: '#33f', 'font-size': 11
      G.retries G.retries! + retry_bonus
      set_score 20000 / delta

    | \lose =>
      set_superlative text: "nope...", p: fill: '#f00'
      num_loss num_loss! + 1
      G.difficulty G.difficulty! - (G.difficulty_mult!)

    | \start =>
      set_superlative text: "get started!!!"
      set_score 0
      # "get started" w/ fade or perhaps some quick instructions
    # last_score = score_delta!
    set_boobles (random G.min_boobles!, G.max_boobles!)
    score_delta Date.now!

  G.E.frame.append-child E.svg =\
    s \svg, width: G.width, height: G.height, ->
      boobles = []
      is_over_boobles = (x, y, r) !->
        for b in boobles
          # (x2-x1)^2 + (y1-y2)^2 <= (r1+r2)^2
          if (Math.pow b.x - x , 2) + (Math.pow y - b.y, 2) <= (Math.pow r + b.r, 2)
            return true
        return false

      scoreboard_width = value 200
      scoreboard_height = value 60
      scoreboard_x = compute [G.width, scoreboard_width], (width, sb_width) -> width - sb_width - 5
      scoreboard_y = value 5
      scoreboard_title_x = transform scoreboard_x, (v) -> v + 20
      scoreboard_score_x = transform scoreboard_x, (v) -> v + 40
      option_width = transform scoreboard_width, (v) -> v - 10
      option_height = compute [G.height, scoreboard_height, G.num_options] (h, sb_h, num_options) ->
        Math.round (h - sb_h - 20) / num_options

      # option_text_x = compute [scoreboard_x, option_width], (x, w) -> x + (w / 2)
      # option_text_x = 0 # compute [scoreboard_x, option_width], (x, w) -> (w / 2)
      option_text_x = transform scoreboard_width, (w) -> w / 2
      score = compute [num_wins, num_loss], (w, l) ->
        (w * 100) + (l * -50)

      button_rounding = value 11
      options_transform = compute [scoreboard_x, option_width, scoreboard_height], (x, w, y) -> "translate(#{x + (w / 2)} #{y + 10})"
      score_transform = compute [scoreboard_x, scoreboard_y], (x, y) -> "translate(#{x} #{y})"

      return
        * s \defs,
            s 'filter#icon-filter', x: -1, y: -1, width: '300%', height: '300%',
              s \feOffset, result: \offOut, in: \SourceGraphic, dx: 0, dy: 2
              s \feGaussianBlur, result: \blurOut, in: \offOut, stdDeviation: 3
              s \feBlend, in: \SourceGraphic in2: \blurOut, mode: \normal

        * s \g.boobles, !->
            els = new ObservArray
            set_boobles (n) !->
              console.log \n, n
              max_x = G.width! - scoreboard_width!
              max_y = G.height!
              min_r = G.min_r!
              max_r = G.max_r!
              boobles.length = 0
              els.empty!
              for i til n
                do
                  r = random min_r, max_r, true
                  x = random r, (max_x - r), true
                  y = random r, (max_y - r), true
                while is_over_boobles x, y, r
                boobles.push {x, y, r}
                els.push el =\
                  s \circle cx: x, cy: y, r: min_r * 0.5, fill: \red, 'stroke-width': 3, stroke: '#000'
                animate el, {r}, {duration: 200ms}
            return els

        * s \g.score, transform: score_transform, !->
            difficulty_text = transform G.difficulty, (v) -> "difficulty: #{v}"
            retries_text = transform G.retries, (v) -> "retries: #{v}"
            score_text = transform set_score, (v) -> Math.round v
            E.score = _e =
              score:
                s \text.score x: option_text_x, y: 50, fill: '#333', 'stroke-width': 2, score_text
              retries:
                s \text.score-retries x: option_text_x, y: 10, fill: '#333', retries_text
              difficulty:
                s \text.score-difficulty x: option_text_x, y: 30, fill: '#333', difficulty_text

            set-interval !->
              # console.log "TODO: score adjust"
              # lose x points each second
              # if less points than 0, game over
              # set_score
            , 1000ms

            return
              * s \rect.score-frame x: 0, y: 0, width: option_width, height: scoreboard_height, fill: '#fff', 'stroke-width': 1, stroke: '#ccc', rx: button_rounding, ry: button_rounding
              # * s \text.score-title x: option_text_x, y: 30, fill: '#333', "wins / losses"
              * _e.difficulty
              * _e.retries
              * _e.score

        * s \g.menu, ->
            fill = (el, val) !-> el.set-attribute \fill, val
            btn_outline = -> s \path fill: '#9e9e9e' d: "m 109.60458,88.33043 c 0.35027,13.64453 -11.913926,25.89283 -25.554996,25.543 -19.95894,-0.0485 -39.92267,0.0978 -59.87857,-0.0744 -13.28532,-0.68659 -24.3242598,-13.1839 -23.5664298,-26.41881 0.0485,-19.64193 -0.0978,-39.28866 0.0744,-58.92754 C 1.3668042,15.17242 13.849574,4.1180363 27.085784,4.8734593 c 19.64225,0.04856 39.28929,-0.09785 58.92849,0.07451 13.41306,0.690775 24.484036,13.3929807 23.590266,26.7364807 0,18.882 0,37.76401 0,56.64601 z"
            btn = -> s \path fill: '#fff' stroke: '#dcdcdc' 'stroke-width': 1.11 'stroke-miterlimit': 10 d: "m 109.60458,84.03343 c 0.3474,13.646 -11.905866,25.91561 -25.554996,25.57 -19.95894,-0.0487 -39.92269,0.098 -59.87857,-0.0746 -13.42095,-0.6931 -24.4608098,-13.42279 -23.5664298,-26.76239 0.0485,-19.53632 -0.0977,-39.07743 0.0744,-58.6107 0.68687,-13.27967 13.1750898,-24.32167667 26.4067998,-23.56531067 19.64225,0.04851 39.28928,-0.09774 58.92849,0.07443 C 99.423754,1.3519923 110.49977,14.04536 109.60454,27.38742 c 0,18.882 0,37.76401 0,56.64601 z"
            mouseenter = !-> fill this.childNodes.1, '#eee'
            mouseleave = !-> fill this.childNodes.1, '#fff'
            click = (e) !->
              # console.log \click, e
              e.prevent-default!
              opts =
                header: header_text = value 'header text'
              svg-modal G, opts, ({s, h}) ->
                h \div.menu,
                  h \div.menu-inner, null,
                    h \button, "button 1", capture: touchstart: -> console.log \button1
                    h \button, "button 2", on: touchstart: -> console.log \button2
                    h \button, "button 3", on: touchstart: -> console.log \button3
              console.log \modal.menu
              set-timeout ->
                header_text 'lala'
              , 2000

            s \g.button, id: \button-menu, transform: "translate(5 5) scale(.3)", filter: 'url(#icon-filter)', on: {mouseenter, mouseleave, touchstart: click },
              btn_outline, btn
              s \line.lala x1: -5, x2: 5, y1: 0, y2: 0
              # s \path fill: '#9e9e9e' d: "m 29.75655,23.86555 c 0,-0.849 -0.414,-1.641 -1.117,-2.107 -0.707,-0.472 -1.604,-0.566 -2.377,-0.246 l -10.715,4.381 c -1.412,0.582 -2.35,1.965 -2.35,3.501 l 0,47.625 c 0,2.083 1.697,3.776 3.775,3.776 l 9.014,0 c 2.084,0 3.77,-1.693 3.77,-3.776 l 0,-53.154 z"
              # s \path fill: '#9e9e9e' d: "m 53.14655,57.15555 c 0,-0.283 -0.418,-0.549 -1.119,-0.703 -0.713,-0.162 -1.604,-0.191 -2.381,-0.086 l -10.715,1.47 c -1.42,0.194 -2.346,0.655 -2.346,1.174 l 0,20.521 c 0,0.696 1.699,1.266 3.771,1.266 l 9.012,0 c 2.076,0 3.777,-0.569 3.777,-1.266 l 0,-22.376 10e-4,0 z"
              # s \path fill: '#9e9e9e' d: "m 76.62555,57.15555 c 0,-0.283 -0.42,-0.549 -1.119,-0.703 -0.713,-0.162 -1.604,-0.191 -2.381,-0.086 l -10.715,1.47 c -1.42,0.194 -2.346,0.655 -2.346,1.174 l 0,20.521 c 0,0.696 1.697,1.266 3.771,1.266 l 9.01,0 c 2.078,0 3.779,-0.569 3.779,-1.266 l 0,-22.376 0.001,0 z"
              # s \path fill: '#9e9e9e' d: "m 99.92055,45.33655 c 0,-0.427 -0.422,-0.822 -1.135,-1.056 -0.699,-0.239 -1.59,-0.286 -2.363,-0.124 l -10.717,2.199 c -1.426,0.291 -2.346,0.988 -2.346,1.758 l 0,30.784 c 0,1.048 1.686,1.897 3.779,1.897 l 8.998,0 c 2.088,0 3.783,-0.85 3.783,-1.897 l 0,-33.561 0.001,0 z"


        * s \g.options, transform: options_transform, (el) !->
            els = new ObservArray
            set_boobles (n) !->
              const min_boobles = G.min_boobles!
              const max_boobles = G.max_boobles!
              const num_options = G.num_options!
                # console.log "whoops", max_boobles, min_boobles
              # console.log "options:", num_options

              # const OPTION_HEIGHT = Math.round (G.height! - scoreboard_height! - 20) / num_options
              const OPTION_HEIGHT = option_height!

              options = [n]
              options.scale = new Array n
              for i til num_options - 1
                do
                  nb = random G.min_boobles!, G.max_boobles!
                while ~options.index-of nb
                options.push nb

              if config.randomize => shuffle options
              else options.sort (a, b) -> if a > b => 1 else -1

              els.empty!
              option_x = transform option_width, (w) -> -w / 2
              option_y = transform option_height, (h) -> -h / 2
              # option_y = transform scoreboard_width, (w) -> -w / 2
              # TODO: calc how many options can fit (and adjust size)
              # for num in options
              each options, (num, i) !->
                color = 204 # #ccc
                if num is n
                  color += 3
                fill = "rgb(#{color},#{color},#{color})"
                click = !->
                  nb = set_boobles!
                  if G.retries! < 1
                    again (if num is nb => \win else \lose )
                  else if nb is num
                    again \win
                  else
                    retry this
                options.scale[i] = option_scale = value 0
                option_transform = compute [option_height, option_scale], (h, s) ->
                  "translate(0 #{(i * h) + (h / 2)}) scale(#{s})"
                els.push el =\
                  s \g.option, on: {touchstart: click}, transform: option_transform,
                    rect =\
                    s \rect x: option_x, y: option_y, width: option_width, height: OPTION_HEIGHT - 2, fill: fill, rx: button_rounding, ry: button_rounding
                    s \text x: 0, y: 0, num

                animate null, { tween: [1, 0] }, {
                  # easing: \spring
                  # loop: true
                  duration: 300ms
                  progress: (elements, c, r, s, t) !->
                    # console.log t
                    option_scale t
                }
                # clear-interval els.loop
                # els.loop = set-interval !->
                #   # option_scale 1 / Math.sin option_scale!
                #   console.log \interval
                #   t = 0.5
                #   # for i til options.length =>
                #   each options, (option, i) !->
                #     $e = els[i]
                #     window.Velocity.RunSequence [
                #       * e: $e, p: {scale: 0.8}, o: {duration: t * 100}
                #       * e: $e, p: {scale: 0.9}, o: {duration: t * 10}
                #       * e: $e, p: {scale: 0.95}, o: {duration: t * 10}
                #       * e: $e, p: {scale: 0.9}, o: {duration: t * 10}
                #       * e: $e, p: {scale: 0.8}, o: {duration: t * 10}
                #       * e: $e, p: {scale: 0.3}, o: {duration: t * 10}
                #       * e: $e, p: {scale: 0.5}, o: {duration: t * 10}
                #       * e: $e, p: {scale: 0.8}, o: {duration: t * 10}
                #       * e: $e, p: {scale: 1}, o: {duration: t * 10}
                #     ]
                #
                #     # animate null, { tween: [1, 0.2, 0.3, 0.5, 1] }, {
                #     #   # easing: \spring
                #     #   duration: 200ms
                #     #   # delay: 2000 / options.length
                #     #   progress: (elements, c, r, s, t) !->
                #     #     # console.log "The current tween value is " + t
                #     #     # options.scale[i] t / Math.sin option_scale!
                #     #     options.scale[i] t
                #     # }
                #
                # , 2000
            return els

        * s \g.superlative (els) !->
            set_superlative (t) !->
              scale = t.scale or 0.5
              duration = t.d or 1000
              if t.zone
                if e = get E, t.zone
                  rect = e.get-bounding-client-rect!
                  # x = +e.get-attribute \x
                  # y = +e.get-attribute \y
                  x = rect.left + (rect.width / 2)
                  y = rect.top + (rect.height / 2)
                  # y = +e.get-attribute \y
                  # x -= e.client-width / 2
                  # y -= e.client-height / 2
                  console.log x, y, rect, t.text
                  # debugger
                  animate e, {'stroke-width': 0, stroke: '#f00'}, 0
                  animate e, {fill: '#c33', 'stroke-width': 2}, {loop: 1, duration: 333ms}

              if x is void
                x = G.width! / 2
                y = G.height! / 2

              opts = defaults {
                transform: "translate(#{x} #{y}) scale(#{scale})"
              }, t.p

              els.append-child el =\
                s \text, opts, t.text

              animate el, {
                translate-x: [x, x]
                translate-y: [y, y]
                scale: [scale, scale]
                opacity: [1, 1]
              }, 0

              opts = defaults t.a, {
                scale: 5
                opacity: 0
              }

              animate el, opts, duration
                .then !-> els.remove-child el
      #</svg>

  # run all animations 5x slower
  # animate.mock = 5
  # start it off...
  again \start

plugin-boilerplate null, \horray-for-boobles, {}, {}, DEFAULT_CONFIG, booble-bobble
