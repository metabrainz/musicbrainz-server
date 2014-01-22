// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module("external links editor", {

    setup: function () {

        $("#qunit-fixture").append($.parseHTML('\
            <table id="external-links-editor">\
            <tbody data-bind="foreach: links">\
              <tr data-bind="urlCleanup: true">\
                <td>\
                  <select data-bind="value: linkType, visible: showTypeSelection()">\
                    <option value="" selected="selected"> </option>\
                    <option value="179">Wikipedia</option>\
                    <option value="180">Discogs</option>\
                    <option value="181">MusicMoz</option>\
                    <option value="188">other databases</option>\
                  </select>\
                </td>\
                <td>\
                  <input type="text" data-bind="value: text" />\
                </td>\
              </tr>\
              <tr><td class="errors"></td></tr>\
            </tbody>\
            </table>\
        '));

        var typeInfo = {
            179: { deprecated: "0", phrase: "Wikipedia" },
            180: { deprecated: "0", phrase: "Discogs" },
            181: { deprecated: "1", phrase: "MusicMoz" },
            188: { deprecated: "0", phrase: "other databases" }
        };

        MB.Control.externalLinksEditor({
            entityType:     "artist",
            formName:       "edit-artist",
            relationships:  [],
            typeInfo:       typeInfo,
            faviconClasses: { "wikipedia.org": "wikipedia" }
        });

        this.URL = MB.Control.externalLinksEditor.URL;
        this.viewModel = MB.Control.externalLinksEditor.viewModel;
    }
});


test("automatic link type detection for URL", function () {
    var url = this.URL({
        text: "http://en.wikipedia.org/wiki/No_Age"
    });

    this.viewModel.links.push(url);

    url.cleanup.urlControl.change();

    ok(url.matchesType(), "wikipedia page is detected");
    equal(url.faviconClass(), "wikipedia-favicon", "wikipedia favicon is used");
    equal(url.label(), "Wikipedia", "wikipedia label is used");
    equal(url.linkType(), 179, "internal link type is set to 179");
    equal(url.cleanup.typeControl.val(), 179, "option with value 179 is selected");
});


test("invalid URL detection", function () {
    var url = this.URL({ text: "foo" });

    this.viewModel.links.push(url);
    url.cleanup.urlControl.change();

    var $errors = url.cleanup.errorList;
    ok($errors.children().length === 1, "error is shown for invalid URL");

    url.cleanup.urlControl.val("http://en.wikipedia.org/wiki/No_Age").change();
    ok($errors.children().length === 0, "error is removed after valid URL is entered");
});


test("deprecated link type detection", function () {
    var url = this.URL({
        text: "http://musicmoz.org/Bands_and_Artists/B/Beatles,_The/"
    });

    this.viewModel.links.push(url);
    url.cleanup.urlControl.change();
    url.cleanup.typeControl.val(181).change();

    var $errors = url.cleanup.errorList;
    ok($errors.children().length === 1, "error is shown for deprecated link type");

    url.cleanup.typeControl.val(188).change();
    ok($errors.children().length === 0, "error is removed after valid link type is selected");
});


test("hidden input data for form submission", function () {
    var existingURL = this.URL({
        relationship_id: 1,
        text: "http://en.wikipedia.org/wiki/Deerhunter",
        link_type_id: 179
    });

    var addedURL = this.URL({
        text: "http://rateyourmusic.com/artist/deerhunter",
        link_type_id: 188
    });

    this.viewModel.links.push(existingURL);
    existingURL.cleanup.urlControl.change();
    existingURL.cleanup.typeControl.change();

    this.viewModel.links.push(addedURL);
    addedURL.cleanup.urlControl.change();
    addedURL.cleanup.typeControl.change();

    deepEqual(this.viewModel.hiddenInputs(), [
        { name: "edit-artist.url.0.text", value: "" },
        { name: "edit-artist.url.0.link_type_id", value: "" },
        { name: "edit-artist.url.1.relationship_id", value: 1 },
        { name: "edit-artist.url.1.text", value: "http://en.wikipedia.org/wiki/Deerhunter" },
        { name: "edit-artist.url.1.link_type_id", value: "179" },
        { name: "edit-artist.url.2.text", value: "http://rateyourmusic.com/artist/deerhunter" },
        { name: "edit-artist.url.2.link_type_id", value: "188" }
    ]);

    existingURL.cleanup.urlControl.val("http://en.wikipedia.org/wiki/dEErHuNtER").change();
    addedURL.remove();

    deepEqual(this.viewModel.hiddenInputs(), [
        { name: "edit-artist.url.0.text", value: "" },
        { name: "edit-artist.url.0.link_type_id", value: "" },
        { name: "edit-artist.url.1.relationship_id", value: 1 },
        { name: "edit-artist.url.1.text", value: "http://en.wikipedia.org/wiki/dEErHuNtER" },
        { name: "edit-artist.url.1.link_type_id", value: "179" }
    ]);

    existingURL.remove();

    deepEqual(this.viewModel.hiddenInputs(), [
        { name: "edit-artist.url.0.text", value: "" },
        { name: "edit-artist.url.0.link_type_id", value: "" },
        { name: "edit-artist.url.1.relationship_id", value: 1 },
        { name: "edit-artist.url.1.removed", value: 1 },
        { name: "edit-artist.url.1.link_type_id", value: "179" }
    ]);
});
