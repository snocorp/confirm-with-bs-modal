var BUILD_DEST = './build/';
var DEMO_DEST = './demo/assets/javascripts/';

var gulp = require('gulp');
var coffee = require('gulp-coffee');
var rename = require("gulp-rename");
var uglify = require('gulp-uglify');
var gutil = require('gulp-util');

gulp.task('default', function() {
  gulp.src('*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest(BUILD_DEST))
    .pipe(gulp.dest(DEMO_DEST))
    .pipe(uglify())
    .pipe(rename({
      suffix: ".min"
    }))
    .pipe(gulp.dest(BUILD_DEST));
});