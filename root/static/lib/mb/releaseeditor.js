
mbz.ReleaseEditor = {};
mbz.ReleaseEditor.live_update_timeout = 500;

/**
 * mbz.ReleaseEditor.Disc provides the tools neccesary to work with discs
 * as they appear on the advanced tab.
 */
mbz.ReleaseEditor.Disc = function (disc) {
    var self = mbz.Object ();

    /**
     * update() parses the track fields as they appear on the advanced
     * view of the tracklist tab.  (it updates the .tracks attribute).
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

    /**
     * addTrack adds a track to the tracklist on the advanced tab.
     *
     */
    var addTrack = function () {
        var table = $('table.medium').eq(self.number);
        var tracks = table.find ('tr.track').size ();
        var newartist;

        if (tracks)
        {
            // Add to existing tracklist
            var previous = table.find ('tr.track').last ();

            previous.after (mbz.template (self.tracktemplate, {
                tracklist: 'mediums.'+self.number+'.tracklist.tracks',
                trackno: tracks,
                position: tracks + 1,
            }));

            newartist = table.find ('tr.track').last ().find ('td.artist');
            newartist.append (previous.find ('td.artist > *').clone ());

            var trackid = new RegExp ("tracklist.tracks.[0-9]+");
            newartist.find('*').each (function (idx, element) {
                var item = $(element);
                var id = item.attr('id').replace(trackid, "tracklist.tracks."+tracks);
                var name = item.attr('name').replace(trackid, "tracklist.tracks."+tracks);
                item.attr ('id', id);
                item.attr ('name', name);
            });
        }
        else
        {
            // First track in tracklist
            table.find ('tbody').append (mbz.template (self.tracktemplate, {
                tracklist: 'mediums.'+self.number+'.tracklist.tracks',
                trackno: 0,
            }));

            newartist = table.find ('tr.track').last ().find ('td.artist');
            newartist.append ($('div#release-artist > *').clone ());

            var trackprefix = 'mediums.'+self.number+'.tracklist.tracks.0.';
            newartist.find('*').each (function (idx, element) {
                var item = $(element);
                var id = trackprefix + item.attr('id');
                var name = trackprefix + item.attr('name');
                item.attr ('id', id);
                item.attr ('name', name);
            });
        }

        /* keep self.tracks somewhat updated without re-parsing everything. */
        self.tracks.push ({
            'position': tracks + 1,
            'track': '',
            'artist': $(newartist).find('input.artist-credit-preview').val (),
            'length': '?:??',
        });
    };

    self.title = '';
    self.tracks = [];
    self.number = disc; // zero-based disc-number.
    self.tracktemplate = (
        '<tr class="track">' +
            '<td class="position">' +
            '  <input class="pos" id="id-#{tracklist}.#{trackno}.position"' +
            '         name="#{tracklist}.#{trackno}.position" value="#{position}" type="text">' +
            '</td>' +
            '<td class="title">' +
            '  <input id="id-#{tracklist}.#{trackno}.id" name="#{tracklist}.#{trackno}.id" value="" type="hidden">' +
            '  <input id="id-#{tracklist}.#{trackno}.name" name="#{tracklist}.#{trackno}.name" value="" type="text" class="track-name" >' +
            '</td>' +
            '<td class="artist"></td>' +
            '<td class="length">' +
            '  <input class="track-length" id="id-#{tracklist}.#{trackno}.length" name="#{tracklist}.#{trackno}.length" size="5" value="?:??" type="text">' +
            '</td>' +
            '<td class="delete"> </td>' +
         '</tr>'
    );

    self.update = update;
    self.fullTitle = fullTitle;
    self.addTrack = addTrack;

    $(".disc-add-track").live ('click', self.addTrack);

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

    /* make sure discs are initialized. */
    self.update ();

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
            mbz.TrackParser (disc).run ();
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




/**
 * mbz.ReleaseEditor.initialize sets up the following events:
 *
 *    - keep preview and basic/advanced tracklists synced
 *    - add track / disc buttons.
 *    - switching between basic/advanced tracklist view
 *    - highlighting inputs on the advanced view
 *    - removing the disabled="disabled" attribute before submit on track artists.
 */
mbz.ReleaseEditor.initialize = function () {

    /* keep preview and basic/advanced tracklists synced.
     * (constructing LiveUpdate will also initialize Preview and
     *  Disc objects, which take care of 'Add Track' buttons, etc..)
     */

    var liveupdate = mbz.ReleaseEditor.LiveUpdate ();
    liveupdate.update ();

    /* switch between basic / advanced view. */

    var moveMediumFields = function (from, to) {
        var discs = $('.basic-medium-format-and-title').size ();

        for (var i = 0; i < discs; i++)
        {
            $('.'+from+'-medium-format-and-title').eq(i).contents ().detach ().appendTo (
                $('.'+to+'-medium-format-and-title').eq(i));
        }
    };

    $("a[href=#advanced]").click (function () {
        moveMediumFields ('basic', 'advanced');
        $('.basic-tracklist').hide ();
        $('.advanced-tracklist').show ();
    });

    $("a[href=#basic]").click (function () {
        moveMediumFields ('advanced', 'basic');
        $('.advanced-tracklist').hide ();
        $('.basic-tracklist').show ();
        liveupdate.update ();
    });

    /* advanced view inputs */

    $('.advanced-tracklist tbody input').focus(function() {
        $(this).css('border','1px solid #FFBA58');
    });
    $('.advanced-tracklist tbody input').blur(function() {
        $(this).css('border','1px solid transparent');
    });

    $('.advanced-tracklist tr.track td.artist input').attr('disabled','disabled').css('color', '#AAA');
    $('.advanced-tracklist th.artist input').change(function() {
        if ($('.advanced-tracklist th.artist input:checked').val() != undefined)
        {
            $('.advanced-tracklist tr.track td.artist input').removeAttr('disabled').css('color', 'inherit');
        }
        else
        {
            $('.advanced-tracklist tr.track td.artist input').attr('disabled','disabled').css('color','#AAAAAA');
        }
    });

    $('form').bind ('submit', function () {
        $('.advanced-tracklist tr.track td.artist input').removeAttr('disabled');
    });

};
