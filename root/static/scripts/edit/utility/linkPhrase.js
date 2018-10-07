/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import _ from 'lodash';

import commaList from '../../common/i18n/commaList';
import commaOnlyList from '../../common/i18n/commaOnlyList';
import typeInfo from '../../common/typeInfo';
import clean from '../../common/utility/clean';

const attributeRegex = /\{(.*?)(?::(.*?))?\}/g;

function mapNameToID(result, info, id) {
  result[info.attribute.name] = id;
}

export const stripAttributes = _.memoize<[LinkTypeT, string], string>(function (
  linkType: LinkTypeT,
  phrase: string,
) {
  const idsByName = _.transform(linkType.attributes, mapNameToID);

  // remove {foo} {bar} junk, unless it's for a required attribute.
  return clean(phrase.replace(attributeRegex, function (match, name, alt) {
    const id = idsByName[name];
    const attr = id && linkType.attributes ? linkType.attributes[id] : null;

    if (attr && !attr.min) {
      return (alt ? alt.split('|')[1] : '') || '';
    }

    return match;
  }));
}, (a, b) => String(a.id) + b);

const EMPTY_OBJECT = Object.freeze({});

const emptyResult = Object.freeze(['', '']);

type CachedResult = {|
  attributeValues: ?{+[string]: Array<string>},
  phraseAndExtraAttributes: {[string]: [string, string]},
|};

type RelationshipInfoT = {
  +attributes?: $ReadOnlyArray<LinkAttrT>,
  +linkTypeID: number,
};

type LinkPhraseProp =
  | 'link_phrase'
  | 'long_link_phrase'
  | 'reverse_link_phrase'
  ;

const resultCache = new WeakMap<RelationshipInfoT, CachedResult>();

function _getResultCache(relationship: RelationshipInfoT) {
  let result = resultCache.get(relationship);
  if (!result) {
    result = {
      attributeValues: null,
      phraseAndExtraAttributes: {},
    };
    resultCache.set(relationship, result);
  }
  return result;
}

function _setAttributeValues(
  relationship: RelationshipInfoT,
  cache: CachedResult,
) {
  const attributes = relationship.attributes;
  if (!attributes) {
    cache.attributeValues = EMPTY_OBJECT;
    return;
  }

  let values;

  for (let i = 0; i < attributes.length; i++) {
    const attribute = attributes[i];
    const type = typeInfo.link_attribute_type[attribute.type.gid];
    let value = type.l_name;

    if (type.freeText) {
      value = clean(attribute.text_value);
      if (value) {
        value = texp.l('{attribute}: {value}', {attribute: type.l_name, value: value});
      }
    }

    if (type.creditable) {
      const credit = clean(attribute.credited_as);
      if (credit) {
        value = texp.l('{attribute} [{credited_as}]', {attribute: type.l_name, credited_as: credit});
      }
    }

    if (value) {
      const rootName = type.root.name;
      if (!values) {
        values = {};
      }
      (values[rootName] = values[rootName] || []).push(values);
    }
  }

  cache.attributeValues = values || EMPTY_OBJECT;
}

export function getPhraseAndExtraAttributes(
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
): [string, string] {
  const linkType = typeInfo.link_type.byId[relationship.linkTypeID];
  if (!linkType) {
    return emptyResult;
  }

  const cache = _getResultCache(relationship);
  const key = phraseProp + '\0' + (forGrouping ? '1' : '0');

  let result = cache.phraseAndExtraAttributes[key];
  if (result) {
    return result;
  }

  const phraseSource = l_relationships(linkType[phraseProp]);
  if (!phraseSource) {
    return emptyResult;
  }

  if (!cache.attributeValues) {
    _setAttributeValues(relationship, cache);
  }

  const {attributeValues} = cache;
  /* flow-include if (!attributeValues) throw 'impossible'; */
  const usedAttributes = Object.create(null);

  const _interpolate = function (match, name, alts) {
    usedAttributes[name] = true;

    const values = attributeValues[name] || [];
    let replacement = commaList(values);

    if (alts) {
      alts = alts.split('|');
      replacement = values.length ? alts[0].replace(/%/g, replacement) : alts[1] || '';
    }

    return replacement;
  };

  const phrase = clean(
    (forGrouping ? stripAttributes(linkType, phraseSource) : phraseSource)
      .replace(attributeRegex, _interpolate),
  );

  const extraAttributes: Array<string> = [];
  for (const key in attributeValues) {
    if (!usedAttributes[key]) {
      const values = attributeValues[key];
      extraAttributes.push(...values);
    }
  }

  result = [phrase, commaOnlyList(extraAttributes)];
  cache.phraseAndExtraAttributes[key] = result;
  return result;
}

export const interpolate = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => getPhraseAndExtraAttributes(relationship, phraseProp, forGrouping)[0];

export const getExtraAttributes = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => getPhraseAndExtraAttributes(relationship, phraseProp, forGrouping)[1];
