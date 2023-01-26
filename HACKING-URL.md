The Developer’s Guide to implementing URL handlers in the MusicBrainz Server
============================================================================

This file describes how to implement specific handlers for external websites in
MusicBrainz Server to: allow linking to other databases and lyrics website,
make it easier to add links, prevent editor from entering wrong links,
improve the display of links on MusicBrainz website.

The easiest way to get started is probably to look at similar
[resolved MBS "URL cleanup" tickets](https://tickets.metabrainz.org/issues/?jql=project%20%3D%20MBS%20AND%20component%20%3D%20%22URL%20cleanup%22%20AND%20status%20%3D%20Closed%20AND%20resolution%20IN%20%28Done%2CFixed%29)
which have comments linking to pull requests. More particularly,
look at potential STYLE tickets linked to these MBS tickets,
and at the commit messages in the pull requests, and try to follow a similar process.
If any doubt, get back to this guide which should contain the answer.

Our URL handling has two main parts: editing handlers (unwanted URL block, URL
cleanup, relationship type autoselection, relationship validation), and
display handlers (with favicons, in relationship lists, in the sidebar).

Table of Contents
-----------------

<!-- toc -->

- [Prerequisites](#prerequisites)
- [URL editing handlers](#url-editing-handlers)
  * [Cleanup](#cleanup)
  * [Autoselection](#autoselection)
  * [Validation](#validation)
  * [Supporting new relationship types](#supporting-new-relationship-types)
  * [Entity-wide rules](#entity-wide-rules)
- [URL display handlers](#url-display-handlers)
  * [Favicons](#favicons)
  * [Sidebar display](#sidebar-display)
  * [Rendered scheme override](#rendered-scheme-override)
  * [Custom in-page display](#custom-in-page-display)
  * [Miscellaneous display customization](miscellaneous-display-customization)

<!-- tocstop -->

Prerequisites
-------------

Allowing to link external websites as
either [other databases](https://musicbrainz.org/doc/Other_Databases_Relationship_Type/Whitelist) (for persistence issues)
or [lyrics websites](https://musicbrainz.org/doc/Style/Relationships/URLs/Lyrics_whitelist) (for license issues)
must be approved by a STYLE decision beforehand.
See <https://musicbrainz.org/doc/Proposals>
for how to request such STYLE decision,
before even thinking about coding handlers.

Other relationship types don’t require any STYLE decision,
but having a self-assigned MBS ticket is still required.

The following research work is usually expected about external websites to be handled:

* Form and number of its URLs in the MusicBrainz database already;
  - Tip: For a first approximate count, you can query the MusicBrainz API about URLs with (approximate) patterns;
  - For example [`url:*/openlibrary.org/*`](https://musicbrainz.org/ws/2/url?query=url:*/openlibrary.org/*&limit=1&fmt=json) counts Open Library URLs (mainly).

* Mapping between patterns of its URLs and MusicBrainz entities with relationship type(s);
  - For example `/authors/` Open Library URLs match MusicBrainz artists.

* Potential alternative forms of its URLs;
  - For example `youtu.be/REF` is an alias for `www.youtube.com/watch?v=REF`.

* Potential query (`?...`) and fragment (`#...`);
  - For example `&list=...` is removed from YouTube video URLs taken from a playlist.

* Potential patterns to be blocked (search pages, unreliable URLs...);
  - For example `youtube.com/playlist` URLs are unwanted and blocked with a message.

* Rationale and real examples for all the above.

Expected behavior and rationale should be given in the ticket,
and implementation details in the pull request and commit messages.

It isn’t required to make a fine-grained implementation.
Sometimes it is even impossible because of URL patterns.

URL editing handlers
--------------------

Most of the handling of URLs, including all three of (URL) cleanup,
(relationship type) autoselect and (URL relationship) validation, happen on
[`root/static/scripts/edit/URLCleanup.js`](root/static/scripts/edit/URLCleanup.js).

For a new domain, you’ll generally want to add a new entry to the `CLEANUPS`
object. Use a descriptive key (often the domain name is the most clear, but
feel free to use the site name if it differs significantly from the domain).
The properties for `CLEANUPS` are documented on that file. You’ll always need
a `match` property with one or more regular expressions to actually match the
URLs, but all the others depend on what you’re trying to do, as described
below.

Make sure to add as many tests as useful to the tests file at
[`root/static/scripts/tests/Control/URLCleanup.js`](root/static/scripts/tests/Control/URLCleanup.js).
For more information about how to build each test, see the comment on that
file. You should at the very least test the main cleanup changes (add an
original URL that has the elements to be cleaned up and make sure it gets
cleaned up as expected), and any validation you’ve added (for example, if an
URL should only be allowed for releases, do add a test ensuring that the
restriction is working).

### Cleanup

If you want to clean up and standardize the URLs to a canonical version (for
example to avoid users adding slightly different duplicates) you’ll want a
`clean` property. This should be a function that takes the URL string,
modifies it (generally using regular expresions with `url.replace`) and then
returns it. Remember to check if the site has optional URL parameters at the
end of some URLs (often separated by ? or #); if so, you might want to remove
them during cleanup to avoid duplication.

### Autoselection

Autoselection of one or more relationship types is generally done using
the `restrict` property. This sets what are the allowed relationships or
relationship combinations for a URL that matches the `match` pattern. In most
cases this will be only one relationship type, or at least only one
relationship type per entity type. In a few cases, it can be a specific *set*
of two or more relationships. All these cases will automatically be
autoselected for the user, since there’s only one valid possibility. In some
cases though there will be several valid possibilities and the user will be
left to choose the correct one (for example, a Bandcamp link can be a
streaming page, a download page, or both, but we have no way to know without
the user’s input).

Different examples for the restrict property:
* `[LINK_TYPES.otherdatabases]`

    The `otherdatabases` type is valid for all allowed entities, and will be
    autoselected.

* `[multiple(LINK_TYPES.downloadfree, LINK_TYPES.streamingfree)]`

    Both types (`downloadfree` and `streamingfree`) are always valid for all
    allowed entities. Both will be autoselected.

* `[{...LINK_TYPES.review, ...LINK_TYPES.bandcamp, work: LINK_TYPES.lyrics.work}]`

    The different types here are valid for different entity types, so they
    do not clash; there’s no entity type with more than one option. As such,
    these will also always be autoselected. `lyrics` is also available for
    other entities, such as artists, but we do not want to allow these here;
    as such, we specifically pass only the work version of that relationship.

* `[LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid, multiple(LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid)]`

    There are three possibilities here: either only `downloadpurchase` and
    `streamingpaid`, or both at the same time. Since there’s more than one
    option for the same entity, nothing is autoselected here; the user will
    be presented with a dropdown offering both allowed relationship types (but
    none of the other, disallowed types).

In cases like the last one, where `restrict` allows for multiple options,
you can use the additional `select` property to specify that some of those
options *always* apply, and should still be autoselected. For example, you
could have a site that always allows to stream the music, but sometimes also
allows a download. In that case, you could pass `select` a function that
returns the appropriate `streamingpaid` relationship type for the entity in
question, but not the `downloadpurchase` one.

Note that `select` accepts the url and the entity type, and it returns
a specific type + entity combination. As such, you would need to make sure you
return `LINK_TYPES.streamingpaid.release` for releases, and so on.

### Validation

If you want to only allow certain URL variations for different relationship
and entity type combinations, you’ll need a `validate` property. For example,
you can use this to specify that pages in the domain containing `/artist`
can only be added to artists, `/label` to labels, and `/review` to release
groups, and that the first two can be added with the “discography page”
relationship but the third needs to use the “review” relationship.

This property is a function that takes the URL and (in most cases) the ID of
the relationship type being validated. The most common usage is to set a
`switch` with different cases for the possible supported relationship types,
and return whether each one is allowed or disallowed and based on what.
In some cases you might want to block a whole URL variation (for example,
a shortened version). In that case you can have a validation function
without ID.

The `validate` function returns a result object. This object has a mandatory
`result` property (a boolean, often the result of a comparison between URL
and prefix but sometimes hardcoded). It also allows for two optional
properties: `error` is a translatable error string specific to this case
(replaced by a default string if not present) and `target` is the level
at which the error should be placed (one of `ERROR_TARGETS.ENTITY`,
`ERROR_TARGETS.RELATIONSHIP` or `ERROR_TARGETS.URL`). Set the target to
whatever is most appropriate: errors where the URL is just not acceptable
at all should be set as `URL`, the ones where the URL would be valid for a
different entity type but not the selected one as `ENTITY`, and the ones where
the URL seems valid but the selected relationship is not as `RELATIONSHIP`.

### Supporting new relationship types

If you want to use a new relationship type that has recently been added, it
might not yet be available to use in `URLCleanup`. In that case, you’ll have
to add an entry to the `LINK_TYPES` object.

If the new relationship type is of the same kind as some already existing ones
then you just need to add a new `entity: mbid` pair to the appropriate
sub-object. Say there’s a new AllMusic relationship for labels: you’d add
`label: $new_type_mbid` to the existing `allmusic` object.

If the new relationship type does not match any of the existing blocks, just
add a new one, in the same format as the existing ones: the key should be
a sensible descriptor for the relationship type, and the value an object
containing `entity: mbid` pairs.

### Entity-wide rules

In some cases, you might not want to specifically match an URL to a
relationship type, but just reject it completely for a particular entity type.
For example, we have decided to completely disallow Wikipedia links to
releases, since those generally belong on the release group but users often
added them to releases using whatever relationship seemed the least bad fit.
We now block those links on releases *and* provide an error message that
explicitly asks the user to add them to the release group instead.

To do this, you will want to use `entitySpecificRules`. For each entity type,
`entitySpecificRules` will map to a function which can be used to reject
links. The function works similarly to `validate` in `CLEANUPS`, and returns
the same kind of error objects. If the entity type you want is not being used
in `entitySpecificRules` yet, just add a new `entitySpecificRules.entity_type`
function based on the existing ones.

URL display handlers
--------------------

### Favicons

For a favicon to be displayed by the URLs of the domain you are adding, you
should add the file as a PNG (preferably sized 32x32, but 16x16 is also
acceptable if that’s all you can find) to
[`root/static/images/external-favicons`](root/static/images/external-favicons).
Try to just extract the favicon directly from the site source code and convert
it as needed, unless the site officially provides the files for download.

For URLs to actually be mapped to the favicon you’ve added, you also
need to add the mapping to `FAVICON_CLASSES` in
[`root/static/scripts/common/constants.js`](root/static/scripts/common/constants.js).
Then add the favicon to the list in
[`root/static/styles/favicons.less`](root/static/styles/favicons.less):
use the favicon class you added in the previous step, and pass a second
argument `32` if the favicon file is 32x32 rather than 16x16.

### Sidebar display

:warning:
The MVC pattern is bent here as the names displayed for hyperlinks are coded in
the entity model layer. Plans are to address this issue tracked with the ticket
[MBS-10605](https://tickets.metabrainz.org/browse/MBS-10605).

For a domain to be displayed on the sidebar, you’ll need to create an URL model
in [`lib/MusicBrainz/Server/Entity/URL/`](lib/MusicBrainz/Server/Entity/URL/).
Base your model on any of the existing ones that are known to go by the same
types of relationship, and name it after the site in question.

The `sidebar_name` method most often returns a simple untranslated string,
the name of the site. You can also return a translated string, most often when:
* The name of the site has official localizations, for example `l(Niconico)`;
* The site is mainly about streaming, for example `l('Stream at YouTube Music')`;
* The site is about scores, even for just some paths, for example the more
  complex method in [IMSLP](lib/MusicBrainz/Server/Entity/URL/IMSLP.pm).

:warning:
The two latter cases are temporary fallbacks to the lack of display layout;
Instead plans are to smartly group external links by relationship type;
See [MBS-10605](https://tickets.metabrainz.org/browse/MBS-10605) again.

For your shiny new URL model to be actually used when loading URLs, you also
need to add the mapping to `%URL_SPECIALIZATIONS` in
[`MusicBrainz::Server::Data::URL`](lib/MusicBrainz/Server/Data/URL.pm).

### Rendered scheme override

There are mainly two reasons for overriding URL scheme (`http`/`https`) on
display:

If the external site supports both `http` and `https` schemes,
then override the method `url_is_scheme_independent` with `{ 1 }`
in the corresponding `Entity` model added for sidebar display.
That way, the URL scheme will match the scheme of the MusicBrainz Server
instance (`https` for `musicbrainz.org`, usually `http` for mirrors).
See [InternetArchive](lib/MusicBrainz/Server/Entity/URL/InternetArchive.pm) for example.

If the external site has dropped support for the `http` scheme or redirects from `http`
to `https`, but its URLs stored in the MusicBrainz database still use `http`
(either because they have not been updated yet,
or because the site has an official permalink format that uses `http`),
then override the method `href_url` to make the appropriate change;
That way, the URL scheme will be systematically overridden accordingly.
See [VIAF](lib/MusicBrainz/Server/Entity/URL/VIAF.pm) for example.

### Custom in-page display

All external links are shown under the “Relationships” tab of entity pages.

You will notice that a few selected websites (Amazon, IMSLP, VIAF, Wikidata...)
have a custom `pretty_name` for URL display here. These websites actually have
dedicated relationship types which names are used as label ahead of the URL so
that the identifier contained in the URL can be shown instead of the full URL.

So it is pointless to have a custom `pretty_name` for other websites.

### Miscellaneous display customization

See documentation comments in
[`lib/MusicBrainz/Server/Entity/URL.pm`](lib/MusicBrainz/Server/Entity/URL.pm)
for other customization options that can be made by overriding these methods.
