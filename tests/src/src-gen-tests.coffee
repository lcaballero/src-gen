sgen    = require("../../src/src-gen")
fs      = require('fs')
path    = require('path')


describe 'sgen tests =>', ->

  contains = (root, file, content) ->
    f = path.resolve(root, file)
    c = fs.readFileSync(f, { encoding: 'utf8' }).toString()
    re = new RegExp(content)
    expect(re.test(c)).to.be.true

  filesExist = (root) -> (dirs...) ->
    for dir in dirs
      file = path.resolve(root, dir)
      expect(fs.existsSync(file), 'should have created file: ' + file).to.be.true

  describe 'constructor =>', ->

    gen = null
    opts =
      source      : 'files/source/test1/new-npm'
      target      : 'files/target/test1/new-npm'
      name        : 'src-gen-test'
      $isTesting  : true

    beforeEach ->
      gen = (opts, done) ->
        # Alias of project name as derived from directory.
        # May need to sanitize name to make it a proper symbol.
        opts.symbol = opts.name.replace('-', '')

        { copy, gen, to, toJson, packageFile, run, file } = sgen(opts)

        gen(
          copy('**/*.coffee', 'license', 'readme.md', 'travis.yml')
          file('package.json', toJson(packageFile(opts)))
          to('gitignore', '.gitignore')
          to('src/FirstClass.coffee.ftl', "#{opts.name}.coffee")
          to('tests/src/FirstTest.coffee.ftl', "#{opts.name}-tests.coffee")
          to('index.js.ftl', 'index.js')
        )
        .on('end', (err) ->
          if !err? and !opts.$isTesting
            run(
              'npm install coffee-script lodash nject moment --save'
              'npm install mocha chai gulp --save-dev'
              'git init'
              "chmod +x #{opts.entryPoint}"
              'npm test'
            )(done)
          else
            done()
        )

    beforeEach (done) ->
      gen(opts, done)

    afterEach (done) ->
      sgen({target:'files/'}).run("rm -rf target/test1/")(done)

    it "should have created the target project", ->
      filesExist(opts.target)(
        '.gitignore'
        "src/#{opts.name}.coffee"
        "tests/src/#{opts.name}-tests.coffee"
        "tests/lib/globals.coffee"
        "index.js"
        "license"
        "package.json"
        "readme.md"
        "travis.yml"
      )

    it.skip 'should have interpolated the project name into package.json', ->
    it.skip 'should have produced the .git folder after running git init', ->
    it.skip 'should package.json prod dependencies: coffee-script lodash nject and moment', ->
    it.skip 'should have package.json dev dependencies: mocha chai and gulp', ->
    it.skip 'the entry point should have been made executable', ->
    it.skip 'all tests on the newly minted project should have passed', ->
