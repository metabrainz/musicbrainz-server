

MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.ArtistCredit = function () {

    QUnit.module ("ReleaseEditor");
    QUnit.test ("ArtistCredit", function () {

        $('#placeholder').empty ();
        $('#placeholder').html (MB.tests.ReleaseEditor.html.information);

        var acv = MB.Control.ArtistCreditVertical (
            $('input#release-artist'), $('div.artist-credit')
        );

        QUnit.equals ($('.artist-credit-vertical:visible').size (), 0, 'Artist Credit form not visible');
        $('#release-artist').focus ();
        QUnit.equals ($('.artist-credit-vertical:visible').size (), 1, 'Artist Credit form visible after focus');

        var box0 = $('.artist-credit-box').eq(0);
        var box1 = $('.artist-credit-box').eq(1);

        box0.find ('input.name').val ('Metallica');
        box0.find ('input.credit').val ('Metallica');
        box0.find ('input.join').val (' (feat. ');
        box1.find ('input.name').val ('Britney Spears');
        box1.find ('input.credit').val ('Britney');
        box1.find ('input.join').val (')');

        /* triggering a blur event doesn't seem to work, so let's just call this directly... */
        acv.renderPreview ();

        QUnit.equals ($('#release-artist').val (), 'Metallica (feat. Britney)', 'Preview updated with correct artist name');

        $('#placeholder').empty ();

    });
};
