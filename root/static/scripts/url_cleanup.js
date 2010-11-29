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
    },
    amazon: {
        match: new RegExp("^(http://)?([^/]+\.)?amazon\.(com|ca|co\.uk|fr|at|de|co\.jp|jp)","i"),
        type: 76
    },
    archive: {
        match: new RegExp("^(http://)?([^/]+\.)?archive\.org/.*\.(jpg|jpeg|png|gif)$","i"),
        type: 77
    },
    cdbaby: {
        match: new RegExp("^(http://)?([^/]+\.)?cdbaby\.(com|name)","i"),
        type: 77
    },
    jamendo: {
        match: new RegExp("^(http://)?([^/]+\.)?jamendo\.com","i"),
        type: 77
    },
    encyclopedisque: {
        match: new RegExp("^(http://)?([^/]+\.)?encyclopedisque\.fr/images/.*\.jpg","i"),
        type: 77
    },
    manjdisc: {
        match: new RegExp("^(http://)?([^/]+\.)?mange-disque\.tv/(fs/md_|fstb/tn_md_|info_disque\.php3\\?dis_code=)[0-9]+","i"),
        type: 77
    },
    lyricwiki: {
        match: new RegExp("^(http://)?([^/]+\.)?lyrics\.wikia\.com", "i"),
        type: 74
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
