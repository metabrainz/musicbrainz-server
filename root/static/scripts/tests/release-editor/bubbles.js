// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');

const common = require('./common');

function trackBubbleTest(name, callback) {
    test(name, function (t) {
        var release = common.setupReleaseEdit();
        var ac = release.mediums()[0].tracks()[0].artistCredit;

        var bubble = MB.releaseEditor.trackArtistBubble;
        var $bubble = $("<div>").addClass("bubble").append("<input>");
        var $button = $("<button>");
        var $fixture = $('<div>').appendTo('body').append($bubble, $button);

        ko.applyBindingsToNode($bubble[0], { bubble: bubble }, ac);
        ko.applyBindingsToNode($button[0], { controlsBubble: bubble }, ac);

        callback(t, bubble, $button);

        $fixture.remove();
    });
}

trackBubbleTest("clicking outside of a track AC bubble closes it", function (t, bubble, $button) {
    t.plan(3);

    t.ok(!bubble.visible(), "bubble is not visible");

    $button.click();
    t.ok(bubble.visible(), "bubble is visible after clicking button");

    $("body").click();
    t.ok(!bubble.visible(), "bubble is hidden after clicking outside of it");
});

trackBubbleTest("creating a new artist from the track AC bubble should not close it (MBS-7251)", function (t, bubble, $button) {
    t.plan(3);

    // Open the track AC bubble.
    $button.click();

    // Simulate an add-entity dialog opening.
    var $fixture = $('<div>').appendTo('body');
    var $dialog = $("<div>").appendTo($fixture).dialog();
    t.ok(bubble.visible(), "bubble is visible after dialog opens above it");

    $dialog.parent().find("button.ui-dialog-titlebar-close").click();
    t.ok(bubble.visible(), "bubble is visible after dialog is closed");

    $button.click();
    t.ok(!bubble.visible(), "bubble is hidden after clicking the button again");

    $fixture.remove();
});
