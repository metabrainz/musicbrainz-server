
MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.Setup = function (callback) {

    /* pause QUnit so that we have some time to load external data. */
    QUnit.stop ();

    var load_files = [
        'ReleaseEditor/information.html',
        'ReleaseEditor/tracklist.html',
        'ReleaseEditor/tracklist.json',
        'ReleaseEditor/tracklist.encoding-test.html',
        'ReleaseEditor/tracklist.encoding-test.json',
        'ReleaseEditor/information.addrelease.html',
        'ReleaseEditor/tracklist.addrelease.html'
    ];

    MB.utility.load_data (load_files, {}, function (loaded) {

        MB.tests.ReleaseEditor.data = loaded;

        QUnit.start ();
        callback ();

    });
        
};

MB.tests.ReleaseEditor.Run = function () {

    MB.tests.ReleaseEditor.Setup (function () {

        MB.tests.ReleaseEditor.ArtistCredit ();
        MB.tests.ReleaseEditor.AdvancedTab ();
        MB.tests.ReleaseEditor.BasicTab ();
        MB.tests.ReleaseEditor.Encoding ();
        MB.tests.ReleaseEditor.TrackParser ();

    });
};