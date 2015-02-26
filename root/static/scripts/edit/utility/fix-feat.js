// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var namesAreSimilar = require('./names-are-similar.js');

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

    entity.name(_.str.clean(name));

    var credits = entity.artistCredit.toJSON();
    var collabs = match[2].split(collabRegex);
    var performers = entity.recording ? entity.recording().performers : entity.performers;

    _.last(credits).joinPhrase = ' feat. ';

    entity.artistCredit.setNames(
        credits.concat(
            _(collabs).chunk(2).map(function (pair) {
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
