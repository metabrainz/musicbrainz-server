/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2019 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {INSTRUMENT_ROOT_ID} from '../constants';
import {type VarArgsObject} from '../i18n/expand2';
import localizeLinkAttributeTypeName
  from '../i18n/localizeLinkAttributeTypeName';
import linkedEntities from '../linkedEntities';

import clean from './clean';

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

export default function displayLinkAttribute(attribute: LinkAttrT) {
  return _displayLinkAttribute<Expand2ReactOutput>(
    attribute,
    getAttributeValueReact,
    exp.l,
  );
}

export function displayLinkAttributeText(attribute: LinkAttrT) {
  return _displayLinkAttribute<string>(
    attribute,
    localizeLinkAttributeTypeName,
    texp.l,
  );
}
