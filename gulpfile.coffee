gulp = require 'gulp'

gulp.task 'del', (cb) ->
  del = require 'del'

  del [ './lib/' ], cb

gulp.task 'icon', (cb) ->
  rename = require 'gulp-rename'
  sketch = require 'gulp-sketch'
  iconfont = require 'gulp-iconfont'
  imagemin = require 'gulp-imagemin'
  consolidate = require 'gulp-consolidate'

  fontName = 'talk-icon-fonts'
  template = 'template'

  gulp
  .src './src/icon-fonts.sketch'
  .pipe sketch export: 'artboards', formats: 'svg'
  .pipe imagemin()
  .pipe iconfont fontName: fontName, formats: ['eot', 'svg', 'ttf', 'woff', 'woff2']

  # generator process.
  .on 'glyphs', (glyphs, options) ->

    # options
    options =
      glyphs: glyphs.map (glyph) -> name: glyph.name, codepoint: glyph.unicode[0].charCodeAt(0)
      fontName: fontName
      fontPath: '../fonts/'
      className: 'icon'

    # generate template css.
    gulp
    .src "./src/#{ template }.css"
    .pipe consolidate 'lodash', options
    .pipe rename basename: 'index'
    .pipe gulp.dest './lib/css/'

    # generate template html.
    gulp
    .src "./src/#{ template }.html"
    .pipe consolidate 'lodash', options
    .pipe rename basename: 'index'
    .pipe gulp.dest './lib/'

  # generate font icons.
  .pipe gulp.dest './lib/fonts/'


# default task to clean old files and generate icon fonts
gulp.task 'default', ['del', 'icon']
