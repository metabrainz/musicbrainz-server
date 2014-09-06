var concat          = require("gulp-concat"),
    extend          = require("extend"),
    fs              = require("fs"),
    glob            = require("glob"),
    gulp            = require("gulp"),
    rev             = require("gulp-rev"),
    through2        = require("through2"),

    commentOrEmpty  = /^(\s*$|#)/,
    trailingSlash   = /\/$/,
    manifestName    = /^([a-z\-]+)\.(js|css)\.manifest$/,
    revManifestPath = "./root/static/build/rev-manifest.json",
    revManifest     = {};

if (fs.existsSync(revManifestPath)) {
    revManifest = JSON.parse(fs.readFileSync(revManifestPath));
}

function unlinkFile(file) {
    // Synchronous so that we don't remove files that haven't changed
    fs.unlinkSync(file);
}

function unlinkFiles(error, files) {
    files.forEach(unlinkFile);
}

function buildManifest(fileType, compile, options) {
    return through2.obj(function (chunk, encoding, callback) {
        var globs = [], lines = chunk.contents.toString("utf8").split("\n");

        lines.forEach(function (line) {
            if (!commentOrEmpty.test(line)) {
                line = "./root/static/" + line;

                if (trailingSlash.test(line)) {
                    globs.push(line + "**/*." + fileType);
                } else {
                    globs.push(line);
                }
            }
        });

        gulp.src(globs)
            .pipe(compile(options))
            .pipe(concat(chunk.relative.replace(manifestName, "$1.$2")))
            .pipe(rev())
            .pipe(gulp.dest("./root/static/build/"))
            .pipe(rev.manifest())
            .pipe(through2.obj(function (chunk, encoding, callback) {
                extend(revManifest, JSON.parse(chunk.contents));

                fs.writeFileSync(revManifestPath, JSON.stringify(revManifest));

                callback();
            }));

        callback();
    });
}

gulp.task("styles", function () {
    glob.sync("./root/static/build/*.css", unlinkFiles);

    return gulp.src("./root/static/*.css.manifest")
        .pipe(
            buildManifest(
                "less",
                require("gulp-less"),
                {
                    rootpath: "/static/",
                    compress: true,
                    relativeUrls: true
                }
            )
        );
});

gulp.task("scripts", function () {
    glob.sync("./root/static/build/*.js", unlinkFiles);

    return gulp.src("./root/static/*.js.manifest")
        .pipe(
            buildManifest(
                "js",
                require("gulp-uglify"),
                {
                    preserveComments: "some",
                    output: { max_line_len: 256 }
                }
            )
        );
});

gulp.task("default", ["styles", "scripts"]);
