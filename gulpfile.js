var extend          = require("extend"),
    File            = require('vinyl'),
    fs              = require("fs"),
    gulp            = require("gulp"),
    less            = require("gulp-less"),
    path            = require('path'),
    po2json         = require("po2json"),
    reactTools      = require('react-tools'),
    rev             = require("gulp-rev"),
    shell           = require("shelljs"),
    source          = require("vinyl-source-stream"),
    streamify       = require("gulp-streamify"),
    through         = require('through'),
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
                    new (require('less-plugin-clean-css'))({compatibility: 'ie8'})
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

    if (process.env.DEVELOPMENT_SERVER == 0) {
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
    var chunks = [];

    return through(
        function (chunk) {
            chunks.push(chunk);
        },
        function () {
            var source = String(Buffer.concat(chunks));

            this.push(reactTools.transform(source, {
                es5: true,
                sourceMap: !!process.env.SOURCEMAPS,
                sourceFilename: filename,
                stripTypes: false,
                harmony: true
            }));

            this.push(null);
        }
    );
}

function buildScripts() {
    process.env.NODE_ENV = process.env.DEVELOPMENT_SERVER == 1 ? 'development' : 'production';

    var commonBundle = runYarb('common.js', function (b) {
        b.expose('./root/static/lib/leaflet/leaflet-src.js', 'leaflet')
         .transform(reactify);
    });

    var languages = (process.env.MB_LANGUAGES || "")
        .split(",")
        .filter(function (lang) { return lang && lang !== 'en' })
        .map(langToPosix);

    languages.forEach(function (lang) {
        var srcPo = "./po/mb_server." + lang + ".po";
        var tmpPo = "./po/javascript." + lang + ".po";
        var scriptName = 'jed-' + lang + '.js';

        // Create a temporary .po file containing only the strings used by root/static/scripts.
        shell.exec("msggrep -N '../root/static/scripts/**/*.js' " + srcPo + " -o " + tmpPo);

        var jedOptions = po2json.parseFileSync(tmpPo, { format: "jed" });
        fs.unlinkSync(tmpPo);

        var langVinyl = new File({
            path: path.resolve('./root/static/scripts/' + scriptName),
            contents: new Buffer('module.exports = ' + JSON.stringify(jedOptions) + ';\n')
        });

        var bundle = yarb().expose(langVinyl, 'jed-' + lang);
        commonBundle.require(langVinyl).external(bundle);
        writeScript(bundle, scriptName);
    });

    var editBundle = runYarb('edit.js', function (b) {
        b.external(commonBundle).transform('envify', {global: true}).transform(reactify);
    });

    var guessCaseBundle = runYarb('guess-case.js', function (b) {
        b.external(commonBundle);
    });

    var placeBundle = runYarb('place.js', function (b) {
        b.external(editBundle).external(guessCaseBundle).transform(reactify);
    });

    var releaseEditorBundle = runYarb('release-editor.js', function (b) {
        b.external(commonBundle).external(editBundle).transform(reactify);
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
        writeScript(placeBundle, 'place.js'),
        writeScript(releaseEditorBundle, 'release-editor.js'),
        writeScript(statisticsBundle, 'statistics.js'),
        writeScript(timelineBundle, 'timeline.js'),
        writeScript(runYarb('debug.js', function (b) {b.external(commonBundle)}), 'debug.js')
    ]).then(writeManifest);
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
            writeScript(b, resourceName).done(writeManifest);
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
            b.transform('envify', {global: true})
             .transform(reactify)
             .expose('./root/static/lib/leaflet/leaflet-src.js', 'leaflet');
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

gulp.task("default", ["styles", "scripts"]);
