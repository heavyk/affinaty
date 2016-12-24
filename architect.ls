require! path: \Path
require! fs: \Fs

src_dir = Path.join __dirname, \src
tmp_dir = Path.join __dirname, \priv \build
out_dir = Path.join __dirname, \priv \static

poems =
  'plugins/booble-bobble.js':
    dest: 'plugins/booble-bobble.js'
    webpack:
      stuff: true
  'plugins/zibble-zabble.js':
    dest: 'plugins/zibble-zabble.js'
  'plugins/mastering-the-zodiac.js':
    dest: 'plugins/mastering-the-zodiac.js'
  'plugins/juego-x.js':
    dest: 'plugins/juego-x.js'
  'plugins/vertele.js':
    dest: 'plugins/vertele.js'
  'plugins/vertele-portada.js':
    dest: 'plugins/vertele-portada.js'
  'plugins/test-jsx.js':
    dest: 'plugins/test-jsx.js'
  'plugins/affinaties.js':
    dest: 'plugins/affinaties.js'
  'plugins/meatr.js':
    dest: 'plugins/meatr.js'




# ===========
# ===========

require! \sander
require! \rollup
require! \rollup-plugin-buble
require! \chokidar
require! \webpack
EE = require \events .EventEmitter


sander.rimraf-sync tmp_dir
sander.mkdir-sync tmp_dir

sander.rimraf-sync out_dir
sander.mkdir-sync out_dir

emitter = new EE

# set-interval !->
#   test-file = Path.join src_dir, \testing-file.js
#   Fs.stat test-file, (err, st) !->
#     if err
#       if Math.random! > 0.5
#         Fs.write-file test-file, 'test!', -> # console.log \added
#       else
#         # console.log \mkdir1
#         Fs.mkdir test-file, ->
#           # console.log \mkdir2
#           Fs.mkdir test-file + '/lala', ->
#             # console.log \write-file
#             Fs.write-file test-file + '/lala/lala.txt', 'test!', -> # console.log \added
#     else
#       sander.rimraf test-file
# , 2000ms

# class Architect extends EE


get-opts = (opts) ->
  outfile = file = Path.basename opts.path
  opts.lang = switch ext = Path.extname file
  | \.ls \.alive => \alive-script
  | \.coffee => \coffee-script
  | \.js \.jsx => \js
  | \.json => \json

  unless opts.outfile
    if ~(idx_ext = file.lastIndexOf '.')
      ext = if opts.ext then opts.ext else file.substr idx_ext
      outfile = file.substr 0, idx_ext
      if ~(idx_ext2 = file.substr(0, idx_ext).lastIndexOf '.')
        ext = if opts.ext then opts.ext else file.substr idx_ext2
        outfile = file.substr 0, idx_ext2
      switch ext
      | '.blueprint.ls' =>
        opts.blueprint = true
        opts.result = true
        ext = \.blueprint
        #fallthrough
      | '.json.ls' =>
        opts.result = true
        opts.json = true
        ext = \.json
      | otherwise =>
        ext = ext.replace /(?:(\.\w+)?\.\w+)?$/, (r, ex) ->
          if ex is \.json then opts.json = true
          return ex or if opts.json then \.json else \.js

      if ext isnt \.js and opts.result isnt false
        opts.result = true
      outfile = outfile + ext
    else if opts.ext
      outfile = file + opts.ext
    else
      throw new Error "source file does not have an extension"

    opts.ext = ext
    # opts.outfile = outfile
    opts.outfile = (opts.path.substr 0, opts.path.length - file.length) + outfile

  unless opts.ext
    opts.ext = ext
  return opts

path_lookup = {}

process_src = (path) !->
  origin = Path.join src_dir, path
  file = Path.basename path
  if file is \.DS_Store
    # console.log 'deleting', path
    return sander.rimraf origin
  opts = get-opts {path}
  # console.log \src.opts, opts
  path_lookup[path] = opts.outfile
  dest = Path.join tmp_dir, opts.outfile
  txt = Fs.readFileSync origin, \utf-8
  switch opts.lang
  | \alive-script =>
    try
      LiveScript = require \livescript
      res = LiveScript.compile txt, {
        bare: true
        header: false
        filename: Path.basename path
        outputFilename: Path.basename opts.outfile
        map: if opts.json => \none else \linked-src # \embedded
        json: opts.json
      }

      output = if opts.json => res else res.code
    catch e
      console.error e

  | \js =>
    # for now, no transformations are done...
    output = txt

  | \coffee-script =>
    throw new Error "coffee-script not yet implemented"

  | otherwise =>
    console.log "#{opts.lang} not yet implemented"
    output = txt

  # if opts.result
	# 	opts.ast.makeReturn!
  #
	# opts.output = opts.ast.compileRoot options
	# if opts.result
	# 	process.chdir Path.dirname opts.path
	# 	opts.output = LiveScript.run opts.output, options, true
	# 	process.chdir CWD

  if output
    # console.log "writing:", dest
    Fs.writeFile dest, output, \utf-8, (err) !->
      if err => throw err
      # else console.log 'written...', output.length, dest


src_watcher = chokidar.watch src_dir, {
  # ignore-initial: true
  # ignored: /[\/\\]\./
  cwd: src_dir
  # always-stat: true
}

src_watcher.on \change, (path) !->
  console.log \src.change, path
  process_src path
  # readFile
  # if length or sha1 contents are different, process it
  # sander.copyFile

src_watcher.on \add, (path) !->
  console.log \src.add, path
  process_src path

src_watcher.on \unlink, (path) !->
  console.log \src.unlink, path
  if out_path = path_lookup[path]
    dest = Path.join tmp_dir, out_path
    console.log \src.unlinking, dest
    Fs.unlink dest, ->

src_watcher.on \addDir, (path) !->
  console.log \src.addDir, path
  # src_watcher.add path
  dest = Path.join tmp_dir, path
  Fs.mkdir dest, (err) !->
    if err and err.code isnt \EEXIST
      throw err

src_watcher.on \unlinkDir, (path) !->
  console.log \src.unlinkDir, path
  dest = Path.join tmp_dir, path
  Fs.rmdir dest, ->

src_watcher.on \ready !->
  console.log \src-ready

  # =======================
  # =======================

  out_watcher = chokidar.watch out_dir, {
    ignore-initial: true
    # ignored: /[\/\\]\./
    cwd: out_dir
    # always-stat: true
  }

  out_watcher.on \change, (path) !->
    console.log \out.change, path

  out_watcher.on \add, (path) !->
    console.log \out.add, path

  out_watcher.on \unlink, (path) !->
    console.log \out.unlink, path

  out_watcher.on \addDir, (path) !->
    console.log \out.addDir, path

  out_watcher.on \unlinkDir, (path) !->
    console.log \out.unlinkDir, path


  tmp_watcher = chokidar.watch tmp_dir, {
    # ignore-initial: true
    # ignored: /[\/\\]\./
    cwd: tmp_dir
    # always-stat: true
  }

  rollup_cache = {}
  rollup_opts =
    format: \umd
    plugins: [ rollup-plugin-buble jsx: \h ]
    source-map: true
    module-context: {}

  # resolve stupid rollup wanring with lodash: invalid use of 'this' at the root level
  rollup_opts.module-context[Path.join tmp_dir, 'lib/lodash/_root.js'] = 'window'



  process_poem = (path) !->
    if not (poem = poems[path]) or poem.processing
      return # console.log "could not process #{path}"
    poem.processing = true
    console.log \process_poem, path
    src = Path.join tmp_dir, path
    dest = Path.join out_dir, poem.dest
    cache = rollup_cache[path]
    opts = {} <<< rollup_opts <<< {
      entry: src
      cache: cache
      dest: dest
    }

    rollup.rollup opts
      .then (bundle) ->
        rollup_cache[path] = bundle
        console.log \poem, dest
        console.log \mods, bundle.modules.length
        # for m in bundle.modules
        #   console.log m.id

        output = bundle.generate opts
        map = output.map
        code = output.code + "\n//# sourceMappingURL=#{Path.basename dest}.map\n"
        # code = output.code + "\n//# sourceMappingURL=#{map.toUrl!}\n"

        Promise.all [
          sander.write-file dest, code
          sander.write-file "#{dest}.map", map.to-string!
        ]
        # Fs.mkdir (Path.dirname dest), (err) !->
        #   if err and err.code isnt \EEXIST
        #     throw err
        #   Fs.write-file-sync "#{dest}.map", map.to-string!
        #   Fs.write-file-sync dest, code
      .catch (e) ->
        # console.log \catch, e.message.substr 0, 1000
        console.log \catch, e.stack
        poem.processing = false
      .then !->
        console.log "bundle written:", dest#, &
        console.log " - TODO emit event"
        poem.processing = false

  tmp_watcher.on \change, (path) !->
    # console.log \tmp.change, path
    process_poem path

  tmp_watcher.on \add, (path) !->
    # console.log \tmp.add, path
    process_poem path

  tmp_watcher.on \unlink, (path) !->
    console.log \tmp.unlink, path

  tmp_watcher.on \addDir, (path) !->
    console.log \tmp.addDir, path

  tmp_watcher.on \unlinkDir, (path) !->
    console.log \tmp.unlinkDir, path
