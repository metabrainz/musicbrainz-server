// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (releaseEditor) {

    var utils = releaseEditor.utils = {};
    var releaseField = ko.observable().subscribeTo("releaseField", true);


    utils.mapChild = function (parent, children, type) {
        return _.map(children || [], function (data) {
            return type(data, parent);
        });
    };


    utils.withRelease = function (read, defaultValue) {
        return MB.utility.computedWith(read, releaseField, defaultValue);
    };


    utils.debounce = function (computed, delay) {
        return computed.extend({
            rateLimit: { method: "notifyWhenChangesStop", timeout: delay || 500 }
        });
    };


    // Webservice helpers

    var specialLuceneChars = /([+\-&|!(){}[\]^"~*?:\\\/])/g;

    utils.escapeLuceneValue = function (value) {
        return String(value).replace(specialLuceneChars, "\\$1");
    };

    function constructLuceneField(values, key) {
        return key + ":(" + values.join(" OR ") + ")";
    }

    utils.constructLuceneFieldConjunction = function (params) {
        return _.map(params, constructLuceneField).join(" AND ");
    };


    utils.search = function (resource, params, limit, offset) {
        var requestArgs = {
            url: "/ws/2/" + resource,
            data: {
                fmt: "json",
                query: utils.constructLuceneFieldConjunction(params)
            }
        };

        if (limit !== undefined) requestArgs.data.limit = limit;

        if (offset !== undefined) requestArgs.data.offset = offset;

        return MB.utility.request(requestArgs);
    };


    // Converts JSON from /ws/2 into /ws/js-formatted data. Hopefully one day
    // we'll have a standard MB data format and this won't be needed.

    utils.cleanWebServiceData = function (data) {
        var clean = { gid: data.id, name: data.title };

        if (data.length) clean.length = data.length;

        if (data["sort-name"]) clean.sortName = data["sort-name"];

        if (data["artist-credit"]) {
            clean.artistCredit = _.map(data["artist-credit"], cleanArtistCreditName);
        }

        if (data.disambiguation) {
            clean.comment = data.disambiguation;
        }

        return clean;
    };

    function cleanArtistCreditName(data) {
        return {
            artist: {
                gid: data.artist.id,
                name: data.artist.name,
                sortName: data.artist["sort-name"]
            },
            name: data.name,
            joinPhrase: data.joinphrase || ""
        };
    }


    // Metadata comparison utilities.

    function lengthsAreWithin10s(a, b) {
        return Math.abs(a - b) <= MB.constants.MAX_LENGTH_DIFFERENCE;
    }

    function namesAreSimilar(a, b) {
        return MB.utility.similarity(a, b) >= MB.constants.MIN_NAME_SIMILARITY;
    }

    utils.similarNames = function (oldName, newName) {
        return oldName == newName || namesAreSimilar(oldName, newName);
    };

    utils.similarLengths = function (oldLength, newLength) {
        // If either of the lengths are empty, we can't compare them, so we
        // consider them to be "similar" for recording association purposes.
        return !oldLength || !newLength || lengthsAreWithin10s(oldLength, newLength);
    };

}(MB.releaseEditor = MB.releaseEditor || {}));
