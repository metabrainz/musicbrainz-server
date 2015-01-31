// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');
var externalLinks = require('../edit/externalLinks.js');
var React = require('react/addons');
var scryRenderedDOMComponentsWithTag = React.addons.TestUtils.scryRenderedDOMComponentsWithTag;
var { triggerChange, addURL } = require('./external-links-editor/utils.js');

MB.faviconClasses = { "wikipedia.org": "wikipedia" };

function externalLinksTest(name, callback, initialLinks) {
    test(name, function (t) {
        var mountPoint = document.createElement('div');

        MB.sourceExternalLinksEditor = externalLinks.createExternalLinksEditor({
            sourceData: { entityType: "artist", relationships: initialLinks || [] },
            mountPoint: mountPoint
        });

        callback(t, $(mountPoint), MB.sourceExternalLinksEditor, _.partial(addURL, MB.sourceExternalLinksEditor));

        delete MB.sourceExternalLinksEditor;
    });
}

function contains(t, $mountPoint, selector, description) {
    t.ok(!!$mountPoint.find(selector).length, description);
}

function not_contains(t, $mountPoint, selector, description) {
    t.ok(!$mountPoint.find(selector).length, description);
}

externalLinksTest("automatic link type detection for URL", function (t, $mountPoint, component, addURL) {
    t.plan(2);

    addURL("http://en.wikipedia.org/wiki/No_Age");

    contains(t, $mountPoint, '.wikipedia-favicon', 'wikipedia favicon is used');
    contains(t, $mountPoint, ':contains(Wikipedia)', 'wikipedia label is used');
});

externalLinksTest("invalid URL detection", function (t, $mountPoint, component, addURL) {
    t.plan(2);

    addURL("foo");
    contains(t, $mountPoint, ':contains(Enter a valid url)', 'error is shown for invalid URL');

    triggerChange(
        scryRenderedDOMComponentsWithTag(component, 'input')[0],
        'http://en.wikipedia.org/wiki/No_Age'
    );

    not_contains(t, $mountPoint, ':contains(Enter a valid url)', 'error is removed after valid URL is entered');
});

externalLinksTest("deprecated link type detection", function (t, $mountPoint, component, addURL) {
    t.plan(2);

    addURL("http://www.example.com/");

    MB.typeInfoByID[666] = {
        deprecated: true,
        phrase: "Example",
        reversePhrase: "Example"
    };

    var selectComponent = scryRenderedDOMComponentsWithTag(component, 'select')[0];
    triggerChange(selectComponent, 666);

    contains(t, $mountPoint, ':contains(This relationship type is deprecated)', 'error is shown for deprecated link type');

    triggerChange(
        scryRenderedDOMComponentsWithTag(component, 'input')[0],
        'http://musicmoz.org/Bands_and_Artists/B/Beatles,_The/'
    );

    triggerChange(selectComponent, 188);

    not_contains(t, $mountPoint, ':contains(This relationship type is deprecated)', 'error is removed after valid URL and type are entered');
    delete MB.typeInfoByID[666];
});

externalLinksTest("hidden input data for form submission", function (t, $mountPoint, component, addURL) {
    t.plan(12);

    var $re = $('<div id="relationship-editor"></div>').appendTo('body');

    addURL('http://rateyourmusic.com/artist/deerhunter');

    MB.relationshipEditor.prepareSubmission('edit-artist');
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/Deerhunter");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");
    t.equal($re.find("input[name=edit-artist\\.url\\.1\\.text]").val(), "http://rateyourmusic.com/artist/deerhunter");
    t.equal($re.find("input[name=edit-artist\\.url\\.1\\.link_type_id]").val(), "188");

    triggerChange(
        scryRenderedDOMComponentsWithTag(component, 'input')[0],
        'http://en.wikipedia.org/wiki/dEErHuNtER'
    );

    $mountPoint.find('button:eq(1)').click();

    MB.relationshipEditor.prepareSubmission('edit-artist');
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/dEErHuNtER");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");

    $mountPoint.find('button:eq(0)').click();

    MB.relationshipEditor.prepareSubmission('edit-artist');
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.removed]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/Deerhunter");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");

    $re.remove();
},
// initial links
[
    {
        id: 1,
        target: MB.entity.URL({ name: "http://en.wikipedia.org/wiki/Deerhunter" }),
        linkTypeID: 179
    }
]);
