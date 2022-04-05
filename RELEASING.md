# MusicBrainz Server release process

> Preamble:
> This document covers steps for releasing new versions of MusicBrainz Server
> which is performed by maintainers only.
> It includes discussion about private servers, repositories and tools which
> other contributors don’t have access to.
> It is made public for transparency and to allow for improvement suggestions.

## Table of contents

<!-- toc -->

- [Prerequisites](#prerequisites)
- [Release production](#release-production)
  * [Update translated messages](#update-translated-messages)
  * [Merge Git branches](#merge-git-branches)
  * [Build Docker images](#build-docker-images)
  * [Announce the deployment](#announce-the-deployment)
  * [Deploy to production](#deploy-to-production)
  * [Update websites’ banner](#update-websites-banner)
  * [Update Jira](#update-jira)
  * [Blog](#blog)
  * [Add Git tag](#add-git-tag)
  * [Release musicbrainz-docker](#release-musicbrainz-docker)
- [Release beta](#release-beta)
- [Update test](#update-test)

<!-- tocstop -->

## Prerequisites

1. Perl module Locale::PO

   For updating translations, also part of `production` server features in `cpanfile`.

2. Transifex client

   See the section “[Translations](INSTALL.md#translations)” of the installation documentation.

See the private system administration wiki for additional prerequisites.

## Release production

### Update translated messages

Assuming the source messages were updated when releasing beta (if not, see that under the beta
process below first!), you need to start by updating the translated messages:

1. Run `./po/update_translations.sh --commit` to download the latest .po files
   from Transifex and commit them to the `beta` branch.

### Merge Git branches

1. Merge `beta` to `production` (`git merge --log=876423 --no-ff beta`) and push.
   Wait until [CircleCI](https://circleci.com/gh/metabrainz/musicbrainz-server) and
   [Jenkins (Selenium)](https://ci.metabrainz.org/job/musicbrainz-server/) are happy
   with this merge.

2. Merge `production` to `master` (`git merge --log=876423 --no-ff production`) and push.

### Build Docker images

Then, you must build new MusicBrainz Server Docker images from Jenkins:

1. Go to https://ci.metabrainz.org/job/musicbrainz-docker-images/

2. “Build with Parameters” (in the left), and enter `production` for _IMAGE_BRANCH_.

A build can take some time (from a few minutes to half an hour).
Once the image is built you can begin the deployment.

### Announce the deployment

Because any deployment may cause issues for MusicBrainz users and MetaBrainz staff,
each deployment should be announced through the IRC channel and the website’s banner.

[Set the banner message](https://musicbrainz.org/admin/banner/edit) to

```html
MusicBrainz servers are being updated, slowdowns may occur for a few minutes, thanks for your patience.
```

### Deploy to production

See the private system administration wiki for instructions.

### Update websites’ banner

Then [unset the banner message on the main website](https://musicbrainz.org/admin/banner/edit)
and [set the banner message on beta](https://beta.musicbrainz.org/admin/banner/edit) to

```html
Beta website is currently the same as the main website, nothing to be tested for now.
```

### Update Jira

Now that you have done the release, you will need to update Jira:

1. Make sure a new release version is present in the
   [Jira project administration panel](https://tickets.metabrainz.org/projects/MBS?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page).

2. Close all tickets
   [`status = "In Beta Testing" and project = MBS`](http://tickets.musicbrainz.org/secure/IssueNavigator.jspa?reset=true&jqlQuery=status+%3D+%22In+Beta+Testing%22+and+project+%3D+mbs)
   as "Fixed."

3. Make sure all the tickets have a type that makes sense, enough information
   to be understandable, and the appropriate components set.

4. Release the current version. All open tickets should be moved to the next
   version.

5. Archive any previous versions still marked as "Released", except for
   the latest schema change release.

### Blog

[Create a new draft from the template](https://wordpress.com/post/blog.metabrainz.org?jetpack-copy=8634).
The list of tickets can be copied from the auto-generated release notes,
by going to the [Releases](http://tickets.musicbrainz.org/browse/MBS#selectedTab=com.atlassian.jira.plugin.system.project%3Aversions-panel) tab,
selecting the version you just released,
and clicking “Release Notes” in the top.

Move sub-tasks of MBS-8609 to the “React Conversion Task” section at the end,
and move other sub-tasks under the “Other Task” section (rename to just “Task”
if there are no React conversion tasks in this release).

Thank reporters of each addressed issue at least, and every other
contributor/tester/translator if possible, but contractors.

Once the draft has been reviewed, publish it, then update the description of the Jira version with the blog post URL.

### Add Git tag

You should tag production releases by using `./script/tag.sh`, which will ask you
the necessary questions. Skip this step if you're releasing beta or test.

### Release musicbrainz-docker

1. Update the current MB version in the musicbrainz-docker repository. See example commit <https://github.com/metabrainz/musicbrainz-docker/commit/83da2d3602030da9596a8899513ccda11498f077>.

2. Tag the release (`git tag -u CE33CF04 $version_number -m 'Upgrade MusicBrainz Server.'`) and push.

3. Do a git release of name `$version_number` (copy the structure from previous [releases](https://github.com/metabrainz/musicbrainz-docker/releases)).

4. Release the appropriate [Jira version](https://tickets.metabrainz.org/projects/MBVM?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page);
   as its description, set the git release URL (https://github.com/metabrainz/musicbrainz-docker/releases/tag/$version_number).
   Archive the previous non-schema change releases, if not yet archived. Create a new version
   for the next expected release, with the description "next release".

5. Edit the blog post to link to the new musicbrainz-docker release.

## Release beta

It has some differences with the production release process; follow these steps:

1. On the translations update step, do not just update translated messages,
   also update source messages for translation. This involves four steps:

   1. Run `./po/update_translations.sh --commit` to download the latest .po files
      from Transifex and commit them to the `master` branch

   2. Run `./po/update_pot.sh` to generate new .pot files from the
      database and templates. It's often a good idea to manually check
      the changes to the .pot files: this is a good moment to find typos
      that were missed during code review, or small changes to lines that
      don't seem useful enough to justify breaking the existing translations.
      If you find any of these, you might want to correct the issues and
      generate the files again. Once you're done, commit the changes.

   3. Push the `.pot` files generated in step 2 to Transifex. To push only the
      ones that changed, give a comma-separated list:

      ```sh
      cd po/
      tx push -s -r musicbrainz.server,musicbrainz.instruments
      ```

      If you want to push languages, keep in mind you need to push
      `musicbrainz.languages-9` (not `musicbrainz.languages`).

   4. Push the commits from steps 1 & 2 to `master`.

2. On the git branches merge step, to update the `beta` branch with the changes from the `master` branch,
   merge `master` into `beta` (with `git merge --log=876423 --no-ff master`) and push to `beta`.
   (Skip this, of course, if you're just deploying changes pushed directly to the `bet`a branch.)

3. On the [build Docker images step](#build-docker-images),
   enter `beta` for _IMAGE_BRANCH_ when doing “Build with Parameters”.
   Wait until the build has completed.

4. On the [deployment’s announcement step](#announce-the-deployment),
   [set the banner message on beta](https://beta.musicbrainz.org/admin/banner/edit) to

   ```html
   Beta website is being updated, slowdowns may occur for a few minutes, thanks for your patience.
   ```

5. On the [deployment step](#deploy-to-production) itself,
   run `./script/update_containers.sh beta`. Wait until the deployment has completed.

   Notes:
   - Background task runners follow the `production` branch only,
     which means that new reports are not available on the beta website for now.
   - The banner’s website is updated only after updating tickets; see below.

6. On the [Jira step](#update-jira), set all the tickets
   [`status = "In Development Branch" and project = MBS`](http://tickets.musicbrainz.org/secure/IssueNavigator.jspa?reset=true&jqlQuery=status+%3D+%22In+Development+Branch%22+and+project+%3D+mbs)
   as status "In Beta Testing." For tickets which fixed a beta-only issue not
   present in production, close the ticket as fixed and set the fix version
   to "Beta." Make sure all the tickets have a type that makes sense, enough information
   to be understandable, and the appropriate components set.

   Notes: None of the following steps are involved in releasing beta:
   - Blog
   - Add git tag
   - Release `musicbrainz-docker`

7. Again, [set the banner message on beta](https://beta.musicbrainz.org/admin/banner/edit) to

   ```html
   Beta MusicBrainz Server has been updated on Month DD, see the list of <a href="https://tickets.metabrainz.org/issues/?filter=10715">tickets available for beta testing</a>.
   ```
## Update test

Unlike production and beta, test is more flexible:
- The `test` branch is not protected and can be force-pushed,
  even though you have to check in with other developers that may be using it.
- The `test.musicbrainz.org` website does not use the production database,
  which means that background tasks can be tested too
  and that potential data loss is not an issue,
  but it might require to recreate the test database for schema changes.

1. Skip the translations; and instead of merging branches do as follows:
   - Either cherry-pick the commits you want to test to the `test` branch and push;
   - Or reset the `test` branch to the branch you want to test and force-push.

2. Then on the [build Docker images step](#build-docker-images),
   enter `test` for _IMAGE_BRANCH_ when doing “Build with Parameters”.

3. On the [deployment step](#deploy-to-production),
   just run `./script/update_containers.sh test`.
   Note that only webservice and website can be deployed in test,
   but background tasks can be manually run from these if needed.
