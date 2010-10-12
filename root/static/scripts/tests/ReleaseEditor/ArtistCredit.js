

MB.tests.ReleaseEditor = (MB.tests.ReleaseEditor) ? MB.tests.ReleaseEditor : {};

MB.tests.ReleaseEditor.ArtistCredit = function () {

    QUnit.module ("ReleaseEditor");
    QUnit.test ("ArtistCredit", function () {

        $('#placeholder').empty ();
        $('#placeholder').html (MB.tests.ReleaseEditor.data['ReleaseEditor/information.html']);

        var acv = MB.Control.ArtistCreditVertical (
            $('#release-artist'), $('div.artist-credit')
        );

        var bc = MB.Control.BubbleCollection (
            $('#release-artist'), $('div.artist-credit')
        );

        QUnit.equals ($('.artist-credit-container:visible').size (), 0, 'Artist Credit form not visible');
        $('#release-artist').focus ();
        QUnit.equals ($('.artist-credit-container:visible').size (), 1, 'Artist Credit form visible after focus');

        var box0 = $('.artist-credit-box').eq(0);
        box0.find ('input.name').focus ().val ('Metallica').blur ();
        box0.find ('input.credit').focus ().val ('Metallica').blur ();
        box0.find ('input.join').focus ().val (' (feat. ').blur ();

        var box1 = $('.artist-credit-box').eq(1);
        box1.find ('input.name').focus ().val ('Britney Spears').blur ();
        box1.find ('input.credit').focus ().val ('Britney').blur ();
        box1.find ('input.join').focus ().val (')').blur ();

        QUnit.equals ($('#release-artist').val (), 'Metallica (feat. Britney)', 'Preview updated with correct artist name');

        $('#placeholder').empty ();

    });

    QUnit.test ("ArtistCredit on Add Release", function () {

        $('#placeholder').empty ();
        $('#placeholder').html (MB.tests.ReleaseEditor.data['ReleaseEditor/information.addrelease.html']);

        var acv = MB.Control.ArtistCreditVertical (
            $('#release-artist'), $('div.artist-credit')
        );

        var bc = MB.Control.BubbleCollection (
            $('#release-artist'), $('div.artist-credit')
        );

        QUnit.equals ($('.artist-credit-vertical:visible').size (), 0, 'Artist Credit form not visible');
        $('#release-artist').focus ();
        QUnit.equals ($('.artist-credit-container:visible').size (), 1, 'Artist Credit form visible after focus');

        var box0 = $('.artist-credit-box').eq(0);
        box0.find ('input.name').focus ().val ('Metallica').blur ();
        box0.find ('input.credit').focus ().val ('Metallica').blur ();
        box0.find ('input.join').focus ().val (' (feat. ').blur ();

        var box1 = $('.artist-credit-box').eq(1);
        box1.find ('input.name').focus ().val ('Britney Spears').blur ();
        box1.find ('input.credit').focus ().val ('Britney').blur ();
        box1.find ('input.join').focus ().val (')').blur ();

        QUnit.equals ($('#release-artist').val (), 'Metallica (feat. Britney)', 'Preview updated with correct artist name');

        $('#placeholder').empty ();

    });
};
