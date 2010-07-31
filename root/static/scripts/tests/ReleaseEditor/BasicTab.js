
MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.BasicTab = function () {

    QUnit.module ("ReleaseEditor");
    QUnit.test ("BasicTab", function () {

        $('#placeholder').empty ();
        $('#placeholder').html (MB.tests.ReleaseEditor.html.tracklist);

        var a = MB.Control.ReleaseAdvancedTab ();
        var b = MB.Control.ReleaseBasicTab (a, MB.tests.ReleaseEditor.json.tracklist);

        /* let's add a new disc for the following tests.. */
        b.tracklist.newDisc (a.addDisc ());

        var rt = b.tracklist.textareas[1];
        rt.textarea.val ('1. Goof (1:23)\n2. Sandjorda (4:56)\n');
        rt.updatePreview ();

        QUnit.equals (typeof a.discs[1].tracks[0], 'object', 'Track created on advanced tab');
        QUnit.equals (a.discs[1].tracks[0].title.val (), 'Goof', '... with correct title');
        QUnit.equals (a.discs[1].tracks[0].length.val (), '1:23', '... with correct length');
        QUnit.equals (a.discs[1].tracks[0].position.val (), '1', '... with correct position');
        QUnit.equals (a.discs[1].tracks[0].preview.val (), 'Various Artists', '... with correct artist');

        /* add a track on the advanced tab and get it to render in the textarea. */
        var track_data = {
            'position': 3,
            'title': 'Widibf',
            'id': 5198784,
            'preview': 'Binärpilot',
            'length': '3:08',
            'deleted': false
        };

        var track2 = a.discs[1].getTrack(2);
        track2.render (track_data);

        rt.render ();
        rt.updatePreview ();

        var expected = '1. Goof (1:23)\n2. Sandjorda (4:56)\n3. Widibf (3:08)\n';
        QUnit.equals (rt.textarea.val (), expected, 'New track rendered correctly in textarea');

        var preview = b.preview.preview;
        QUnit.equals (preview.find ('td.title').eq (14+2).text (), 'Widibf', 'New track rendered correctly in preview');
        QUnit.equals (preview.find ('td.duration').eq (14+2).text (), '3:08', 'New track rendered correctly in preview');
    });
};
