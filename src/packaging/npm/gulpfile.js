var gulp = require('gulp');
var fs = require('fs');
var minimist = require('minimist');
var tl = require('vsts-task-lib/task');

var argv = minimist(process.argv.slice(2));

function ensureParameter(p, s){
    if(!p){
        throw "Missing expected parameter: " + s;
    }
}

gulp.task('verify-file-exists', function() {
    var path = argv["path"];
    ensureParameter(path, "path");

    if(!fs.existsSync(path)) {
        throw "Path not found: " + path;
    }

    console.log("Verified path: " + path)
});

gulp.task('verify-file-does-not-exist', function() {
    var path = argv["path"];
    ensureParameter(path, "path");

    if(fs.existsSync(path)) {
        throw "Path found: " + path;
    }

    console.log("Verified path does not exist: " + path)
});

gulp.task('write-npmrc', function() {
    var path = argv["path"];
    var registry = argv["registry"];
    var token = argv["token"];

    ensureParameter(path, "path");
    ensureParameter(registry, "registry");
    ensureParameter(token, "token");
    
    var content = "registry=" + registry + "\nalways-auth=true\n" + token;

    console.log("Writing " + path);
    fs.writeFileSync(path, content);
});

gulp.task('show-all-files', function() {
    var files = tl.ls("-R", ".");
    for (file in files) {
        console.log(files[file]);
    }
});

gulp.task('clean-node-modules', function() {
    var path = argv["path"];
    ensureParameter(path, "path");

    var modules = tl.findMatch(path, "node_modules");
    modules.forEach(x => {
        tl.rmRF(x);
    });
});

