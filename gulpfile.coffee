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
consolidate = require 'gulp-consolidate'
cssbeautify = require 'gulp-cssbeautify'

PACKAGE = require './package.json'
FONT_NAME = 'talk-iconfonts'
CLASS_NAME = 'ti'
TALK_ICONFONTS = 'Talk Iconfonts'

gulp.task 'beautify', ->
  gulp
  .src "./lib/css/#{ FONT_NAME }.css"
  .pipe cssbeautify
    indent: '  '
    openbrace: 'end-of-line'
    autosemicolon: true
  .pipe gulp.dest './lib/css/'

gulp.task 'example', ->
  gulp
  .src './example/index.html'
  .pipe htmlmin collapseWhitespace: true
  .pipe gulp.dest './example/'

gulp.task 'del', (cb) ->
  del ['./lib/'], cb

gulp.task 'iconfonts', ->
  try
    which.sync 'sketchtool'
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
    fontName: FONT_NAME
    normalize: true
  # Process of generating iconfonts
  .on 'glyphs', (glyphs, options) ->
    info =
      glyphs: glyphs.reduce (arr, glyph) ->
        names = glyph.name.split '&'
        .map (name) ->
          name: name
          unicode: glyph.unicode[0].charCodeAt(0).toString(16).toUpperCase()
        arr.concat names
      , []
      version: PACKAGE.version
      fontName: FONT_NAME
      fontPath: '../fonts/'
      className: CLASS_NAME
      fontFamily: TALK_ICONFONTS

    gulp
    .src "./src/#{ FONT_NAME }.css"
    .pipe consolidate 'lodash', info
    .pipe rename basename: FONT_NAME
    .pipe gulp.dest './lib/css/'

    gulp
    .src './src/index.html'
    .pipe consolidate 'lodash', info
    .pipe gulp.dest './example/'

  .pipe gulp.dest './lib/fonts/'

gulp.task 'minify', ->
  gulp
  .src "./lib/css/#{ FONT_NAME }.css"
  .pipe cssnano()
  .pipe rename suffix: '.min'
  .pipe gulp.dest './lib/css/'

# default task to clean old files and generate icon fonts.
gulp.task 'default', (cb) ->
  run 'del', 'iconfonts', cb

# build task for publishing.
gulp.task 'build', (cb) ->
  run 'del', 'iconfonts', 'beautify', 'minify', 'example', cb
