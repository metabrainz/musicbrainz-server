/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import commaList, {commaListText} from '../../common/i18n/commaList';
import commaOnlyList, {commaOnlyListText}
  from '../../common/i18n/commaOnlyList';
import {VarArgs, type VarArgsObject} from '../../common/i18n/expand2';
import expand2react from '../../common/i18n/expand2react';
import expand2text from '../../common/i18n/expand2text';
import localizeLinkAttributeTypeName
  from '../../common/i18n/localizeLinkAttributeTypeName';
import linkedEntities from '../../common/linkedEntities';
import clean from '../../common/utility/clean';
import displayLinkAttribute, {displayLinkAttributeText}
  from '../../common/utility/displayLinkAttribute';

const EMPTY_OBJECT = Object.freeze({});

const emptyResult = Object.freeze(['', '']);
const entity0Subst = /\{entity0\}/;
const entity1Subst = /\{entity1\}/;

export type CachedLinkPhraseData<T> = {
  attributeValues: ?{+[string]: Array<T> | T, ...},
  phraseAndExtraAttributes: {[string]: [T, T], ...},
};

export type RelationshipInfoT = {
  +attributes?: $ReadOnlyArray<LinkAttrT>,
  +linkTypeID: number,
  ...,
};

type LinkPhraseProp =
  | 'link_phrase'
  | 'long_link_phrase'
  | 'reverse_link_phrase'
  ;

function _getResultCache<T>(
  resultCache: WeakMap<RelationshipInfoT, CachedLinkPhraseData<T>>,
  relationship: RelationshipInfoT,
): CachedLinkPhraseData<T> {
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

type AttrValue<T> = Array<T | string> | T | string;

class PhraseVarArgs<T> extends VarArgs<AttrValue<T>> {
  +usedAttributes: Array<string>;

  +makeCommaList: ($ReadOnlyArray<T | string>) => T | string;

  constructor(
    args: ?VarArgsObject<AttrValue<T>>,
    makeCommaList: ($ReadOnlyArray<T | string>) => T | string,
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
}

export type LinkPhraseI18n<T> = {
  cache: WeakMap<RelationshipInfoT, CachedLinkPhraseData<T>>,
  commaList: ($ReadOnlyArray<T>) => T,
  commaOnlyList: ($ReadOnlyArray<T>) => T,
  expand: (string, PhraseVarArgs<T>) => T,
  displayLinkAttribute: (LinkAttrT) => T,
};

const reactI18n: LinkPhraseI18n<Expand2ReactOutput> = {
  cache: new WeakMap<
    RelationshipInfoT,
    CachedLinkPhraseData<Expand2ReactOutput>,
  >(),
  commaList,
  commaOnlyList,
  expand: expand2react,
  displayLinkAttribute,
};

const textI18n: LinkPhraseI18n<string> = {
  cache: new WeakMap<RelationshipInfoT, CachedLinkPhraseData<string>>(),
  commaList: commaListText,
  commaOnlyList: commaOnlyListText,
  expand: expand2text,
  displayLinkAttribute: displayLinkAttributeText,
};

function _setAttributeValues<T>(
  i18n: LinkPhraseI18n<T | string>,
  relationship: RelationshipInfoT,
  entity0: ?T,
  entity1: ?T,
  cache: CachedLinkPhraseData<T>,
) {
  const attributes = relationship.attributes;
  const values = entity0 && entity1 ? {entity0, entity1} : {};

  cache.attributeValues = values;

  if (!attributes) {
    return;
  }

  const linkType = linkedEntities.link_type[relationship.linkTypeID];

  for (let i = 0; i < attributes.length; i++) {
    const attribute = attributes[i];
    const value = i18n.displayLinkAttribute(attribute);

    if (value) {
      const type = linkedEntities.link_attribute_type[attribute.typeID];
      const info = linkType.attributes[type.root_id];
      const rootName = linkedEntities.link_attribute_type[type.root_id].name;

      /*
       * This may be a historical relationship which uses an attribute
       * that has since been removed from the link type, but where the
       * attribute still exists in the link_attribute_type table. In
       * that case we assume `max` is unbounded just to be safe. (The
       * only effect this has is passing the values to commaOnlyList
       * for display.)
       */
      if (info && info.max === 1) {
        values[rootName] = value;
      } else {
        (values[rootName] = values[rootName] || []).push(value);
      }
    }
  }
}

const requiredAttributesCache: {
  __proto__: null,
  [number]: {+[string]: string},
  ...,
} = Object.create(null);

function _getRequiredAttributes(linkType: LinkTypeT) {
  let required = requiredAttributesCache[linkType.id];
  if (required) {
    return required;
  }
  for (const [typeId, info] of Object.entries(linkType.attributes)) {
    const {min} = ((info: any): LinkTypeAttrTypeT);
    if (min) {
      const attribute = linkedEntities.link_attribute_type[(typeId: any)];
      required = required || {};
      required[attribute.name] = localizeLinkAttributeTypeName(attribute);
    }
  }
  return (requiredAttributesCache[linkType.id] = required || EMPTY_OBJECT);
}

export function getPhraseAndExtraAttributes<T>(
  i18n: LinkPhraseI18n<T | string>,
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
  entity0?: T,
  entity1?: T,
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

  let phraseSource = l_relationships(linkType[phraseProp]);
  if (!phraseSource) {
    return emptyResult;
  }

  if (!cache.attributeValues) {
    _setAttributeValues<T | string>(
      i18n,
      relationship,
      entity0,
      entity1,
      cache,
    );
  }

  const attributeValues = cache.attributeValues;

  /* flow-include if (!attributeValues) throw 'impossible'; */

  /*
    * When forGrouping is enabled:
    *
    * For ordered relationships (such as those in a series), build
    * a phrase with attributes removed, so that those relationships
    * can remain grouped together under the same phrase in our
    * relationships display, even if their attributes differ.
    *
    * Required attributes (where `min` is not null) are kept in the
    * phrase, however, since they wouldn't be written in a way that'd
    * make sense without them grammatically. Note, however, that there
    * are currently no orderable link types with any required
    * attributes.
    */
  const shouldStripAttributes =
    forGrouping &&
    linkType.orderable_direction > 0;

  if (phraseProp === 'long_link_phrase' && entity0 && entity1) {
    if (!entity0Subst.test(phraseSource)) {
      phraseSource = '{entity0} ' + phraseSource;
    }
    if (!entity1Subst.test(phraseSource)) {
      phraseSource += ' {entity1}';
    }
  }

  const varArgs = new PhraseVarArgs(
    shouldStripAttributes
      ? _getRequiredAttributes(linkType)
      : attributeValues,
    i18n.commaList,
  );

  let phrase = i18n.expand(phraseSource, varArgs);
  if (typeof phrase === 'string') {
    phrase = clean(phrase);
  }

  const extraAttributes: Array<T | string> = [];
  for (const key in attributeValues) {
    if (shouldStripAttributes ||
        !varArgs.usedAttributes.includes(key)) {
      const values = attributeValues[key];
      if (Array.isArray(values)) {
        extraAttributes.push(...values);
      } else {
        extraAttributes.push(values);
      }
    }
  }

  result = [
    phrase,
    i18n.commaOnlyList(extraAttributes),
  ];

  cache.phraseAndExtraAttributes[key] = result;
  return result;
}

export const getPhraseAndExtraAttributesText = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
) => getPhraseAndExtraAttributes<string, StrOrNum>(
  textI18n,
  relationship,
  phraseProp,
  forGrouping,
);

export const interpolate = (
  relationship: RelationshipInfoT,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
  entity0?: React$MixedElement,
  entity1?: React$MixedElement,
) => getPhraseAndExtraAttributes<Expand2ReactOutput, Expand2ReactInput>(
  reactI18n,
  relationship,
  phraseProp,
  forGrouping,
  entity0,
  entity1,
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
) => getPhraseAndExtraAttributes<Expand2ReactOutput, Expand2ReactInput>(
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
