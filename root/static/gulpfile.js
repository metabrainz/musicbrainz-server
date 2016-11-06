const canonicalJSON = require('canonical-json');
const fs = require('fs');
const gulp = require('gulp');
const less = require('gulp-less');
const rev = require('gulp-rev');
const streamify = require('gulp-streamify');
const _ = require('lodash');
const path = require('path');
const po2json = require('po2json');
const Q = require('q');
const shellQuote = require('shell-quote');
const shell = require('shelljs');
const File = require('vinyl');
const source = require('vinyl-source-stream');
const yarb = require('yarb');

const {findObjectFile} = require('../server/gettext');

const CACHED_BUNDLES = {};
const CHECKOUT_DIR = path.resolve(__dirname, '../../');
const PO_DIR = path.resolve(CHECKOUT_DIR, 'po');
const ROOT_DIR = path.resolve(CHECKOUT_DIR, 'root');
const STATIC_DIR = path.resolve(ROOT_DIR, 'static');
const STYLES_DIR = path.resolve(STATIC_DIR, 'styles');
const BUILD_DIR = path.resolve(STATIC_DIR, 'build');
const SCRIPTS_DIR = path.resolve(STATIC_DIR, 'scripts');
const IMAGES_DIR = path.resolve(STATIC_DIR, 'images');

const revManifest = {};

const JED_OPTIONS_EN = {
  domain: 'mb_server',
  locale_data: {
    mb_server: {'': {}},
  },
};

function writeResource(stream) {
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
          return canonicalJSON(_.assign(revManifest, contents));
        },
      },
    }))
    .pipe(gulp.dest(BUILD_DIR))
    .on('finish', function () {
      deferred.resolve();
    });

  return deferred.promise;
}

function buildStyles(callback) {
  return writeResource(
    gulp.src([
      path.resolve(STYLES_DIR, 'common.less'),
      path.resolve(STYLES_DIR, 'icons.less'),
      path.resolve(STYLES_DIR, 'statistics.less'),
    ], {base: STATIC_DIR})
    .pipe(less({
      rootpath: '/static/',
      relativeUrls: true,
      plugins: [
        new (require('less-plugin-clean-css'))({compatibility: 'ie8'})
      ]
    }))
  ).done(callback);
}

function transformBundle(bundle) {
  const DBDefs = require('./scripts/common/DBDefs');

  bundle.transform('babelify');
  bundle.transform('envify', {global: true});

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

  return bundle;
}

function runYarb(resourceName, callback) {
  const DBDefs = require('./scripts/common/DBDefs');

  if (CACHED_BUNDLES[resourceName]) {
    return CACHED_BUNDLES[resourceName];
  }

  const vinyl = new File({
    base: STATIC_DIR,
    path: path.resolve(SCRIPTS_DIR, resourceName),
  });
  vinyl.contents = fs.createReadStream(vinyl.path);

  var bundle = transformBundle(yarb(vinyl, {
    debug: DBDefs.DEVELOPMENT_SERVER,
  }));

  if (callback) {
    callback(bundle);
  }

  CACHED_BUNDLES[resourceName] = bundle;
  return bundle;
}

function bundleScripts(b, resourceName) {
  return b.bundle().on('error', console.log).pipe(source('scripts/' + resourceName));
}

function writeScript(b, resourceName) {
  return writeResource(bundleScripts(b, resourceName));
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

function buildScripts() {
  const DBDefs = require('./scripts/common/DBDefs');

  process.env.NODE_ENV = DBDefs.DEVELOPMENT_SERVER ? 'development' : 'production';

  var commonBundle = runYarb('common.js');

  // The client JS needs access to rev-manifest.json too. We obviously can't
  // know its contents yet. So, create an empty Vinyl whose path is set to
  // rev-manifest.json. Yarb will use this instead of attempting to read that
  // path from disk. Later, once the `revManifest` object is populated, we
  // can set the contents buffer on this currently-empty Vinyl.
  const manifestContents = new File({
    path: path.resolve(BUILD_DIR, 'rev-manifest.json'),
    contents: null,
  });

  const manifestBundle = runYarb('rev-manifest.js');
  commonBundle.external(manifestBundle);

  _((DBDefs.MB_LANGUAGES || '').replace(/\s+/g, ''))
    .split(',')
    .compact()
    .without('en')
    .map(langToPosix)
    .transform(function (result, lang) {
      var srcPo = shellQuote.quote([findObjectFile('mb_server', lang, 'po')]);
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

      result[lang] = po2json.parseFileSync(tmpPo, {format: 'jed1.x', domain: 'mb_server'});

      fs.unlinkSync(tmpPo);
    }, {})
    .assign({en: JED_OPTIONS_EN})
    .each(function (jedOptions, lang) {
      var bundle = transformBundle(yarb().expose(createLangVinyl(lang, jedOptions), 'jed-data'));
      commonBundle.external(bundle);
      writeScript(bundle, 'jed-' + lang + '.js');
    })
    .value();

  var editBundle = runYarb('edit.js', function (b) {
    b.external(commonBundle);
  });

  var editNotesReceivedBundle = runYarb('edit/notes-received.js', function (b) {
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

  var votingBundle = runYarb('voting.js', function (b) {
    b.external(commonBundle);
  });

  var workBundle = runYarb('work.js', function (b) {
    b.external(editBundle).external(guessCaseBundle);
  });

  return Q.all([
    writeScript(commonBundle, 'common.js'),
    writeScript(editBundle, 'edit.js'),
    writeScript(editNotesReceivedBundle, 'edit-notes-received.js'),
    writeScript(guessCaseBundle, 'guess-case.js'),
    writeScript(placeBundle, 'place.js'),
    writeScript(releaseEditorBundle, 'release-editor.js'),
    writeScript(seriesBundle, 'series.js'),
    writeScript(statisticsBundle, 'statistics.js'),
    writeScript(timelineBundle, 'timeline.js'),
    writeScript(urlBundle, 'url.js'),
    writeScript(votingBundle, 'voting.js'),
    writeScript(workBundle, 'work.js'),
    writeScript(runYarb('debug.js', function (b) {
      b.external(commonBundle);
    }), 'debug.js')
  ]).then(function () {
    manifestContents.contents = new Buffer(canonicalJSON(revManifest));

    // Note that writeResource will change the contents of revManifest, and
    // write a new rev-manifest.json, before we write our bundled version with
    // the contents above. This is okay, because the client will never need
    // to lookup "rev-manifest.js". It'll be included on every page by the
    // server, which'll have access to the final rev-manifest.json on disk.
    return writeScript(manifestBundle, 'rev-manifest.js');
  });
}

function buildImages() {
  return Q.all([
    writeResource(gulp.src(path.join(IMAGES_DIR, 'entity/*'), {base: STATIC_DIR})),
    writeResource(gulp.src(path.join(IMAGES_DIR, 'icons/*'), {base: STATIC_DIR})),
    writeResource(gulp.src(path.join(IMAGES_DIR, 'image404-125.png'), {base: STATIC_DIR})),
    writeResource(gulp.src(path.join(IMAGES_DIR, 'layout/*'), {base: STATIC_DIR})),
    writeResource(gulp.src(path.join(IMAGES_DIR, 'licenses/*'), {base: STATIC_DIR})),
    writeResource(gulp.src(path.join(IMAGES_DIR, 'logos/*'), {base: STATIC_DIR})),
  ]);
}

gulp.task('watch', ['default'], function () {
  let watch = require('gulp-watch');

  watch(path.resolve(STATIC_DIR, '**/*.less'), function () {
    process.stdout.write('Rebuilding styles ... ');

    buildStyles(function () {
      process.stdout.write('done.\n');
    });
  });

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
      process.stdout.write(`Rebuilding ${resourceName} (${file.event}: ${file.path}) ... `);
      writeScript(b, resourceName).done(function () {
        process.stdout.write('done.\n');
      });
    }
  }

  watch(path.resolve(SCRIPTS_DIR, '**/*.js'), function (file) {
    _.each(CACHED_BUNDLES, function (bundle, resourceName) {
      rebundle(bundle, resourceName, file);
    });
  });
});

gulp.task('tests', function () {
  process.env.NODE_ENV = 'development';

  return bundleScripts(
    runYarb('tests/browser-runner.js', function (b) {
      b.expose(createLangVinyl('en', JED_OPTIONS_EN), 'jed-data');
    }),
    'tests.js'
  ).pipe(gulp.dest(BUILD_DIR));
});

gulp.task('default', function () {
  // Scripts cannot be built without images or styles. The client JS needs
  // access to the final paths for these resources.
  return Q.all([buildImages(), buildStyles()]).then(buildScripts);
});
