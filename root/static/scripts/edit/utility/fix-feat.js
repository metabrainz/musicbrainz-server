// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var featRegex = /(.+?)\(?(?:feat\.|featuring |ft\.)([^\(\)]+)\)?(.*)/i;
var collabRegex = /(,? (?:&|and|et) |, | vs\. )/i;

module.exports = function (entity) {
    var name = entity.name();
    var match = _.map(name.match(featRegex), _.str.trim);

    if (!match.length) {
        return;
    }

    name = match[1];

    if (match[3]) {
        name += ' ' + match[3]; // suffix
    }

    entity.name(name);

    var credits = entity.artistCredit.toJSON();
    _.last(credits).joinPhrase = ' feat. ';

    var collabs = match[2].split(collabRegex);
    for (var i = 0, len = collabs.length; i < len; i += 2) {
        credits.push({ name: _.str.clean(collabs[i]), joinPhrase: collabs[i + 1] || '' });
    }

    entity.artistCredit.setNames(credits);
};
