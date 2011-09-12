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
    musicmoz: {
        release_group: 91,
        artist: 181
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
    socialnetwork: {
        artist: 192,
        label: 218
    },
    vgmdb: {
        artist: 191,
        release: 86,
        label: 210
    },
    youtube: {
        artist: 193,
        label: 225
    }
};

MB.constants.CLEANUPS = {
    wikipedia: {
        match: new RegExp("^(https?://)?(([^/]+\\.)?wikipedia|secure\\.wikimedia)\\.","i"),
        type: MB.constants.LINK_TYPES.wikipedia,
        clean: function(url) {
            url =  url.replace(/^https:\/\/secure\.wikimedia\.org\/wikipedia\/([a-z-]+)\/wiki\/(.*)/, "http://$1.wikipedia.org/wiki/$2");
            url =  url.replace(/\.wikipedia\.org\/w\/index\.php\?title=([^&]+).*/, ".wikipedia.org/wiki/$1");
            return url.replace(/\.wikipedia\.org\/[a-z-]+\/([^?]+)$/, ".wikipedia.org/wiki/$1");
        }
    },
    discogs: {
        match: new RegExp("^(https?://)?([^/]+\.)?discogs\.com","i"),
        type: MB.constants.LINK_TYPES.discogs,
        clean: function(url) {
            url = url.replace(/\/viewimages\?release=([0-9]*)/, "/release/$1");
            return url.replace(/^https?:\/\/([^.]+\.)?discogs\.com\/(.*\/(artist|release|master|label))?/, "http://www.discogs.com/$3");
        }
    },
    musicmoz: {
        match: new RegExp("^(https?://)?([^/]+\.)?musicmoz\.","i"),
        type: MB.constants.LINK_TYPES.musicmoz
    },
    imdb: {
        match: new RegExp("^(https?://)?([^/]+\.)?imdb\.com","i"),
        type: MB.constants.LINK_TYPES.imdb,
        clean: function(url) {
            return url.replace(/^https?:\/\/([^.]+\.)?imdb\.com\/([a-z]+\/[a-z0-9]+)(\/(bio|soundtrack)?)?/, "http://www.imdb.com/$2/");
        }
    },
    myspace: {
        match: new RegExp("^(https?://)?([^/]+\.)?myspace\.com","i"),
        type: MB.constants.LINK_TYPES.myspace,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?myspace\.com/, "http://www.myspace.com");
        }
    },
    purevolume: {
        match: new RegExp("^(https?://)?([^/]+\.)?purevolume\.com","i"),
        type: MB.constants.LINK_TYPES.purevolume
    },
    allmusic: {
        match: new RegExp("^(https?://)?([^/]+\.)?allmusic\.com","i"),
        type: MB.constants.LINK_TYPES.allmusic,
        clean: function(url) {
            return url.replace(/^https?:\/\/(?:[^.]+\.)?allmusic\.com\/(artist|album|work|song|performance)\/(?:[^\/]*-)?([pqrwtcf][0-9]+).*/, "http://allmusic.com/$1/$2");
        }
    },
    amazon: {
        match: new RegExp("^(https?://)?([^/]+\.)?amazon\.(com|ca|co\.uk|fr|at|de|it|co\.jp|jp|cn)","i"),
        type: MB.constants.LINK_TYPES.amazon,
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
            if ((m = url.match(/(?:\/|\ba=)([A-Z0-9]{10})(?:[/?&#]|$)/)) != null) {
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
        match: new RegExp("^(https?://)?([^/]+\.)?archive\.org/.*\.(jpg|jpeg|png|gif)$","i"),
        type: MB.constants.LINK_TYPES.coverart,
        clean: function(url) { 
            return url.replace(/http:\/\/(.*)\.archive.org\/\d\/items\/(.*)\/(.*)/, "http://www.archive.org/download/$2/$3");
        }
    },
    cdbaby: {
        match: new RegExp("^(https?://)?([^/]+\.)?cdbaby\.(com|name)","i"),
        type: MB.constants.LINK_TYPES.coverart,
        clean: function(url) {
            if ((m = url.match(/(?:https?:\/\/)?(?:www\.)?cdbaby\.com\/cd\/([^\/]+)(\/(from\/[^\/]+)?)?/)) != null)
                url = "http://www.cdbaby.com/cd/" + m[1].toLowerCase();
            url = url.replace(/(?:https?:\/\/)?(?:www\.)?cdbaby\.com\/Images\/Album\/([a-z0-9]+)(?:_small)?\.jpg/, "http://www.cdbaby.com/cd/$1");
            return url.replace(/(?:https?:\/\/)?(?:images\.)?cdbaby\.name\/.\/.\/([a-z0-9]+)(?:_small)?\.jpg/, "http://www.cdbaby.com/cd/$1");
        }
    },
    jamendo: {
        match: new RegExp("^(https?://)?([^/]+\.)?jamendo\.com","i"),
        type: MB.constants.LINK_TYPES.coverart,
        clean: function(url) {
            url =  url.replace(/jamendo\.com\/\w\w\/album\//, "jamendo.com/album/");
            url =  url.replace(/img\.jamendo\.com\/albums\/(\d+)\/covers\/\d+\.\d+\.jpg/, "www.jamendo.com/album/$1/");
            return url.replace(/jamendo\.com\/\w\w\/artist\//, "jamendo.com/artist/");
        }
    },
    encyclopedisque: {
        match: new RegExp("^(https?://)?([^/]+\.)?encyclopedisque\.fr/images/.*\.jpg","i"),
        type: MB.constants.LINK_TYPES.coverart,
        clean: function(url) {
            return url.replace(/images\/imgdb\/thumb250\//, "images/imgdb/main/");
        }
    },
    manjdisc: {
        match: new RegExp("^(https?://)?([^/]+\.)?mange-disque\.tv/(fs/md_|fstb/tn_md_|info_disque\.php3\\?dis_code=)[0-9]+","i"),
        type: MB.constants.LINK_TYPES.coverart,
        clean: function(url) {
            return url.replace(/(www\.)?mange-disque\.tv\/(fstb\/tn_md_|fs\/md_|info_disque\.php3\?dis_code=)(\d+)(\.jpg)?/,
                "www.mange-disque.tv/fs/md_$3.jpg");
        }
    },
    lyrics: {
        match: new RegExp("^(https?://)?([^/]+\.)?(lyrics\.wikia\.com|directlyrics\.com)", "i"),
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
    ozonrucoverart: {
        match: new RegExp("^(https?://)?(www\\.)?ozon\\.ru/multimedia/", "i"),
        type: MB.constants.LINK_TYPES.coverart
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
        match: new RegExp("^(https?://)?([^/]+\.)?secondhandsongs\\.com/", "i"),
        type: MB.constants.LINK_TYPES.secondhandsongs
    },
    socialnetwork: {
        match: new RegExp("^(https?://)?([^/]+\.)?(facebook\\.com|last\\.fm|lastfm\\.(at|br|de|es|fr|it|jp|pl|pt|ru|se|com\\.tr))/", "i"),
        type: MB.constants.LINK_TYPES.socialnetwork,
        clean: function(url) {
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?facebook\.com(\/#!)?/, "http://www.facebook.com");
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?(last\.fm|lastfm\.(at|br|de|es|fr|it|jp|pl|pt|ru|se|com\.tr))/, "http://www.last.fm");
            url = url.replace(/^http:\/\/www\.last\.fm\/music\/([^?]+).*/, "http://www.last.fm/music/$1");
            return url;
        }
    },
    vgmdb: {
        match: new RegExp("^(https?://)?vgmdb\\.net/", "i"),
        type: MB.constants.LINK_TYPES.vgmdb
    },
    youtube: {
        match: new RegExp("^(https?://)?([^/]+\.)?youtube\\.com/", "i"),
        type: MB.constants.LINK_TYPES.youtube,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?([^\/]+\.)?youtube\.com/, "http://www.youtube.com");
        }
    }
};


MB.Control.URLCleanup = function (sourceType, typeControl, urlControl) {
    var self = MB.Object ();

    self.typeControl = $(typeControl);
    self.urlControl = $(urlControl);
    self.sourceType = sourceType;


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
        return $('#id-ar\\.url').val().match(/\/(artist)\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/\/album\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.work ] = function() {
        return $('#id-ar\\.url').val().match(/\/work|song\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.recording ] = function() {
        return $('#id-ar\\.url').val().match(/\/(performance)\//) != null;
    }
    // only allow domains on the cover art whitelist
    validationRules[ MB.constants.LINK_TYPES.coverart.release ] = function() {
        var sites = new RegExp("^(https?://)?([^/]+\.)?(archive\.org|magnatune\.com|jamendo\.com|cdbaby.(com|name)|ozon\.ru|mange-disque\.tv|encyclopedisque\.fr|thastrom\.se|universalpoplab\.com|alpinechic\.net|angelika-express\.de|fixtstore\.com|phantasma13\.com|primordialmusic\.com|transistorsounds\.com|alter-x\.net|zorchfactoryrecords\.com)/");
        return sites.test($('#id-ar\\.url').val())
    };

    self.guessType = function (sourceType, currentURL) {
        for (var group in MB.constants.CLEANUPS) {
            if(!MB.constants.CLEANUPS.hasOwnProperty(group)) { continue; }
            
            var cleanup = MB.constants.CLEANUPS[group];
            if(!cleanup.match.test(currentURL)) { continue; }
            return cleanup.type[sourceType];
        }
        return;
    };

    self.cleanUrl = function (dirtyURL) {
        dirtyURL = dirtyURL.replace(/^\s+/, '');

        for (var group in MB.constants.CLEANUPS) {
            if(!MB.constants.CLEANUPS.hasOwnProperty(group)) { continue; }

            var cleanup = MB.constants.CLEANUPS[group];
            if(!cleanup.hasOwnProperty('clean') || !cleanup.match.test(dirtyURL)) 
                continue;

            return cleanup.clean(dirtyURL);
        }
        return dirtyURL;
    };
 
    var typeChanged = function() {
        var checker = validationRules[$('#id-ar\\.link_type_id').val()];
        $('button[type="submit"]').attr('disabled',
            !checker || checker() ? false : 'disabled');
    };

    var urlChanged = function() {
        var url = self.urlControl.val(),
            clean = self.cleanUrl(url) || url;

        if (url.match(/^\w+\./)) {
            self.urlControl.val('http://' + url);
            return
        }

        if (url !== clean)
            self.urlControl.val(clean);

        if (self.typeControl.length) {
            var type = self.guessType(self.sourceType, clean);
            self.typeControl.children('option[value="' + type +'"]')
                .attr('selected', 'selected');
            typeChanged();
        }
    };

    self.urlControl
        .change(urlChanged)
        .keyup(urlChanged);

    self.urlControl.parents('form').submit(urlChanged);

    return self;
};
