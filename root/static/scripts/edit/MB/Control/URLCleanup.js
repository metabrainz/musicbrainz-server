/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

MB.constants.LINK_TYPES = {
    wikipedia: {
        artist: 179,
        label: 216,
        release_group: 89,
        work: 279
    },
    discogs: {
        release: 76,
        release_group: 90,
        artist: 180,
        label: 217
    },
    imdb: {
        release_group: 97,
        artist: 178
    },
    myspace: {
        artist: 189,
        label: 215
    },
    purevolume: {
        artist: 174
    },
    allmusic: {
        artist: 283,
        release_group: 284,
        work: 286,
        recording: 285
    },
    amazon: {
        release: 77
    },
    coverart: {
        release: 78
    },
    license: {
        release: 301,
        recording: 302
    },
    lyrics: {
        artist: 197,
        release_group: 93,
        work: 271
    },
    bbcmusic: {
        artist: 190
    },
    discography: {
        artist: 184
    },
    mailorder: {
        artist: 175,
        release: 79
    },
    downloadpurchase: {
        artist: 176,
        release: 74,
        recording: 254
    },
    downloadfree: {
        artist: 177,
        release: 75,
        recording: 255
    },
    microblog: {
        artist: 198,
        label: 223
    },
    review: {
        release_group: 94
    },
    score: {
        release_group: 92,
        work: 274
    },
    secondhandsongs: {
        work: 280
    },
    songfacts: {
        work: 289
    },
    socialnetwork: {
        artist: 192,
        label: 218
    },
    soundcloud: {
        artist:291,
        label: 290
    },
    streamingmusic: {
        recording: 268
    },
    vgmdb: {
        artist: 191,
        release: 86,
        label: 210
    },
    youtube: {
        artist: 193,
        label: 225,
        recording: 268
    },
    otherdatabases: {
        artist: 188,
        label: 222,
        release_group: 96,
        release: 82,
        work: 273,
        recording: 306
    }
};

MB.constants.CLEANUPS = {
    wikipedia: {
        match: new RegExp("^(https?://)?(([^/]+\\.)?wikipedia|secure\\.wikimedia)\\.","i"),
        type: MB.constants.LINK_TYPES.wikipedia,
        clean: function(url) {
            url =  url.replace(/^https:\/\/secure\.wikimedia\.org\/wikipedia\/([a-z-]+)\/wiki\/(.*)/, "http://$1.wikipedia.org/wiki/$2");
            url =  url.replace(/^https:\/\//, "http://");
            url =  url.replace(/\.wikipedia\.org\/w\/index\.php\?title=([^&]+).*/, ".wikipedia.org/wiki/$1");
            url =  url.replace(/(?:\.m)?\.wikipedia\.org\/[a-z-]+\/([^?]+)$/, ".wikipedia.org/wiki/$1");
            if ((m = url.match(/^(.*\.wikipedia\.org\/wiki\/)([^?#]+)(.*)$/)) != null)
                url = m[1] + encodeURIComponent(decodeURIComponent(m[2])).replace(/%20/g, "_").replace(/%24/g, "$").replace(/%2C/g, ",").replace(/%2F/g, "/").replace(/%3A/g, ":").replace(/%3B/g, ";").replace(/%40/g, "@") + m[3];
            return url;
        }
    },
    discogs: {
        match: new RegExp("^(https?://)?([^/]+\\.)?discogs\\.com","i"),
        type: MB.constants.LINK_TYPES.discogs,
        clean: function(url) {
            url = url.replace(/\/viewimages\?release=([0-9]*)/, "/release/$1");
            url = url.replace(/^https?:\/\/([^.]+\.)?discogs\.com\/(.*\/(artist|release|master|label))?([^#?]*).*$/, "http://www.discogs.com/$3$4");
            if ((m = url.match(/^(http:\/\/www\.discogs\.com\/(?:artist|label))\/(.+)/)) != null)
                url = m[1] + "/" + encodeURIComponent(decodeURIComponent(m[2].replace(/\+/g, "%20"))).replace(/%20/g, "+");
            return url;
        }
    },
    imdb: {
        match: new RegExp("^(https?://)?([^/]+\\.)?imdb\\.","i"),
        type: MB.constants.LINK_TYPES.imdb,
        clean: function(url) {
            return url.replace(/^https?:\/\/([^.]+\.)?imdb\.(com|de|it|es|fr|pt)\/([a-z]+\/[a-z0-9]+)(\/.*)*$/, "http://www.imdb.com/$3/");
        }
    },
    myspace: {
        match: new RegExp("^(https?://)?([^/]+\\.)?myspace\\.(com|de|fr)","i"),
        type: MB.constants.LINK_TYPES.myspace,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?([^.]+\.)?myspace\.(com|de|fr)/, "http://www.myspace.com");
        }
    },
    purevolume: {
        match: new RegExp("^(https?://)?([^/]+\\.)?purevolume\\.com","i"),
        type: MB.constants.LINK_TYPES.purevolume
    },
    allmusic: {
        match: new RegExp("^(https?://)?([^/]+\\.)?allmusic\\.com","i"),
        type: MB.constants.LINK_TYPES.allmusic,
        clean: function(url) {
            return url.replace(/^https?:\/\/(?:[^.]+\.)?allmusic\.com\/(artist|album|composition|song|performance)\/(?:[^\/]*-)?((?:mn|mw|mc|mt|mq)[0-9]+).*/, "http://www.allmusic.com/$1/$2");
        }
    },
    amazon: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(amazon\\.(com|ca|co\\.uk|fr|at|de|it|co\\.jp|jp|cn|es)|amzn\\.com)","i"),
        type: MB.constants.LINK_TYPES.amazon,
        clean: function(url) {
            // determine tld, asin from url, and build standard format [1],
            // if both were found. There used to be another [2], but we'll
            // stick to the new one for now.
            //
            // [1] "http://www.amazon.<tld>/gp/product/<ASIN>"
            // [2] "http://www.amazon.<tld>/exec/obidos/ASIN/<ASIN>"
            var tld = "", asin = "";
            if ((m = url.match(/(?:amazon|amzn)\.([a-z\.]+)\//)) != null) {
                tld = m[1];
                if (tld == "jp") tld = "co.jp";
                if (tld == "at") tld = "de";
            }

            if ((m = url.match(/\/e\/([A-Z0-9]{10})(?:[/?&%#]|$)/)) != null) { // artist pages
                return "http://www.amazon." + tld + "/-/e/" + m[1];
            } else if ((m = url.match(/\/(?:product|dp)\/(B00[0-9A-Z]{7}|[0-9]{9}[0-9X])(?:[/?&%#]|$)/)) != null) { // strict regex to catch most ASINs
                asin = m[1];
            } else if ((m = url.match(/(?:\/|\ba=)([A-Z0-9]{10})(?:[/?&%#]|$)/)) != null) { // if all else fails, find anything that could be an ASIN
                asin = m[1];
            }
            if (tld != "" && asin != "") {
                return "http://www.amazon." + tld + "/gp/product/" + asin;
            }

        }
    },
    archive: {
        match: new RegExp("^(https?://)?([^/]+\\.)?archive\\.org/.*\\.(jpg|jpeg|png|gif)(\\?cnt=\\d+)?$","i"),
        type: MB.constants.LINK_TYPES.coverart,
        clean: function(url) { 
            url = url.replace(/\?cnt=\d+$/, "");
            return url.replace(/http:\/\/(.*)\.archive.org\/\d+\/items\/(.*)\/(.*)/, "http://www.archive.org/download/$2/$3");
        }
    },
    cdbaby: {
        match: new RegExp("^(https?://)?([^/]+\\.)?cdbaby\\.(com|name)","i"),
        clean: function(url) {
            if ((m = url.match(/(?:https?:\/\/)?(?:www\.)?cdbaby\.com\/cd\/([^\/]+)(\/(from\/[^\/]+)?)?/)) != null)
                url = "http://www.cdbaby.com/cd/" + m[1].toLowerCase();
            url = url.replace(/(?:https?:\/\/)?(?:www\.)?cdbaby\.com\/Images\/Album\/([a-z0-9]+)(?:_small)?\.jpg/, "http://www.cdbaby.com/cd/$1");
            return url.replace(/(?:https?:\/\/)?(?:images\.)?cdbaby\.name\/.\/.\/([a-z0-9]+)(?:_small)?\.jpg/, "http://www.cdbaby.com/cd/$1");
        }
    },
    itunes: {
        match: new RegExp("^https?://itunes.apple.com/", "i"),
        type: MB.constants.LINK_TYPES.downloadpurchase,
        clean: function(url) {
            return url.replace(/^https?:\/\/itunes\.apple\.com\/([a-z]{2}\/)?(artist|album|music-video|preorder)\/([a-z0-9!.-]+\/)?(id[0-9]+)(\?.*)?$/, "http://itunes.apple.com/$1$2/$4");
        }
    },
    jamendo: {
        match: new RegExp("^(https?://)?([^/]+\\.)?jamendo\\.com","i"),
        type: MB.constants.LINK_TYPES.downloadfree,
        clean: function(url) {
            url =  url.replace(/jamendo\.com\/(?:\w\w\/)?(album|list|track)\/([^\/]+)(\/.*)?$/, "jamendo.com/$1/$2");
            url =  url.replace(/img\.jamendo\.com\/albums\/(\d+)\/covers\/\d+\.\d+\.jpg/, "www.jamendo.com/album/$1/");
            url =  url.replace(/jamendo\.com\/\w\w\/artist\//, "jamendo.com/artist/");
            return url;
        }
    },
    manjdisc: {
        match: new RegExp("^(https?://)?([^/]+\\.)?mange-disque\\.tv/(fs/md_|fstb/tn_md_|info_disque\\.php3\\?dis_code=)[0-9]+","i"),
        type: MB.constants.LINK_TYPES.coverart,
        clean: function(url) {
            return url.replace(/(www\.)?mange-disque\.tv\/(fstb\/tn_md_|fs\/md_|info_disque\.php3\?dis_code=)(\d+)(\.jpg)?/,
                "www.mange-disque.tv/fs/md_$3.jpg");
        }
    },
    license: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(artlibre\\.org/licence|creativecommons\\.org/(licenses|publicdomain)/)", "i"),
        type: MB.constants.LINK_TYPES.license,
        clean: function(url) {
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?creativecommons\.org\//, "http://creativecommons.org/");
            url = url.replace(/^http:\/\/creativecommons\.org\/(licenses|publicdomain)\/(.+)\/((legalcode|deed)((\.|-)[A-Za-z_]+)?)?/, "http://creativecommons.org/$1/$2/");

            // make sure there is exactly one terminating slash
            url = url.replace(/^(http:\/\/creativecommons\.org\/licenses\/(?:by|(?:by-|)(?:nc|nc-nd|nc-sa|nd|sa)|(?:nc-|)sampling\+?)\/[0-9]+\.[0-9]+(?:\/(?:ar|au|at|be|br|bg|ca|cl|cn|co|cr|hr|cz|dk|ec|ee|fi|fr|de|gr|gt|hk|hu|in|ie|il|it|jp|lu|mk|my|mt|mx|nl|nz|no|pe|ph|pl|pt|pr|ro|rs|sg|si|za|kr|es|se|ch|tw|th|uk|scotland|us|vn)|))\/*$/, "$1/");
            url = url.replace(/^(http:\/\/creativecommons\.org\/publicdomain\/zero\/[0-9]+\.[0-9]+)\/*$/, "$1/");
            url = url.replace(/^(http:\/\/creativecommons\.org\/licenses\/publicdomain)\/*$/, "$1/");

            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?artlibre\.org\//, "http://artlibre.org/");
            url = url.replace(/^http:\/\/artlibre\.org\/licence\.php\/lal\.html/, "http://artlibre.org/licence/lal");
            return url;
        }
    },
    lyrics: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(lyrics\\.wikia\\.com|directlyrics\\.com|lyricstatus\\.com|kasi-time\\.com|wikisource\\.org)", "i"),
        type: MB.constants.LINK_TYPES.lyrics
    },
    bbcmusic: {
        match: new RegExp("^(https?://)?(www\\.)?bbc\\.co\\.uk/music/artists/", "i"),
        type: MB.constants.LINK_TYPES.bbcmusic
    },
    discography: {
        match: new RegExp("^(https?://)?(www\\.)?metal-archives\\.com/band\\.php", "i"),
        type: MB.constants.LINK_TYPES.discography
    },
    microblog: {
        match: new RegExp("^(https?://)?(www\\.)?twitter\\.com/", "i"),
        type: MB.constants.LINK_TYPES.microblog,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?(www\.)?twitter\.com(\/#!)?/, "http://twitter.com");
        }
    },
    ozonru: {
        match: new RegExp("^(https?://)?(www\\.)?ozon\\.ru/context/detail/id/", "i"),
        type: MB.constants.LINK_TYPES.mailorder
    },
    review: {
        match: new RegExp("^(https?://)?(www\\.)?(bbc\\.co\\.uk/music/reviews/|metal-archives\\.com/review\\.php)", "i"),
        type: MB.constants.LINK_TYPES.review
    },
    score: {
        match: new RegExp("^(https?://)?(www\\.)?(imslp\\.org/)", "i"),
        type: MB.constants.LINK_TYPES.score
    },
    secondhandsongs: {
        match: new RegExp("^(https?://)?([^/]+\\.)?secondhandsongs\\.com/", "i"),
        type: MB.constants.LINK_TYPES.secondhandsongs
    },
    songfacts: {
        match: new RegExp("^(https?://)?([^/]+\\.)?songfacts\\.com/", "i"),
        type: MB.constants.LINK_TYPES.songfacts
    },
    socialnetwork: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(facebook\\.com|last\\.fm|lastfm\\.(at|br|de|es|fr|it|jp|pl|pt|ru|se|com\\.tr)|plus.google.com)/", "i"),
        type: MB.constants.LINK_TYPES.socialnetwork,
        clean: function(url) {
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?facebook\.com(\/#!)?/, "http://www.facebook.com");
            if (url.match (/^http:\/\/www\.facebook\.com.*$/))
            {
                  // Remove ref (where the user came from) and sk (subpages in a page, since we want the main link)
                  url = url.replace(/([&?])(sk|ref)=([^?&]*)/, "$1");
                  // Ensure the first parameter left uses ? not to break the URL
                  url = url.replace(/([&?])&/, "$1");
                  url = url.replace(/[&?]$/, "");
            }
            url = url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(at|br|de|es|fr|it|jp|pl|pt|ru|se|com\.tr))/, "http://www.last.fm");
            url = url.replace(/^http:\/\/www\.last\.fm\/music\/([^?]+).*/, "http://www.last.fm/music/$1");
            url = url.replace(/^(?:https?:\/\/)?plus\.google\.com\/(?:u\/[0-9]\/)?([0-9]+)(\/.*)?$/, "https://plus.google.com/$1");
            return url;
        }
    },
    soundcloud: {
        match: new RegExp("^(https?://)?([^/]+\\.)?soundcloud\\.com","i"),
        type: MB.constants.LINK_TYPES.soundcloud,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?(www\.)?soundcloud\.com(\/#!)?/, "http://soundcloud.com");
        }
    },
    spotify: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(spotify\\.com)", "i"),
        type: MB.constants.LINK_TYPES.streamingmusic,
        clean: function(url) {
            url = url.replace(/^https?:\/\/embed\.spotify\.com\/\?uri=spotify:([a-z]+):([a-zA-Z0-9_-]+)$/, "http://open.spotify.com/$1/$2");
            return url;
        }
    },
    vimeo: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(vimeo\\.com/)", "i"),
        type: MB.constants.LINK_TYPES.streamingmusic,
        clean: function(url) {
            url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?vimeo\.com/, "http://vimeo.com");
            // Remove query string, just the video id should be enough.
            url = url.replace(/\?.*/, "");
	    return url;
        }
    },
    youtube: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(youtube\\.com/|youtu\\.be/)", "i"),
        type: MB.constants.LINK_TYPES.youtube,
        clean: function(url) {
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?youtube\.com/, "http://www.youtube.com");
            // YouTube URL shortener
            url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?youtu\.be\/([a-zA-Z0-9_-]+)/, "http://www.youtube.com/watch?v=$1");
            // YouTube standard watch URL
            url = url.replace(/^http:\/\/www\.youtube\.com\/.*[?&](v=[a-zA-Z0-9_-]+).*$/, "http://www.youtube.com/watch?$1");
            // YouTube embeds
            url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?youtube\.com\/(?:embed|v)\/([a-zA-Z0-9_-]+)/, "http://www.youtube.com/watch?v=$1");
            url = url.replace(/\/user\/([^\/\?#]+).*$/, "/user/$1");
	    return url;
        }
    },
    vgmdb: {
        match: new RegExp("^(https?://)?vgmdb\\.net/", "i"),
        type: MB.constants.LINK_TYPES.vgmdb
    },
    otherdatabases: {
        match: new RegExp("^(https?://)?(www\\.)?(rateyourmusic\\.com/|worldcat\\.org/|musicmoz\\.org/|45cat\\.com/|musik-sammler\\.de/|discografia\\.dds\\.it/|tallinn\\.ester\\.ee/|tartu\\.ester\\.ee/|encyclopedisque\\.fr/|discosdobrasil\\.com\\.br/|isrc\\.ncl\\.edu\\.tw/|rolldabeats\\.com/|psydb\\.net/|metal-archives\\.com/|spirit-of-metal\\.com/|ibdb\\.com/|lortel.\\org/|theatricalia\\.com/|ocremix\\.org/|trove\\.nla\\.gov\\.au/|(wiki\\.)?rockinchina\\.com)", "i"),
        type: MB.constants.LINK_TYPES.otherdatabases,
        clean: function(url) {
            //Removing cruft from Worldcat URLs
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?worldcat\.org(?:\/title\/[a-zA-Z0-9_-]+)?\/oclc\/([^&?]+)(?:.*)$/, "http://www.worldcat.org/oclc/$1");
            //Standardising IBDb not to use www
            url = url.replace(/^(https?:\/\/)?(www\.)?ibdb\.com/, "http://ibdb.com");
            //Standardising ESTER to their default parameters
            url = url.replace(/^(?:https?:\/\/)?(tallinn|tartu)\.ester\.ee\/record=([^~]+)(?:.*)?$/, "http://$1.ester.ee/record=$2~S1*est");
            //Standardising Trove
            url = url.replace(/^(?:https?:\/\/)?trove.nla.gov.au\/([^\/]+)\/([^\/?]+)(?:\?.*)?$/, "http://trove.nla.gov.au/$1/$2");
            //Standardising RIC
            url = url.replace(/^(?:https?:\/\/)?(wiki|www)\.rockinchina\.com\/w\/(.*)+$/, "http://www.rockinchina.com/w/$2");
            return url;
        }
    }
};


MB.Control.URLCleanup = function (sourceType, typeControl, urlControl) {
    var self = MB.Object ();

    self.typeControl = $(typeControl);
    self.urlControl = $(urlControl);
    self.sourceType = sourceType;

    self.errorList = $('<ul class="errors" />').hide();
    self.typeControl.after(self.errorList);

    var validationRules = { };
    // "has lyrics at" is only allowed for certain lyrics sites
    validationRules[ MB.constants.LINK_TYPES.lyrics.artist ] = function() {
        return MB.constants.CLEANUPS.lyrics.match.test($('#id-ar\\.url').val())
    };
    validationRules[ MB.constants.LINK_TYPES.lyrics.release_group ] = function() {
        return MB.constants.CLEANUPS.lyrics.match.test($('#id-ar\\.url').val())
    };
    validationRules[ MB.constants.LINK_TYPES.lyrics.work ] = function() {
        return MB.constants.CLEANUPS.lyrics.match.test($('#id-ar\\.url').val())
    };
    // allow Discogs page only for the correct entities
    validationRules[ MB.constants.LINK_TYPES.discogs.artist ] = function() {
        return $('#id-ar\\.url').val().match(/\/(artist|user)\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.label ] = function() {
        return $('#id-ar\\.url').val().match(/\/label\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/\/master\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.release ] = function() {
        return $('#id-ar\\.url').val().match(/\/(release|mp3)\//) != null;
    }
    // allow Allmusic page only for the correct entities
    validationRules[ MB.constants.LINK_TYPES.allmusic.artist ] = function() {
        return $('#id-ar\\.url').val().match(/\/artist\/mn/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/\/album\/mw/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.work ] = function() {
        return $('#id-ar\\.url').val().match(/\/composition\/mc|song\/mt/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.recording ] = function() {
        return $('#id-ar\\.url').val().match(/\/performance\/mq/) != null;
    }
    // only allow domains on the cover art whitelist
    validationRules[ MB.constants.LINK_TYPES.coverart.release ] = function() {
        var sites = new RegExp("^(https?://)?([^/]+\\.)?(archive\\.org|magnatune\\.com|jamendo\\.com|cdbaby.(com|name)|mange-disque\\.tv|thastrom\\.se|universalpoplab\\.com|alpinechic\\.net|angelika-express\\.de|fixtstore\\.com|phantasma13\\.com|primordialmusic\\.com|transistorsounds\\.com|alter-x\\.net|zorchfactoryrecords\\.com)/");
        return sites.test($('#id-ar\\.url').val())
    };

    var validateFacebook = function() {
        var url = $('#id-ar\\.url').val();
        if (url.match(/facebook.com\/pages\//)) {
            return url.match(/\/pages\/[^\/?#]+\/\d+/);
        }
        return true;
    };
    validationRules[ MB.constants.LINK_TYPES.socialnetwork.artist ] = validateFacebook;
    validationRules[ MB.constants.LINK_TYPES.socialnetwork.label ] = validateFacebook;

    self.guessType = function (sourceType, currentURL) {
        for (var group in MB.constants.CLEANUPS) {
            if(!MB.constants.CLEANUPS.hasOwnProperty(group)) { continue; }

            var cleanup = MB.constants.CLEANUPS[group];
            if(!cleanup.match.test(currentURL) || !cleanup.type.hasOwnProperty(sourceType)) { continue; }
            return cleanup.type[sourceType];
        }
        return;
    };

    self.cleanUrl = function (sourceType, dirtyURL) {
        dirtyURL = dirtyURL.replace(/^\s+/, '');
        dirtyURL = dirtyURL.replace(/\s+$/, '');

        for (var group in MB.constants.CLEANUPS) {
            if(!MB.constants.CLEANUPS.hasOwnProperty(group)) { continue; }

            var cleanup = MB.constants.CLEANUPS[group];
            if(!cleanup.hasOwnProperty('clean') || !cleanup.match.test(dirtyURL))
                continue;

            return cleanup.clean(dirtyURL);
        }
        return dirtyURL;
    };

    var typeChanged = function(event) {
        var checker = validationRules[$('#id-ar\\.link_type_id').val()];
        if (!checker || checker()) {
            self.errorList.hide();
            $('button[type="submit"]').attr('disabled', false);
        }
        else {
            self.errorList.show().empty().append('<li>This URL is not allowed for the selected link type, or is incorrectly formatted.</li>');
            if (event.type === 'submit') {
                event.preventDefault();
            }
            $('button[type="submit"]').attr('disabled', 'disabled');
        }
    };

    var urlChanged = function(event) {
        var url = self.urlControl.val(),
            clean = self.cleanUrl(self.sourceType, url) || url;

        if (url.match(/^\w+\./)) {
            self.urlControl.val('http://' + url);
            return
        }

        if (url !== clean)
            self.urlControl.val(clean);

        if (self.typeControl.length) {
            var type = self.guessType(self.sourceType, clean);
            self.typeControl.children('option[value="' + type +'"]')
                .attr('selected', 'selected').trigger('change');
            typeChanged(event);
        }
    };

    self.urlControl
        .change(urlChanged)
        .keyup(urlChanged)
        .bind('input propertychange', urlChanged);

    self.urlControl.parents('form').submit(urlChanged);

    return self;
};
