// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');

MB.testArtistCreditData = [
    [
        {
            artist: {
                id: 956,
                gid: "5441c29d-3602-4898-b1a1-b77fa23b8e50",
                name: "david bowie"
            }
        }
    ],
    [
        {
            artist: {
                id: 956,
                gid: "5441c29d-3602-4898-b1a1-b77fa23b8e50",
                name: "david bowie"
            },
            name: "david robert jones"
        }
    ],
    [
        {
            artist: {
                gid: "5441c29d-3602-4898-b1a1-b77fa23b8e50",
                name: "david bowie"
            },
            joinPhrase: " & "
        },
        {
            artist: {
                id: 99,
                gid: "2437980f-513a-44fc-80f1-b90d9d7fcf8f",
                name: "bing crosby"
            }
        }
    ]
];

test("Hidden inputs", function (t) {
    t.plan(6);

    var artistCredits = _.map(MB.testArtistCreditData, function (data) {
        return MB.Control.ArtistCredit({
            initialData: data,
            hiddenInputs: true,
            formName: "form"
        });
    });

    t.equal(artistCredits[0].isComplex(), false, "david bowie is not complex");
    t.equal(artistCredits[1].isComplex(), true, "david robert jones is complex");
    t.equal(artistCredits[2].isComplex(), true, "david bowie & bing crosby is complex");

    t.deepEqual(artistCredits[0].hiddenInputs(), [
        { name: "form.artist_credit.names.0.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.join_phrase", value: "" },
        { name: "form.artist_credit.names.0.artist.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.artist.id", value: 956 }
    ],
    "hidden inputs are generated correctly for david bowie");

    t.deepEqual(artistCredits[1].hiddenInputs(), [
        { name: "form.artist_credit.names.0.name", value: "david robert jones" },
        { name: "form.artist_credit.names.0.join_phrase", value: "" },
        { name: "form.artist_credit.names.0.artist.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.artist.id", value: 956 }
    ],
    "hidden inputs are generated correctly for david robert jones");

    t.deepEqual(artistCredits[2].hiddenInputs(), [
        { name: "form.artist_credit.names.0.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.join_phrase", value: " & " },
        { name: "form.artist_credit.names.0.artist.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.artist.id", value: 956 },
        { name: "form.artist_credit.names.1.name", value: "bing crosby" },
        { name: "form.artist_credit.names.1.join_phrase", value: "" },
        { name: "form.artist_credit.names.1.artist.name", value: "bing crosby" },
        { name: "form.artist_credit.names.1.artist.id", value: 99 }
    ],
    "hidden inputs are generated correctly for david bowie & bing crosby");
});
