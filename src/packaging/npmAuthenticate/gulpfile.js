var gulp = require('gulp');

// Include Our Plugins
var run = require('gulp-run-command').default;
var subproject = "projecta";
// Run NPM install

gulp.task('before', run('ls ' + subproject));
gulp.task('npmconfigls', ['before'], run('npm config ls', { cwd: "projecta" }));
gulp.task('npminstall', ['npmconfigls'], run('npm install --verbose', { cwd: "projecta" }));
gulp.task('after', ['npminstall'], run('ls ' + subproject));

gulp.task('yarn-cache-clean', run('yarn cache clean'))
gulp.task('yarninstall-vsts', ['yarn-cache-clean'], run('yarn install --verbose', { cwd: "projecta" }));
gulp.task('yarninstall-externalVsts', ['yarn-cache-clean'], run('yarn install --verbose', { cwd: "projectb-externalVsts" }));

// Default Task
gulp.task('default', ['after']);