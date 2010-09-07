
MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.Encoding = function () {

    QUnit.module ("ReleaseEditor");
    QUnit.test ("Encoding", function () {

        var tracks_html = MB.tests.ReleaseEditor.data['ReleaseEditor/tracklist.encoding-test.html'];
        var tracks_json = MB.tests.ReleaseEditor.data['ReleaseEditor/tracklist.encoding-test.json'];

        $('#placeholder').empty ();
        $('#placeholder').html (tracks_html);

        /* useful when debugging these tests. */
        $('.basic-tracklist').hide ();
        $('.advanced-tracklist').show ();

        var a = MB.Control.ReleaseAdvancedTab ();
        var b = MB.Control.ReleaseBasicTab (a, tracks_json);

        var rt = b.tracklist.textareas[0];
        var lines = rt.textarea.val ().split ('\n');

        lines[2] = lines[2].replace ('Test', 'B0RK');
        rt.textarea.val (lines.join ('\n'));
        rt.updatePreview ();

        QUnit.equals (a.discs[0].tracks.length, 6, 'Tracklist has a new track');
        QUnit.equals (a.discs[0].tracks[3].title.val (), 'Anöther B0RK', 'New track has metal umlaut');
        QUnit.equals (a.discs[0].tracks[5].title.val (), 'بالسكوت (ريمكس)', 'Track still has the same name');
    });
};
