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

gulp.task("clean", function () {
    var fileRegex = /^([a-z\-]+)-[a-f0-9]+\.(js|css)$/,
        existingFiles = fs.readdirSync("./root/static/build/");

    existingFiles.forEach(function (file) {
        if (file !== "rev-manifest.json" && revManifest[file.replace(fileRegex, "$1.$2")] !== file) {
            fs.unlinkSync("./root/static/build/" + file);
        }
    });

    Object.keys(revManifest).forEach(function (key) {
        if (!fs.existsSync("./root/static/" + key + ".manifest")) {
            delete existingFiles[key];
        }
    });

    fs.writeFileSync(revManifestPath, JSON.stringify(revManifest));
});

gulp.task("default", ["styles", "scripts"]);
