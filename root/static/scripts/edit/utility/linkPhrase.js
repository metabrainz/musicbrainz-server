/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import commaList, {commaListText} from '../../common/i18n/commaList';
import {
  VarArgs,
  type VarArgsObject,
  type VarArgsClass,
} from '../../common/i18n/expand2';
import {
  expand2reactWithVarArgsInstance,
} from '../../common/i18n/expand2react';
import {expand2textWithVarArgsClass} from '../../common/i18n/expand2text';
import linkedEntities from '../../common/linkedEntities';
import clean from '../../common/utility/clean';
import {compareStrings} from '../../common/utility/compare';
import displayLinkAttribute, {displayLinkAttributeText}
  from '../../common/utility/displayLinkAttribute';

const EMPTY_OBJECT = Object.freeze({});

const emptyResult = Object.freeze(['', []]);
const entity0Subst = /\{entity0\}/;
const entity1Subst = /\{entity1\}/;

type LinkAttrs = Array<LinkAttrT> | LinkAttrT;

type LinkAttrsByRootName = {
  [attributeName: string]: LinkAttrs,
};

export type LinkPhraseProp =
  | 'link_phrase'
  | 'long_link_phrase'
  | 'reverse_link_phrase';

class PhraseVarArgs<T>
  extends VarArgs<LinkAttrs, T | string>
  implements VarArgsClass<T | string> {
  +i18n: LinkPhraseI18n<T>;

  +entity0: T | string;

  +entity1: T | string;

  /*
   * Contains attributes that appear in the text of the given link
   * phrase. Later used for calculating "extra" attributes (which
   * didn't appear in the link phrase, so that we can display them
   * separately).
   */
   +usedPhraseAttributes: Array<string>;

   constructor(
     args: ?VarArgsObject<LinkAttrs>,
     i18n: LinkPhraseI18n<T>,
     entity0: ?T,
     entity1: ?T,
   ) {
     super(args || EMPTY_OBJECT);
     this.i18n = i18n;
     this.entity0 = entity0 || '';
     this.entity1 = entity1 || '';
     this.usedPhraseAttributes = [];
   }

   get(name: string): T | string {
     if (name === 'entity0') {
       return this.entity0;
     }
     if (name === 'entity1') {
       return this.entity1;
     }
     const attributes = this.data[name];
     if (attributes == null) {
       return '';
     }
     if (Array.isArray(attributes)) {
       return this.i18n.commaList(
         attributes.map(this.i18n.displayLinkAttribute),
       );
     }
     return this.i18n.displayLinkAttribute(attributes);
   }

   has(name: string): boolean {
     this.usedPhraseAttributes.push(name);
     return true;
   }
}

export type LinkPhraseI18n<T> = {
  commaList: ($ReadOnlyArray<T>) => T,
  displayLinkAttribute: (LinkAttrT) => T,
  expand: (string, VarArgsClass<T>) => T,
};

const reactI18n: LinkPhraseI18n<Expand2ReactOutput> = {
  commaList,
  displayLinkAttribute,
  expand: expand2reactWithVarArgsInstance,
};

const textI18n: LinkPhraseI18n<string> = {
  commaList: commaListText,
  displayLinkAttribute: displayLinkAttributeText,
  expand: expand2textWithVarArgsClass,
};

function _getAttributesByRootName<T>(
  i18n: LinkPhraseI18n<T | string>,
  linkType: LinkTypeT,
  attributes: $ReadOnlyArray<LinkAttrT>,
): LinkAttrsByRootName {
  const values: LinkAttrsByRootName = {};

  for (let i = 0; i < attributes.length; i++) {
    const attribute = attributes[i];
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
      values[rootName] = attribute;
    } else {
      const attributesList = values[rootName];
      if (attributesList /*:: && Array.isArray(attributesList) */) {
        attributesList.push(attribute);
      } else {
        values[rootName] = [attribute];
      }
    }
  }

  return values;
}

export function cmpLinkAttrs(a: LinkAttrT, b: LinkAttrT): number {
  const aType = linkedEntities.link_attribute_type[a.typeID];
  const bType = linkedEntities.link_attribute_type[b.typeID];
  const aRootType = linkedEntities.link_attribute_type[aType.root_id];
  const bRootType = linkedEntities.link_attribute_type[bType.root_id];

  return (
    (aRootType.child_order - bRootType.child_order) ||
    /*
     * Sorting by the types' child orders doesn't make sense without taking
     * into account the entire parent hierarchy, so we just sort by ID if
     * they have the same root child order to achieve a consistent sort.
     */
    (aType.id - bType.id) ||
    /*
     * Since we now know the ids are the same, we can assume
     * aRootType === bRootType below.
     */
    (aRootType.free_text ?
      compareStrings((a.text_value ?? ''), (b.text_value ?? '')) : 0) ||
    (aRootType.creditable ?
      compareStrings((a.credited_as ?? ''), (b.credited_as ?? '')) : 0)
  );
}

const requiredAttributesCache: {
  __proto__: null,
  [linkTypeId: number]: {+[attributeName: string]: LinkAttrT, ...},
  ...
} = Object.create(null);

function _getRequiredAttributes(
  linkType: LinkTypeT,
  attributesByRootName: ?LinkAttrsByRootName,
) {
  let required = requiredAttributesCache[linkType.id];
  if (required) {
    return required;
  }
  for (const typeId of Object.keys(linkType.attributes)) {
    const {min} = linkType.attributes[Number(typeId)];
    if (min) {
      const attribute = linkedEntities.link_attribute_type[Number(typeId)];
      required = required || {};
      required[attribute.name] = attributesByRootName ? (
        attributesByRootName[attribute.name]
      ) : {
        type: attribute,
        typeID: attribute.id,
        typeName: attribute.name,
      };
    }
  }
  return (requiredAttributesCache[linkType.id] = required || EMPTY_OBJECT);
}

export function getPhraseAndExtraAttributes<T>(
  i18n: LinkPhraseI18n<T | string>,
  linkType: LinkTypeT,
  attributes: $ReadOnlyArray<LinkAttrT>,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
  entity0?: T,
  entity1?: T,
): [T | string, Array<LinkAttrT>] {
  let phraseSource = l_relationships(linkType[phraseProp]);
  if (!phraseSource) {
    return emptyResult;
  }

  const attributesByRootName = _getAttributesByRootName<T | string>(
    i18n,
    linkType,
    attributes,
  );

  /* flow-include if (!attributesByRootName) throw 'impossible'; */

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

  const requiredAttributes = _getRequiredAttributes(
    linkType,
    attributesByRootName,
  );

  const varArgs = new PhraseVarArgs(
    shouldStripAttributes
      ? requiredAttributes
      : attributesByRootName,
    i18n,
    entity0,
    entity1,
  );

  let phrase = i18n.expand(phraseSource, varArgs);
  if (typeof phrase === 'string') {
    phrase = clean(phrase);
  }

  const extraAttributes: Array<LinkAttrT> = [];

  for (const key in attributesByRootName) {
    if (
      (shouldStripAttributes && requiredAttributes[key] == null) ||
      !varArgs.usedPhraseAttributes.includes(key)
    ) {
      const attributes = attributesByRootName[key];
      if (Array.isArray(attributes)) {
        extraAttributes.push(...attributes);
      } else {
        extraAttributes.push(attributes);
      }
    }
  }

  extraAttributes.sort(cmpLinkAttrs);
  return [phrase, extraAttributes];
}

export const getPhraseAndExtraAttributesText = (
  linkType: LinkTypeT,
  attributes: $ReadOnlyArray<LinkAttrT>,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
): [string, Array<LinkAttrT>] => getPhraseAndExtraAttributes<
  string,
  StrOrNum,
>(
  textI18n,
  linkType,
  attributes,
  phraseProp,
  forGrouping,
);

export const interpolate = (
  linkType: LinkTypeT,
  attributes: $ReadOnlyArray<LinkAttrT>,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
  entity0?: React$MixedElement,
  entity1?: React$MixedElement,
): Expand2ReactOutput | string => getPhraseAndExtraAttributes<
  Expand2ReactOutput,
  Expand2ReactInput,
>(
  reactI18n,
  linkType,
  attributes,
  phraseProp,
  forGrouping,
  entity0,
  entity1,
)[0];

export const interpolateText = (
  linkType: LinkTypeT,
  attributes: $ReadOnlyArray<LinkAttrT>,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
): string => getPhraseAndExtraAttributesText(
  linkType,
  attributes,
  phraseProp,
  forGrouping,
)[0];

export const getExtraAttributes = (
  linkType: LinkTypeT,
  attributes: $ReadOnlyArray<LinkAttrT>,
  phraseProp: LinkPhraseProp,
  forGrouping?: boolean = false,
): Array<LinkAttrT> => getPhraseAndExtraAttributes<
  Expand2ReactOutput,
  Expand2ReactInput,
>(
  reactI18n,
  linkType,
  attributes,
  phraseProp,
  forGrouping,
)[1];

export const stripAttributes = (
  linkType: LinkTypeT,
  phrase: string,
): string => {
  return clean(textI18n.expand(phrase, new PhraseVarArgs(
    _getRequiredAttributes(linkType, null),
    textI18n,
    null,
    null,
  )));
};
