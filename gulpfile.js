var extend          = require("extend"),
    fs              = require("fs"),
    gulp            = require("gulp"),
    rev             = require("gulp-rev"),
    streamify       = require("gulp-streamify"),
    through2        = require("through2"),
    Q               = require("q"),

    revManifestPath = "./root/static/build/rev-manifest.json",
    revManifest     = {};

if (fs.existsSync(revManifestPath)) {
    revManifest = JSON.parse(fs.readFileSync(revManifestPath));
}

function buildResource(stream) {
    var deferred = Q.defer();

    stream
        .on("error", console.log)
        .pipe(streamify(rev()))
        .pipe(gulp.dest("./root/static/build/"))
        .pipe(rev.manifest())
        .pipe(through2.obj(function (chunk, encoding, callback) {
            extend(revManifest, JSON.parse(chunk.contents));

            fs.writeFileSync(revManifestPath, JSON.stringify(revManifest));

            callback();
        }))
        .on("finish", function () {
            deferred.resolve();
        });

    return deferred.promise;
}

gulp.task("styles", function () {
    var less = require("gulp-less");

    return buildResource(
        gulp.src("./root/static/*.less")
            .pipe(less({
                rootpath: "/static/",
                cleancss: true,
                relativeUrls: true
            }))
    );
});

gulp.task("scripts", function () {
    var browserify = require("browserify");
    var source = require("vinyl-source-stream");

    function bundle(resourceName) {
        var b = browserify("./root/static/scripts/" + resourceName, { debug: !!process.env.DEBUG });

        switch (resourceName) {
            case "common.js":
                // XXX The jquery.flot.* plugins in statistics.js depend on jquery
                b.require("./root/static/lib/jquery/jquery.js", { expose: "jquery" });

                // XXX The knockout-* plugins in edit.js attempt to require() knockout as a CommonJS module
                b.require("./root/static/lib/knockout/knockout-latest.debug.js", { expose: "knockout" });

                break;
            case "edit.js":
                b.external("./root/static/lib/knockout/knockout-latest.debug.js");
                break;
            case "statistics.js":
                b.external("./root/static/lib/jquery/jquery.js");
                break;
        }

        if (process.env.UGLIFY) {
            b.transform("uglifyify", {
                // See https://github.com/substack/node-browserify#btransformtr-opts
                global: true,

                // Uglify options
                preserveComments: "some",
                output: { max_line_len: 256 }
            });
        }

        return buildResource(b.bundle().pipe(source(resourceName)));
    }

    return Q.all([
        bundle("common.js"),
        bundle("edit.js"),
        bundle("guess-case.js"),
        bundle("release-editor.js"),
        bundle("statistics.js")
    ]);
});

gulp.task("clean", function () {
    var fileRegex = /^([a-z\-]+)-[a-f0-9]+\.(js|css)$/;

    fs.readdirSync("./root/static/build/").forEach(function (file) {
        if (fileRegex.test(file) && revManifest[file.replace(fileRegex, "$1.$2")] !== file) {
            fs.unlinkSync("./root/static/build/" + file);
        }
    });

    fs.writeFileSync(revManifestPath, JSON.stringify(revManifest));
});

gulp.task("jshint", function () {
    var jshint = require("gulp-jshint");

    return gulp.src("./root/static/scripts/**/*.js")
        .pipe(jshint())
        .pipe(jshint.reporter("default"));
});

gulp.task("default", ["styles", "scripts"]);
