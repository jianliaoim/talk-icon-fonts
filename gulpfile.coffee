gulp = require 'gulp'

# Remove building output files before running task.
#

gulp.task 'del', (cb) ->
  del = require 'del'

  del [ './index.html', './lib/' ], cb

# Generate icon fonts from sketch,
# also export template homepage.
#

gulp.task 'icon', ->
  rename = require 'gulp-rename'
  sketch = require 'gulp-sketch'
  iconfont = require 'gulp-iconfont'
  imagemin = require 'gulp-imagemin'
  consolidate = require 'gulp-consolidate'

  fontName = 'talk-iconfonts'
  template = 'template'

  gulp
  .src './sketch/16px.sketch'
  .pipe sketch
    clean: true
    export: 'artboards'
    compact: true
    formats: 'svg'
    saveForWeb: true
  .pipe imagemin()
  .pipe iconfont
    formats: [ 'eot', 'svg', 'ttf', 'woff', 'woff2' ]
    fontName: fontName

  # generator process.
  #

  .on 'glyphs', (glyphs, options) ->

    # options
    #

    resolveGlyphs = (glyphs) ->

      DEFAULT_TYPE = '未分类'

      glyphTypes =
        "#{ DEFAULT_TYPE }": []

      glyphs
      .forEach (glyph) ->

        glyph.name
        .split /\u0020|\u2002|\u2003/g
        .forEach (nameType) ->

          names = nameType.split /\u0040/g

          name = names[0]
          type = names[1] or DEFAULT_TYPE

          if not glyphTypes[type]?
            glyphTypes[type] = []

          glyphTypes[type].push
            name: name
            unicode: glyph.unicode[0].charCodeAt(0).toString(16).toUpperCase()

      glyphTypes

    info =
      glyphTypes: resolveGlyphs glyphs
      fontName: fontName
      fontPath: '../fonts/'
      className: 'ti'

    # generate template css.
    #

    gulp
    .src './src/template.css'
    .pipe consolidate 'lodash', info
    .pipe rename basename: fontName
    .pipe gulp.dest './lib/css/'

    # generate template html.
    #

    gulp
    .src './src/template.html'
    .pipe consolidate 'lodash', info
    .pipe rename basename: 'index'
    .pipe gulp.dest './'

  # generate font icons.
  #

  .pipe gulp.dest './lib/fonts/'

# beautify css.
#

gulp.task 'beautify', ->
  cssbeautify = require 'gulp-cssbeautify'

  gulp
  .src './lib/css/talk-iconfonts.css'
  .pipe cssbeautify
    indent: '  '
    autosemicolon: true
  .pipe gulp.dest './lib/css/'

# compress assets.
#

gulp.task 'compress', ->
  rename = require 'gulp-rename'
  htmlmin = require 'gulp-htmlmin'
  minifyCss = require 'gulp-minify-css'

  gulp
  .src './index.html'
  .pipe htmlmin collapseWhitespace: true
  .pipe gulp.dest './'

  gulp
  .src './lib/css/talk-iconfonts.css'
  .pipe minifyCss()
  .pipe rename suffix: '.min'
  .pipe gulp.dest './lib/css/'

# default task to clean old files and generate icon fonts.
gulp.task 'default', [ 'del', 'icon' ]

# build task for publishing.
gulp.task 'build', (cb) ->
  run = require 'run-sequence'

  run 'del', 'icon', 'beautify', 'compress', cb
