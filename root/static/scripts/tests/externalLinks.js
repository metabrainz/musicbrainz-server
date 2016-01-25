// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');
const ReactTestUtils = require('react-addons-test-utils');

const externalLinks = require('../edit/externalLinks');
const {triggerChange, triggerClick, addURL} = require('./external-links-editor/utils');

MB.faviconClasses = { "wikipedia.org": "wikipedia" };

function externalLinksTest(name, callback, initialLinks) {
    test(name, function (t) {
        var mountPoint = document.createElement('div');

        MB.typeInfoByID[666] = {
            deprecated: true,
            phrase: "Example",
            reversePhrase: "Example"
        };

        MB.sourceExternalLinksEditor = externalLinks.createExternalLinksEditor({
            sourceData: { entityType: "artist", relationships: initialLinks || [] },
            mountPoint: mountPoint
        });

        callback(t, $(mountPoint), MB.sourceExternalLinksEditor, _.partial(addURL, MB.sourceExternalLinksEditor));

        delete MB.sourceExternalLinksEditor;
        delete MB.typeInfoByID[666];
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
        ReactTestUtils.scryRenderedDOMComponentsWithTag(component, 'input')[0],
        'http://en.wikipedia.org/wiki/No_Age'
    );

    not_contains(t, $mountPoint, ':contains(Enter a valid url)', 'error is removed after valid URL is entered');
});

externalLinksTest("shortened URL detection", function (t, $mountPoint, component, addURL) {
    t.plan(2);

    addURL("http://goo.gl/example");
    contains(t, $mountPoint, ":contains(Please don't use shortened URLs)", 'error is shown for shortened URL');

    triggerChange(
        ReactTestUtils.scryRenderedDOMComponentsWithTag(component, 'input')[0],
        'http://google.com/example'
    );

    not_contains(t, $mountPoint, ":contains(Please don't use shortened URLs)", 'error is removed after valid URL is entered');
});

externalLinksTest("deprecated link type detection for new links", function (t, $mountPoint, component, addURL) {
    t.plan(2);

    addURL("http://www.example.com/");

    var selectComponent = ReactTestUtils.scryRenderedDOMComponentsWithTag(component, 'select')[0];
    triggerChange(selectComponent, 666);
    contains(t, $mountPoint, ':contains(This relationship type is deprecated)', 'error is shown for deprecated link type');

    triggerChange(
        ReactTestUtils.scryRenderedDOMComponentsWithTag(component, 'input')[0],
        'http://musicmoz.org/Bands_and_Artists/B/Beatles,_The/'
    );

    triggerChange(selectComponent, 188);
    not_contains(t, $mountPoint, ':contains(This relationship type is deprecated)', 'error is removed after valid URL and type are entered');
});

externalLinksTest("deprecated link type detection for existing links (MBS-8408)", function (t, $mountPoint, component, addURL) {
    t.plan(2);

    var selectComponent = ReactTestUtils.scryRenderedDOMComponentsWithTag(component, 'select')[0];
    triggerChange(selectComponent, 666);
    contains(t, $mountPoint, ':contains(This relationship type is deprecated)', 'error is shown for deprecated link type');

    triggerChange(selectComponent, 179);
    not_contains(t, $mountPoint, ':contains(This relationship type is deprecated)', 'error is removed after valid type is entered');
},
// initial links
[
    {
        id: 1,
        target: MB.entity.URL({ name: "http://www.example.com/" }),
        linkTypeID: 179
    }
]);

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
        $mountPoint.find('input[type=url]:eq(0)')[0],
        'http://en.wikipedia.org/wiki/dEErHuNtER'
    );

    triggerClick($mountPoint.find('button:eq(1)')[0]);

    MB.relationshipEditor.prepareSubmission('edit-artist');
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.relationship_id]").val(), "1");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.text]").val(), "http://en.wikipedia.org/wiki/dEErHuNtER");
    t.equal($re.find("input[name=edit-artist\\.url\\.0\\.link_type_id]").val(), "179");

    triggerClick($mountPoint.find('button:eq(0)')[0]);

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
