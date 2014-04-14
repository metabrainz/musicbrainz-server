// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

releaseEditor.test.module("track parser", function () {

    releaseEditor.trackParser.options = {
        trackNumbers: true,
        vinylNumbers: false,
        trackTimes: true
    };
});


test("track numbers", function () {
    releaseEditor.trackParser.options.vinylNumbers = true;

    var input = [
        "a1  Kermis         02:04",
        "a2.  Glitch        02:51",
        "a3.Afrik Slang     02:11",
        "4 Rot Beat         01:07",
        "5. Pruik           02:21",
        "6.In Je Graff      03:21",
        "７ Ｈｉｌｌｗｏｏｄ   ０２：３４"
    ]
    .join("\n");

    releaseEditor.test.trackParser(input, [
        { position: 1, number: "a1", name: "Kermis" },
        { position: 2, number: "a2", name: "Glitch" },
        { position: 3, number: "a3", name: "Afrik Slang" },
        { position: 4, number: "4", name: "Rot Beat" },
        { position: 5, number: "5", name: "Pruik" },
        { position: 6, number: "6", name: "In Je Graff" },
        { position: 7, number: "7", name: "Ｈｉｌｌｗｏｏｄ" }
    ]);
});


test("parsing track durations with trailing whitespace (MBS-1284)", function () {

    var input = [
        "1. Forgotten Child    3:39    ",
        "2. Dirty Looks  4:34   ",
        "  3. Private Life  3:29  ",
        "4.  Never Can Wait  3:24 "
    ]
    .join("\n");

    releaseEditor.test.trackParser(input, [
        { position: 1, name: "Forgotten Child", formattedLength: "3:39" },
        { position: 2, name: "Dirty Looks",     formattedLength: "4:34" },
        { position: 3, name: "Private Life",    formattedLength: "3:29" },
        { position: 4, name: "Never Can Wait",  formattedLength: "3:24" }
    ]);
});


test("numbers at the end of track names being wrongly interpreted as durations (MBS-2511, MBS-2902)", function () {
    var input = [
        "1. Criminology 2.5",
        "2. Love On A .45"
    ]
    .join("\n");

    releaseEditor.test.trackParser(input, [
        { position: 1, name: "Criminology 2.5", formattedLength: "" },
        { position: 2, name: "Love On A .45", formattedLength: "" }
    ]);
});


test("ignoring lines that don't start with a number when the option is set (MBS-2540)", function () {

    var input = "\
        1 Freeman Hardy & Willis Acid\n\n\
           Written-By – James*, Jenkinson* \n\n\
        5:42\n\
        2 Orange Romeda\n\n\
        Written-By – Eoin*, Sandison* \n\n\
        4:51 \n\
    ";

    releaseEditor.test.trackParser(input, [
        { position: 1, name: "Freeman Hardy & Willis Acid", formattedLength: "" },
        { position: 2, name: "Orange Romeda", formattedLength: "" }
    ]);
});


test("XX:XX:XX track times (MBS-3353)", function () {
    var input = "1. Love On A .45  05:22:31";

    releaseEditor.test.trackParser(input, [
        { position: 1, name: "Love On A .45", formattedLength: "5:22:31" }
    ]);
});


test("internal track positions are updated appropriately after being reused", function () {
    var re = releaseEditor;

    re.rootField = re.fields.Root();
    re.rootField.release(re.fields.Release(re.test.testRelease));

    var release = re.rootField.release();
    var medium = release.mediums()[0];

    medium.cdtocs = 0;
    medium.toc(null);

    var input = _.str.lines(re.trackParser.mediumToString(medium)).reverse().join("\n");

    medium.tracks(re.trackParser.parse(input, medium));

    var tracks = medium.tracks();

    equal(tracks[0].position(), 1, "track 1 has position 1");
    equal(tracks[1].position(), 2, "track 2 has position 2");
});


test("MBS-7451: track parser can clear TOC track lengths", function () {
    var re = releaseEditor;

    re.rootField = re.fields.Root();
    re.rootField.release(re.fields.Release(re.test.testRelease));

    var release = re.rootField.release();
    var medium = release.mediums()[0];

    medium.cdtocs = 1;

    re.trackParser.options = {
        trackNumbers: false,
        vinylNumbers: false,
        trackTimes: true
    };

    // The string does not include track numbers.
    var input = re.trackParser.mediumToString(medium);

    // Re-enable track numbers so that parsing anything fails.
    re.trackParser.options.trackNumbers = true;

    medium.tracks(re.trackParser.parse(input, medium));

    var tracks = medium.tracks();

    deepEqual(
        _.invoke(tracks, "length"),
        _.pluck(medium.original().tracklist, "length"),
        "track lengths are unchanged"
    );
});
