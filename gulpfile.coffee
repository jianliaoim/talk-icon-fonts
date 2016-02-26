del = require 'del'
run = require 'run-sequence'
gulp = require 'gulp'
gutil = require 'gulp-util'
which = require('npm-which')(__dirname)
rename = require 'gulp-rename'
sketch = require 'gulp-sketch'
cssnano = require 'gulp-cssnano'
htmlmin = require 'gulp-htmlmin'
iconfont = require 'gulp-iconfont'
imagemin = require 'gulp-imagemin'
browserSync = require 'browser-sync'
consolidate = require 'gulp-consolidate'
cssbeautify = require 'gulp-cssbeautify'

pkg = require './package.json'

fontName = 'talk-iconfonts'
className = 'ti'
iconfontName = 'Talk Iconfonts'

iconfontProcess = (cb, dest) ->
  try which.sync 'sketchtool'
  catch err
    gutil.log err
    return

  gulp
  .src './sketch/16px.sketch'
  .pipe sketch
    export: 'artboards'
    compact: true
    formats: 'svg'
    saveForWeb: true
  .pipe imagemin()
  .pipe iconfont
    formats: ['eot', 'svg', 'ttf', 'woff', 'woff2']
    fontName: fontName
  .on 'glyphs', (glyphs) ->
    info =
      glyphs: glyphs.reduce (arr, glyph) ->
        names = glyph.name
        .split '&'
        .map (name) ->
          name: name
          unicode: glyph.unicode[0].charCodeAt(0).toString(16).toUpperCase()
        arr.concat names
      , []
      version: pkg.version
      fontName: fontName
      fontPath: '../fonts/'
      className: className
      fontFamily: iconfontName
    cb info
  .pipe gulp.dest dest

###
 * @开发
###

gulp.task 'dev', (cb) ->
  run 'dev:clean', 'dev:iconfonts', 'dev:browser', 'dev:watch', cb

bs = browserSync.create 'dev'
gulp.task 'dev:browser', ->
  bs.init
    open: false
    server:
      baseDir: './examples'
      directory: true

gulp.task 'dev:clean', (cb) ->
  del ['./examples/'], cb

gulp.task 'dev:iconfonts', ->
  iconfontProcess (info) ->
    gulp.src "./src/#{fontName}.css"
    .pipe consolidate 'lodash', info
    .pipe rename basename: fontName
    .pipe gulp.dest './examples/css/'

    gulp.src './src/index.html'
    .pipe consolidate 'lodash', info
    .pipe gulp.dest './examples/'
  , './examples/fonts/'

gulp.task 'dev:watch', ->
  gulp.watch './sketch/*.sketch', ['compile:iconfonts']

###
 * @编译
###

gulp.task 'compile', (cb) ->
  run 'compile:clean', 'compile:iconfonts', 'compile:beautify', 'compile:minify', cb

gulp.task 'compile:beautify', ->
  gulp.src "./lib/css/#{fontName}.css"
  .pipe cssbeautify
    indent: '  '
    openbrace: 'end-of-line'
    autosemicolon: true
  .pipe gulp.dest './lib/css/'

gulp.task 'compile:clean', (cb)->
  del ['./lib/'], cb

gulp.task 'compile:iconfonts', ->
  iconfontProcess (info) ->
    gulp.src "./src/#{fontName}.css"
    .pipe consolidate 'lodash', info
    .pipe rename basename: fontName
    .pipe gulp.dest './lib/css/'
  ,'./lib/fonts/'

gulp.task 'compile:minify', ->
  gulp.src "./lib/css/#{fontName}.css"
  .pipe cssnano()
  .pipe rename suffix: '.min'
  .pipe gulp.dest './lib/css/'

###
 * @快捷任务命令
###

gulp.task 'build', (cb) ->
  run 'compile', cb
