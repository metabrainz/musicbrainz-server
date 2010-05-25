
mbz.ReleaseEditor = {};
mbz.ReleaseEditor.live_update_timeout = 500;

/**
 * mbz.ReleaseEditor.Disc provides the tools neccesary to work with discs
 * as they appear on the advanced tab.
 */
mbz.ReleaseEditor.Disc = function (disc) {
    var self = mbz.Object ();

    /**
     * update parses the track fields as they appear on the advanced
     * view of the tracklist tab.
     */
    var update = function () {

        self.tracks = [];

        $('table.medium').eq(self.number).find('tr.track').each (function (idx, item) {
            self.tracks.push ({
                'position': $(item).find('td.position input').val (),
                'track': $(item).find('td.title input.track-name').val (),
                'artist': $(item).find('td.artist input.artist-credit-preview').val (),
                'length': $(item).find('td.length input').val ()
            });
        });

        self.title = $('#id-mediums\\.'+self.number+'\\.name').val ();
    };

    /**
     * fullTitle returns the disc title prefixed with 'Disc #: '.  Or just
     * 'Disc #' if the disc doesn't have a title.
     */
    var fullTitle = function () {
        return 'Disc ' + (self.number + 1) + (self.title ? ': '+self.title : '');
    };

    self.title = '';
    self.tracks = [];
    self.number = disc; // zero-based disc-number.

    self.update = update;
    self.fullTitle = fullTitle;

    return self;
};

/**
 * mbz.ReleaseEditor.Preview is used to render the preview and textareas.
 */
mbz.ReleaseEditor.Preview = function () {
    var self = mbz.Object ();

    var update = function () {
        $.each (self.discs, function (idx, disc) {
            disc.update ();
        });
    };

    var renderPreview = function () {
        var preview = $('#preview').html ('');

        $.each (self.discs, function (idx, disc) {

            $('<h3>').text (disc.fullTitle ()).appendTo (preview);

            var table = $('<table class="preview">').appendTo(preview);

            $.each (disc.tracks, function (idx, item) {
                var tr = $('<tr>').appendTo (table);
                $('<td class="trackno">').text (item.position).appendTo (tr);
                $('<td>').text (item.track).appendTo (tr);
                $('<td class="duration">').text (item.length).appendTo (tr);
            });

        });
    };

    var renderTextAreas = function () {

        $.each (self.discs, function (idx, disc) {
            var str = "";

            $.each (disc.tracks, function (idx, item) {
                str += item.position + ". " + item.track;
                if (item.length)
                {
                    str += " (" + item.length + ")";
                }
                str += "\n";
            });

            $('#mediums\\.'+disc.number+'\\.tracklist').val (str);
         });

    };

    self.discs = [];

    var discs = $('.basic-medium-format-and-title').size ();
    for (var i = 0; i < discs; i++)
    {
        self.discs.push (mbz.ReleaseEditor.Disc (i));
    }

    self.update = update;
    self.renderPreview = renderPreview;
    self.renderTextAreas = renderTextAreas;

    return self;
};

/**
 * mbz.ReleaseEditor.LiveUpdate is used to make sure all the places where
 * data appears on the tracklist tab are kept up-to-date with eachother.
 */
mbz.ReleaseEditor.LiveUpdate = function () {
    var self = mbz.Object ();

    var previewUpdate = function () {
        $.each (self.preview.discs, function (idx, disc) {
            mbz.TrackParser (idx).run ();
        });

        self.preview.update ();
        self.preview.renderPreview ();
    };

    var update = function () {
        self.preview.update ();
        self.preview.renderPreview ();
        self.preview.renderTextAreas ();
    };

    $("textarea.tracklist").live ('keyup', function () {
        if (typeof self.timeout == "number")
        {
            clearTimeout (self.timeout);
        }

        self.timeout = setTimeout (function () {
            delete self.timeout;
            self.previewUpdate ();
        }, mbz.ReleaseEditor.live_update_timeout);

    });

    self.preview = mbz.ReleaseEditor.Preview ();

    self.previewUpdate = previewUpdate;
    self.update = update;

    return self;
};
