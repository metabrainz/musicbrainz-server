// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');

const {l} = require('../../common/i18n');
const commaList = require('../../common/i18n/commaList');
const commaOnlyList = require('../../common/i18n/commaOnlyList');
const clean = require('../../common/utility/clean');

var attributeRegex = /\{(.*?)(?::(.*?))?\}/g;

function mapNameToID(result, info, id) {
    result[info.attribute.name] = id;
}

exports.clean = _.memoize(function (linkType, backward) {
    var linkType = MB.typeInfoByID[linkType];
    var idsByName = _.transform(linkType.attributes, mapNameToID);

    // remove {foo} {bar} junk, unless it's for a required attribute.
    var phrase = backward ? linkType.reversePhrase : linkType.phrase;

    return clean(phrase.replace(attributeRegex, function (match, name, alt) {
        var id = idsByName[name];

        if (id !== undefined && linkType.attributes[id].min < 1) {
            return (alt ? alt.split('|')[1] : '') || '';
        }

        return match;
    }));
}, (a, b) => a + String(b));

exports.interpolate = function (linkType, attributes) {
    if (!linkType) {
        return ['', '', ''];
    }

    var phrase = linkType.phrase;
    var reversePhrase = linkType.reversePhrase;
    var cleanPhrase = '';
    var cleanReversePhrase = '';
    var cleanExtraAttributes;
    var attributesByName = {};
    var usedAttributes = [];

    _.each(attributes, function (attribute) {
        var type = attribute.type;
        var value = type.l_name;

        if (type.freeText) {
            value = clean(attribute.textValue());
            if (value) {
                value = l('{attribute}: {value}', {attribute: type.l_name, value: value});
            }
        }

        if (type.creditable) {
            var credit = clean(attribute.creditedAs());
            if (credit) {
                value = l('{attribute} [{credited_as}]', {attribute: type.l_name, credited_as: credit});
            }
        }

        if (value) {
            var rootName = type.root.name;
            (attributesByName[rootName] = attributesByName[rootName] || []).push(value);
        }
    });

    function interpolate(match, name, alts) {
        usedAttributes.push(name);

        var values = attributesByName[name] || [];
        var replacement = commaList(values)

        if (alts && (alts = alts.split('|'))) {
            replacement = values.length ? alts[0].replace(/%/g, replacement) : alts[1] || '';
        }

        return replacement;
    }

    phrase = clean(phrase.replace(attributeRegex, interpolate));
    reversePhrase = clean(reversePhrase.replace(attributeRegex, interpolate));
    const extraAttributes = commaOnlyList(_(attributesByName).omit(usedAttributes).values().flatten().value());

    if (linkType.orderableDirection > 0) {
        usedAttributes = [];
        cleanPhrase = clean(exports.clean(linkType.id, false).replace(attributeRegex, interpolate));
        cleanReversePhrase = clean(exports.clean(linkType.id, true).replace(attributeRegex, interpolate));
        cleanExtraAttributes = commaOnlyList(_(attributesByName).omit(usedAttributes).values().flatten().value());
    }

    return [
        phrase,
        reversePhrase,
        extraAttributes,
        cleanPhrase,
        cleanReversePhrase,
        cleanExtraAttributes,
    ];
};
