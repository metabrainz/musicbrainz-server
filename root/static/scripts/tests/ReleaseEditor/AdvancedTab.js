
MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.AdvancedTab = function () {

    QUnit.module ("ReleaseEditor");
    QUnit.test ("AdvancedTab", function () {

        $('#placeholder').empty ();
        $('#placeholder').html (MB.tests.ReleaseEditor.html.tracklist);

        /* useful when debugging these tests. */
        $('.basic-tracklist').hide ();
        $('.advanced-tracklist').show ();

        var a = MB.Control.ReleaseAdvancedTab ();

        QUnit.equals ($('#id-mediums\\.1\\.tracklist\\.id').size (), 0, 'There is no second disc.');
        a.addDisc ();
        QUnit.equals ($('#id-mediums\\.1\\.tracklist\\.id').size (), 1, 'Second disc was added.');

        var track = a.discs[1].getTrack (4);
        QUnit.equals (track.title.attr ('id'), 'id-mediums.1.tracklist.tracks.4.name', 'Tracks were added');

        a.discs[1].removeTracks (2);
        QUnit.equals ($('#id-mediums\\.1\\.tracklist\\.id').size (), 1, 'removeTracks, Track 1 still exists');
        QUnit.equals ($('#id-mediums\\.2\\.tracklist\\.id').size (), 0, 'removeTracks, Track 2 was removed');

        a.discs[1].tracks[0].title.val ('Foo');
        a.discs[1].tracks[1].title.val ('Bar');
        a.discs[1].tracks[2].title.val ('Baz');

        a.discs[1].tracks[0].position.val ('2');
        a.discs[1].tracks[1].position.val ('3');
        a.discs[1].tracks[2].position.val ('1');

        a.discs[1].sort ();
        titles = a.discs[1].table.find ('td.title input.track-name');
        QUnit.equals (titles.eq(0).val (), 'Baz', 'Baz sorted to table row 0');
        QUnit.equals (titles.eq(1).val (), 'Foo', 'Foo sorted to table row 1');
        QUnit.equals (titles.eq(2).val (), 'Bar', 'Bar sorted to table row 2');

        $('input.artistcolumn').attr('checked', 'checked');
        a.discs[0].updateArtistColumn ();
        a.discs[1].updateArtistColumn ();
        ok (! a.discs[0].tracks[13].preview.attr ('disabled'), 'Artist column should be enabled');
        ok (! a.discs[1].tracks[0].preview.attr ('disabled'), 'Artist column should be enabled');
        $('input.artistcolumn').removeAttr('checked');
        a.discs[0].updateArtistColumn ();
        a.discs[1].updateArtistColumn ();
        ok (a.discs[0].tracks[13].preview.attr ('disabled'), 'Artist column should be disabled');
        ok (a.discs[1].tracks[0].preview.attr ('disabled'), 'Artist column should be disabled');

        var track_data = {
            'position': 5,
            'title': 'ST-God Back From Hell',
            'id': 8928778,
            'preview': 'Stu',
            'length': '4:08',
            'deleted': false
        };

        track = a.discs[1].getTrack (4);
        track.render (track_data);

        QUnit.equals (track.position.val (), '5', 'Track position rendered correctly');
        QUnit.equals (track.title.val (), 'ST-God Back From Hell', 'Track title rendered correctly');
        QUnit.equals (track.preview.val (), 'Stu', 'Track artist rendered correctly');
        QUnit.equals (track.length.val (), '4:08', 'Track length rendered correctly');
        QUnit.ok (! track.row.hasClass ('deleted'), 'Track not will not be deleted');

        track.toggleDelete ();

        QUnit.ok (track.row.hasClass ('deleted'), 'Track marked to be deleted');
        QUnit.ok (track.isDeleted, 'Track marked to be deleted');

    });
};
