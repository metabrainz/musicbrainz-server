
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

To rebuild the tests image, just update `TESTS_IMAGE_TAG` in
[.github/workflows/ci.yml](.github/workflows/ci.yml).
