
Introduction
============

This file contains specific instructions that apply mostly or exclusively
to the MusicBrainz production servers.

Updating Docker files after cpanfile modifications
=======

If you modify the cpanfile, especially if you add new packages to it,
you will also need to update the files used to build Docker images.

The first step is to generate a new `cpanfile.snapshot`. To do this, assuming
you have a Docker service running, run:

    $ ./docker/generate_cpanfile_snapshot.sh 

Generating the snapshot will take quite a while. Once it is done, commit it
and push it.

Then you will need to create a Docker `musicbrainz-tests` image. This step
also takes quite a while, so you might want to consider running it inside a
MetaBrainz server to make it faster. In any case, inside a musicbrainz-server
checkout running the updated branch, you should run (note the dot at the end):

    $ docker build --tag metabrainz/musicbrainz-tests:v-YYYY-MM --file docker/Dockerfile.tests .

Then log into Docker Hub with `docker login` (the credentials are in the
syswiki repo) and push the created image to Docker Hub:

    $ docker push metabrainz/musicbrainz-tests:v-YYYY-MM

Finally, you will need to update [.circleci/config.yml](.circleci/config.yml),
update the listed `musicbrainz-tests` image version and push the changes.
