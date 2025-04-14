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
  * [Prepare Jira](#prepare-jira)
  * [Update translated messages](#update-translated-messages)
  * [Draft blog post](#draft-blog-post)
  * [Merge Git branches](#merge-git-branches)
  * [Add Git tag](#add-git-tag)
  * [Build Docker images](#build-docker-images)
  * [Announce the deployment](#announce-the-deployment)
  * [Deploy to production](#deploy-to-production)
  * [Update websites’ banner](#update-websites-banner)
  * [Update Jira](#update-jira)
  * [Blog](#blog)
  * [Release musicbrainz-docker](#release-musicbrainz-docker)
- [Release beta](#release-beta)
- [Update test](#update-test)

<!-- tocstop -->

## Prerequisites

1. Perl module Locale::PO

   For updating translations, also part of `production` server features in `cpanfile`.

See the private system administration wiki for additional prerequisites.

The Git remote `origin` is assumed to point at `https://github.com/metabrainz/musicbrainz-server.git`.

## Release production

### Prepare Jira

Those steps should be followed when releasing beta, and then double-checked when releasing production.

1. Make sure a version with status “Unreleased”, usually named “next”, is present in the
   [Jira MBS project administration panel](https://tickets.metabrainz.org/projects/MBS?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page). Its serial ID will be used for tagging the branch `production` in Git.

2. Make sure that the field “Fix Version” is set to this version for all the
   [tickets in beta testing](http://tickets.musicbrainz.org/secure/IssueNavigator.jspa?reset=true&jqlQuery=status+%3D+%22In+Beta+Testing%22+and+project+%3D+mbs). If needed, use “Tools”, “Bulk Change”, “Edit Issues”, without “Send mail for this update”.

3. Make sure that all of these tickets also have:

   * A “type” that makes sense;
   * A “summary” that makes sense for the type, and is clear even in a list that does not include other fields;
   * A “description” that explains the why and the how, the situation before and after;
   * The appropriate “components” and “labels” set.

   (It is fairly common to have to update both summary and description after implementation.)

### Update translated messages

Assuming the source messages were updated when releasing beta (if not, see that under the beta
process below first!), you need to start by updating the translated messages:

1. From the [repository in Weblate](https://translations.metabrainz.org/projects/musicbrainz/#repository):

   1. If there are any “Pending changes”, “Commit” those and wait a bit before reloading the page.

   2. If there are any commits “missing in the push branch”, “Push” those and wait (some more time) before reloading the page.

   3. If there are any “missing commits” from “upstream” (beta branch), “Update” the “Weblate repository” and wait (even longer) before reloading the page.

2. Update your local `translations` branch and merge it to `beta` and push as follows:
   ```sh
   git fetch origin && \
   git checkout origin/translations -B translations && \
   git checkout beta && \
   git merge --log=876423 --no-ff translations && \
   git push
   ```
   Wait until [GitHub Actions](https://github.com/metabrainz/musicbrainz-server/actions/) is happy
   with this merge as some unmatching translations can break building Docker images.

   :bricks: While waiting you can pre-empt [drafting blog post](#draft-blog-post)!

### Draft blog post

[Create a new draft from the template](https://wordpress.com/post/blog.metabrainz.org?jetpack-copy=8634).
The list of tickets can be copied from the auto-generated release notes,
by going to the [Releases](http://tickets.musicbrainz.org/browse/MBS#selectedTab=com.atlassian.jira.plugin.system.project%3Aversions-panel) tab,
selecting the version you are going to release,
and clicking “Release Notes” in the top.

If there are any React conversion tasks
(which should be sub-tasks of [MBS-8609](https://tickets.metabrainz.org/browse/MBS-8609)),
move these to the section “React Conversion Task” at the end,
and move other (sub-)tasks under the section “Other Task”.
Otherwise, just put all the tasks under a unique section “Task”.

Last but not least, thank (in order of rarity):
* code contributors, who can be listed with `./script/list_code_contributors`,
* translators, who can be listed with `./po/list_translators`,
* reporters of each addressed issue at least,
  and every other constructive feedback providers if possible:
  * reporters of [tickets addressed in beta](https://tickets.metabrainz.org/issues/?filter=10715&jql=project%20%3D%20MBS%20AND%20status%20%3D%20%22In%20Beta%20Testing%22%20ORDER%20BY%20reporter%20ASC%2C%20type%2C%20key)
  * reporters of [tickets about beta](https://tickets.metabrainz.org/issues/?jql=project%20%3D%20MBS%20AND%20%28summary%20~%20Beta%20OR%20fixVersion%20%3D%20Beta%29%20AND%20created%20%3E%3D%20-2weeks%20ORDER%20BY%20reporter%20ASC) (assuming a two weeks cycle)
  * especially good comment authors if possible (using the same lists ordered by “Watchers” to find the most popular tickets, see also pull requests)

(Avoid thanking ourselves, contractors.)

### Merge Git branches

1. Merge `beta` to `production` (`git merge --log=876423 --no-ff beta`) and push.
   Wait until [GitHub Actions](https://github.com/metabrainz/musicbrainz-server/actions/)
   is happy with this merge.

   :bricks: While waiting you can pre-empt [drafting Docker Compose release notes](#release-musicbrainz-docker)!

2. Merge `production` to `master` (`git merge --log=876423 --no-ff production`) and push.

### Add Git tag

You should tag production releases by using `./script/tag.sh`, which will ask you
the necessary questions. Skip this step if you're releasing beta or test.

### Build Docker images

Then, you must build new MusicBrainz Server Docker images from Jenkins:

1. Go to https://ci.metabrainz.org/job/musicbrainz-docker-images/

2. “Build with Parameters” (in the left), and enter `production` for _IMAGE_BRANCH_.

A build can take some time (from a few minutes to half an hour).
Once the image is built you can begin the deployment.

:bricks: While waiting you can pre-empt [building Docker image for mirrors](#release-musicbrainz-docker)!

### Announce the deployment

Because any deployment may cause issues for MusicBrainz users and MetaBrainz staff,
each deployment should be announced through the chat and the website’s banner.

[Set the banner message](https://musicbrainz.org/admin/banner/edit) to

```html
MusicBrainz servers are being updated, slowdowns may occur for a few minutes, thanks for your patience.
```

Also drop a line about it to the MusicBrainz community in ChatBrainz.

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

1. Edit the unreleased version “next” in the
   [Jira MBS project administration panel](https://tickets.metabrainz.org/projects/MBS?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page) to set the field “Release date” to the current date and the field “Name” also to the current date (or to “Schema Change, Year Q#” for schema change release).

2. Close all the 
   [tickets in beta testing](http://tickets.musicbrainz.org/secure/IssueNavigator.jspa?reset=true&jqlQuery=status+%3D+%22In+Beta+Testing%22+and+project+%3D+mbs)
   as “Fixed”.

3. Create a new version named “next” with “TBD” as description.

4. “Release” the current version. Any tickets remaining in this version and
   having a status other than “Closed” should be moved to the version “next”.

5. “Archive” any previous versions still marked as “Released”, except for
   the latest schema change release.

### Blog

Assuming that you [drafted a blog post](#draft-blog-post) already,
just make sure to update the following if any changes occurred:

* Tickets’ title and type
* Acknowledgments (including translators and beta reporters)

To do so, you can adapt the draft section with:
* appending a Git revision range `v-prev-io-us..v-curr-en-t`
  to the listing commands (see `--help` for details),
* replacing some condition with
  `fixVersion = ` _the current version_
  in the Jira queries.

Once the draft has been reviewed, then update the description of the MBS version in Jira with the blog post URL.
This URL will also be used in the following section.
The blog post will be published only after that.

### Release musicbrainz-docker

In your clone of [MusicBrainz’s Docker Compose project](https://github.com/metabrainz/musicbrainz-docker):

1. Update the version of MusicBrainz Server to dockerize.
   See example commit <https://github.com/metabrainz/musicbrainz-docker/commit/a0930848751a9b923e8c7261f2ff2904af2577ec>.
   See also prerequisites from `admin/repository/prebuild-musicbrainz --help`.

   Check files under `build/musicbrainz/` and `build/musicbrainz-dev/` and update those if needed.
   It can usually be needed when changing `DBDefs`, dependencies, or scripts in MusicBrainz Server.

2. Build, tag and push Docker image for mirrors using the script `admin/repository/prebuild-musicbrainz`

3. Manually test running a mirror with this image.
   (Test development setup too if there is any change to it.)

4. Tag your local Git branch `master` (`git tag -u CE33CF04 $version_number -m 'Upgrade MusicBrainz Server.'`)
   and push both the commits and the tag.

5. Draft a GitHub release of name `$version_number` (copy the structure from previous [releases](https://github.com/metabrainz/musicbrainz-docker/releases)).

6. Release the appropriate [Jira version](https://tickets.metabrainz.org/projects/MBVM?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page);
   as its description, set the GitHub release URL (`https://github.com/metabrainz/musicbrainz-docker/releases/tag/$version_number`).
   Archive the previous non-schema change releases, if not yet archived. Create a new version
   for the next expected release, with the description “TBD”.

7. Edit the blog post to link to the new musicbrainz-docker release.

8. Publish both the blog post and the musicbrainz-docker release.

## Release beta

It has some differences with the production release process; follow these steps:

1. On the [prepare Jira](#prepare-jira) step, it might take some more time
   to update tickets than for production release when everything is ready.

2. On the [translations update](#update-translated-messages) step,
   start with following the exact same two steps (more detailed above):

   1. “Commit” any pending change, “push” any missing commit to downstream, and “update” any missing commit from upstream, all from the
      [repository in Weblate](https://translations.metabrainz.org/projects/musicbrainz/#repository).

   2. Update your local `translations` branch and merge it to `beta` and push.

   Then additionally update source messages for translation as follows:

   3. On `master` (or `beta` if changes have been pushed directly there),
      run `./po/update_pot.sh` to generate new .pot files from the
      database and templates. It's often a good idea to manually check
      the changes to the .pot files: this is a good moment to find typos
      that were missed during code review, or small changes to lines that
      don't seem useful enough to justify breaking the existing translations.
      If you find any of these, you might want to correct the issues and
      generate the files again. Once you're done, commit the changes and push.
      Keep in mind Weblate is following `*.pot` files from the `beta` branch;
      if you updated `master` here then `beta` will be updated
      in the next step.

3. On the git branches merge step, to update the `beta` branch with the changes from the `master` branch,
   merge `master` into `beta` (with `git merge --log=876423 --no-ff master`) and push to `beta`.
   (Skip this, of course, if you're just deploying changes pushed directly to the `beta` branch.)

4. On the [build Docker images step](#build-docker-images),
   enter `beta` for _IMAGE_BRANCH_ when doing “Build with Parameters”.
   Wait until the build has completed.

5. On the [deployment’s announcement step](#announce-the-deployment),
   [set the banner message on beta](https://beta.musicbrainz.org/admin/banner/edit) to

   ```html
   Beta website is being updated, slowdowns may occur for a few minutes, thanks for your patience.
   ```

   Also drop a line about it to the MusicBrainz community in ChatBrainz.

6. On the [deployment step](#deploy-to-production) itself,
   run `./script/update_containers.sh beta`. Wait until the deployment has completed.

   Notes:
   - Background task runners follow the `production` branch only,
     which means that new reports are not available on the beta website for now.
   - The banner’s website is updated only after updating tickets; see below.

7. On the [Jira step](#update-jira), transition all the
   [tickets marked as in development branch](http://tickets.musicbrainz.org/secure/IssueNavigator.jspa?reset=true&jqlQuery=status+%3D+%22In+Development+Branch%22+and+project+%3D+mbs)
   to the status “In Beta Testing”. For tickets which fixed a beta-only issue not
   present in production, close the ticket as fixed and set the field “Fix Version”
   to “Beta”. Make sure all the tickets have a type that makes sense, enough information
   to be understandable, and the appropriate components and labels set.

   Notes: None of the following steps are involved in releasing beta:
   - Blog
   - Add git tag
   - Release `musicbrainz-docker`

8. Again, [set the banner message on beta](https://beta.musicbrainz.org/admin/banner/edit) to

   ```html
   Beta MusicBrainz Server has been updated on Month DD, see the list of <a href="https://tickets.metabrainz.org/issues/?filter=10715">tickets available for beta testing</a>.
   ```
## Update test

Unlike production and beta, test is more flexible:
- The `test` branch is not protected and can be force-pushed,
  but you should always check with the other developers to make sure they are not currently using it.
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
