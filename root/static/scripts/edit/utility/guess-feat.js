// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var balanced = require('balanced-match');
var namesAreSimilar = require('./names-are-similar.js');

var featRegex = /(?:^\s*|[,\-]\s*|\s+)(?:(?:ft|feat)[.\s]|featuring\s+)/i;
var collabRegex = /(,?\s+(?:&|and|et)\s+|,\s+|\s*\/\s*|\s+vs\.\s+)/i;
var bracketPairs = [['(', ')'], ['[', ']']];

function joinCredits(credits) {
    return _(credits).compact().join(' & ');
}

function extractNonBracketedFeatCredits(str) {
    var wrapped = _(str.split(featRegex)).map(_.str.clean);
    return {name: wrapped.first(), credits: joinCredits(wrapped.rest())};
}

function extractBracketedFeatCredits(str) {
    return _.reduce(bracketPairs, function (accum, pair) {
        var name = '';
        var credits = [accum.credits];
        var remainder = accum.name;
        var b, m;

        while (true) {
            b = balanced(pair[0], pair[1], remainder);
            if (b) {
                m = extractFeatCredits(b.body, true);
                name += (b.pre + (m.name ? (pair[0] + m.name + pair[1]) : ''));
                credits.push(m.credits);
                remainder = b.post;
            } else {
                name += remainder;
                break;
            }
        }

        return {name: _.str.clean(name), credits: joinCredits(credits)};
    }, {name: str, credits: ''});
}

function extractFeatCredits(str, allowEmptyName) {
    var m1 = extractBracketedFeatCredits(str);

    if (!m1.name && !allowEmptyName) {
        return {name: str, credits: ''};
    }

    var m2 = extractNonBracketedFeatCredits(m1.name);

    if (!m2.name && !allowEmptyName) {
        return m1;
    }

    return {name: m2.name, credits: joinCredits([m2.credits, m1.credits])}
}

module.exports = function (entity) {
    var name = entity.name();
    var match = extractFeatCredits(name, false);

    if (!match.name || !match.credits) {
        return;
    }

    entity.name(match.name);

    var credits = entity.artistCredit.toJSON();
    var performers = entity.recording ? entity.recording().performers : entity.performers;

    _.last(credits).joinPhrase = ' feat. ';

    entity.artistCredit.setNames(
        credits.concat(
            _(match.credits.split(collabRegex)).chunk(2).map(function (pair) {
                var name = _.str.clean(pair[0]);

                return {
                    artist: _.find(performers, function (p) { return namesAreSimilar(name, p.name) }),
                    name: name,
                    joinPhrase: pair[1] || ''
                };
            }).value()
        )
    );
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
