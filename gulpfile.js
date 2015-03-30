var extend          = require("extend"),
    fs              = require("fs"),
    gulp            = require("gulp"),
    less            = require("gulp-less"),
    po2json         = require("po2json"),
    reactTools      = require('react-tools'),
    rev             = require("gulp-rev"),
    shell           = require("shelljs"),
    source          = require("vinyl-source-stream"),
    streamify       = require("gulp-streamify"),
    through2        = require("through2"),
    Q               = require("q"),
    watch           = require('gulp-watch'),
    yarb            = require('yarb'),

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
                relativeUrls: true,
                plugins: [
                    new (require('less-plugin-clean-css'))
                ]
            }))
    ).done(writeManifest);
}

var CACHED_BUNDLES = Object.create(null);

function runYarb(resourceName, callback) {
    if (resourceName in CACHED_BUNDLES) {
        return CACHED_BUNDLES[resourceName];
    }

    var bundle = yarb('./root/static/scripts/' + resourceName, {
        debug: !!process.env.SOURCEMAPS
    });

    callback && callback(bundle);

    if (process.env.UGLIFY) {
        bundle.transform("uglifyify", {
            // See https://github.com/substack/node-browserify#btransformtr-opts
            global: true,

            // Uglify options
            preserveComments: "some",
            output: { max_line_len: 256 }
        });
    }

    CACHED_BUNDLES[resourceName] = bundle;
    return bundle;
}

function bundleScripts(b, resourceName) {
    return b.bundle().on("error", console.log).pipe(source(resourceName));
}

function writeScript(b, resourceName) {
    return writeResource(bundleScripts(b, resourceName));
}

function langToPosix(lang) {
    return lang.replace(/^([a-zA-Z]+)-([a-zA-Z]+)$/, function (match, l, c) {
        return l + '_' + c.toUpperCase()
    });
}

function reactify(filename) {
    return through2(function (chunk, enc, cb) {
        this.push(reactTools.transform(String(chunk), {
          es5: true,
          sourceMap: !!process.env.SOURCEMAPS,
          sourceFilename: filename,
          stripTypes: false,
          harmony: true
        }));
        cb();
    });
}

function buildScripts() {
    process.env.NODE_ENV = process.env.UGLIFY ? 'production' : 'development';

    var langPromises = [];
    var languages = (process.env.MB_LANGUAGES || "")
        .split(",")
        .filter(function (lang) { return lang && lang !== 'en' })
        .map(langToPosix);

    languages.forEach(function (lang) {
        var srcPo = "./po/mb_server." + lang + ".po";
        var tmpPo = "./po/javascript." + lang + ".po";

        // Create a temporary .po file containing only the strings used by root/static/scripts.
        shell.exec("msggrep -N '../root/static/scripts/**/*.js' " + srcPo + " -o " + tmpPo);

        var jedOptions = po2json.parseFileSync(tmpPo, { format: "jed" });
        fs.unlinkSync(tmpPo);

        var scriptName = 'jed-' + lang + '.js';
        var jedWrapper = './root/static/scripts/' + scriptName;

        fs.writeFileSync(
            jedWrapper,
            'module.exports = ' + JSON.stringify(jedOptions) + ';\n'
        );

        var promise = writeScript(
            yarb(scriptName).require(jedWrapper, {expose: 'jed-' + lang}),
            scriptName
        );

        langPromises.push(promise);
        promise.done(function () {fs.unlinkSync(jedWrapper)});
    });

    Q.all(langPromises).then(function () {
        var commonBundle = runYarb('common.js', function (b) {
            b.expose('./root/static/lib/knockout/knockout-latest.debug.js', 'knockout');
            b.expose('./root/static/lib/leaflet/leaflet-src.js', 'leaflet');
        });

        var editBundle = runYarb('edit.js', function (b) {
            b.external(commonBundle);
            b.transform('envify', {global: true});
            b.transform(reactify);
        });

        var guessCaseBundle = runYarb('guess-case.js', function (b) {
            b.external(commonBundle);
        });

        var releaseEditorBundle = runYarb('release-editor.js', function (b) {
            b.external(commonBundle)
            b.external(editBundle)
            b.transform(reactify);
        });

        var statisticsBundle = runYarb('statistics.js', function (b) {
            b.external(commonBundle);
        });

        var timelineBundle = runYarb('timeline.js', function (b) {
            b.external(commonBundle);
        });

        return Q.all([
            writeScript(commonBundle, 'common.js'),
            writeScript(editBundle, 'edit.js'),
            writeScript(guessCaseBundle, 'guess-case.js'),
            writeScript(releaseEditorBundle, 'release-editor.js'),
            writeScript(statisticsBundle, 'statistics.js'),
            writeScript(timelineBundle, 'timeline.js')
        ]);
    }).then(writeManifest);
}

gulp.task("styles", buildStyles);
gulp.task("scripts", buildScripts);

gulp.task("watch", ['styles', 'scripts'], function () {
    watch("./root/static/**/*.less", buildStyles);

    function rebundle(b, resourceName, file) {
        var rebuild = false;

        switch (file.event) {
            case 'add':
                rebuild = true;
                break;
            case 'change':
            case 'unlink':
                rebuild = b.has(file.path);
                break;
        }

        if (rebuild) {
            writeScript(b, resourceName);
        }
    }

    watch("./root/static/scripts/**/*.js", function (file) {
        Object.keys(CACHED_BUNDLES).forEach(function (resourceName) {
            rebundle(CACHED_BUNDLES[resourceName], resourceName, file);
        });
    });
});

gulp.task("tests", function () {
    process.env.NODE_ENV = 'development';

    return bundleScripts(
        runYarb('tests.js', function (b) {
            b.transform('envify', {global: true});
            b.transform(reactify);
            b.expose('./root/static/lib/knockout/knockout-latest.debug.js', 'knockout');
            b.expose('./root/static/lib/leaflet/leaflet-src.js', 'leaflet');
        }),
        'tests.js'
    ).pipe(gulp.dest("./root/static/build/"));
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
