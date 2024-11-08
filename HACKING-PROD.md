
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

Generating this new snapshot will often install the latest version of Chrome,
which will require updating the version of ChromeDriver installed through
[docker/Dockerfile.tests](docker/Dockerfile.tests). Check the appropriate
version of ChromeDriver for the new version of Chrome from
https://chromedriver.chromium.org/downloads and modify the Dockerfile
accordingly.
