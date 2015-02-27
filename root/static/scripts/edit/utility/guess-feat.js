// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var balanced = require('balanced-match');
var namesAreSimilar = require('./names-are-similar.js');

var featRegex = /(?:^\s*|[,\-]\s*|\s+)(?:(?:ft|feat)[.\s]|featuring\s+)/i;
var collabRegex = /(,?\s+(?:&|and|et)\s+|,\s+|;\s+|\s*\/\s*|\s+vs\.\s+)/i;
var bracketPairs = [['(', ')'], ['[', ']']];

function extractNonBracketedFeatCredits(str) {
    var wrapped = _(str.split(featRegex)).map(_.str.clean);
    return {name: _.str.clean(wrapped.first()), credits: wrapped.rest().compact().value()};
}

function extractBracketedFeatCredits(str, relatedArtists, isProbablyClassical) {
    return _.reduce(bracketPairs, function (accum, pair) {
        var name = '';
        var credits = accum.credits;
        var remainder = accum.name;
        var b, m;

        while (true) {
            b = balanced(pair[0], pair[1], remainder);
            if (b) {
                m = extractFeatCredits(b.body, relatedArtists, isProbablyClassical, true);
                name += b.pre;

                if (m.name) {
                    if (findSimilarArtist(relatedArtists, m.name)) {
                        credits.push(m.name);
                    } else {
                        name += pair[0] + m.name + pair[1];
                    }
                }

                credits = credits.concat(m.credits);
                remainder = b.post;
            } else {
                name += remainder;
                break;
            }
        }

        return {name: _.str.clean(name), credits: credits};
    }, {name: str, credits: []});
}

function extractFeatCredits(str, relatedArtists, isProbablyClassical, allowEmptyName) {
    var m1 = extractBracketedFeatCredits(str, relatedArtists, isProbablyClassical);

    if (!m1.name && !allowEmptyName) {
        return {name: str, credits: []};
    }

    var m2 = extractNonBracketedFeatCredits(m1.name);

    if (!m2.name && !allowEmptyName) {
        return m1;
    }

    return {name: m2.name, credits: m2.credits.concat(m1.credits)}
}

function findSimilarArtist(artists, name) {
    return _.find(artists, function (a) { return namesAreSimilar(name, a.name) });
}

module.exports = function (entity) {
    var relatedArtists = _.result(entity, 'relatedArtists');
    var isProbablyClassical = _.result(entity, 'isProbablyClassical');

    var name = entity.name();
    var match = extractFeatCredits(name, relatedArtists, isProbablyClassical, false);

    if (!match.name || !match.credits.length) {
        return;
    }

    entity.name(match.name);

    var oldCredits = entity.artistCredit.toJSON();
    _.last(oldCredits).joinPhrase = isProbablyClassical ? '; ' : ' feat. ';

    var fixName = function (name) {
        // remove classical roles
        return isProbablyClassical ? name.replace(/^[a-z]+: (.+)$/, '$1') : name;
    };

    var newCredit = function (artist, name, joinPhrase) {
        return {artist: artist, name: name, joinPhrase: isProbablyClassical ? ', ' : (joinPhrase || ' & ')};
    };

    var newCredits = oldCredits.concat(
        _(match.credits).map(fixName).map(function (name) {
            var artist = findSimilarArtist(relatedArtists, name);

            if (artist) {
                return newCredit(artist, name);
            } else {
                return _.map(_.chunk(name.split(collabRegex), 2), function (pair) {
                    var name = fixName(pair[0]);
                    return newCredit(findSimilarArtist(relatedArtists, name), name, pair[1]);
                });
            }
        }).flatten().value()
    );

    _.last(newCredits).joinPhrase = '';
    entity.artistCredit.setNames(newCredits);
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
