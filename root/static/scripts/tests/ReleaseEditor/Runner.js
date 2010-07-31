
MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.Setup = function (callback) {

    /* pause QUnit so that we have some time to load external data. */
    QUnit.stop ();

    MB.tests.ReleaseEditor.html = {};
    MB.tests.ReleaseEditor.json = {};

    jQuery.get ('ReleaseEditor/information.html', function (data) {
        MB.tests.ReleaseEditor.html.information = data;

        jQuery.get ('ReleaseEditor/tracklist.html', function (data) {
            MB.tests.ReleaseEditor.html.tracklist = data;

            jQuery.getJSON ('ReleaseEditor/tracklist.json', function (data) {
                MB.tests.ReleaseEditor.json.tracklist = data;

                /* all data loaded, continue running tests now. */
                QUnit.start ();
                callback ();
            });
        });
    });

};

MB.tests.ReleaseEditor.Run = function () {

    MB.tests.ReleaseEditor.Setup (function () {

        MB.tests.ReleaseEditor.ArtistCredit ();
        MB.tests.ReleaseEditor.AdvancedTab ();
        MB.tests.ReleaseEditor.BasicTab ();

    });
};