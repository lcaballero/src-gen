[![Build Status](https://travis-ci.org/lcaballero/src-gen.svg?branch=master)](https://travis-ci.org/) [![NPM version](https://badge.fury.io/js/src-gen.svg)](http://badge.fury.io/js/src-gen)

# Introduction

`src-gen` is a library used to create code generation packages.
`src-gen` is heavily influenced by [gulp][gulp], and takes advantage
of [node-streams][node-streams].

Generally speaking, globs are submitted to `src-gen` functions that
target a set of files in a template directory.  Those files are then
processed, or copied, and output into a target directory.

In practice most files in a template are pass-through copies of files
in the source directory, but some files are also templated via
embedded JS as provided by [Lodash][Lodash] templating.  By default a
file with a .ftl extensions is processed as template and the resulting
output is placed in the target directory in a file of the same name
without the .ftl extension.  So a file source/package.json.ftl in the
source directory is process and output into target/package.json.

However, a source generation template isn't limited to embeded JS and
copies.  The full power of Node and NPM modules are also available.
The idea though is to leverage processing streams based on globs, and
process each file.

Here is some good reading material on Gulp streams: [gulpy][gulpy],
[gulp-vision][gulp-vision].

## Overview

The idea behind this `src-gen` is to help easily create new templates
for code generation tasks.  I've used the lib to create procs,
new-npms, static nginx sites, even pom.xml based maven java projects.

Additionally, there is a command line that executes `src-gen`
templates. Link forth-coming.


## Installation

```
%> npm install src-gen --save
```

## Usage

`src-gen` is geared around globs and pipes, just like [gulp][gulp].
So, given a directory structure like this:

``` 
new-npm
├── gitignore
├── index.js.ftl
├── license
├── package.json
├── readme.md
├── src
│   └── FirstClass.coffee.ftl
├── tests
│   ├── lib
│   │   └── globals.coffee
│   └── src
│       └── FirstTest.coffee.ftl
└── travis.yml
```
`Produced via: (M-1 M-! tree --noreport files/source/test1/new-npm)`

Then we can merge a number of processing commands.  The code below
shows how this might be done in coffee.  First the `rungen` function
is created which takes an options object with the source, target,
name, etc.  With `opts` `src-gen` is initialized.  It will use the
source directory as cwd while creating streams for processing files,
and then target as the dest() of the output streams.  These are
concepts from `gulp` in general, but really they are the interface to
[vinyl-fs][vinyl-fs]. 

```coffee
  rungen = (opts, done) ->
    # Alias of project name as derived from directory.
	# May need to sanitize name to make it a proper symbol.
	opts.symbol = opts.name.replace('-', '')
    { copy, gen, to, toJson, packageFile, run, file } = require('src-gen')(opts)
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
```

## License

See license file.

The use and distribution terms for this software are covered by the
[Eclipse Public License 1.0][EPL-1], which can be found in the file 'license' at the
root of this distribution. By using this software in any fashion, you are
agreeing to be bound by the terms of this license. You must not remove this
notice, or any other, from this software.


[EPL-1]: http://opensource.org/licenses/eclipse-1.0.txt
[gulp]: http://gulpjs.com/
[node-streams]: https://nodejs.org/api/stream.html
[vinyl-fs]: https://github.com/wearefractal/vinyl-fs
[Lodash]: https://lodash.com/docs#template
[gulpy]: https://medium.com/@webprolific/getting-gulpy-a2010c13d3d5
[gulp-vision]: https://medium.com/@contrahacks/gulp-3828e8126466
