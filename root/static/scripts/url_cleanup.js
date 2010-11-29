/*
 *
// amazon:		new RegExp("^(http://)?([^/]+\.)?amazon\.(com|ca|co\.uk|fr|at|de|co\.jp|jp)","i"),
// archive:	new RegExp("^(http://)?([^/]+\.)?archive\.org/.*\.(jpg|jpeg|png|gif)$","i"),
// cdbaby:		new RegExp("^(http://)?([^/]+\.)?cdbaby\.(com|name)","i"),
// jamendo:	new RegExp("^(http://)?([^/]+\.)?jamendo\.com","i"),
// encyclopedisque:	new RegExp("^(http://)?([^/]+\.)?encyclopedisque\.fr/images/.*\.jpg","i"),
// manjdisc:	new RegExp("^(http://)?([^/]+\.)?mange-disque\.tv/(fs/md_|fstb/tn_md_|info_disque\.php3\\?dis_code=)[0-9]+","i"),
// lyricwiki:      new RegExp("^(http://)?([^/]+\.)?lyrics\.wikia\.com", "i"),
*/

var cleanups = {
    wikipedia: {
        match: new RegExp("^(http://)?([^/]+\.)?wikipedia\.","i"),
        type: 180
    },
    discogs: {
        match: new RegExp("^(https?://)?([^/]+\.)?discogs\.com","i"),
        type: 181
    },
    musicmoz: {
        match: new RegExp("^(http://)?([^/]+\.)?musicmoz\.","i"),
        type: 182
    },
    imdb: {
        match: new RegExp("^(http://)?([^/]+\.)?imdb\.com","i"),
        type: 179
    },
    myspace: {
        match: new RegExp("^(http://)?([^/]+\.)?myspace\.com","i"),
        type: 190
    },
    purevolume: {
        match: new RegExp("^(http://)?([^/]+\.)?purevolume\.com","i"),
        type: 175
    }
};

function cleanup(current_url) {
    for each (var url in cleanups) {
        if(!url.match.test(current_url)) { continue; }
        $('#id-ar\\.link_type_id option[value="' + url.type +'"]')
            .attr('selected', 'selected');
        return;
    }
}
   
$(function() {
    var change_handler = function() {
        cleanup($('#id-ar\\.url').val());
    };
    $('#id-ar\\.url')
        .change(change_handler)
        .keyup(change_handler);
});
