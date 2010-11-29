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
        type: 76,
        clean: function(url) {
            // determine tld, asin from url, and build standard format [1],
            // if both were found. There used to be another [2], but we'll
            // stick to the new one for now.
            //
            // [1] "http://www.amazon.<tld>/gp/product/<ASIN>"
            // [2] "http://www.amazon.<tld>/exec/obidos/ASIN/<ASIN>"
            var tld = "", asin = "";
            if ((m = url.match(/amazon\.([a-z\.]+)\//)) != null) {
                tld = m[1];
            }
            if ((m = url.match(/\/([A-Z0-9]{10})(?:[/?]|$)/)) != null) {
                asin = m[1];
            }
            if (tld != "" && asin != "") {
                if (tld == "jp") tld = "co.jp";
                if (tld == "at") tld = "de";
                return "http://www.amazon." + tld + "/gp/product/" + asin;
            }

        }
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

var validation_rules = {
    // "has lyrics at" is only allowed for Lyric Wiki
    74: function() {
        return cleanups.lyricwiki.match.test($('#id-ar\\.url').val())
    }
}

function guess_type(current_url) {
    for each (var url in cleanups) {
        if(!url.match.test(current_url)) { continue; }
        return url.type;
    }
    return;
}

function clean_url(dirty_url) {
    for each (var group in cleanups) {
        if(!group.hasOwnProperty('clean') || !group.match.test(dirty_url)) 
            continue;

        return group.clean(dirty_url);
    }
    return dirty_url;
}
 
$(function() {
    var type_changed = function() {
        var checker = validation_rules[$('#id-ar\\.link_type_id').val()];
        $('button[type="submit"]').attr('disabled',
            !checker || checker() ? false : 'disabled');
    };
    var url_changed = function() {
        var url = $('#id-ar\\.url').val(),
            type = guess_type(url),
            clean = clean_url(url);

        $('#id-ar\\.link_type_id option[value="' + type +'"]')
            .attr('selected', 'selected');
        type_changed();

        $('#id-ar\\.url').val(clean);
    };

    $('#id-ar\\.url')
        .change(url_changed)
        .keyup(url_changed);
});
