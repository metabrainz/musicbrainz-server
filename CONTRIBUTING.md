# Contributing to MusicBrainz Server

Thank you for considering contributing to MusicBrainz Server.

Get started with <https://musicbrainz.org/doc/Development> first,
then continue reading the additional guidelines below.

Some more general guidelines (not complete yet) are available at
<https://github.com/metabrainz/guidelines/> too.

## Submitting changes

### Commit message

Please follow the generally accepted [seven rules of a great Git
commit message](https://chris.beams.io/posts/git-commit/#seven-rules):

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain _what_ and _why_ vs. _how_

Additionally, start the subject line with a ticket reference if applicable.

### Pull request

#### Ticket

If your change is large or relevant to users, it should have a ticket
in [our issue tracker](https://tickets.metabrainz.org/browse/MBS).
Create one if necessary.
Reference it with its key `MBS-XXX`.
It will be used to follow the progress of the change and to generate
the release notes that are made available to users on the blog.

Untracked changes are typos, comments, coding style changes, automated
dependency updates, unnoticeable refactoring, and so on.

#### Title

Describe your change with a short imperative title, e.g.

> Change small unnoticeable bits

If your change resolves a ticket (see [above](#ticket)), please make sure you
prefix your pull request title with `MBS-XXX: ` in order for our issue tracker
to link your pull request to that ticket, e.g.

> MBS-1234567: Change things relevant to users

If it **partially resolves** a ticket, use parenthesis, e.g.

> MBS-1234567 (I): Make first part of needed changes

If your change relate to **several tickets**, separate these with commas, e.g.

> MBS-1234567, MBS-2345678: Change two related things at once

#### Comment

Just follow our [pull request template](.github/PULL_REQUEST_TEMPLATE.md).

If your change relates to a ticket, make sure to mention it in the comment, e.g.

```Markdown
# Summary

Fix MBS-1234567: Change things relevant to users
```
