var urlRegExps = {
    amazon:          new RegExp("^(?:http://)?(?:[^/]+.)?amazon.(com|ca|cn|co.uk|uk|fr|at|de|co.jp|jp)","i"),
    archivedown:     new RegExp("^(http://)?([^/]+.)?archive.org/.*.(mp3|ogg|flac|shn)$","i"),
    archiveimg:      new RegExp("^(http://)?([^/]+.)?archive.org/.*.(jpg|jpeg|png|gif)$","i"),
    cdbaby:          new RegExp("^(http://)?([^/]+.)?cdbaby.(com|name)","i"),
    discogs:         new RegExp("^(http://)?([^/]+.)?discogs.com","i"),
    ibdb:            new RegExp("^(http://)?([^/]+.)?ibdb.com","i"),
    imdb:            new RegExp("^(http://)?([^/]+.)?imdb.com","i"),
    iobdb:           new RegExp("^(http://)?([^/]+.)?lortel.org","i"),
    jamendo:         new RegExp("^(http://)?([^/]+.)?jamendo.com","i"),
    jamendoimg:      new RegExp("^(http://)?([^/]+.)?imgjam.com","i"),  // Jamendo coverart server
    magnatune:       new RegExp("^(http://)?([^/]+.)?(he3.)?magnatune.com","i"),
    musicmoz:        new RegExp("^(http://)?([^/]+.)?musicmoz.(com|org)","i"),
    myspace:         new RegExp("^(http://)?([^/]+.)?myspace.com","i"),
    ozon:            new RegExp("^(http://)?([^/]+.)?www.ozon.ru","i"),
    purevolume:      new RegExp("^(http://)?([^/]+.)?purevolume.com","i"),
    thastrom:        new RegExp("^(http://)?([^/]+.)?www.thastrom.se","i"),
    universalpoplab: new RegExp("^(http://)?([^/]+.)?www.universalpoplab.com","i"),
    wikipedia:       new RegExp("^(http://)?([^/]+.)?wikipedia.","i"),
    youtube:         new RegExp("^(http://)?([^/]+.)?youtube.com","i")
},
    urlARValues = {
    artist:  0,
    release: 1,
    track:   2,
    label:   3,
    invalid:    ["||",   "||",  "||",   "||"],
    asin:       ["||",   "30|",  "||",   "||"],
    coverart:   ["||",   "34|",  "||",   "||"],
    discogs:    ["11|",  "24|",  "||",   "9|"],
    download:   ["||",   "20|",  "17|",  "||"],
    imdb:       ["17|",  "27|",  "||",   "||"],
    ibdb:       ["25|",  "36|",  "23|",  "||"],
    iobdb:      ["26|",  "37|",  "24|",  "||"],
    mailorder:  ["||",   "19|",  "||",   "||"],
    musicmoz:   ["12|",  "25|",  "||",   "||"],
    myspace:    ["19|",  "||",   "||",   "10|"],
    purevolume: ["22|",  "||",   "||",   "||"],
    wikipedia:  ["10|",  "23|",  "||",   "8|"],
    youtube:    ["27|",  "||",   "||",   "12|"]
};
function fixSetURLAR() {
    var thisURL = $("#form-add-url-relationship-url").attr("value"),
        newURL = "",
        site = "",
        setSelect = function(ARtype) {
            var EntityType = $("#entity-type").attr("value");
            $("#form-add-url-relationship-type").selectOptions(urlARValues[ARtype][urlARValues[EntityType]], true);
    };
    if (thisURL.match(urlRegExps.amazon)) {
        site = "asin";
    } else if (thisURL.match(urlRegExps.archivedown)) {
        site = "download";
    } else if (thisURL.match(urlRegExps.archiveimg)) {
        site = "coverart";
    } else if (thisURL.match(urlRegExps.cdbaby)) {
        site = "coverart";
        thisURL = thisURL.replace("/from/musicbrainz","");
    } else if (thisURL.match(urlRegExps.discogs)) {
        site = "discogs";
    } else if (thisURL.match(urlRegExps.ibdb)) {
        site = "ibdb";
    } else if (thisURL.match(urlRegExps.imdb)) {
        site = "imdb";
    } else if (thisURL.match(urlRegExps.iobdb)) {
        site = "iobdb";
    } else if (thisURL.match(urlRegExps.jamendoimg)) {
        site = "coverart";
    } else if (thisURL.match(urlRegExps.jamendo)) {
        site = "coverart";
    } else if (thisURL.match(urlRegExps.magnatune)) {
        site = "coverart";
    } else if (thisURL.match(urlRegExps.musicmoz)) {
        site = "musicmoz";
    } else if (thisURL.match(urlRegExps.myspace)) {
        site = "myspace";
    } else if (thisURL.match(urlRegExps.ozon)) {
        site = "coverart";
    } else if (thisURL.match(urlRegExps.purevolume)) {
        site = "purevolume";
    } else if (thisURL.match(urlRegExps.thastrom)) {
        site = "coverart";
    } else if (thisURL.match(urlRegExps.universalpoplab)) {
        site = "coverart";
    } else if (thisURL.match(urlRegExps.wikipedia)) {
        site = "wikipedia";
    } else if (thisURL.match(urlRegExps.youtube)) {
        site = "youtube";
    }
    /* Change the selected option in the select. */
    setSelect(site);
    /* Clean up the url. */
    switch (site) {
        case "archiveimg":
            newURL = thisURL.replace(/\/http:\/\//, "/");
            break;
        case "asin":
            // http://www.amazon.TLD/gp/product/ASIN
            var tld = thisURL.match(urlRegExps.amazon),
                asin = thisURL.match(/\/([A-Z0-9]{10})(?:[\/?]|$|#)/);
            if (tld == "jp" || tld == "uk") {
                tld = "co." + tld;
            }
            if (tld !== "" && asin !== "") {
                newURL = "http://www.amazon." + tld + "/gp/product/" + asin;
            }
            if (tld == "cn") {  // .cn does not use standard ASINs.
                setSelect("mailorder");
                newURL = thisURL;
            }
            break;
//        case "cdbaby":  // If ticket 4979 is added, a second AR could be auto-added here for mailorder.
//            break;
        case "discogs":
            newURL = thisURL.replace(/^https?:\/\/([^.]+\.)?discogs\.com\/(.*\/(artist|release|label))?/, "http://www.discogs.com/$3");
            break;
        case "jamendo":  // If ticket 4979 is added, a second AR could be auto-added here for free download.
            thisURL = thisURL.replace(/jamendo\.com\/\w\w\/album\/(\d+)/, "$1");  // Jamendo site URLs
            thisURL = thisURL.replace(/jamendo\.com\/albums\/(\d+)/, "$1");  // Old Jamendo art URLs
            thisURL = thisURL.replace(/imgjam\.com\/albums\/(\d+)/, "$1");  // New Jamendo art URLs
            newURL = "http://www.jamendo.com/en/album/" + thisURL;
            break;
        case "myspace":
            thisURL.match(/^(?:http:\/\/)?(?:[^\/]+\.)?myspace\.com\/(?:index.+friendId=)?([a-zA-Z\d]+)/);
            newURL = "http://www.myspace.com/" + thisURL;
            break;
        case "youtube":
            newURL = thisURL.replace(/^http:\/\/(?:[^.]+\.)?youtube\.com\/(.+\/|watch\?v=|videos_list\?(?:user|tag)=)(.+)/, 
                function(str, p1, p2) {
                    if (p1 != "videos_list?tag=" && p1 != "watch?v=" && p1 != "tags/") {
                        return "http://www.youtube.com/user/" + p2;
                    } else {
                        setSelect("invalid");
                        alertUser("error",text.NonValidYouTubeAR);
                    }
                }
            );
            break;
        default:
            newURL = thisURL;
    }
    /* Set the field value to the newly cleaned URL. */
    $("#form-add-url-relationship-url").attr("value", newURL);
}
$(function() {
    $("#form-add-url-relationship-url").blur(function() {
        fixSetURLAR();
    });
    $("#form-add-url-relationship-url").change(function() {
        fixSetURLAR();
    });
    $("#form-add-url-relationship-url").focus(function() {
        fixSetURLAR();
    });
    $("#form-add-url-relationship-url").keyup(function() {
        fixSetURLAR();
    });
    $("#form-add-url-relationship-type").change(function() {
        if ($("#form-add-url-relationship-type").selectedValues() == "34|") {
            var goodCoverArtSite = false;
            var validCoverArtSites = /^(http:\/\/)?([^\/]+\.)(cdbaby\.com|archive\.org|www\.encyclopedisque\.fr|(?:img\.)?jamendo\.com|imgjam\.com|(he3\.)magnatune\.com|www\.ozon\.ru|www\.thastrom\.se|www\.universalpoplab\.com)/;
            fixSetURLAR();
            if ($("#form-add-url-relationship-type").selectedValues() == "34|") {
                if (validCoverArtSites.test($("#form-add-url-relationship-url").attr("value"))) {
                    goodCoverArtSite = true;
                }
                if (!goodCoverArtSite) {
                    alertUser("error",text.NonValidCoverArtAR);
                }
            }
        }
    });
});
