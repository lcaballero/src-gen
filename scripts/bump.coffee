#!/usr/bin/env coffee

path  = require 'path'
fs    = require 'fs'
yargs = require 'yargs'


module.exports = do ->
  pkg = require path.resolve 'package.json'
  [major, minor, patch] = (pkg.version.split '.').map parseFloat

  {part} = yargs.argv

  version = switch part
    when 'major'
      "#{major+1}.0.0"
    when 'minor'
      "#{major}.#{minor+1}.0"
    else
      "#{major}.#{minor}.#{patch+1}"

  pkg.version = version
  fs.writeFileSync(path.resolve('package.json'), JSON.stringify pkg, null, 3)
  console.log "--- bumping to #{version} ---"