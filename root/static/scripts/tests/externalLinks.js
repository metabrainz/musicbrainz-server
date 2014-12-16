// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module("external links editor", {

    setup: function () {

        $("#qunit-fixture").append($.parseHTML('\
            <table id="external-links-editor">\
            <tbody data-bind="loop: { items: nonRemovedLinks, id: \'uniqueID\' }">\
              <tr data-bind="urlCleanup: \'artist\'">\
                <td>\
                  <select data-bind="value: linkTypeID, visible: showTypeSelection()">\
                    <option value=""> </option>\
                    <option value="179">Wikipedia</option>\
                    <option value="180">Discogs</option>\
                    <option value="181">MusicMoz</option>\
                    <option value="188">other databases</option>\
                  </select>\
                </td>\
                <td>\
                  <input type="url" data-bind="value: url" />\
                  <!-- ko with: error() -->\
                    <div class="errors" data-bind="text: $data"></div>\
                  <!-- /ko -->\
                </td>\
              </tr>\
            </tbody>\
            </table>\
            <div id="external-link-bubble"></div>\
            <div id="relationship-editor"></div>\
        '));

        MB.faviconClasses = { "wikipedia.org": "wikipedia" };

        this.addURL = function (name) {
            var source = this.viewModel.source;
            var target = MB.entity.URL({ name: name });
            var url = this.viewModel.getRelationship({ target: target }, source);

            source.relationships.push(url);

            return url;
        };

        this.viewModel = MB.Control.externalLinks.applyBindings({
            sourceData: { entityType: "artist", relationships: [] },
            formName: "edit-artist"
        });

        MB.sourceExternalLinksEditor = this.viewModel;

        this.RE = MB.relationshipEditor;
    },

    teardown: function () {
        MB.sourceExternalLinksEditor = null;
    }
});


test("automatic link type detection for URL", function () {
    var url = this.addURL("http://en.wikipedia.org/wiki/No_Age");

    ok(url.matchesType(), "wikipedia page is detected");
    equal(url.faviconClass(), "wikipedia-favicon", "wikipedia favicon is used");
    equal(url.linkPhrase(this.viewModel.source), "Wikipedia", "wikipedia label is used");
    equal(url.linkTypeID(), 179, "internal link type is set to 179");
    equal(url.cleanup.typeControl.val(), 179, "option with value 179 is selected");
});


test("invalid URL detection", function () {
    var url = this.addURL("foo");

    ok(!!url.error(), "error is shown for invalid URL");

    url.cleanup.urlControl.val("http://en.wikipedia.org/wiki/No_Age").change();
    ok(!url.error(), "error is removed after valid URL is entered");
});


test("deprecated link type detection", function () {
    var url = this.addURL("http://musicmoz.org/Bands_and_Artists/B/Beatles,_The/");

    MB.typeInfoByID[181] = {
        deprecated: true,
        phrase: "MusicMoz",
        reversePhrase: "MusicMoz"
    };

    url.cleanup.typeControl.val(181).change();

    ok(!!url.error(), "error is shown for deprecated link type");

    url.cleanup.typeControl.val(188).change();
    ok(!url.error(), "error is removed after valid link type is selected");
});


test("hidden input data for form submission", function () {
    var source = this.viewModel.source;
    var $re = $("#relationship-editor");

    var existingURL = this.viewModel.getRelationship({
        id: 1,
        target: MB.entity.URL({ name: "http://en.wikipedia.org/wiki/Deerhunter" }),
        linkTypeID: 179
    }, source);

    var addedURL = this.viewModel.getRelationship({
        target: MB.entity.URL({ name: "http://rateyourmusic.com/artist/deerhunter" }),
        linkTypeID: 188
    }, source);

    existingURL.cleanup.urlControl.change();
    existingURL.cleanup.typeControl.change();

    source.relationships.push(addedURL);
    addedURL.cleanup.urlControl.change();
    addedURL.cleanup.typeControl.change();

    this.RE.prepareSubmission();
    equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/Deerhunter");
    equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");
    equal($re.find("input[name=edit-artist\\.url\\.1\\.text]").val(), "http://rateyourmusic.com/artist/deerhunter");
    equal($re.find("input[name=edit-artist\\.url\\.1\\.link_type_id]").val(), "188");

    existingURL.cleanup.urlControl.val("http://en.wikipedia.org/wiki/dEErHuNtER").change();
    addedURL.remove();

    this.RE.prepareSubmission();
    equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/dEErHuNtER");
    equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");

    existingURL.removed(true);

    this.RE.prepareSubmission();
    equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    equal($re.find("input[name=edit-artist\\.url\\.0\\.removed]").val(), "1");
    equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/dEErHuNtER");
    equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");
});
