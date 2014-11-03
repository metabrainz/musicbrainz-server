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

module("Artist Credit", {
    setup: function () {
        this.artistCredits = _.map(MB.testArtistCreditData, function (data) {
            return MB.Control.ArtistCredit({
                initialData: data,
                hiddenInputs: true,
                formName: "form"
            });
        });
    }
});

test("Hidden inputs", function () {
    var artistCredits = this.artistCredits;

    QUnit.equal(artistCredits[0].isComplex(), false, "david bowie is not complex");
    QUnit.equal(artistCredits[1].isComplex(), true, "david robert jones is complex");
    QUnit.equal(artistCredits[2].isComplex(), true, "david bowie & bing crosby is complex");

    QUnit.deepEqual(artistCredits[0].hiddenInputs(), [
        { name: "form.artist_credit.names.0.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.join_phrase", value: "" },
        { name: "form.artist_credit.names.0.artist.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.artist.id", value: 956 }
    ],
    "hidden inputs are generated correctly for david bowie");

    QUnit.deepEqual(artistCredits[1].hiddenInputs(), [
        { name: "form.artist_credit.names.0.name", value: "david robert jones" },
        { name: "form.artist_credit.names.0.join_phrase", value: "" },
        { name: "form.artist_credit.names.0.artist.name", value: "david bowie" },
        { name: "form.artist_credit.names.0.artist.id", value: 956 }
    ],
    "hidden inputs are generated correctly for david robert jones");

    QUnit.deepEqual(artistCredits[2].hiddenInputs(), [
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
