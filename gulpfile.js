var browserify      = require("browserify"),
    extend          = require("extend"),
    fs              = require("fs"),
    gulp            = require("gulp"),
    less            = require("gulp-less"),
    po2json         = require("po2json"),
    rev             = require("gulp-rev"),
    shell           = require("shelljs"),
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
                relativeUrls: true,
                plugins: [
                    new (require('less-plugin-clean-css'))
                ]
            }))
    );
}

function runBrowserify(resourceName, watch, callback) {
    var b = browserify("./root/static/scripts/" + resourceName, {
        cache: {},
        packageCache: {},
        fullPaths: watch ? true : false,
        debug: !!process.env.SOURCEMAPS
    });

    if (callback) {
        callback(b);
    }

    return b;
}

function bundleScripts(b, resourceName) {
    return b.bundle().on("error", console.log).pipe(source(resourceName));
}

function createBundle(resourceName, watch, callback) {
    var b = runBrowserify(resourceName, watch, callback);

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
        return writeResource(bundleScripts(b, resourceName));
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

function langToPosix(lang) {
    return lang.replace(/^([a-zA-Z]+)-([a-zA-Z]+)$/, function (match, l, c) {
        return l + '_' + c.toUpperCase()
    });
}

function buildScripts(watch) {
    if (process.env.UGLIFY) {
        process.env.NODE_ENV = 'production';
    }

    var promises = [];

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

        var jedWrapper = './root/static/scripts/jed-' + lang + '.js';

        fs.writeFileSync(
            jedWrapper,
            'module.exports = ' + JSON.stringify(jedOptions) + ';\n'
        );

        createBundle("jed-" + lang + ".js", watch, function (b) {
            b.external('jed');
            b.require(jedWrapper, { expose: 'jed-' + lang });
        }).done(function () {
            fs.unlinkSync(jedWrapper);
        });
    });

    return Q.all([
        createBundle("common.js", watch, function (b) {
            languages.forEach(function (lang) {
                b.external('jed-' + lang);
            });

            b.require('jquery', { expose: 'jquery' });
            // Needed by knockout-* plugins in edit.js
            b.require('./root/static/lib/knockout/knockout-latest.debug.js', { expose: 'knockout' });
            b.require('./root/static/scripts/common/i18n.js', { expose: true });
            b.require('./root/static/scripts/common/utility/debounce.js', { expose: true });
            b.require('./root/static/scripts/common/utility/formatTrackLength.js', { expose: true });
            b.require('./root/static/scripts/common/utility/request.js', { expose: true });
        }),
        createBundle("edit.js", watch, function (b) {
            b.transform('reactify', { es6: true });

            b.external('./root/static/lib/knockout/knockout-latest.debug.js');
            b.external('./root/static/scripts/common/i18n.js');
            b.external('./root/static/scripts/common/utility/request.js');

            b.require('./root/static/scripts/edit/utility/dates.js', { expose: true });
            b.require('./root/static/scripts/edit/utility/deferFocus.js', { expose: true });
            b.require('./root/static/scripts/edit/utility/isPositiveInteger.js', { expose: true });
            b.require('./root/static/scripts/edit/externalLinks.js', { expose: true });
            b.require('./root/static/scripts/edit/validation.js', { expose: true });     
        }),
        createBundle("guess-case.js", watch, function (b) {
            b.external('./root/static/scripts/common/i18n.js');
        }),
        createBundle("release-editor.js", watch, function (b) {
            b.transform('reactify', { es6: true });

            b.external('./root/static/scripts/common/i18n.js');
            b.external('./root/static/scripts/common/utility/debounce.js');
            b.external('./root/static/scripts/common/utility/formatTrackLength.js');
            b.external('./root/static/scripts/common/utility/request.js');
            b.external('./root/static/scripts/edit/externalLinks.js');
            b.external('./root/static/scripts/edit/validation.js');
            b.external('./root/static/scripts/edit/utility/dates.js');
            b.external('./root/static/scripts/edit/utility/deferFocus.js');
            b.external('./root/static/scripts/edit/utility/isPositiveInteger.js');
        }),
        createBundle("statistics.js", watch, function (b) {
            b.external('jquery');
            b.external('./root/static/scripts/common/utility/debounce.js');
        }),
        createBundle('timeline.js')
    ]);
}

gulp.task("styles", function () {
    return buildStyles().done(writeManifest);
});

gulp.task("scripts", function () {
    return buildScripts(false).done(writeManifest);
});

gulp.task("tests", function () {
    process.env.NODE_ENV = 'development';

    return bundleScripts(
        runBrowserify('tests.js', false, function (b) {
            b.transform('reactify', { es6: true });

            b.require('./root/static/lib/knockout/knockout-latest.debug.js', { expose: 'knockout' });
        }),
        'tests.js'
    ).pipe(gulp.dest("./root/static/build/"));
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
