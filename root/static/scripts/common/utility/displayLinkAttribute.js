/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {INSTRUMENT_ROOT_ID} from '../constants.js';
import commaList, {commaListText} from '../i18n/commaList.js';
import {type VarArgsObject} from '../i18n/expand2.js';
import localizeLinkAttributeTypeName
  from '../i18n/localizeLinkAttributeTypeName.js';
import linkedEntities from '../linkedEntities.mjs';
import clean from '../utility/clean.js';

function _displayLinkAttribute<T>(
  attribute: LinkAttrT,
  getAttributeValue: (LinkAttrTypeT) => T,
  l: (string, VarArgsObject<T | string>) => T,
): T {
  const type = linkedEntities.link_attribute_type[attribute.typeID];
  let value = getAttributeValue(type);

  if (type.free_text) {
    const textValue = clean(attribute.text_value);
    if (textValue) {
      value = l('{attribute}: {value}', {
        attribute: value,
        value: textValue,
      });
    }
  }

  if (type.creditable) {
    const credit = clean(attribute.credited_as);
    if (credit) {
      value = l('{attribute} [{credited_as}]', {
        attribute: value,
        credited_as: credit,
      });
    }
  }

  return value;
}

function getAttributeValueReact(type: LinkAttrTypeT) {
  const typeName = localizeLinkAttributeTypeName(type);
  return (
    type.root_id === INSTRUMENT_ROOT_ID
      ? <a href={'/instrument/' + type.gid}>{typeName}</a>
      : typeName
  );
}

export default function displayLinkAttribute(
  attribute: LinkAttrT,
): Expand2ReactOutput {
  return _displayLinkAttribute<Expand2ReactOutput>(
    attribute,
    getAttributeValueReact,
    exp.l,
  );
}

export function displayLinkAttributeText(attribute: LinkAttrT): string {
  return _displayLinkAttribute<string>(
    attribute,
    localizeLinkAttributeTypeName,
    texp.l,
  );
}

export function displayLinkAttributes(
  attributes: $ReadOnlyArray<LinkAttrT>,
): Expand2ReactOutput {
  return commaList(attributes.map(displayLinkAttribute));
}

export function displayLinkAttributesText(
  attributes: $ReadOnlyArray<LinkAttrT>,
): string {
  return commaListText(attributes.map(displayLinkAttributeText));
}
