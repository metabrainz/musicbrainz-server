// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const balanced = require('balanced-match');
const _ = require('lodash');

const {MIN_NAME_SIMILARITY} = require('../../common/constants');
const clean = require('../../common/utility/clean');
const getSimilarity = require('./similarity');

var featRegex = /(?:^\s*|[,\-]\s*|\s+)(?:(?:ft|feat)[.\s]|featuring\s+)/i;
var collabRegex = /(,?\s+(?:&|and|et)\s+|,\s+|;\s+|\s*\/\s*|\s+vs\.\s+)/i;
var bracketPairs = [['(', ')'], ['[', ']']];

function extractNonBracketedFeatCredits(str, artists, isProbablyClassical) {
    var wrapped = _(str.split(featRegex)).map(clean);
    return {
        name: clean(wrapped.first()),
        artistCredit: wrapped.rest().compact()
            .map(c => expandCredit(c, artists, isProbablyClassical)).flatten().value()
    };
}

function extractBracketedFeatCredits(str, artists, isProbablyClassical) {
    return _.reduce(bracketPairs, function (accum, pair) {
        var name = '';
        var credits = accum.artistCredit;
        var remainder = accum.name;
        var b, m;

        while (true) {
            b = balanced(pair[0], pair[1], remainder);
            if (b) {
                m = extractFeatCredits(b.body, artists, isProbablyClassical, true);
                name += b.pre;

                if (m.name) {
                    // Check if the remaining text in the brackets is also an artist name.
                    var expandedCredits = expandCredit(m.name, artists, isProbablyClassical);

                    if (_.any(expandedCredits, c => c.similarity >= MIN_NAME_SIMILARITY)) {
                        credits = credits.concat(expandedCredits);
                    } else {
                        name += pair[0] + m.name + pair[1];
                    }
                }

                credits = credits.concat(m.artistCredit);
                remainder = b.post;
            } else {
                name += remainder;
                break;
            }
        }

        return {name: clean(name), artistCredit: credits};
    }, {name: str, artistCredit: []});
}

function extractFeatCredits(str, artists, isProbablyClassical, allowEmptyName) {
    var m1 = extractBracketedFeatCredits(str, artists, isProbablyClassical);

    if (!m1.name && !allowEmptyName) {
        return {name: str, artistCredit: []};
    }

    var m2 = extractNonBracketedFeatCredits(m1.name, artists, isProbablyClassical);

    if (!m2.name && !allowEmptyName) {
        return m1;
    }

    return {name: m2.name, artistCredit: m2.artistCredit.concat(m1.artistCredit)}
}

function cleanCredit(name, isProbablyClassical) {
    // remove classical roles
    return isProbablyClassical ? name.replace(/^[a-z]+: (.+)$/, '$1') : name;
}

function bestArtistMatch(artists, name, isProbablyClassical) {
    return _(artists)
        .map(function (a) {
            var similarity = getSimilarity(name, a.name);
            if (similarity >= MIN_NAME_SIMILARITY) {
                return {similarity: similarity, artist: a, name: name};
            }
        })
        .compact()
        .sortBy('similarity')
        .reverse()
        .first();
}

function expandCredit(fullName, artists, isProbablyClassical) {
    fullName = cleanCredit(fullName, isProbablyClassical);

    // See which produces a better match to an existing artist: the full
    // credit, or the individual credits as split by collabRegex. Some artist
    // names legitimately contain characters in collabRegex, so this stops
    // those from getting split (assuming the artist appears in a relationship
    // or artist credit).
    var bestFullMatch = bestArtistMatch(artists, fullName, isProbablyClassical);

    var fixJoinPhrase = function (existing) {
        return isProbablyClassical ? ', ' : (existing || ' & ');
    };

    var splitMatches = _(fullName.split(collabRegex))
        .chunk(2)
        .map(function (pair) {
            var name = cleanCredit(pair[0], isProbablyClassical);

            return _.assign(
                {similarity: -1, artist: null, name: name, joinPhrase: fixJoinPhrase(pair[1])},
                bestArtistMatch(artists, name, isProbablyClassical) || {}
            );
        });

    if (bestFullMatch && bestFullMatch.similarity > splitMatches.sortBy('similarity').reverse().first().similarity) {
        bestFullMatch.joinPhrase = fixJoinPhrase();
        return [bestFullMatch];
    }

    return splitMatches.value();
}

module.exports = function (entity) {
    var relatedArtists = _.result(entity, 'relatedArtists');
    var isProbablyClassical = _.result(entity, 'isProbablyClassical');

    var name = entity.name();
    var match = extractFeatCredits(name, relatedArtists, isProbablyClassical, false);

    if (!match.name || !match.artistCredit.length) {
        return;
    }

    entity.name(match.name);

    var artistCredit = entity.artistCredit.toJSON();
    _.last(artistCredit).joinPhrase = isProbablyClassical ? '; ' : ' feat. ';
    _.last(match.artistCredit).joinPhrase = '';

    entity.artistCredit.setNames(artistCredit.concat(match.artistCredit));
};

// For use outside of the release editor.
MB.Control.initGuessFeatButton = function (formName) {
    var nameInput = document.getElementById('id-' + formName + '.name');

    var augmentedEntity = _.assign(
        Object.create(MB.sourceRelationshipEditor.source),
        {
            // Emulate an observable that just reads/writes to the name input directly.
            name: function () {
                if (arguments.length) {
                    nameInput.value = arguments[0];
                } else {
                    return nameInput.value;
                }
            },
            // Confusingly, the artistCredit object used to generated hidden input
            // fields is also different from MB.sourceRelationshipEditor.source's,
            // so we have to replace this field too.
            artistCredit: ko.dataFor(document.getElementById('entity-artist'))
        }
    );

    $(document).on('click', 'button.guessfeat.icon', function () {
        module.exports(augmentedEntity);
    });
};
