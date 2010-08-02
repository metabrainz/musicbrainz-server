
MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.TrackParser = function () {

    QUnit.module ("ReleaseEditor");
    QUnit.test ("TrackParser interactions (fillInData)", function () {

        var tracks_html = MB.tests.ReleaseEditor.data['ReleaseEditor/tracklist.html'];
        var tracks_json = MB.tests.ReleaseEditor.data['ReleaseEditor/tracklist.json'];

        $('#placeholder').empty ();
        $('#placeholder').html (tracks_html);

        var a = MB.Control.ReleaseAdvancedTab ();
        var b = MB.Control.ReleaseBasicTab (a, tracks_json);

        var rt = b.tracklist.textareas[0];
        var tp = rt.trackparser;
        var lines = tp.textarea.val ().split ('\n');

        /* 
           Delete track test
           =================
        */
        var deleted = lines.splice (3, 1);
        tp.textarea.val (lines.join ('\n'));
        rt.updatePreview ();

        var tracks = a.discs[0].tracks;

        QUnit.equals (tracks.length, 14, "Release has 14 tracks");
        QUnit.equals (tracks[3].title.val (), 'Kick the P.A.', '4th track is');
        QUnit.equals (tracks[3].deleted.val (), '1', "4th track will be deleted");

        /* 
           Move track test
           =================
        */
        lines.splice (7, 0, deleted[0]);
        tp.textarea.val (lines.join ('\n'));
        rt.updatePreview ();

        QUnit.equals (tracks[3].title.val (), 'Tiny Rubberband', '4th track is');
        QUnit.equals (tracks[7].title.val (), 'Kick the P.A.', '8th track is');
        QUnit.equals (tracks[7].position.val (), '8', '8th track has position');
        QUnit.equals (tracks[8].position.val (), '9', '9th track has position');
        
        /* 
           Insert track test
           =================
        */
        lines.splice (2, 0, '2. Insert track test');
        tp.textarea.val (lines.join ('\n'));
        rt.updatePreview ();

        QUnit.equals (tracks[2].position.val (), '3', '2nd track has position');
        QUnit.equals (tracks[2].title.val (), 'Insert track test', '2nd track has title');
        QUnit.equals (tracks[3].position.val (), '4', '3rd track has position');
        QUnit.equals (tracks[3].title.val (), 'Satan', '3rd track has title');

        /* 
           Rename track test (this is just a delete + insert)
           ==================================================
        */
        lines.splice (9, 1, '10. Two Men Army');
        tp.textarea.val (lines.join ('\n'));
        rt.updatePreview ();

        QUnit.equals (tracks[9].title.val (), 'One Man Army', 'Old name still exists:');
        QUnit.equals (tracks[9].position.val (), '9', 'Old name still at position:');
        QUnit.equals (tracks[9].deleted.val (), '1', 'Old name will be deleted:');
        QUnit.equals (tracks[10].title.val (), 'Two Men Army', 'New name also exists:');
        QUnit.equals (tracks[10].position.val (), '10', 'New name at position:');
        QUnit.equals (tracks[10].deleted.val (), '0', 'New name will not be deleted:');
    });

    QUnit.test ("TrackParser remaining methods", function () {

        var tracks_html = MB.tests.ReleaseEditor.data['ReleaseEditor/tracklist.html'];
        var tracks_json = MB.tests.ReleaseEditor.data['ReleaseEditor/tracklist.json'];

        $('#placeholder').empty ();
        $('#placeholder').html (tracks_html);

        var a = MB.Control.ReleaseAdvancedTab ();
        var b = MB.Control.ReleaseBasicTab (a, tracks_json);

        var tp = b.tracklist.textareas[0].trackparser;
        tp.textarea.val ('1. Goof (1:23)\n2. Sandjorda (4:56)\n');

        tp.getTrackInput ();
        tp.removeTrackNumbers ();
        QUnit.same (tp.inputlines, [ 'Goof (1:23)', 'Sandjorda (4:56)' ], 'Removed track numbers');

        tp.textarea.val ('B. Goof (1:23)\nBB. Sandjorda (4:56)\n');

        tp.getTrackInput ();
        tp.removeTrackNumbers ();
        QUnit.same (tp.inputlines, [ 'B. Goof (1:23)', 'BB. Sandjorda (4:56)' ], 'Did not remove track numbers');

        $('#vinylnumbers').attr ('checked', 'checked');
        tp.getTrackInput ();
        tp.removeTrackNumbers ();
        QUnit.same (tp.inputlines, [ 'Goof (1:23)', 'Sandjorda (4:56)' ], 'Removed vinyl style track numbers');

        tp.parseTimes ();
        tp.cleanSpaces ();
        tp.cleanTitles ();
        QUnit.same (tp.inputdurations, [ '1:23', '4:56' ], 'Separated track durations');
        QUnit.same (tp.inputlines, [ 'Goof', 'Sandjorda' ], 'Removed track durations');
    });

};
