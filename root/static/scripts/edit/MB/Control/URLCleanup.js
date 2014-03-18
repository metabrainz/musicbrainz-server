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
        area: 355,
        place: 595
    },
    discogs: {
        artist: 180,
        label: 217,
        place: 705,
        release: 76,
        release_group: 90
    },
    imdb: {
        artist: 178,
        label: 313,
        place: 706,
        release_group: 97
    },
    imdbsamples: {
        release: 83,
        recording: 258
    },
    myspace: {
        artist: 189,
        label: 215,
        place: 462
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
    image: {
        artist: 173,
        label: 213,
        place: 396,
        work: 274 // This is the "score" type, which is here because of Wikipedia Commons URLs
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
        label: 218,
        place: 429
    },
    soundcloud: {
        artist: 291,
        label: 290
    },
    blog: {
        artist: 199,
        label: 224,
        place: 627
    },
    streamingmusic: {
        artist: 194,
        recording: 268,
        release: 85
    },
    vimeo: {
        // Video channel for artist/label, streaming music for release/recording
        artist: 303,
        label: 304,
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
        recording: 268,
        place: 528
    },
    otherdatabases: {
        artist: 188,
        label: 222,
        place: 561,
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
        work: 351,
        place: 594
    },
    bandcamp: {
        artist: 718,
        label: 719
    }
};

MB.constants.CLEANUPS = {
    wikipedia: {
        match: new RegExp("^(https?://)?(([^/]+\\.)?wikipedia|secure\\.wikimedia)\\.","i"),
        type: MB.constants.LINK_TYPES.wikipedia,
        clean: function(url) {
            url =  url.replace(/^https:\/\/secure\.wikimedia\.org\/wikipedia\/([a-z-]+)\/wiki\/(.*)/, "http://$1.wikipedia.org/wiki/$2");
            url =  url.replace(/^https:\/\//, "http://");
            url =  url.replace(/^http:\/\/wikipedia\.org\/(.+)$/, "http://en.wikipedia.org/$1");
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
            url = url.replace(/^(http:\/\/www\.discogs\.com\/(?:artist|label))\/([0-9]+)-[^+]+$/, "$1/$2"); // URLs containing Discogs IDs
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
    mora: {
        match: new RegExp("^(https?://)?([^/]+\\.)?mora\\.jp","i"),
        type: MB.constants.LINK_TYPES.downloadpurchase,
        clean: function(url) {
            return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?mora\.jp\/package\/([0-9]+)\/([a-zA-Z0-9-]+)(\/)?.*$/, "http://mora.jp/package/$1/$2/");
        }
    },
    myspace: {
        match: new RegExp("^(https?://)?([^/]+\\.)?myspace\\.(com|de|fr)","i"),
        type: MB.constants.LINK_TYPES.myspace,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?([^.]+\.)?myspace\.(com|de|fr)/, "https://myspace.com");
        }
    },
    purevolume: {
        match: new RegExp("^(https?://)?([^/]+\\.)?purevolume\\.com","i"),
        type: MB.constants.LINK_TYPES.purevolume
    },
    recochoku: {
        match: new RegExp("^(https?://)?([^/]+\\.)?recochoku\\.jp","i"),
        type: MB.constants.LINK_TYPES.downloadpurchase,
        clean: function(url) {
            return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?recochoku\.jp\/(album|song)\/([a-zA-Z0-9]+)(\/)?.*$/, "http://recochoku.jp/$1/$2/");
        }
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
        match: new RegExp("^(https?://)?([^/]+\\.)?archive\\.org/","i"),
        clean: function(url) {
            url = url.replace(/^https?:\/\/(www.)?archive.org\//, "https://archive.org/");
            // clean up links to files
            url = url.replace(/\?cnt=\d+$/, "");
            url = url.replace(/^https?:\/\/(.*)\.archive.org\/\d+\/items\/(.*)\/(.*)/, "https://archive.org/download/$2/$3");
            // clean up links to items
            return url.replace(/^(https:\/\/archive\.org\/details\/[A-Za-z0-9._-]+)\/$/, "$1");
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
            return url.replace(/^https?:\/\/itunes\.apple\.com\/([a-z]{2}\/)?(artist|album|music-video|preorder)\/(?:[^?#\/]+\/)?(id[0-9]+)(?:\?.*)?$/, "https://itunes.apple.com/$1$2/$3");
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
        match: new RegExp("^(https?://)?([^/]+\\.)?(lyrics\\.wikia\\.com|directlyrics\\.com|decoda\\.com|kasi-time\\.com|wikisource\\.org|recmusic\\.org|utamap\\.com|j-lyric\\.net|lyricsnmusic\\.com|muzikum\\.eu)", "i"),
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
    image: {
        match: new RegExp("^(https?://)?(commons\\.wikimedia\\.org|upload\\.wikimedia\\.org/wikipedia/commons/)","i"),
        type: MB.constants.LINK_TYPES.image,
        clean: function(url) {
            url = url.replace(/^https?:\/\/upload\.wikimedia\.org\/wikipedia\/commons\/(thumb\/)?[0-9a-z]\/[0-9a-z]{2}\/([^\/]+)(\/[^\/]+)?$/, "https://commons.wikimedia.org/wiki/File:$2");
            url = url.replace(/\?uselang=[a-z-]+$/, "");
            return url.replace(/^https?:\/\/commons\.wikimedia\.org\/wiki\/(File|Image):/, "https://commons.wikimedia.org/wiki/File:");
        }
    },
    discographyentry: {
        match: new RegExp("^(https?://)?(www\\.)?(naxos\\.com/catalogue/item\\.asp|bis\\.se/index\\.php\\?op=album|universal-music\\.co\\.jp/([a-z0-9-]+/)?[a-z0-9-]+/products/[a-z]{4}-[0-9]{5}/$|lantis\\.jp/release-item2\\.php\\?id=[0-9a-f]{32}$|jvcmusic\\.co\\.jp/[a-z-]+/Discography/[A0-9-]+/[A-Z]{4}-[0-9]+\\.html$|wmg\\.jp/artist/[A-Za-z0-9]+/[A-Z]{4}[0-9]{9}\\.html$|avexnet\\.jp/id/[a-z0-9]{5}/discography/product/[A-Z0-9]{4}-[0-9]{5}\\.html$|kingrecords\\.co\\.jp/cs/g/g[A-Z]{4}-[0-9]+/$)", "i"),
        type: MB.constants.LINK_TYPES.discographyentry
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
        match: new RegExp("^(https?://)?((www\\.)?(imslp\\.org/|neyzen\\.com)|commons\\.wikimedia\\.org|www3?\\.cpdl\\.org)", "i"),
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
        match: new RegExp("^(https?://)?([^/]+\\.)?(facebook\\.com|last\\.fm|lastfm\\.(at|br|de|es|fr|it|jp|pl|pt|ru|se|com\\.tr)|reverbnation\\.com|plus\\.google\\.com|vk\\.com|twitter\\.com|instagram\\.com)/", "i"),
        type: MB.constants.LINK_TYPES.socialnetwork,
        clean: function(url) {
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?facebook\.com(\/#!)?/, "https://www.facebook.com");
            if (url.match(/^https:\/\/www\.facebook\.com.*$/)) {
                // Remove ref (where the user came from) and sk (subpages in a page, since we want the main link)
                url = url.replace(/([&?])(sk|ref|fref)=([^?&]*)/, "$1");
                // Ensure the first parameter left uses ? not to break the URL
                url = url.replace(/([&?])&/, "$1");
                url = url.replace(/[&?]$/, "");
                // Remove trailing slashes
                if (url.match(/\?/)) {
                    url = url.replace(/\/\?/, "?");
                } else {
                    url = url.replace(/(facebook\.com\/.*)\/$/, "$1");
                }
            }
            url = url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(at|br|de|es|fr|it|jp|pl|pt|ru|se|com\.tr))/, "http://www.last.fm");
            url = url.replace(/^http:\/\/www\.last\.fm\/music\/([^?]+).*/, "http://www.last.fm/music/$1");
            url = url.replace(/^(?:https?:\/\/)?plus\.google\.com\/(?:u\/[0-9]\/)?([0-9]+)(\/.*)?$/, "https://plus.google.com/$1");
            url = url.replace(/^(?:https?:\/\/)?(?:(?:www|mobile)\.)?twitter\.com(?:\/#!)?\/@?([^\/]+)\/?$/, "https://twitter.com/$1");
            return url;
        }
    },
    soundcloud: {
        match: new RegExp("^(https?://)?([^/]+\\.)?soundcloud\\.com","i"),
        type: MB.constants.LINK_TYPES.soundcloud,
        clean: function(url) {
            return url.replace(/^(https?:\/\/)?(www\.)?soundcloud\.com(\/#!)?/, "https://soundcloud.com");
        }
    },
    blog: {
        match: new RegExp("^(https?://)?([^/]+\\.)?(ameblo\\.jp|blog\\.livedoor\\.jp|([^./]+)\\.jugem\\.jp|([^./]+)\\.exblog\\.jp|([^./]+)\\.tumblr\\.com)", "i"),
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
        type: MB.constants.LINK_TYPES.vimeo,
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
            url = url.replace(/^(https?:\/\/)?([^\/]+\.)?youtube\.com(?:\/#)?/, "http://www.youtube.com");
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
        match: new RegExp("^(https?://)?vgmdb\\.(net|com)/", "i"),
        type: MB.constants.LINK_TYPES.vgmdb,
        clean: function(url) {
            return url.replace(/^(?:https?:\/\/)?vgmdb\.(?:net|com)\/(album|artist|org)\/([0-9]+).*$/, "http://vgmdb.net/$1/$2");
        }
    },
    wikidata: {
        match: new RegExp("^(https?://)?([^/]+\\.)?wikidata\\.org","i"),
        type: MB.constants.LINK_TYPES.wikidata,
        clean: function(url) {
            return url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?wikidata\.org\/wiki\/(Q([0-9]+)).*$/, "http://www.wikidata.org/wiki/$1");
        }
    },
    bandcamp: {
        match: new RegExp("^(https?://)?([^/]+)\\.bandcamp\\.com","i"),
        type: MB.constants.LINK_TYPES.bandcamp,
        clean: function(url) {
            return url.replace(/^(?:https?:\/\/)?([^\/]+)\.bandcamp\.com(?:\/(((album|track)\/([^\/\?]+)))?)?.*$/, "http://$1.bandcamp.com/$2");
        }
    },
    otherdatabases: {
        match: new RegExp("^(https?://)?(www\\.)?(rateyourmusic\\.com/|worldcat\\.org/|musicmoz\\.org/|45cat\\.com/|musik-sammler\\.de/|discografia\\.dds\\.it/|tallinn\\.ester\\.ee/|tartu\\.ester\\.ee/|encyclopedisque\\.fr/|discosdobrasil\\.com\\.br/|isrc\\.ncl\\.edu\\.tw/|rolldabeats\\.com/|psydb\\.net/|metal-archives\\.com/|spirit-of-metal\\.com/|ibdb\\.com/|lortel.\\org/|theatricalia\\.com/|ocremix\\.org/|(trove\\.)?nla\\.gov\\.au/|rockensdanmarkskort\\.dk|(wiki\\.)?rockinchina\\.com|(www\\.)?dhhu\\.dk|thesession\\.org|openlibrary\\.org|animenewsnetwork\\.com|generasia\\.com|soundtrackcollector\\.com|rockipedia\\.no|whosampled\\.com)", "i"),
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
            //Standardising Rockens Danmarkskort
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rockensdanmarkskort\.dk\/steder\/(.*)+$/, "http://www.rockensdanmarkskort.dk/steder/$1");
            //Standardising RIC
            url = url.replace(/^(?:https?:\/\/)?(wiki|www)\.rockinchina\.com\/w\/(.*)+$/, "http://www.rockinchina.com/w/$2");
            //Standardising Rockipedia
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rockipedia\.no\/(utgivelser|artister|plateselskap)\/(.+)\/.*$/, "http://www.rockipedia.no/$1/$2/");
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
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/.*\?movieid=([0-9]+).*$/, "http://soundtrackcollector.com/title/$1/");
            url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/.*\?composerid=([0-9]+).*$/, "http://soundtrackcollector.com/composer/$1/");
            return url;
        }
    }
};


MB.Control.URLCleanup = function (sourceType, typeControl, urlControl, errorObservable, handleErrors) {
    var self = {};

    self.typeControl = $(typeControl);
    self.urlControl = $(urlControl);
    self.sourceType = sourceType;
    self.error = errorObservable || ko.observable("");

    self.error.subscribe(function (error) {
        $("button[type=submit]").prop("disabled", !!error);
    });

    self.error.notifySubscribers(self.error());

    if (handleErrors !== false) {
        var $errorSpan = $("<span>").addClass("error").hide();

        self.typeControl.after($errorSpan);

        ko.applyBindingsToNode($errorSpan[0], {
            visible: self.error, text: self.error
        });
    }

    var validationRules = { };
    // "has lyrics at" is only allowed for certain lyrics sites
    validationRules[ MB.constants.LINK_TYPES.lyrics.artist ] = function (url) {
        return MB.constants.CLEANUPS.lyrics.match.test(url)
    };
    validationRules[ MB.constants.LINK_TYPES.lyrics.release_group ] = function (url) {
        return MB.constants.CLEANUPS.lyrics.match.test(url)
    };
    validationRules[ MB.constants.LINK_TYPES.lyrics.work ] = function (url) {
        return MB.constants.CLEANUPS.lyrics.match.test(url)
    };
    // allow Discogs page only for the correct entities
    validationRules[ MB.constants.LINK_TYPES.discogs.artist ] = function (url) {
        return url.match(/discogs\.com\/(artist|user)\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.label ] = function (url) {
        return url.match(/discogs\.com\/label\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.release_group ] = function (url) {
        return url.match(/discogs\.com\/master\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.discogs.release ] = function (url) {
        return url.match(/discogs\.com\/(release|mp3)\//) != null;
    }
    // allow Allmusic page only for the correct entities
    validationRules[ MB.constants.LINK_TYPES.allmusic.artist ] = function (url) {
        return url.match(/allmusic\.com\/artist\/mn/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.release_group ] = function (url) {
        return url.match(/allmusic\.com\/album\/mw/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.work ] = function (url) {
        return url.match(/allmusic\.com\/composition\/mc|song\/mt/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.allmusic.recording ] = function (url) {
        return url.match(/allmusic\.com\/performance\/mq/) != null;
    }

    // allow only artist pages in BBC Music links
    validationRules[ MB.constants.LINK_TYPES.bbcmusic.artist ] = function (url) {
        return url.match(/bbc\.co\.uk\/music\/artists\//) != null;
    }

    // allow only Wikipedia pages with the Wikipedia rel
    validationRules[ MB.constants.LINK_TYPES.wikipedia.artist ] = function (url) {
        return url.match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.work ] = function (url) {
        return url.match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.label ] = function (url) {
        return url.match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.release_group ] = function (url) {
        return url.match(/wikipedia\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikipedia.area ] = function (url) {
        return url.match(/wikipedia\.org\//) != null;
    }

    // allow only Myspace pages with the Myspace rel
    validationRules[ MB.constants.LINK_TYPES.myspace.artist ] = function (url) {
        return url.match(/myspace\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.myspace.label ] = function (url) {
        return url.match(/myspace\.com\//) != null;
    }

    // allow only PureVolume pages with the PureVolume rel
    validationRules[ MB.constants.LINK_TYPES.purevolume.artist ] = function (url) {
        return url.match(/purevolume\.com\//) != null;
    }

    // allow only SecondHandSongs pages with the SecondHandSongs rel
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.artist ] = function (url) {
        return url.match(/secondhandsongs\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.release ] = function (url) {
        return url.match(/secondhandsongs\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.work ] = function (url) {
        return url.match(/secondhandsongs\.com\//) != null;
    }

    // allow only Songfacts pages with the Songfacts rel
    validationRules[ MB.constants.LINK_TYPES.songfacts.work ] = function (url) {
        return url.match(/songfacts\.com\//) != null;
    }

    // allow only Soundcloud pages with the Soundcloud rel
    validationRules[ MB.constants.LINK_TYPES.soundcloud.artist ] = function (url) {
        return url.match(/soundcloud\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.soundcloud.label ] = function (url) {
        return url.match(/soundcloud\.com\//) != null;
    }

    // allow only VIAF pages with the VIAF rel
    validationRules[ MB.constants.LINK_TYPES.viaf.artist ] = function (url) {
        return url.match(/viaf\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.viaf.work ] = function (url) {
        return url.match(/viaf\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.viaf.label ] = function (url) {
        return url.match(/viaf\.org\//) != null;
    }

    // allow only VGMdb pages with the VGMdb rel
    validationRules[ MB.constants.LINK_TYPES.vgmdb.artist ] = function (url) {
        return url.match(/vgmdb\.net\/(?:artist|org)\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.vgmdb.release ] = function (url) {
        return url.match(/vgmdb\.net\/album\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.vgmdb.label ] = function (url) {
        return url.match(/vgmdb\.net\/org\//) != null;
    }

    // allow only YouTube pages with the YouTube rel
    validationRules[ MB.constants.LINK_TYPES.youtube.artist ] = function (url) {
        return url.match(/youtube\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.youtube.label ] = function (url) {
        return url.match(/youtube\.com\//) != null;
    }

    // allow only Amazon pages with the Amazon rel
    validationRules[ MB.constants.LINK_TYPES.amazon.release ] = function (url) {
        return url.match(/amazon\.(com|ca|co\.uk|fr|at|de|it|co\.jp|jp|cn|es)\//) != null;
    }

    // allow only IMDb pages with the IMDb rels
    validationRules[ MB.constants.LINK_TYPES.imdb.artist ] = function (url) {
        return url.match(/imdb\.com\/(name|character|company)/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdb.label ] = function (url) {
        return url.match(/imdb\.com\/company/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdb.release_group ] = function (url) {
        return url.match(/imdb\.com\/title/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdbsamples.recording ] = function (url) {
        return url.match(/imdb\.com\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.imdbsamples.release ] = function (url) {
        return url.match(/imdb\.com\//) != null;
    }

    // allow only SecondHandSongs pages with the SecondHandSongs rel and at the right level
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.artist ] = function (url) {
        return url.match(/secondhandsongs\.com\/artist\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.release ] = function (url) {
        return url.match(/secondhandsongs\.com\/release\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.secondhandsongs.work ] = function (url) {
        return url.match(/secondhandsongs\.com\/work\//) != null;
    }

    // allow only Wikidata pages with the Wikidata rel
    validationRules[ MB.constants.LINK_TYPES.wikidata.artist ] = function (url) {
        return url.match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.work ] = function (url) {
        return url.match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.label ] = function (url) {
        return url.match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.release_group ] = function (url) {
        return url.match(/wikidata\.org\//) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.wikidata.area ] = function (url) {
        return url.match(/wikidata\.org\//) != null;
    }

    // allow only top-level Bandcamp pages as artist/label URLs
    validationRules[ MB.constants.LINK_TYPES.bandcamp.artist ] = function (url) {
        return url.match(/\.bandcamp\.com\/$/) != null;
    }
    validationRules[ MB.constants.LINK_TYPES.bandcamp.label ] = function (url) {
        return url.match(/\.bandcamp\.com\/$/) != null;
    }

    // avoid wikipedia being added as release-level discography entry
    validationRules [ MB.constants.LINK_TYPES.discographyentry.release ] = function (url) {
        var is_wikipedia = new RegExp('^(https?://)?([^.]+\.)?wikipedia\\.org/');
        return !is_wikipedia.test(url)
    };

    // only allow domains on the score whitelist
    var validateScore = function (url) {
        return MB.constants.CLEANUPS.score.match.test(url)
    };
    validationRules[ MB.constants.LINK_TYPES.score.release_group ] = validateScore;
    validationRules[ MB.constants.LINK_TYPES.score.work ] = validateScore;

    // Ensure Soundtrack Collector stuff is added to the right level
    var STCollector_is_not_RG = function (url) {
        var STcheckRG = new RegExp('^(https?://)?(www\\.)?soundtrackcollector\\.com/title/');
        return !STcheckRG.test(url)
    };
    var STCollector_is_not_artist = function (url) {
        var STcheckartist = new RegExp('^(https?://)?(www\\.)?soundtrackcollector\\.com/composer/');
        return !STcheckartist.test(url)
    };

    // only allow domains on the other databases whitelist
    var validateOtherDatabases = function (url) {
        return MB.constants.CLEANUPS.otherdatabases.match.test(url)
    };
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.artist ] = function (url) {return validateOtherDatabases(url) && STCollector_is_not_RG(url)}
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.label ] = validateOtherDatabases
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.release_group ] = function (url) {return validateOtherDatabases(url) && STCollector_is_not_artist(url)}
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.release ] = function (url) {return validateOtherDatabases(url) && STCollector_is_not_RG(url) && STCollector_is_not_artist(url)}
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.work ] = validateOtherDatabases
    validationRules[ MB.constants.LINK_TYPES.otherdatabases.recording ] = validateOtherDatabases

    var validateFacebook = function (url) {
        if (url.match(/facebook.com\/pages\//)) {
            return url.match(/\/pages\/[^\/?#]+\/\d+/);
        }
        return true;
    };
    validationRules[ MB.constants.LINK_TYPES.socialnetwork.artist ] = validateFacebook;
    validationRules[ MB.constants.LINK_TYPES.socialnetwork.label ] = validateFacebook;

    // Block images from sites that don't allow deeplinking
    var validateImage = function (url) {
        if (url.match(/\/\/s\.pixogs\.com\//)) { return false; }
        if (url.match(/\/\/s\.discogss\.com\//)) { return false; }
        return true;
    };
    validationRules[ MB.constants.LINK_TYPES.image.artist ] = validateImage;
    validationRules[ MB.constants.LINK_TYPES.image.label ] = validateImage;
    validationRules[ MB.constants.LINK_TYPES.image.place ] = validateImage;

    self.guessType = function (sourceType, currentURL) {
        var cleanup = _.find(MB.constants.CLEANUPS, function (cleanup) {
            return (cleanup.type || {})[sourceType] && cleanup.match.test(currentURL);
        });

        return cleanup && cleanup.type[sourceType];
    };

    self.cleanUrl = function (sourceType, dirtyURL) {
        dirtyURL = _.str.trim(dirtyURL).replace(/(%E2%80%8E|\u200E)$/, "");

        var cleanup = _.find(MB.constants.CLEANUPS, function (cleanup) {
            return cleanup.clean && cleanup.match.test(dirtyURL);
        });

        return cleanup ? cleanup.clean(dirtyURL) : dirtyURL;
    };

    // A list of errors that are set/cleared by the URLCleanup code. Used to
    // determine whether it's safe to clear other errors set by outside code.

    var linkTypeErrors = [
        MB.text.SelectURLType,
        MB.text.URLNotAllowed
    ];


    var typeChanged = function (event) {
        var url = self.urlControl.val();
        var linkType = self.typeControl.val();
        var checker = validationRules[linkType];

        if (url && !linkType) {
            self.error(MB.text.SelectURLType);
        }
        else if (url && checker && !checker(url)) {
            self.error(MB.text.URLNotAllowed);
        }
        else if (_.contains(linkTypeErrors, self.error())) {
            self.error("");
        }
    };

    var urlChanged = function(event) {
        var url = self.urlControl.val(),
            clean = self.cleanUrl(self.sourceType, url) || url;

        if (url.match(/^\w+\./)) {
            self.urlControl.val('http://' + url);
            return;
        }

        // Allow adding spaces while typing; they'll be trimmed later onblur.
        if (_.str.trim(url) !== clean) {
            self.urlControl.val(clean);
        }

        if (!clean) {
            if (self.error() !== MB.text.RequiredField) {
                self.error("");
            }
        }
        else if (!MB.utility.isValidURL(clean)) {
            self.error(MB.text.EnterAValidURL);
        }
        else {
            if (self.error() === MB.text.EnterAValidURL) {
                self.error("");
            }

            if (self.typeControl.length) {
                var type = self.guessType(self.sourceType, clean);

                if (type) {
                    self.typeControl.val(type).trigger("change");
                }

                typeChanged(event);
            }
        }

        if (event.type === "submit" && self.error()) {
            event.preventDefault();
        }
    };

    self.typeControl.on("change", typeChanged);
    self.urlControl.on("change keydown keyup input propertychange", urlChanged);

    self.urlControl.on("blur", function () {
        this.value = _.str.trim(this.value);
    });

    self.urlControl.parents('form').submit(urlChanged);

    return self;
};
