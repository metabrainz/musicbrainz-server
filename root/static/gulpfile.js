var _ = require('lodash');
var babelify = require('babelify');
var File = require('vinyl');
var fs = require('fs');
var gulp = require('gulp');
var less = require('gulp-less');
var path = require('path');
var po2json = require('po2json');
var rev = require('gulp-rev');
var shell = require('shelljs');
var source = require('vinyl-source-stream');
var streamify = require('gulp-streamify');
var through2 = require('through2');
var Q = require('q');
var watch = require('gulp-watch');
var yarb = require('yarb');

const CACHED_BUNDLES = new Map();
const revManifestPath = './root/static/build/rev-manifest.json';
const revManifest = {};

if (fs.existsSync(revManifestPath)) {
  _.assign(revManifest, JSON.parse(fs.readFileSync(revManifestPath)));
}

function writeManifest() {
  fs.writeFileSync(revManifestPath, JSON.stringify(revManifest));
}

function writeResource(stream) {
  var deferred = Q.defer();

  stream
    .pipe(streamify(rev()))
    .pipe(gulp.dest('./root/static/build/'))
    .pipe(rev.manifest())
    .pipe(through2.obj(function (chunk, encoding, callback) {
      _.assign(revManifest, JSON.parse(chunk.contents));
      callback();
    }))
    .on('finish', function () {
      deferred.resolve();
    });

  return deferred.promise;
}

function buildStyles() {
  return writeResource(
    gulp.src('./root/static/*.less')
    .pipe(less({
      rootpath: '/static/',
      relativeUrls: true,
      plugins: [
        new (require('less-plugin-clean-css'))({compatibility: 'ie8'})
      ]
    }))
  ).done(writeManifest);
}

function transformBundle(bundle) {
  bundle.transform(babelify.configure({
    blacklist: ['strict'],
    nonStandard: true,
    only: /root\/static\/scripts\/.+\.js$/,
    optional: [
      'es7.objectRestSpread'
    ],
    sourceMap: false,
  }));

  bundle.transform('envify', {global: true});

  if (String(process.env.DEVELOPMENT_SERVER) === '0') {
    bundle.transform('uglifyify', {
      // See https://github.com/substack/node-browserify#btransformtr-opts
      global: true,

      // Uglify options
      output: {
        comments: /@preserve|@license/,
        max_line_len: 256
      },

      sourcemap: false
    });
  }

  return bundle;
}

function runYarb(resourceName, callback) {
  if (resourceName in CACHED_BUNDLES) {
    return CACHED_BUNDLES.get(resourceName);
  }

  var bundle = transformBundle(yarb('./root/static/scripts/' + resourceName, {
    debug: false // disable sourcemaps
  }));

  if (callback) {
    callback(bundle);
  }

  CACHED_BUNDLES.set(resourceName, bundle);
  return bundle;
}

function bundleScripts(b, resourceName) {
  return b.bundle().on('error', console.log).pipe(source(resourceName));
}

function writeScript(b, resourceName) {
  return writeResource(bundleScripts(b, resourceName));
}

function createLangVinyl(lang, jedOptions) {
  return new File({
    path: path.resolve('./root/static/scripts/jed-' + lang + '.js'),
    contents: new Buffer('export default ' + JSON.stringify(jedOptions) + ';\n'),
  });
}

function langToPosix(lang) {
  return lang.replace(/^([a-zA-Z]+)-([a-zA-Z]+)$/, function (match, l, c) {
    return l + '_' + c.toUpperCase()
  });
}

function buildScripts() {
  process.env.NODE_ENV = String(process.env.DEVELOPMENT_SERVER) === '1' ? 'development' : 'production';

  var commonBundle = runYarb('common.js', function (b) {
    b.expose('./root/static/lib/leaflet/leaflet-src.js', 'leaflet');
  });

  _((process.env.MB_LANGUAGES || '').replace(/\s+/g, ''))
    .split(',')
    .compact()
    .without('en')
    .map(langToPosix)
    .transform(function (result, lang) {
      var tmpPo = `./po/javascript.${lang}.po`;

      // Create a temporary .po file containing only the strings used by root/static/scripts.
      shell.exec(`msggrep -N ../root/static/scripts/**/*.js ./po/mb_server.${lang}.po -o ${tmpPo}`);

      result[lang] = po2json.parseFileSync(tmpPo, {format: 'jed'});

      fs.unlinkSync(tmpPo);
    }, {})
    .assign({en: {}})
    .each(function (jedOptions, lang) {
      var bundle = transformBundle(yarb().expose(createLangVinyl(lang, jedOptions), 'jed-data'));
      commonBundle.external(bundle);
      writeScript(bundle, 'jed-' + lang + '.js');
    })
    .value();

  var editBundle = runYarb('edit.js', function (b) {
    b.external(commonBundle);
  });

  var guessCaseBundle = runYarb('guess-case.js', function (b) {
    b.external(commonBundle);
  });

  var placeBundle = runYarb('place.js', function (b) {
    b.external(editBundle).external(guessCaseBundle);
  });

  var releaseEditorBundle = runYarb('release-editor.js', function (b) {
    b.external(commonBundle).external(editBundle);
  });

  var seriesBundle = runYarb('series.js', function (b) {
    b.external(editBundle).external(guessCaseBundle);
  });

  var statisticsBundle = runYarb('statistics.js', function (b) {
    b.external(commonBundle);
  });

  var timelineBundle = runYarb('timeline.js', function (b) {
    b.external(commonBundle);
  });

  var urlBundle = runYarb('url.js', function (b) {
    b.external(editBundle);
  });

  var workBundle = runYarb('work.js', function (b) {
    b.external(editBundle).external(guessCaseBundle);
  });

  return Q.all([
    writeScript(commonBundle, 'common.js'),
    writeScript(editBundle, 'edit.js'),
    writeScript(guessCaseBundle, 'guess-case.js'),
    writeScript(placeBundle, 'place.js'),
    writeScript(releaseEditorBundle, 'release-editor.js'),
    writeScript(seriesBundle, 'series.js'),
    writeScript(statisticsBundle, 'statistics.js'),
    writeScript(timelineBundle, 'timeline.js'),
    writeScript(urlBundle, 'url.js'),
    writeScript(workBundle, 'work.js'),
    writeScript(runYarb('debug.js', function (b) {
      b.external(commonBundle);
    }), 'debug.js')
  ]).then(writeManifest);
}

gulp.task('styles', buildStyles);
gulp.task('scripts', buildScripts);

gulp.task('watch', ['styles', 'scripts'], function () {
  watch('./root/static/**/*.less', buildStyles);

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

  watch('./root/static/scripts/**/*.js', function (file) {
    CACHED_BUNDLES.forEach(function (bundle, resourceName) {
      rebundle(bundle, resourceName, file);
    });
  });
});

gulp.task('tests', function () {
  process.env.NODE_ENV = 'development';

  return bundleScripts(
    runYarb('tests.js', function (b) {
      b.expose(createLangVinyl('en', {}), 'jed-data');
      b.expose('./root/static/lib/leaflet/leaflet-src.js', 'leaflet');
    }),
    'tests.js'
  ).pipe(gulp.dest('./root/static/build/'));
});

gulp.task('clean', function () {
  var fileRegex = /^([a-z\-]+)-[a-f0-9]+\.(js|css)$/;

  fs.readdirSync('./root/static/build/').forEach(function (file) {
    if (fileRegex.test(file) && revManifest[file.replace(fileRegex, '$1.$2')] !== file) {
      fs.unlinkSync(`./root/static/build/${file}`);
    }
  });
});

gulp.task('default', ['styles', 'scripts']);
