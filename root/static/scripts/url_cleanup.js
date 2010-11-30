var cleanups = {
    wikipedia: {
        match: new RegExp("^(http://)?([^/]+\.)?wikipedia\.","i"),
        type: { artist: 180, label: 218, release_group: 89 }
    },
    discogs: {
        match: new RegExp("^(https?://)?([^/]+\.)?discogs\.com","i"),
        type: { release: 72, release_group: 90, artist: 181, label: 219 },
        clean: function(url) {
            return url.replace(/^https?:\/\/([^.]+\.)?discogs\.com\/(.*\/(artist|release|master|label))?/, "http://www.discogs.com/$3");
        }
    },
    musicmoz: {
        match: new RegExp("^(http://)?([^/]+\.)?musicmoz\.","i"),
        type: { release: 73, artist: 182 }
    },
    imdb: {
        match: new RegExp("^(http://)?([^/]+\.)?imdb\.com","i"),
        type: { release_group: 97, artist: 179 }
    },
    myspace: {
        match: new RegExp("^(http://)?([^/]+\.)?myspace\.com","i"),
        type: { artist: 190, label: 217 }
    },
    purevolume: {
        match: new RegExp("^(http://)?([^/]+\.)?purevolume\.com","i"),
        type: { artist: 175 }
    },
    amazon: {
        match: new RegExp("^(http://)?([^/]+\.)?amazon\.(com|ca|co\.uk|fr|at|de|co\.jp|jp)","i"),
        type: { release: 76 },
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
        type: { release: 77 },
        clean: function(url) { 
            url = url.replace(/\/http:\/\//, "/");
			return url.replace(/http:\/\/(.*)\.archive.org\/\d\/items\/(.*)\/(.*)/, "http://www.archive.org/download/$2/$3");
        }
    },
    cdbaby: {
        match: new RegExp("^(http://)?([^/]+\.)?cdbaby\.(com|name)","i"),
        type: { release: 77 }
    },
    jamendo: {
        match: new RegExp("^(http://)?([^/]+\.)?jamendo\.com","i"),
        type: { release: 77 },
        clean: function(url) {
            url =  url.replace(/jamendo\.com\/\w\w\/album\//, "jamendo.com/album/");
            url =  url.replace(/img\.jamendo\.com\/albums\/(\d+)\/covers\/\d+\.\d+\.jpg/, "www.jamendo.com/album/$1/");
            return url.replace(/jamendo\.com\/\w\w\/artist\//, "jamendo.com/artist/");
        }
    },
    encyclopedisque: {
        match: new RegExp("^(http://)?([^/]+\.)?encyclopedisque\.fr/images/.*\.jpg","i"),
        type: { release: 77 },
        clean: function(url) {
            return url.replace(/images\/imgdb\/thumb250\//, "images/imgdb/main/");
        }
    },
    manjdisc: {
        match: new RegExp("^(http://)?([^/]+\.)?mange-disque\.tv/(fs/md_|fstb/tn_md_|info_disque\.php3\\?dis_code=)[0-9]+","i"),
        type: { release: 77 },
        clean: function(url) {
            return url.replace(/(www\.)?mange-disque\.tv\/(fstb\/tn_md_|fs\/md_|info_disque\.php3\?dis_code=)(\d+)(\.jpg)?/,
                "www.mange-disque.tv/fs/md_$3.jpg");
        }
    },
    lyricwiki: {
        match: new RegExp("^(http://)?([^/]+\.)?lyrics\.wikia\.com", "i"),
        type: { release: 74 }
    }
};

var validation_rules = {
    // "has lyrics at" is only allowed for Lyric Wiki
    74: function() {
        return cleanups.lyricwiki.match.test($('#id-ar\\.url').val())
    }
}

function guess_type(source_type, current_url) {
    for (var group in cleanups) {
        if(!cleanups.hasOwnProperty(group)) { continue; }
        
        var cleanup = cleanups[group];
        if(!cleanup.match.test(current_url)) { continue; }
        return cleanup.type[source_type];
    }
    return;
}

function clean_url(dirty_url) {
    for (var group in cleanups) {
        if(!cleanups.hasOwnProperty(group)) { continue; }

        var cleanup = cleanups[group];
        if(!cleanup.hasOwnProperty('clean') || !cleanup.match.test(dirty_url)) 
            continue;

        return cleanup.clean(dirty_url);
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
            clean = clean_url(url),
            type = guess_type($('#id-ar\\.type').val(), clean);

        $('#id-ar\\.url').val(clean);
        $('#id-ar\\.link_type_id option[value="' + type +'"]')
            .attr('selected', 'selected');
        type_changed();
    };

    $('#id-ar\\.url')
        .change(url_changed)
        .keyup(url_changed);
});
