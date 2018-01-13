const canonicalJSON = require('canonical-json');
const EventEmitter = require('events');
const fs = require('fs');
const gulp = require('gulp');
const less = require('gulp-less');
const rev = require('gulp-rev');
const streamify = require('gulp-streamify');
const _ = require('lodash');
const mergeStream = require('merge-stream');
const path = require('path');
const Q = require('q');
const shellQuote = require('shell-quote');
const shell = require('shelljs');
const File = require('vinyl');
const source = require('vinyl-source-stream');
const yarb = require('yarb');

const poFile = require('../server/gettext/poFile');
const DBDefs = require('./scripts/common/DBDefs');

// This may need to be increased when a new bundle is added, to silence
// warnings of the form "Possible EventEmitter memory leak detected."
EventEmitter.defaultMaxListeners = 16;

process.env.NODE_ENV = DBDefs.DEVELOPMENT_SERVER ? 'development' : 'production';

const SCRIPT_BUNDLES = {};
const CHECKOUT_DIR = path.resolve(__dirname, '../../');
const PO_DIR = path.resolve(CHECKOUT_DIR, 'po');
const ROOT_DIR = path.resolve(CHECKOUT_DIR, 'root');
const STATIC_DIR = path.resolve(ROOT_DIR, 'static');
const STYLES_DIR = path.resolve(STATIC_DIR, 'styles');
const BUILD_DIR = process.env.MBS_STATIC_BUILD_DIR || path.resolve(STATIC_DIR, 'build');
const SCRIPTS_DIR = path.resolve(STATIC_DIR, 'scripts');
const IMAGES_DIR = path.resolve(STATIC_DIR, 'images');

const revManifestContents = {};

// This file must exist for any task that runs.
const REV_MANIFEST_PATH = path.join(BUILD_DIR, 'rev-manifest.json');
if (!fs.existsSync(REV_MANIFEST_PATH)) {
  fs.writeFileSync(REV_MANIFEST_PATH, '{}');
}

const revManifestBundle = runYarb('rev-manifest.js', function (b) {
  b.expose(path.join(BUILD_DIR, 'rev-manifest.json'), 'rev-manifest.json');
});

const JED_OPTIONS_EN = {
  domain: 'mb_server',
  locale_data: {
    mb_server: {'': {}},
  },
};

function writeResources(stream, writeManifest = true) {
  var deferred = Q.defer();

  stream
    .pipe(streamify(rev()))
    .pipe(gulp.dest(BUILD_DIR))
    // The rev-manifest path must be absolute for the `merge` option to work.
    .pipe(rev.manifest(path.resolve(BUILD_DIR, 'rev-manifest.json'), {
      // By default, `base` is the current working directory, so this ensures
      // the manifest is saved directly under BUILD_DIR, rather than
      // $BUILD_DIR/root/static/build/.
      base: BUILD_DIR,
      merge: true,
      transformer: {
        parse: JSON.parse,
        stringify: function (contents) {
          return canonicalJSON(_.assign(revManifestContents, contents));
        },
      },
    }))
    .pipe(gulp.dest(BUILD_DIR))
    .on('finish', function () {
      if (writeManifest) {
        writeResources(bundleScripts(revManifestBundle, 'rev-manifest.js'), false)
          .done(deferred.resolve);
      } else {
        deferred.resolve();
      }
    });

  return deferred.promise;
}

const STYLE_GLOBS = [
  'common.less',
  'icons.less',
  'statistics.less',
];

function buildStyles() {
  return gulp.src(
    STYLE_GLOBS.map(x => path.resolve(STYLES_DIR, x)),
    {base: STATIC_DIR}
  ).pipe(less({
    rootpath: '/static/',
    relativeUrls: true,
    plugins: [
      new (require('less-plugin-clean-css'))({compatibility: 'ie8'})
    ]
  }));
}

function bundleScripts(bundle, name) {
  return bundle
    .bundle()
    .on('error', console.error)
    .pipe(source('scripts/' + name));
}

function runYarb(resourceName, vinyl, callback) {
  if (!vinyl || typeof vinyl === 'function') {
    callback = vinyl;
    vinyl = new File({
      base: STATIC_DIR,
      path: path.resolve(SCRIPTS_DIR, resourceName),
    });
    vinyl.contents = fs.createReadStream(vinyl.path);
  }

  var bundle = yarb(vinyl, {
    debug: DBDefs.DEVELOPMENT_SERVER,
  });

  bundle.transform('babelify');
  bundle.transform('envify', {global: true});
  bundle.transform('insert-module-globals', {
    global: true,
    vars: {
      L: function (file) {
        if (/leaflet\.markercluster/.test(file)) {
          return "require('leaflet/dist/leaflet-src')";
        }
      },
    },
  });

  if (!DBDefs.DEVELOPMENT_SERVER) {
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

  if (callback) {
    callback(bundle);
  }

  SCRIPT_BUNDLES[resourceName] = bundle;
  return bundle;
}

function createLangVinyl(lang, jedOptions) {
  return new File({
    path: path.resolve(SCRIPTS_DIR, `jed-${lang}.js`),
    contents: new Buffer('module.exports = ' + canonicalJSON(jedOptions) + ';\n'),
  });
}

function langToPosix(lang) {
  return lang.replace(/^([a-zA-Z]+)-([a-zA-Z]+)$/, function (match, l, c) {
    return l + '_' + c.toUpperCase();
  });
}

const commonBundle = runYarb('common.js', function (b) {
  b.external(revManifestBundle);

  // Map DBDefs.js to DBDefs-client.js on disk. (The actual requires have to
  // remain constant for the node renderer.)
  b.require(
    new File({
      path: path.resolve(SCRIPTS_DIR, 'common', 'DBDefs.js'),
      contents: fs.readFileSync(
        path.resolve(SCRIPTS_DIR, 'common', 'DBDefs-client.js')),
    })
  );
});

_(DBDefs.MB_LANGUAGES || '')
  .split(/\s+/)
  .compact()
  .without('en')
  .map(langToPosix)
  .transform(function (result, lang) {
    var srcPo = shellQuote.quote([poFile.find('mb_server', lang, 'po')]);
    var tmpPo = shellQuote.quote([path.resolve(PO_DIR, `javascript.${lang}.po`)]);

    // msggrep's -N option supports wildcards which use fnmatch internally.
    // The '*' cannot match path separators, so we must generate a list of
    // possible terminal paths.
    let scriptsDir = shellQuote.quote([SCRIPTS_DIR]);
    let nestedDirs = shell.exec(`find ${scriptsDir} -type d`, {silent: true}).output.split('\n');
    let msgLocations = _(nestedDirs)
      .compact()
      .map(dir => '-N ' + shellQuote.quote(['..' + dir.replace(CHECKOUT_DIR, '') + '/*.js']))
      .join(' ');

    // Create a temporary .po file containing only the strings used by root/static/scripts.
    shell.exec(`msggrep ${msgLocations} ${srcPo} -o ${tmpPo}`);

    result[lang] = poFile.load('javascript', lang, 'mb_server');
    fs.unlinkSync(tmpPo);
  }, {})
  .assign({en: JED_OPTIONS_EN})
  .each(function (jedOptions, lang) {
    const langVinyl = createLangVinyl(lang, jedOptions);

    runYarb(`jed-${lang}.js`, langVinyl, function (b) {
      b.expose(langVinyl, 'jed-data');
      commonBundle.external(b);
    });
  });

runYarb('area/places-map.js', function (b) {
  b.external(commonBundle);
});

runYarb('debug.js', function (b) {
  b.external(commonBundle);
});

const editBundle = runYarb('edit.js', function (b) {
  b.external(commonBundle);
});

runYarb('edit/notes-received.js', function (b) {
  b.external(commonBundle);
});

const guessCaseBundle = runYarb('guess-case.js', function (b) {
  b.external(commonBundle);
});

const placeMapBundle = runYarb('place/map.js', function (b) {
  b.external(commonBundle);
});

runYarb('place.js', function (b) {
  b.external(placeMapBundle).external(editBundle).external(guessCaseBundle);
});

runYarb('release-editor.js', function (b) {
  b.external(commonBundle).external(editBundle);
});

runYarb('series.js', function (b) {
  b.external(editBundle).external(guessCaseBundle);
});

runYarb('statistics.js', function (b) {
  b.external(commonBundle);
});

runYarb('timeline.js', function (b) {
  b.external(commonBundle);
});

runYarb('url.js', function (b) {
  b.external(editBundle);
});

runYarb('voting.js', function (b) {
  b.external(commonBundle);
});

runYarb('work.js', function (b) {
  b.external(editBundle).external(guessCaseBundle);
});

runYarb('commons-image.js', function (b) {
  b.external(commonBundle);
});

gulp.task('watch', ['default'], function () {
  let watch = require('gulp-watch');

  watch(path.resolve(STATIC_DIR, '**/*.less'), function () {
    process.stdout.write('Rebuilding styles ... ');

    writeResources(buildStyles()).done(function () {
      process.stdout.write('done.\n');
    });
  });

  function shouldRebuild(b, resourceName, file) {
    switch (file.event) {
      case 'add':
        return true;
      case 'change':
      case 'unlink':
        return b.has(file.path);
    }
    return false;
  }

  watch(path.resolve(SCRIPTS_DIR, '**/*.js'), function (file) {
    const changed = {};

    _.each(SCRIPT_BUNDLES, function (bundle, resourceName) {
      if (shouldRebuild(bundle, resourceName, file)) {
        changed[resourceName] = bundle;
      }
    });

    if (!_.isEmpty(changed)) {
      const changedNames = Object.keys(changed).sort().join(', ');

      process.stdout.write(`Rebuilding ${changedNames} ... `);

      writeResources(mergeStream.apply(null, _.map(changed, bundleScripts)))
        .done(function () {
          process.stdout.write('done.\n');
        });
    }
  });
});

function createTestsTask(name, source) {
  gulp.task(name, function () {
    process.env.NODE_ENV = 'development';

    var deferred = Q.defer();

    bundleScripts(
        runYarb(source)
          .expose(path.join(BUILD_DIR, 'rev-manifest.json'), 'rev-manifest.json')
          .expose(createLangVinyl('en', JED_OPTIONS_EN), 'jed-data'),
        name + '.js'
      )
      .pipe(gulp.dest(BUILD_DIR))
      .on('finish', function () { deferred.resolve() });

    return deferred.promise;
  });
}

createTestsTask('tests', 'tests/browser-runner.js');
createTestsTask('web-tests', 'tests/index-web.js');

gulp.task('default', function () {
  const IMAGE_GLOBS = [
    'entity/*',
    'icons/*',
    'image404-125.png',
    'layout/*',
    'leaflet/*',
    'licenses/*',
    'logos/*',
  ];

  return writeResources(mergeStream.apply(null, [
    gulp.src(
      IMAGE_GLOBS.map(x => path.join(IMAGES_DIR, x)),
      {base: STATIC_DIR}
    ),

    // The rev-manifest.js bundle can't be written until all other resources
    // are written (because we obviously don't know its contents otherwise,
    // which includes the final hashes of every resource). This is handled
    // by writeResources.
    _.map(_.omit(SCRIPT_BUNDLES, 'rev-manifest.js'), bundleScripts),

    buildStyles()
  ]));
});
