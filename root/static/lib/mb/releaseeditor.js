
mbz.ReleaseEditor = {};
mbz.ReleaseEditor.live_update_timeout = 500;
mbz.ReleaseEditor.disabled_colour = '#AAA';

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
     * removeTrack toggles the .deleted hidden input and renders a pending delete
     * in the release editor.
     */
    var removeTrack = function (trackno) {
        var input = $('#id-mediums\\.'+self.number+'\\.tracklist\\.tracks\\.'+trackno+'\\.deleted');
        var deleted = !parseInt (input.val ());
        var row = input.closest ('tr');
        if (deleted)
        {
            input.val('1');
            row.addClass('deleted');
            row.find ('input.pos').val ('');
        }
        else
        {
            input.val ('0');
            row.removeClass('deleted');
        }
        var trackpos = row.find ('input.pos').val ();

        row.closest ('tbody').find ('tr').not ('tr.deleted').each (
            function (idx, elem) {
                $(elem).find('input.pos').val (idx + 1);
            }
        );
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
                position: 1,
            }));

            newartist = table.find ('tr.track').last ().find ('td.artist');
            newartist.append ($('div#release-artist > *').clone ());
            newartist.find ('.artist-credit-preview').
                attr ('disabled', 'disabled').
                css ('color', mbz.ReleaseEditor.disabled_colour);

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

        /* and scroll down to the new position of the 'Add Track' button if possible. */
        var newpos = $('html').scrollTop () + table.find ('tr.track').last ().height ();
        $('html').animate({ scrollTop: newpos }, 100);
    };

    self.title = '';
    self.tracks = [];
    self.number = disc; // zero-based disc-number.

    // FIXME: hardcoded static url in this template. --warp.
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
            '<td class="delete">'+
            '  <input type="hidden" value="0" name="#{tracklist}.#{trackno}.deleted" id="id-#{tracklist}.#{trackno}.deleted" />' +
            '  <a class="disc-remove-track" href="#remove_track">' +
            '    <img src="/static/images/release_editor/remove-track.png" title="Remove Track" />' +
            '  </a>' +
            '</td>' +
         '</tr>'
    );

    self.update = update;
    self.fullTitle = fullTitle;
    self.removeTrack = removeTrack;
    self.addTrack = addTrack;

    $("#mediums\\."+self.number+"\\.add_track").click(self.addTrack);
    
    return self;
};

/**
 * mbz.ReleaseEditor.Preview is used to render the preview and textareas.
 * (it is therefore not accurately named. FIXME. --warp).
 *
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

    var addDisc = function () {

        var discs = $('.basic-disc').size ();
        var lastdisc_bas = $('.basic-disc').last ();
        var lastdisc_adv = $('.advanced-disc').last ();

        var newdisc_bas = lastdisc_bas.clone ().insertAfter (lastdisc_bas);
        var newdisc_adv = lastdisc_adv.clone ().insertAfter (lastdisc_adv);

        newdisc_adv.find ('tbody').empty ();

        var h3 = newdisc_bas.find ("h3");
        h3.text (h3.text ().replace (/[0-9]+/, discs + 1));

        var legend = newdisc_adv.find ("legend");
        legend.text (legend.text ().replace (/[0-9]+/, discs + 1));

        var mediumid = new RegExp ("mediums.[0-9]+");
        var update_ids = function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').replace(mediumid, "mediums."+discs));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').replace(mediumid, "mediums."+discs));
            }
        };

        newdisc_bas.find ("*").each (update_ids);
        newdisc_adv.find ("*").each (update_ids);

        /* clear the cloned rowid for this medium, so a new medium will be created. */
        $("#id-mediums\\."+discs+"\\.id").val('');

        $("#id-mediums\\."+discs+"\\.position").val(discs + 1);

        self.discs.push (mbz.ReleaseEditor.Disc (discs));

        newdisc_bas.find ('textarea').empty ();

        /* and scroll down to the new position of the 'Add Disc' button if possible. */
        /* FIXME: this hardcodes the fieldset bottom margin, shouldn't do that. */
        var newpos = lastdisc_adv.height () ? lastdisc_adv.height () + 12 : lastdisc_bas.height ();
        $('html').animate({ scrollTop: $('html').scrollTop () + newpos }, 500);
    };

    var removeTrack = function (event) {

        /* figure out which track needs to be deleted, then call removeTrack
           on the appropriate disc object with those details. */
        var matches = $(this).prev ("input[type=hidden]").attr ('id').match (
                /mediums\.([0-9]+)\.tracklist.tracks.([0-9]+)/)
        var disc = matches[1];
        var track = matches[2];

        if (disc && track)
        {
            self.discs[disc].removeTrack (track);
        }
    };

    self.discs = [];

    var discs = $('.basic-disc').size ();
    for (var i = 0; i < discs; i++)
    {
        self.discs.push (mbz.ReleaseEditor.Disc (i));
    }


    self.update = update;
    self.renderPreview = renderPreview;
    self.renderTextAreas = renderTextAreas;
    self.addDisc = addDisc;
    self.removeTrack = removeTrack;

    /* make sure discs are initialized. */
    self.update ();

    $("a[href=#add_disc]").click (self.addDisc);
    $("a[href=#remove_track]").live ('click', self.removeTrack);

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
        var discs = $('.basic-disc').size ();

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

    /* FIXME: should only toggle the artist column for the associated disc. */
    $('.advanced-tracklist tr.track td.artist input').attr('disabled','disabled').css('color', mbz.ReleaseEditor.disabled_colour);
    $('.advanced-tracklist th.artist input').live ('change', function() {
        if ($('.advanced-tracklist th.artist input:checked').val() != undefined)
        {
            $('.advanced-tracklist tr.track td.artist input').removeAttr('disabled').css('color', 'inherit');
        }
        else
        {
            $('.advanced-tracklist tr.track td.artist input').attr('disabled','disabled').css('color', mbz.ReleaseEditor.disabled_colour);
        }
    });

    $('form').bind ('submit', function () {
        $('.advanced-tracklist tr.track td.artist input').removeAttr('disabled');
    });

};
