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
  className = 'talk-icon-fonts'

  gulp
  .src './src/icon-fonts.sketch'
  .pipe sketch export: 'artboards', formats: 'svg'
  .pipe imagemin()
  .pipe iconfont fontName: fontName, formats: ['eot', 'svg', 'ttf', 'woff', 'woff2']

  # generator process.
  .on 'glyphs', (glyphs, options) ->
    console.log glyphs
    # options
    options =
      glyphs: glyphs.map (glyph) -> name: glyph.name, codepoint: glyph.unicode[0].charCodeAt(0)
      fontName: fontName
      fontPath: '../fonts/'
      className: className

    # generate template css.
    gulp
    .src "./src/#{ template }.css"
    .pipe consolidate 'lodash', options
    .pipe rename basename: fontName
    .pipe gulp.dest './lib/css/'

    # generate template html.
    gulp
    .src "./src/#{ template }.html"
    .pipe consolidate 'lodash', options
    .pipe rename basename: 'index'
    .pipe gulp.dest '../'

  # generate font icons.
  .pipe gulp.dest './lib/fonts/'


# default task to clean old files and generate icon fonts
gulp.task 'default', ['del', 'icon']
