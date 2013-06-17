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
        area: 355,
        artist: 179,
        label: 216,
        release_group: 89,
        work: 279,
        area: 355
    },
    discogs: {
        artist: 180,
        label: 217,
        release: 76,
        release_group: 90
    },
    imdb: {
        artist: 178,
        label: 313,
        release_group: 97
    },
    imdbsamples: {
        release: 83,
        recording: 258
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
        recording: 285,
        release_group: 284,
        work: 286
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
    discographyentry: {
        release: 288
    },
    mailorder: {
        artist: 175,
        release: 79
    },
    downloadpurchase: {
        artist: 176,
        recording: 254,
        release: 74
    },
    downloadfree: {
        artist: 177,
        recording: 255,
        release: 75
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
        artist: 307,
        release: 308,
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
        artist: 291,
        label: 290
    },
    blog: {
        artist: 199,
        label: 224
    },
    streamingmusic: {
	artist: 194,
        recording: 268,
	release: 85
    },
    vgmdb: {
        artist: 191,
        label: 210,
        release: 86
    },
    youtube: {
        artist: 193,
        label: 225,
        recording: 268
    },
    otherdatabases: {
        artist: 188,
        label: 222,
        recording: 306,
        release: 82,
        release_group: 96,
        work: 273
    },
    viaf: {
        artist: 310,
        label: 311,
        work: 312
    },
    wikidata: {
        area: 358,
        artist: 352,
        label: 354,
        release_group: 353,
        work: 351
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
    imdbsamples: {
        match: new RegExp("^(https?://)?([^/]+\\.)?imdb\\.","i"),
        type: MB.constants.LINK_TYPES.imdbsamples,
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
    downloadpurchase: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(beatport\\.com|junodownload\\.com|audiojelly\\.com|itunes\\.apple\\.com/)", "i"),
        type: MB.constants.LINK_TYPES.downloadpurchase,
        clean: function(url) {
            // iTunes cleanup
            return url.replace(/^https?:\/\/itunes\.apple\.com\/([a-z]{2}\/)?(artist|album|music-video|preorder)\/([a-z0-9!.-]+\/)?(id[0-9]+)(\?.*)?$/, "https://itunes.apple.com/$1$2/$4");
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
        match: new RegExp("^(https?://)?([^/]+\\.)?(lyrics\\.wikia\\.com|directlyrics\\.com|lyricstatus\\.com|kasi-time\\.com|wikisource\\.org|recmusic\\.org|utamap\\.com|j-lyric\\.net|lyricsnmusic\\.com)", "i"),
        type: MB.constants.LINK_TYPES.lyrics,
        clean: function(url) {
            return url.replace(/^https:\/\/([a-z-]+\.)?wikisource\.org/, "http://$1wikisource.org");
        }
    },
    bbcmusic: {
        match: new RegExp("^(https?://)?(www\\.)?bbc\\.co\\.uk/music/artists/", "i"),
        type: MB.constants.LINK_TYPES.bbcmusic
    },
    discography: {
        match: new RegExp("^(https?://)?(www\\.)?metal-archives\\.com/band\\.php", "i"),
        type: MB.constants.LINK_TYPES.discography
    },
    discographyentry: {
        match: new RegExp("^(https?://)?(www\\.)?(naxos\\.com/catalogue/item\\.asp|bis\\.se/index\\.php\\?op=album|universal-music\\.co\\.jp/([a-z0-9-]+/)?[a-z0-9-]+/products/[a-z]{4}-[0-9]{5}/$|lantis\\.jp/release-item2\\.php\\?id=[0-9a-f]{32}$|jvcmusic\\.co\\.jp/[a-z-]+/Discography/[A0-9-]+/[A-Z]{4}-[0-9]+\\.html$|wmg\\.jp/artist/[A-Za-z0-9]+/[A-Z]{4}[0-9]{9}\\.html$|avexnet\\.jp/id/[a-z0-9]{5}/discography/product/[A-Z0-9]{4}-[0-9]{5}\\.html$|kingrecords\\.co\\.jp/cs/g/g[A-Z]{4}-[0-9]+/$)", "i"),
        type: MB.constants.LINK_TYPES.discographyentry
    },
    microblog: {
        match: new RegExp("^(https?://)?(www\\.)?twitter\\.com/", "i"),
        type: MB.constants.LINK_TYPES.microblog,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?(www\.)?twitter\.com(\/#!)?/, "https://twitter.com");
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
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?facebook\.com(\/#!)?/, "https://www.facebook.com");
            if (url.match (/^https:\/\/www\.facebook\.com.*$/))
            {
                  // Remove ref (where the user came from) and sk (subpages in a page, since we want the main link)
                  url = url.replace(/([&?])(sk|ref|fref)=([^?&]*)/, "$1");
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
    blog: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(ameblo\\.jp|blog\\.livedoor\\.jp|([^./]+)\\.jugem\\.jp|([^./]+)\\.exblog\\.jp)", "i"),
        type: MB.constants.LINK_TYPES.blog,
        clean: function(url) {
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ameblo\.jp\/([^\/]+).*$/, "http://ameblo.jp/$1/");
            return url;
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
    viaf: {
        match: new RegExp("^(https?://)?([^/]+\\.)?viaf\\.org", "i"),
        type: MB.constants.LINK_TYPES.viaf,
        clean: function(url) {
            url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?viaf\.org\/viaf\/([0-9]+).*$/,
            "http://viaf.org/viaf/$1");
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
    wikidata: {
        match: new RegExp("^(https?://)?([^/]+\\.)?wikidata\\.org","i"),
        type: MB.constants.LINK_TYPES.wikidata,
        clean: function(url) {
            return url.replace(/^https:\/\//, "http://");
        }
    },
    otherdatabases: {
        match: new RegExp("^(https?://)?(www\\.)?(rateyourmusic\\.com/|worldcat\\.org/|musicmoz\\.org/|45cat\\.com/|musik-sammler\\.de/|discografia\\.dds\\.it/|tallinn\\.ester\\.ee/|tartu\\.ester\\.ee/|encyclopedisque\\.fr/|discosdobrasil\\.com\\.br/|isrc\\.ncl\\.edu\\.tw/|rolldabeats\\.com/|psydb\\.net/|metal-archives\\.com/|spirit-of-metal\\.com/|ibdb\\.com/|lortel.\\org/|theatricalia\\.com/|ocremix\\.org/|(trove\\.)?nla\\.gov\\.au/|(wiki\\.)?rockinchina\\.com|(www\\.)?dhhu\\.dk|thesession\\.org|openlibrary\\.org|animenewsnetwork\\.com|generasia\\.com|soundtrackcollector\\.com)", "i"),
        type: MB.constants.LINK_TYPES.otherdatabases,
        clean: function(url) {
            //Removing cruft from Worldcat URLs
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?worldcat\.org(?:\/title\/[a-zA-Z0-9_-]+)?\/oclc\/([^&?]+)(?:.*)$/, "http://www.worldcat.org/oclc/$1");
            //Standardising IBDb not to use www
            url = url.replace(/^(https?:\/\/)?(www\.)?ibdb\.com/, "http://ibdb.com");
            //Standardising ESTER to their default parameters
            url = url.replace(/^(?:https?:\/\/)?(tallinn|tartu)\.ester\.ee\/record=([^~]+)(?:.*)?$/, "http://$1.ester.ee/record=$2~S1*est");
            //Standardising Trove
            url = url.replace(/^(?:https?:\/\/)?trove.nla.gov.au\/work\/([^\/?]+)(?:\?.*)?$/, "http://trove.nla.gov.au/work/$1");
            //Standardising RIC
            url = url.replace(/^(?:https?:\/\/)?(wiki|www)\.rockinchina\.com\/w\/(.*)+$/, "http://www.rockinchina.com/w/$2");
            //Standardising DHHU
            url = url.replace(/^(?:https?:\/\/)?(www\.)?dhhu\.dk\/w\/(.*)+$/, "http://www.dhhu.dk/w/$2");
            //Standardising The Session
            url = url.replace(/^(?:https?:\/\/)?(www\.)?thesession\.org\/([^\/]+)(\/.*)?\/([0-9]+)+(#.*)*$/, "http://thesession.org/$2/$4");
            //Standardising Open Library
            url = url.replace(/^(?:https?:\/\/)?(www\.)?openlibrary\.org\/(authors|books|works)\/(OL[0-9]+[AMW]\/)(.*)*$/, "http://openlibrary.org/$2/$3");
            //Standardising Anime News Network
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?animenewsnetwork\.com\/encyclopedia\/(people|company).php\?id=([0-9]+).*$/, "http://www.animenewsnetwork.com/encyclopedia/$1.php?id=$2");
            //Standardising Generasia
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?generasia\.com\/wiki\/(.*)$/, "http://www.generasia.com/wiki/$1");
            //Standardising Soundtrack Collector
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/(composer|title)\/([0-9]+).*$/, "http://soundtrackcollector.com/$1/$2/");
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
        return $('#id-ar\\.url').val().match(/discogs\.com\/(artist|user)\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.label ] = function() {
        return $('#id-ar\\.url').val().match(/discogs\.com\/label\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/discogs\.com\/master\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.release ] = function() {
        return $('#id-ar\\.url').val().match(/discogs\.com\/(release|mp3)\//) != null;
    }
    // allow Allmusic page only for the correct entities
    validationRules[ MB.constants.LINK_TYPES.allmusic.artist ] = function() {
        return $('#id-ar\\.url').val().match(/allmusic\.com\/artist\/mn/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/allmusic\.com\/album\/mw/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.work ] = function() {
        return $('#id-ar\\.url').val().match(/allmusic\.com\/composition\/mc|song\/mt/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.recording ] = function() {
        return $('#id-ar\\.url').val().match(/allmusic\.com\/performance\/mq/) != null;
    }

    // allow only artist pages in BBC Music links
    validationRules[ MB.constants.LINK_TYPES.bbcmusic.artist ] = function() {
        return $('#id-ar\\.url').val().match(/bbc\.co\.uk\/music\/artists\//) != null;
    }

    // allow only Wikipedia pages with the Wikipedia rel
    validationRules[ MB.constants.LINK_TYPES.wikipedia.artist ] = function() {
        return $('#id-ar\\.url').val().match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.work ] = function() {
        return $('#id-ar\\.url').val().match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.label ] = function() {
        return $('#id-ar\\.url').val().match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.area ] = function() {
        return $('#id-ar\\.url').val().match(/wikipedia\.org\//) != null;
    }

    // allow only Myspace pages with the Myspace rel
    validationRules[ MB.constants.LINK_TYPES.myspace.artist ] = function() {
        return $('#id-ar\\.url').val().match(/myspace\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.myspace.label ] = function() {
        return $('#id-ar\\.url').val().match(/myspace\.com\//) != null;
    }

    // allow only PureVolume pages with the PureVolume rel
    validationRules[ MB.constants.LINK_TYPES.purevolume.artist ] = function() {
        return $('#id-ar\\.url').val().match(/purevolume\.com\//) != null;
    }

    // allow only SecondHandSongs pages with the SecondHandSongs rel
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.artist ] = function() {
        return $('#id-ar\\.url').val().match(/secondhandsongs\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.release ] = function() {
        return $('#id-ar\\.url').val().match(/secondhandsongs\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.work ] = function() {
        return $('#id-ar\\.url').val().match(/secondhandsongs\.com\//) != null;
    }

    // allow only Songfacts pages with the Songfacts rel
    validationRules[ MB.constants.LINK_TYPES.songfacts.work ] = function() {
        return $('#id-ar\\.url').val().match(/songfacts\.com\//) != null;
    }

    // allow only Soundcloud pages with the Soundcloud rel
    validationRules[ MB.constants.LINK_TYPES.soundcloud.artist ] = function() {
        return $('#id-ar\\.url').val().match(/soundcloud\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.soundcloud.label ] = function() {
        return $('#id-ar\\.url').val().match(/soundcloud\.com\//) != null;
    }

    // allow only VIAF pages with the VIAF rel
    validationRules[ MB.constants.LINK_TYPES.viaf.artist ] = function() {
        return $('#id-ar\\.url').val().match(/viaf\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.viaf.work ] = function() {
        return $('#id-ar\\.url').val().match(/viaf\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.viaf.label ] = function() {
        return $('#id-ar\\.url').val().match(/viaf\.org\//) != null;
    }

    // allow only VGMdb pages with the VGMdb rel
    validationRules[ MB.constants.LINK_TYPES.vgmdb.artist ] = function() {
        return $('#id-ar\\.url').val().match(/vgmdb\.net\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.vgmdb.release ] = function() {
        return $('#id-ar\\.url').val().match(/vgmdb\.net\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.vgmdb.label ] = function() {
        return $('#id-ar\\.url').val().match(/vgmdb\.net\//) != null;
    }

    // allow only YouTube pages with the YouTube rel
    validationRules[ MB.constants.LINK_TYPES.youtube.artist ] = function() {
        return $('#id-ar\\.url').val().match(/youtube\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.youtube.label ] = function() {
        return $('#id-ar\\.url').val().match(/youtube\.com\//) != null;
    }

    // allow only Amazon pages with the Amazon rel
    validationRules[ MB.constants.LINK_TYPES.amazon.release ] = function() {
        return $('#id-ar\\.url').val().match(/amazon\.(com|ca|co\.uk|fr|at|de|it|co\.jp|jp|cn|es)\//) != null;
    }

    // allow only IMDb pages with the IMDb rels
    validationRules[ MB.constants.LINK_TYPES.imdb.artist ] = function() {
        return $('#id-ar\\.url').val().match(/imdb\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdb.label ] = function() {
        return $('#id-ar\\.url').val().match(/imdb\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdb.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/imdb\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdbsamples.recording ] = function() {
        return $('#id-ar\\.url').val().match(/imdb\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdbsamples.release ] = function() {
        return $('#id-ar\\.url').val().match(/imdb\.com\//) != null;
    }

    // allow only SecondHandSongs pages with the SecondHandSongs rel and at the right level
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.artist ] = function() {
        return $('#id-ar\\.url').val().match(/secondhandsongs\.com\/artist\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.release ] = function() {
        return $('#id-ar\\.url').val().match(/secondhandsongs\.com\/release\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.work ] = function() {
        return $('#id-ar\\.url').val().match(/secondhandsongs\.com\/work\//) != null;
    }

    // allow only Wikidata pages with the Wikidata rel
    validationRules[ MB.constants.LINK_TYPES.wikidata.artist ] = function() {
        return $('#id-ar\\.url').val().match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.work ] = function() {
        return $('#id-ar\\.url').val().match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.label ] = function() {
        return $('#id-ar\\.url').val().match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.release_group ] = function() {
        return $('#id-ar\\.url').val().match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.area ] = function() {
        return $('#id-ar\\.url').val().match(/wikidata\.org\//) != null;
    }

    // only allow domains on the cover art whitelist
    validationRules[ MB.constants.LINK_TYPES.coverart.release ] = function() {
        var sites = new RegExp("^(https?://)?([^/]+\\.)?(archive\\.org|magnatune\\.com|jamendo\\.com|cdbaby.(com|name)|mange-disque\\.tv|thastrom\\.se|universalpoplab\\.com|alpinechic\\.net|angelika-express\\.de|fixtstore\\.com|phantasma13\\.com|primordialmusic\\.com|transistorsounds\\.com|alter-x\\.net|zorchfactoryrecords\\.com)/");
        return sites.test($('#id-ar\\.url').val())
    };

    // avoid wikipedia being added as release-level discography entry
    validationRules [ MB.constants.LINK_TYPES.discographyentry.release ] = function() {
        var is_wikipedia = new RegExp('^(https?://)?([^.]+\.)?wikipedia\\.org/');
        return !is_wikipedia.test($('#id-ar\\.url').val())
    };

    // only allow domains on the score whitelist
    var validateScore = function() {
        return MB.constants.CLEANUPS.score.match.test($('#id-ar\\.url').val())
    };
    validationRules[ MB.constants.LINK_TYPES.score.release_group ] = validateScore;
    validationRules[ MB.constants.LINK_TYPES.score.work ] = validateScore;

    // Ensure Soundtrack Collector stuff is added to the right level
    var STCollector_is_not_RG = function () {
        var STcheckRG = new RegExp('^(https?://)?(www\\.)?soundtrackcollector\\.com/title/');
        return !STcheckRG.test($('#id-ar\\.url').val())
    };
    var STCollector_is_not_artist = function () {
        var STcheckartist = new RegExp('^(https?://)?(www\\.)?soundtrackcollector\\.com/composer/');
        return !STcheckartist.test($('#id-ar\\.url').val())
    };

    // only allow domains on the other databases whitelist
    var validateOtherDatabases = function() {
        return MB.constants.CLEANUPS.otherdatabases.match.test($('#id-ar\\.url').val())
    };
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.artist ] = function () {return validateOtherDatabases() && STCollector_is_not_RG()}
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.label ] = validateOtherDatabases
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.release_group ] = function () {return validateOtherDatabases() && STCollector_is_not_artist()}
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.release ] = function () {return validateOtherDatabases() && STCollector_is_not_RG() && STCollector_is_not_artist()}
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.work ] = validateOtherDatabases
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.recording ] = validateOtherDatabases

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
            $('button[type="submit"]').prop('disabled', false);
        }
        else {
            self.errorList.show().empty().append('<li>This URL is not allowed for the selected link type, or is incorrectly formatted.</li>');
            if (event.type === 'submit') {
                event.preventDefault();
            }
            $('button[type="submit"]').prop('disabled', true);
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
                .prop('selected', true).trigger('change');
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
