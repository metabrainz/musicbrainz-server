// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');

MB.faviconClasses = { "wikipedia.org": "wikipedia" };

function addURL(name) {
    var vm = MB.sourceExternalLinksEditor;

    var url = vm.getRelationship({ target: MB.entity.URL({ name: name }) }, vm.source);
    vm.source.relationships.push(url);

    return url;
}

function externalLinksTest(name, callback) {
    test(name, function (t) {
        var $fixture = $('<div>').appendTo('body');

        $fixture.append($.parseHTML('\
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

        MB.initRelationshipEditors({
            sourceData: { entityType: "artist", relationships: [] },
            formName: "edit-artist"
        });

        callback(t);

        $fixture.remove();
        MB.entityCache = {};
        MB.sourceExternalLinksEditor = null;
    });
}

externalLinksTest("automatic link type detection for URL", function (t) {
    t.plan(5);

    var url = addURL("http://en.wikipedia.org/wiki/No_Age");

    t.ok(url.matchesType(), "wikipedia page is detected");
    t.equal(url.faviconClass(), "wikipedia-favicon", "wikipedia favicon is used");
    t.equal(url.linkPhrase(MB.sourceExternalLinksEditor.source), "Wikipedia", "wikipedia label is used");
    t.equal(url.linkTypeID(), 179, "internal link type is set to 179");
    t.equal(+url.cleanup.typeControl.val(), 179, "option with value 179 is selected");
});

externalLinksTest("invalid URL detection", function (t) {
    t.plan(2);

    var url = addURL("foo");

    t.ok(!!url.error(), "error is shown for invalid URL");

    url.cleanup.urlControl.val("http://en.wikipedia.org/wiki/No_Age").change();
    t.ok(!url.error(), "error is removed after valid URL is entered");
});

externalLinksTest("deprecated link type detection", function (t) {
    t.plan(2);

    var url = addURL("http://musicmoz.org/Bands_and_Artists/B/Beatles,_The/");

    MB.typeInfoByID[181] = {
        deprecated: true,
        phrase: "MusicMoz",
        reversePhrase: "MusicMoz"
    };

    url.cleanup.typeControl.val(181).change();

    t.ok(!!url.error(), "error is shown for deprecated link type");

    url.cleanup.typeControl.val(188).change();
    t.ok(!url.error(), "error is removed after valid link type is selected");
});

externalLinksTest("hidden input data for form submission", function (t) {
    t.plan(12);

    var viewModel = MB.sourceExternalLinksEditor;
    var source = viewModel.source;
    var $re = $("#relationship-editor");

    var existingURL = viewModel.getRelationship({
        id: 1,
        target: MB.entity.URL({ name: "http://en.wikipedia.org/wiki/Deerhunter" }),
        linkTypeID: 179
    }, source);

    var addedURL = viewModel.getRelationship({
        target: MB.entity.URL({ name: "http://rateyourmusic.com/artist/deerhunter" }),
        linkTypeID: 188
    }, source);

    existingURL.cleanup.urlControl.change();
    existingURL.cleanup.typeControl.change();

    source.relationships.push(addedURL);
    addedURL.cleanup.urlControl.change();
    addedURL.cleanup.typeControl.change();

    MB.relationshipEditor.prepareSubmission();
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/Deerhunter");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");
    t.equal($re.find("input[name=edit-artist\\.url\\.1\\.text]").val(), "http://rateyourmusic.com/artist/deerhunter");
    t.equal($re.find("input[name=edit-artist\\.url\\.1\\.link_type_id]").val(), "188");

    existingURL.cleanup.urlControl.val("http://en.wikipedia.org/wiki/dEErHuNtER").change();
    addedURL.remove();

    MB.relationshipEditor.prepareSubmission();
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/dEErHuNtER");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");

    existingURL.removed(true);

    MB.relationshipEditor.prepareSubmission();
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.removed]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/dEErHuNtER");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");
});
