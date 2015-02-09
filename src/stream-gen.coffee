gulp        = require 'gulp'
mv          = require 'gulp-rename'
template    = require 'gulp-template'
_           = require 'lodash'
{ spawn }   = require 'child_process'
merge       = require 'merge2'
insertFile  = require 'gulp-file'


module.exports = (opts) ->

  opts = _.defaults({}, { $isTesting: true }, opts)

  ###
    rename(), once configured with input parameters that provide
    the source directory and any model data creates a function
    that will creates a stream using the single input file and
    outputs that file with a new name given by the second parameter.

    @a {String} - Starting file name.
    @b {String} - New name of file.
  ###
  rename = (opts, source) -> (a, b) ->

    newName = (p) ->
      p.basename = b
      p.extname = if p.extname is '.ftl' then '' else p.extname

    gulp.src(a, source())
      .pipe(template(opts))
      .pipe(mv(newName))

  ###
    Configures a function that uses the target as the current working
    directory.  Configuration can also include setting up stdio as
    per the spawn Node documentation.

    The resulting function can take a variable number of arguments
    that are commands to run via the shell.  For instance:

    %> npm install chai mocha --save-dev
    %> git init

    Where each of the commands can be passed as a string to the
    resulting function.
  ###
  execs = (opts) ->

    opts       ?= {}
    opts.cwd   ?= opts.target or process.cwd()
    opts.stdio ?= [ process.stdin, process.stdout, process.stderr ]

    (commands...) ->

      handleClose = (next) -> (code, signal) ->
        if code isnt 0
          next(new Error("code: #{code}, signal: #{signal}"))
        else if next? and code is 0
          next(null, code)

      handleProc = (e, cb) ->
        args = e.split(' ')
        name = args.shift()
        proc = spawn(name, args, opts)
        proc.on('exit', handleClose(cb))

      (_done) ->
        async.mapSeries(commands, handleProc, (err, res) ->
          if err? then _done(err, null)
          else _done(null, res)
        )

  ###
    Generates a minimal object that represents a package.json file.
  ###
  packageFile = (inputs) ->
    name        : inputs.name
    version     : inputs.version
    description : inputs.description
    author      : inputs.author
    main        : inputs.entryPoint
    keywords    : do ->
      keywords = _.compact((inputs.keywords or "").split(" "))
      if keywords.length > 0
        keywords
      else
        []
    license     : inputs.license or "Eclipse Public License (EPL)"
    repository  : inputs.repo
    scripts     :
      test: inputs.testCommand or ""

  ###
    Generates a typical configuration object to be passed to
    a stream where the source directory is considered the base
    current working directory.
  ###
  source = -> cwd: opts.source, cwdbase: true

  ###
    Creates a destination stream sink based on the target directory
    provided as part of the options.
  ###
  target = -> gulp.dest opts.target
  toJson = (a) -> JSON.stringify(a, null, '  ')
  to     = rename(opts, source)
  run    =
    if opts.$isTesting
      (cmds) -> (done) -> done()
    else
      execs(opts)
  copy   = (src...) ->
    for m in src
      gulp.src(m, source())

  ###
    Creates a stream that outputs a single a file.  Typically, the
    resulting stream is merged with other streams of this kind.
  ###
  file = (a, b) -> insertFile(a, b, { src: true })

  ###
    Merges the given streams where the streams will all be ended.
    'error' events and 'close' events will be logged.
  ###
  gen = (streams...) ->
    streams.push({ end: true })
    merge(streams...)
      .pipe(target())
      .on('error', (err, res) -> console.log('error', err, res))
      .on('close', (err, res) -> console.log('close', err, res))

  {
    file, gen, copy, source,
    target, toJson, to, packageFile,
    execs, run
  }
