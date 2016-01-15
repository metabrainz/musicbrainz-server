// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');

const common = require('./common');

var releaseEditor = MB.releaseEditor;

$.ui.dialog.prototype.options.appendTo = "#fixture";

function dialogTest(name, callback) {
    test(name, function (t) {
        var release = common.setupReleaseAdd();

        releaseEditor.trackParser.options = {
            hasTrackNumbers: true,
            hasVinylNumbers: false,
            hasTrackArtists: false,
            useTrackNumbers: true,
            useTrackArtists: true,
            useTrackNames: true,
            useTrackLengths: true
        };

        var $fixture = $('<div>').attr('id', 'fixture').appendTo('body').append(
            $("<div>").attr("id", "add-disc-dialog").hide(),
            $("<div>").attr("id", "track-parser-dialog").hide()
        );

        releaseEditor.activeTabID("#information");

        callback(t, release);

        $fixture.remove();
    });
}

dialogTest("adding an empty medium via the add-disc dialog is allowed (MBS-7221)", function (t, release) {
    t.plan(3);

    var addDiscDialog = releaseEditor.addDiscDialog;
    var trackParserDialog = releaseEditor.trackParserDialog;
    var mediums = release.mediums;

    t.ok(!mediums()[0].hasTracks(), "first medium is empty");

    trackParserDialog.open(mediums()[0]);
    trackParserDialog.toBeParsed("1. ~fooo~ (1:23)\n");
    trackParserDialog.parse();

    t.ok(mediums()[0].hasTracks(), "first medium has tracks after using track parser");

    addDiscDialog.open();
    addDiscDialog.currentTab(trackParserDialog);
    addDiscDialog.trackParser.toBeParsed("\n\t\n");
    addDiscDialog.addDisc();

    t.ok(!mediums()[1].hasTracks(), "new empty medium was added");
});

dialogTest("switching to the tracklist tab opens the add-disc dialog if there's only one empty medium", function (t, release) {
    t.plan(3);

    var addDiscDialog = releaseEditor.addDiscDialog;
    var trackParserDialog = releaseEditor.trackParserDialog;

    releaseEditor.activeTabID("#tracklist");
    releaseEditor.autoOpenTheAddDiscDialog(release);

    var uiDialog = $(addDiscDialog.element).data("ui-dialog");

    t.ok(uiDialog.isOpen(), "add-disc dialog is open after switching to the tracklist tab");

    releaseEditor.activeTabID("#information");
    releaseEditor.autoOpenTheAddDiscDialog(release);

    t.ok(!uiDialog.isOpen(), "add-disc dialog is closed after switching back to the information tab");

    release.mediums()[0].tracks.push(
        releaseEditor.fields.Track({ name: "~fooo~", position: 1, length: 12345 })
    );

    releaseEditor.activeTabID("#information");
    releaseEditor.autoOpenTheAddDiscDialog(release);

    t.ok(!uiDialog.isOpen(), "add-disc dialog remains closed after switching to the tracklist tab with a non-empty medium");
});

dialogTest("clearing the tracks of an existing medium via the track parser doesn't cause the add-disc dialog to open", function (t, release) {
    t.plan(3);

    var addDiscDialog = releaseEditor.addDiscDialog;
    var trackParserDialog = releaseEditor.trackParserDialog;
    var medium = release.mediums()[0];

    medium.tracks.push(
        releaseEditor.fields.Track({ name: "~fooo~", position: 1, length: 12345 })
    );

    t.ok(medium.hasTracks(), "medium has tracks");

    releaseEditor.activeTabID("#tracklist");
    trackParserDialog.open(medium);
    trackParserDialog.toBeParsed("");
    trackParserDialog.parse();
    releaseEditor.autoOpenTheAddDiscDialog(release);

    t.ok(!medium.hasTracks(), "medium does not have tracks");

    var uiDialog = $(addDiscDialog.element).data("ui-dialog");
    t.ok(!uiDialog, "add-disc dialog is not open");
});

dialogTest("adding a new medium does not cause reorder edits (MBS-7412)", function (t, release) {
    t.plan(1);

    var addDiscDialog = releaseEditor.addDiscDialog;
    var mediumSearchTab = releaseEditor.mediumSearchTab;

    release.mediums([
        releaseEditor.fields.Medium(
            _.assign(_.omit(common.testMedium, "id"), { position: 1 })
        )
    ]);

    addDiscDialog.open();
    addDiscDialog.currentTab(mediumSearchTab);
    mediumSearchTab.result({ position: 1, tracks: [{ name: "foo" }] });
    addDiscDialog.addDisc();

    common.createMediums(release);

    t.equal(releaseEditor.edits.mediumReorder(release).length, 0, "mediums are not reordered");
});
