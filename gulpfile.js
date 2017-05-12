var gulp = require('gulp');
var del = require('del');
var ts = require("gulp-typescript");
var sourcemaps = require('gulp-sourcemaps');

gulp.task('clean', function() {
    return del('build/**/*')
});

gulp.task('compile', ['clean'], function () {
    return gulp.src('src/*.ts')
        .pipe(sourcemaps.init())
        .pipe(ts({
                module: "commonjs",
                target: "es6",
                lib: [
                    "es6"
                ],
                sourceMap: true,
                alwaysStrict: true
            }))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('build/'));
});

gulp.task('copy', ['clean'], function() {
    return gulp.src('src/powershell/**/*').pipe(gulp.dest('build/powershell/'));
});

gulp.task('default', ['clean', 'copy', 'compile']);