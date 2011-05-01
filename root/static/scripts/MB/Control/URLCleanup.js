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
        release_group: 89
    },
    discogs: {
        release: 76,
        release_group: 90,
        artist: 180,
        label: 217
    },
    musicmoz: {
        release: 91,
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
    amazon: {
        release: 77
    },
    coverart: {
        release: 78
    },
    lyrics: {
        artist: 197,
        release_group: 93,
        work: 272
    }
};

MB.Control.URLCleanup = function (sourceType, typeControl, urlControl) {
    var self = MB.Object ();

    self.typeControl = $(typeControl);
    self.urlControl = $(urlControl);
    self.sourceType = sourceType;

    var cleanups = {
        wikipedia: {
            match: new RegExp("^(http://)?([^/]+\.)?wikipedia\.","i"),
            type: MB.constants.LINK_TYPES.wikipedia
        },
        discogs: {
            match: new RegExp("^(https?://)?([^/]+\.)?discogs\.com","i"),
            type: MB.constants.LINK_TYPES.discogs,
            clean: function(url) {
                return url.replace(/^https?:\/\/([^.]+\.)?discogs\.com\/(.*\/(artist|release|master|label))?/, "http://www.discogs.com/$3");
            }
        },
        musicmoz: {
            match: new RegExp("^(http://)?([^/]+\.)?musicmoz\.","i"),
            type: MB.constants.LINK_TYPES.musicmoz
        },
        imdb: {
            match: new RegExp("^(http://)?([^/]+\.)?imdb\.com","i"),
            type: MB.constants.LINK_TYPES.imdb
        },
        myspace: {
            match: new RegExp("^(http://)?([^/]+\.)?myspace\.com","i"),
            type: MB.constants.LINK_TYPES.myspace
        },
        purevolume: {
            match: new RegExp("^(http://)?([^/]+\.)?purevolume\.com","i"),
            type: MB.constants.LINK_TYPES.purevolume
        },
        amazon: {
            match: new RegExp("^(http://)?([^/]+\.)?amazon\.(com|ca|co\.uk|fr|at|de|it|co\.jp|jp)","i"),
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
            type: MB.constants.LINK_TYPES.coverart,
            clean: function(url) { 
                url = url.replace(/\/http:\/\//, "/");
                return url.replace(/http:\/\/(.*)\.archive.org\/\d\/items\/(.*)\/(.*)/, "http://www.archive.org/download/$2/$3");
            }
        },
        cdbaby: {
            match: new RegExp("^(http://)?([^/]+\.)?cdbaby\.(com|name)","i"),
            type: MB.constants.LINK_TYPES.coverart
        },
        jamendo: {
            match: new RegExp("^(http://)?([^/]+\.)?jamendo\.com","i"),
            type: MB.constants.LINK_TYPES.coverart,
            clean: function(url) {
                url =  url.replace(/jamendo\.com\/\w\w\/album\//, "jamendo.com/album/");
                url =  url.replace(/img\.jamendo\.com\/albums\/(\d+)\/covers\/\d+\.\d+\.jpg/, "www.jamendo.com/album/$1/");
                return url.replace(/jamendo\.com\/\w\w\/artist\//, "jamendo.com/artist/");
            }
        },
        encyclopedisque: {
            match: new RegExp("^(http://)?([^/]+\.)?encyclopedisque\.fr/images/.*\.jpg","i"),
            type: MB.constants.LINK_TYPES.coverart,
            clean: function(url) {
                return url.replace(/images\/imgdb\/thumb250\//, "images/imgdb/main/");
            }
        },
        manjdisc: {
            match: new RegExp("^(http://)?([^/]+\.)?mange-disque\.tv/(fs/md_|fstb/tn_md_|info_disque\.php3\\?dis_code=)[0-9]+","i"),
            type: MB.constants.LINK_TYPES.coverart,
            clean: function(url) {
                return url.replace(/(www\.)?mange-disque\.tv\/(fstb\/tn_md_|fs\/md_|info_disque\.php3\?dis_code=)(\d+)(\.jpg)?/,
                    "www.mange-disque.tv/fs/md_$3.jpg");
            }
        },
        lyrics: {
            match: new RegExp("^(http://)?([^/]+\.)?(lyrics\.wikia\.com|directlyrics\.com)", "i"),
            type: MB.constants.LINK_TYPES.lyrics
        }
    };

    var validationRules = { };
    // "has lyrics at" is only allowed for certain lyrics sites
    validationRules[ MB.constants.LINK_TYPES.lyrics.artist ] = function() {
        return cleanups.lyrics.match.test($('#id-ar\\.url').val())
    };
    validationRules[ MB.constants.LINK_TYPES.lyrics.release_group ] = function() {
        return cleanups.lyrics.match.test($('#id-ar\\.url').val())
    };
    validationRules[ MB.constants.LINK_TYPES.lyrics.work ] = function() {
        return cleanups.lyrics.match.test($('#id-ar\\.url').val())
    };


    self.guessType = function (sourceType, currentURL) {
        for (var group in cleanups) {
            if(!cleanups.hasOwnProperty(group)) { continue; }
            
            var cleanup = cleanups[group];
            if(!cleanup.match.test(currentURL)) { continue; }
            return cleanup.type[sourceType];
        }
        return;
    };

    self.cleanUrl = function (dirtyURL) {
        for (var group in cleanups) {
            if(!cleanups.hasOwnProperty(group)) { continue; }

            var cleanup = cleanups[group];
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

    return self;
};
