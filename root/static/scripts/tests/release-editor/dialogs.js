// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

releaseEditor.test.module("release editor dialogs", releaseEditor.test.setupReleaseAdd);


test("adding an empty medium via the add-disc dialog (MBS-7221)", function () {
    var addDiscDialog = releaseEditor.addDiscDialog;
    var trackParserDialog = releaseEditor.trackParserDialog;
    var mediums = this.release.mediums;

    releaseEditor.trackParser.options = {
        trackArtists: false,
        trackNumbers: true,
        trackTimes: true,
        vinylNumbers: false
    };

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
