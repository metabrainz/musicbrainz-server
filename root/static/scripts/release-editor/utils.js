// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2011-2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt
//
// The 'base64' function contained in this file is derived from:
// http://stringencoders.googlecode.com/svn-history/r210/trunk/javascript/base64.js
// Original version Copyright (C) 2010 Nick Galbreath, and released under
// the MIT license: http://opensource.org/licenses/MIT

import ko from 'knockout';
import _ from 'lodash';

import {rstr_sha1} from '../../lib/sha1/sha1';
import {MAX_LENGTH_DIFFERENCE, MIN_NAME_SIMILARITY}
    from '../common/constants';
import escapeLuceneValue from '../common/utility/escapeLuceneValue';
import request from '../common/utility/request';
import similarity from '../edit/utility/similarity';

import releaseEditor from './viewModel';

const utils = {};

releaseEditor.utils = utils;

utils.mapChild = function (parent, children, type) {
    return _.map(children || [], function (data) {
        return new type(data, parent);
    });
};


utils.computedWith = function (callback, observable, defaultValue) {
    return ko.computed(function () {
        var result = observable();
        return result ? callback(result) : defaultValue;
    });
};


utils.withRelease = function (read, defaultValue) {
    return utils.computedWith(read, releaseEditor.rootField.release, defaultValue);
};

export function unformatTrackLength(duration) {
    if (!duration) {
        return null;
    }

    if (duration.slice(-2) == 'ms') {
        return parseInt(duration, 10);
    }

    var parts = duration.replace(/[:\.]/, ':').split(':');
    if (parts[0] == '?' || parts[0] == '??' || duration === '') {
        return null;
    }

    var seconds = parseInt(parts.pop(), 10);
    var minutes = parseInt(parts.pop() || 0, 10) * 60;
    var hours = parseInt(parts.pop() || 0, 10) * 3600;

    return (hours + minutes + seconds) * 1000;
}

utils.unformatTrackLength = unformatTrackLength;

// Webservice helpers

utils.escapeLuceneValue = escapeLuceneValue;

utils.constructLuceneField = function (values, key) {
    return key + ':(' + values.join(' OR ') + ')';
};

utils.constructLuceneFieldConjunction = function (params) {
    return _.map(params, utils.constructLuceneField).join(' AND ');
};


utils.search = function (resource, query, limit, offset) {
    var requestArgs = {
        url: '/ws/2/' + resource,
        data: {
            fmt: 'json',
            query: query,
        },
    };

    if (limit !== undefined) requestArgs.data.limit = limit;

    if (offset !== undefined) requestArgs.data.offset = offset;

    return request(requestArgs);
};


utils.reuseExistingMediumData = function (data) {
    /*
     * When reusing an existing medium, we don't want to keep its id or
     * its cdtocs, since neither of those will be shared. However, if we
     * haven't loaded the tracks yet, we retain the id as originalID so we
     * can request them later. We also drop the format, since it'll often
     * be different.
     */
    var newData = _.omit(data, 'id', 'cdtocs', 'format', 'formatID');

    if (data.id) newData.originalID = data.id;

    return newData;
};


// Converts JSON from /ws/2 into /ws/js-formatted data. Hopefully one day
// we'll have a standard MB data format and this won't be needed.

utils.cleanWebServiceData = function (data) {
    var clean = {gid: data.id, name: data.title};

    if (data.length) clean.length = data.length;

    if (data['sort-name']) clean.sort_name = data['sort-name'];

    if (data['artist-credit']) {
        clean.artistCredit = {
            names: _.map(data['artist-credit'], cleanArtistCreditName),
        };
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
            sort_name: data.artist['sort-name'],
            entityType: 'artist',
        },
        name: data.name || data.artist.name,
        joinPhrase: data.joinphrase || '',
    };
}


// Metadata comparison utilities.

function lengthsAreWithin10s(a, b) {
    return Math.abs(a - b) <= MAX_LENGTH_DIFFERENCE;
}

function namesAreSimilar(a, b) {
    return similarity(a, b) >= MIN_NAME_SIMILARITY;
}

utils.similarNames = function (oldName, newName) {
    return oldName == newName || namesAreSimilar(oldName, newName);
};

utils.similarLengths = function (oldLength, newLength) {
    // If either of the lengths are empty, we can't compare them, so we
    // consider them to be "similar" for recording association purposes.
    return !oldLength || !newLength || lengthsAreWithin10s(oldLength, newLength);
};


export function calculateDiscID(toc) {
    var info = toc.split(/\s/);

    var temp = paddedHex(info.shift(), 2) + paddedHex(info.shift(), 2);

    for (var i = 0; i < 100; i++) {
        temp += paddedHex(info[i], 8);
    }

    return base64(rstr_sha1(temp));
}

utils.calculateDiscID = calculateDiscID;

function paddedHex(str, length) {
    return _.padStart((parseInt(str, 10) || 0).toString(16).toUpperCase(), length, '0');
}

// The alphabet has been modified and does not conform to RFC822.
// For an explanation, see http://wiki.musicbrainz.org/Disc_ID_Calculation

var padchar = '-';
var alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._';

function base64(s) {
    var i, b10;
    var x = [];
    var imax = s.length - s.length % 3;

    for (i = 0; i < imax; i += 3) {
        b10 = (s.charCodeAt(i) << 16) | (s.charCodeAt(i + 1) << 8) | s.charCodeAt(i + 2);
        x.push(alpha.charAt(b10 >> 18));
        x.push(alpha.charAt((b10 >> 12) & 0x3F));
        x.push(alpha.charAt((b10 >> 6) & 0x3F));
        x.push(alpha.charAt(b10 & 0x3F));
    }

    switch (s.length - imax) {
        case 1:
            b10 = s.charCodeAt(i) << 16;
            x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
                   padchar + padchar);
            break;
        case 2:
            b10 = (s.charCodeAt(i) << 16) | (s.charCodeAt(i + 1) << 8);
            x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
                   alpha.charAt((b10 >> 6) & 0x3F) + padchar);
            break;
    }

    return x.join('');
}

export default utils;
