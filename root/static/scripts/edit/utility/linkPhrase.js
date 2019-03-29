/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {INSTRUMENT_ROOT_ID} from '../../common/constants';
import commaList, {commaListText} from '../../common/i18n/commaList';
import commaOnlyList, {commaOnlyListText} from '../../common/i18n/commaOnlyList';
import {VarArgs, type VarArgsObject} from '../../common/i18n/expand2';
import expand2react from '../../common/i18n/expand2react';
import expand2text from '../../common/i18n/expand2text';
import linkedEntities from '../../common/linkedEntities';
import clean from '../../common/utility/clean';

const EMPTY_OBJECT = Object.freeze({});

const emptyResult = Object.freeze(['', '']);

type CachedResult<T> = {|
  attributeValues: ?{+[string]: Array<T>},
  phraseAndExtraAttributes: {[string]: [T, T]},
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

function _getResultCache<T>(
  resultCache: WeakMap<RelationshipInfoT, CachedResult<T>>,
  relationship: RelationshipInfoT,
): CachedResult<T> {
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

function getAttributeLName(type: AttrInfoT | LinkAttrTypeT) {
  if (type.root_id === INSTRUMENT_ROOT_ID) {
    if (type.instrument_comment) {
      return lp_instruments(type.name, type.instrument_comment);
    }
    return l_instruments(type.name);
  }
  return l_relationships(type.name);
}

type AttrValue<T> = Array<T | string> | T | string;

class PhraseVarArgs<T> extends VarArgs<AttrValue<T>> {
  +usedAttributes: Array<string>;

  +makeCommaList: (Array<T | string>) => T | string;

  constructor(
    args: ?VarArgsObject<AttrValue<T>>,
    makeCommaList: (Array<T | string>) => T | string,
  ) {
    super(args || EMPTY_OBJECT);
    this.usedAttributes = [];
    this.makeCommaList = makeCommaList;
  }

  get(name): T | string {
    const value = super.get(name);
    if (value == null) {
      return '';
    }
    if (Array.isArray(value)) {
      return this.makeCommaList(value);
    }
    return value;
  }

  has(name) {
    this.usedAttributes.push(name);
    return true;
  }

  getExtraAttributes(): Array<T | string> {
    const extraAttributes = [];
    for (const key in this.data) {
      if (!this.usedAttributes.includes(key)) {
        const values = this.data[key];
        if (Array.isArray(values)) {
          extraAttributes.push(...values);
        } else {
          extraAttributes.push(values);
        }
      }
    }
    return extraAttributes;
  }
}

type I18n<T, V> = {
  cache: WeakMap<RelationshipInfoT, CachedResult<T>>,
  commaList: (Array<T>) => T,
  commaOnlyList: (Array<T>) => T,
  expand: (string, PhraseVarArgs<T>) => T,
  getAttributeValue: (AttrInfoT | LinkAttrTypeT, string) => T,
  l: (string, VarArgsObject<T | V>) => T,
};

const reactI18n: I18n<Expand2ReactOutput, Expand2ReactInput> = {
  cache: new WeakMap<RelationshipInfoT, CachedResult<Expand2ReactOutput>>(),
  commaList,
  commaOnlyList,
  expand: expand2react,
  getAttributeValue: (type, typeName) => (
    type.root_id === INSTRUMENT_ROOT_ID
      ? <a href={'/instrument/' + type.gid}>{typeName}</a>
      : typeName
  ),
  l: exp.l,
};

const textI18n: I18n<string, StrOrNum> = {
  cache: new WeakMap<RelationshipInfoT, CachedResult<string>>(),
  commaList: commaListText,
  commaOnlyList: commaOnlyListText,
  expand: expand2text,
  getAttributeValue: (type, typeName) => typeName,
  l: texp.l,
};

function _setAttributeValues<T, V>(
  i18n: I18n<T | string, V | string>,
  relationship: RelationshipInfoT,
  cache: CachedResult<T>,
) {
  const attributes = relationship.attributes;
  if (!attributes) {
    cache.attributeValues = EMPTY_OBJECT;
    return;
  }

  let values;
  const linkType = linkedEntities.link_type[relationship.linkTypeID];

  for (let i = 0; i < attributes.length; i++) {
    const attribute = attributes[i];
    const type = linkedEntities.link_attribute_type[attribute.type.gid];
    const typeName = getAttributeLName(type);
    let value = i18n.getAttributeValue(type, typeName);

    if (type.free_text) {
      const textValue = clean(attribute.text_value);
      if (textValue) {
        value = i18n.l('{attribute}: {value}', {
          attribute: value,
          value: textValue,
        });
      }
    }

    if (type.creditable) {
      const credit = clean(attribute.credited_as);
      if (credit) {
        value = i18n.l('{attribute} [{credited_as}]', {
          attribute: value,
          credited_as: credit,
        });
      }
    }

    if (value) {
      if (!values) {
        values = {};
      }

      const info = linkType.attributes[type.root_id];
      const rootName = linkedEntities.link_attribute_type[type.root_gid].name;

      if (info.max === 1) {
        values[rootName] = value;
      } else {
        (values[rootName] = values[rootName] || []).push(value);
      }
    }
  }

  cache.attributeValues = values || EMPTY_OBJECT;
}

const requiredAttributesCache: {
  __proto__: null,
  [number]: {+[string]: string},
} = Object.create(null);

function _getRequiredAttributes(linkType: LinkTypeT) {
  let required = requiredAttributesCache[linkType.id];
  if (required) {
    return required;
  }
  for (const [, info] of Object.entries(linkType.attributes)) {
    const {attribute, min} = ((info: any): LinkTypeAttrTypeT);
    if (min) {
      required = required || {};
      required[attribute.name] = `{${getAttributeLName(attribute)}}`;
    }
  }
  return (requiredAttributesCache[linkType.id] = required || EMPTY_OBJECT);
}

function _getPhraseAndExtraAttributes<T, V>(
  i18n: I18n<T | string, V | string>,
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
): [T | string, T | string] {
  const cache = _getResultCache<T | string>(i18n.cache, relationship);
  const key = phraseProp + '\0' + (forGrouping ? '1' : '0');

  let result = cache.phraseAndExtraAttributes[key];
  if (result) {
    return result;
  }

  const linkType = linkedEntities.link_type[relationship.linkTypeID];
  if (!linkType) {
    return emptyResult;
  }

  const phraseSource = l_relationships(linkType[phraseProp]);
  if (!phraseSource) {
    return emptyResult;
  }

  if (!forGrouping && !cache.attributeValues) {
    _setAttributeValues<T | string, V>(i18n, relationship, cache);
  }

  /* flow-include if (!cache.attributeValues) throw 'impossible'; */

  const varArgs = new PhraseVarArgs(
    forGrouping ? _getRequiredAttributes(linkType) : cache.attributeValues,
    i18n.commaList,
  );

  let phrase = i18n.expand(phraseSource, varArgs);
  if (typeof phrase === 'string') {
    phrase = clean(phrase);
  }

  result = [
    phrase,
    i18n.commaOnlyList(varArgs.getExtraAttributes()),
  ];

  cache.phraseAndExtraAttributes[key] = result;
  return result;
}

export const getPhraseAndExtraAttributesText = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => _getPhraseAndExtraAttributes<string, StrOrNum>(
  textI18n,
  relationship,
  phraseProp,
  forGrouping,
);

export const interpolate = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => _getPhraseAndExtraAttributes<Expand2ReactOutput, Expand2ReactInput>(
  reactI18n,
  relationship,
  phraseProp,
  forGrouping,
)[0];

export const interpolateText = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => getPhraseAndExtraAttributesText(
  relationship,
  phraseProp,
  forGrouping,
)[0];

export const getExtraAttributes = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => _getPhraseAndExtraAttributes<Expand2ReactOutput, Expand2ReactInput>(
  reactI18n,
  relationship,
  phraseProp,
  forGrouping,
)[1];

export const getExtraAttributesText = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => getPhraseAndExtraAttributesText(
  relationship,
  phraseProp,
  forGrouping,
)[1];

export const stripAttributes = (linkType: LinkTypeT, phrase: string) => {
  return clean(textI18n.expand(phrase, new PhraseVarArgs(
    _getRequiredAttributes(linkType),
    textI18n.commaList,
  )));
};
