var browserify      = require("browserify"),
    extend          = require("extend"),
    fs              = require("fs"),
    gulp            = require("gulp"),
    less            = require("gulp-less"),
    rev             = require("gulp-rev"),
    source          = require("vinyl-source-stream"),
    streamify       = require("gulp-streamify"),
    through2        = require("through2"),
    Q               = require("q"),

    revManifestPath = "./root/static/build/rev-manifest.json",
    revManifest     = {};

if (fs.existsSync(revManifestPath)) {
    revManifest = JSON.parse(fs.readFileSync(revManifestPath));
}

function writeManifest() {
    fs.writeFileSync(revManifestPath, JSON.stringify(revManifest));
}

function writeResource(stream) {
    var deferred = Q.defer();

    stream
        .pipe(streamify(rev()))
        .pipe(gulp.dest("./root/static/build/"))
        .pipe(rev.manifest())
        .pipe(through2.obj(function (chunk, encoding, callback) {
            extend(revManifest, JSON.parse(chunk.contents));
            callback();
        }))
        .on("finish", function () {
            deferred.resolve();
        });

    return deferred.promise;
}

function buildStyles() {
    return writeResource(
        gulp.src("./root/static/*.less")
            .pipe(less({
                rootpath: "/static/",
                cleancss: true,
                relativeUrls: true
            }))
    );
}

function createBundle(resourceName, watch, callback) {
    var b = browserify("./root/static/scripts/" + resourceName, {
        cache: {},
        packageCache: {},
        fullPaths: watch ? true : false,
        debug: !!process.env.SOURCEMAPS
    });

    if (callback) {
        callback(b);
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

    function build() {
        return writeResource(
            b.bundle()
            .on("error", console.log)
            .pipe(source(resourceName))
        );
    }

    if (watch) {
        b = require("watchify")(b);

        function _build() {
            console.log("building " + resourceName);
            build().done(writeManifest);
        }

        _build();
        b.on("update", _build);
    }

    return build();
}

function buildScripts(watch) {
    return Q.all([
        createBundle("common.js", watch, function (b) {
            // Needed by knockout-* plugins in edit.js
            b.require('./root/static/lib/knockout/knockout-latest.debug.js', { expose: 'knockout' });
        }),
        createBundle("edit.js", watch, function (b) {
            b.external('./root/static/lib/knockout/knockout-latest.debug.js');
        }),
        createBundle("guess-case.js", watch),
        createBundle("release-editor.js", watch),
        createBundle("statistics.js", watch)
    ]);
}

gulp.task("styles", function () {
    return buildStyles().done(writeManifest);
});

gulp.task("scripts", function () {
    return buildScripts(false).done(writeManifest);
});

gulp.task("watch", function () {
    function _buildStyles() {
        console.log("building all styles");
        buildStyles().done(writeManifest);
    }

    _buildStyles();
    gulp.watch("./root/static/**/*.less", _buildStyles);

    buildScripts(true);
});

gulp.task("clean", function () {
    var fileRegex = /^([a-z\-]+)-[a-f0-9]+\.(js|css)$/;

    fs.readdirSync("./root/static/build/").forEach(function (file) {
        if (fileRegex.test(file) && revManifest[file.replace(fileRegex, "$1.$2")] !== file) {
            fs.unlinkSync("./root/static/build/" + file);
        }
    });
});

gulp.task("jshint", function () {
    var jshint = require("gulp-jshint");

    return gulp.src("./root/static/scripts/**/*.js")
        .pipe(jshint())
        .pipe(jshint.reporter("default"));
});

gulp.task("default", ["styles", "scripts"]);
