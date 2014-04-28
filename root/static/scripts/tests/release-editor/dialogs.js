// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

$.ui.dialog.prototype.options.appendTo = "#qunit-fixture";


releaseEditor.test.module("release editor dialogs", function () {
    releaseEditor.test.setupReleaseAdd();

    releaseEditor.trackParser.options = {
        trackArtists: false,
        trackNumbers: true,
        trackTimes: true,
        vinylNumbers: false
    };

    $("#qunit-fixture").append(
        $("<div>").attr("id", "add-disc-dialog").hide(),
        $("<div>").attr("id", "track-parser-dialog").hide()
    );

    releaseEditor.activeTabID("#information");
});


test("adding an empty medium via the add-disc dialog is allowed (MBS-7221)", function () {
    var addDiscDialog = releaseEditor.addDiscDialog;
    var trackParserDialog = releaseEditor.trackParserDialog;
    var mediums = this.release.mediums;

    ok(!mediums()[0].hasTracks(), "first medium is empty");

    trackParserDialog.open(mediums()[0]);
    trackParserDialog.toBeParsed("1. ~fooo~ (1:23)\n");
    trackParserDialog.parse();

    ok(mediums()[0].hasTracks(), "first medium has tracks after using track parser");

    addDiscDialog.open();
    addDiscDialog.currentTab(trackParserDialog);
    addDiscDialog.trackParser.toBeParsed("\n\t\n");
    addDiscDialog.addDisc();

    ok(!mediums()[1].hasTracks(), "new empty medium was added");
});


test("switching to the tracklist tab opens the add-disc dialog if there's only one empty medium", function () {
    var addDiscDialog = releaseEditor.addDiscDialog;
    var trackParserDialog = releaseEditor.trackParserDialog;

    releaseEditor.activeTabID("#tracklist");
    releaseEditor.autoOpenTheAddDiscDialog(this.release);

    var uiDialog = $(addDiscDialog.element).data("ui-dialog");

    ok(uiDialog.isOpen(), "add-disc dialog is open after switching to the tracklist tab");

    releaseEditor.activeTabID("#information");
    releaseEditor.autoOpenTheAddDiscDialog(this.release);

    ok(!uiDialog.isOpen(), "add-disc dialog is closed after switching back to the information tab");

    this.release.mediums()[0].tracks.push(
        releaseEditor.fields.Track({ name: "~fooo~", position: 1, length: 12345 })
    );

    releaseEditor.activeTabID("#information");
    releaseEditor.autoOpenTheAddDiscDialog(this.release);

    ok(!uiDialog.isOpen(), "add-disc dialog remains closed after switching to the tracklist tab with a non-empty medium");
});


test("clearing the tracks of an existing medium via the track parser doesn't cause the add-disc dialog to open", function () {
    var addDiscDialog = releaseEditor.addDiscDialog;
    var trackParserDialog = releaseEditor.trackParserDialog;
    var medium = this.release.mediums()[0];

    medium.tracks.push(
        releaseEditor.fields.Track({ name: "~fooo~", position: 1, length: 12345 })
    );

    ok(medium.hasTracks(), "medium has tracks");

    releaseEditor.activeTabID("#tracklist");
    trackParserDialog.open(medium);
    trackParserDialog.toBeParsed("");
    trackParserDialog.parse();
    releaseEditor.autoOpenTheAddDiscDialog(this.release);

    ok(!medium.hasTracks(), "medium does not have tracks");

    var uiDialog = $(addDiscDialog.element).data("ui-dialog");
    ok(!uiDialog, "add-disc dialog is not open");
});


test("adding a new medium does not cause reorder edits (MBS-7412)", function () {
    var addDiscDialog = releaseEditor.addDiscDialog;
    var mediumSearchTab = releaseEditor.mediumSearchTab;

    this.release.mediums([
        releaseEditor.fields.Medium(
            _.assign(_.omit(releaseEditor.test.testMedium, "id"), { position: 1 })
        )
    ]);

    addDiscDialog.open();
    addDiscDialog.currentTab(mediumSearchTab);
    mediumSearchTab.result({ position: 1, tracks: [{ name: "foo" }] });
    addDiscDialog.addDisc();

    releaseEditor.test.createMediums(this.release);

    equal(releaseEditor.edits.mediumReorder(this.release).length, 0, "mediums are not reordered");
});
