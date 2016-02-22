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
    var typeInfo = MB.typeInfoByID[linkType];
    var idsByName = _.transform(typeInfo.attributes, mapNameToID);

    // remove {foo} {bar} junk, unless it's for a required attribute.
    var phrase = backward ? typeInfo.reversePhrase : typeInfo.phrase;

    return phrase.replace(attributeRegex, function (match, name, alt) {
        var id = idsByName[name];

        if (typeInfo.attributes[id].min < 1) {
            return (alt ? alt.split('|')[1] : '') || '';
        }

        return match;
    });
}, (a, b) => a + String(b));

exports.interpolate = function (linkType, attributes) {
    var typeInfo = MB.typeInfoByID[linkType];

    if (!typeInfo) {
        return ['', '', ''];
    }

    var phrase = typeInfo.phrase;
    var reversePhrase = typeInfo.reversePhrase;

    if (typeInfo.orderableDirection > 0) {
        phrase = exports.clean(typeInfo.id, false);
        reversePhrase = exports.clean(typeInfo.id, true);
    }

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

    return [
        clean(phrase.replace(attributeRegex, interpolate)),
        clean(reversePhrase.replace(attributeRegex, interpolate)),
        commaOnlyList(_(attributesByName).omit(usedAttributes).values().flatten().value())
    ];
};
