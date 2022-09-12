#!/usr/bin/env bash

# Explanatory production notes:
#
# Building webpack/server.config.mjs is necessary in order to generate
# *.css files in the Docker image, which are extracted from the image
# in a Jenkins job and synced to a static resources volume on our gateway
# servers.
#
# Building the server-side JS requires a DBDefs file, though, and one isn't
# available when building the image.  Our production DBDefs files are stored
# in a private repository and copied into the containers at runtime.
#
# Since the .less files aren't affected by any specific DBDefs configuration,
# and because the server JS is rebuilt anyway after the container starts, we
# can temporarily use the sample DBDefs file in the repository to allow the
# CSS to build into the image, and then remove the useless server JS files
# which contain sample configuration.

cp lib/DBDefs.pm.sample lib/DBDefs.pm

carton exec -- ./script/compile_resources.sh

rm -f \
    lib/DBDefs.pm \
    root/static/build/{jed-*.source.js,server.js}
