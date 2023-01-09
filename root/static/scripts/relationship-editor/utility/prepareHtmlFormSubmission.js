/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';

import {compactEntityJson} from '../../../../utility/compactEntityJson.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {hasSessionStorage} from '../../common/utility/storage.js';
import {
  REL_STATUS_NOOP,
  REL_STATUS_REMOVE,
} from '../constants.js';
import type {
  RelationshipEditorStateT,
  RelationshipStateT,
} from '../types.js';
import {
  compareLinkAttributeIds,
} from '../utility/compareRelationships.js';
import {
  findTargetTypeGroups,
  iterateRelationshipsInTargetTypeGroups,
} from '../utility/findState.js';
import isRelationshipBackward from '../utility/isRelationshipBackward.js';

function pushRelationshipHiddenInputs(
  formName: string,
  source: CoreEntityT,
  relationship: RelationshipStateT,
  index: number,
  pushInput: (string, string, string) => void,
): void {
  const relPrefix = formName + '.rel.' + index;

  if (isDatabaseRowId(relationship.id)) {
    pushInput(relPrefix, 'relationship_id', '' + relationship.id);
  }

  if (relationship._status === REL_STATUS_REMOVE) {
    pushInput(relPrefix, 'removed', '1');
  }

  const backward = isRelationshipBackward(relationship, source);
  const target = backward ? relationship.entity0 : relationship.entity1;

  if (target.gid) {
    pushInput(relPrefix, 'target', target.gid);
  }

  const pushAttributeInputs = (
    index: number,
    attribute: LinkAttrT,
    removed?: boolean = false,
  ) => {
    const attrPrefix = relPrefix + '.attributes.' + index;

    pushInput(attrPrefix, 'type.gid', attribute.type.gid);

    if (removed) {
      pushInput(attrPrefix, 'removed', '1');
    } else {
      if (attribute.credited_as != null) {
        pushInput(attrPrefix, 'credited_as', attribute.credited_as);
      }
      if (attribute.text_value != null) {
        pushInput(attrPrefix, 'text_value', attribute.text_value);
      }
    }
  };

  const newAttributes = relationship.attributes;
  let attributeIndex = 0;
  for (const attribute of tree.iterate(newAttributes)) {
    pushAttributeInputs(attributeIndex, attribute);
    attributeIndex++;
  }

  const origRelationship = relationship._original;
  if (origRelationship) {
    const origAttributes = origRelationship.attributes;

    for (const attribute of tree.iterate(origAttributes)) {
      const newAttribute = tree.find(
        newAttributes,
        attribute,
        compareLinkAttributeIds,
      );
      if (!newAttribute) {
        pushAttributeInputs(attributeIndex++, attribute, true /* removed */);
      }
      attributeIndex++;
    }
  }

  pushInput(relPrefix, 'entity0_credit', relationship.entity0_credit);
  pushInput(relPrefix, 'entity1_credit', relationship.entity1_credit);

  const beginDate = relationship.begin_date;
  const endDate = relationship.end_date;

  pushInput(
    relPrefix,
    'period.begin_date.year',
    '' + (beginDate?.year ?? ''),
  );
  pushInput(
    relPrefix,
    'period.begin_date.month',
    '' + (beginDate?.month ?? ''),
  );
  pushInput(relPrefix, 'period.begin_date.day', '' + (beginDate?.day ?? ''));
  pushInput(relPrefix, 'period.end_date.year', '' + (endDate?.year ?? ''));
  pushInput(relPrefix, 'period.end_date.month', '' + (endDate?.month ?? ''));
  pushInput(relPrefix, 'period.end_date.day', '' + (endDate?.day ?? ''));
  pushInput(relPrefix, 'period.ended', relationship.ended ? '1' : '0');
  pushInput(relPrefix, 'backward', backward ? '1' : '0');

  const linkTypeId = relationship.linkTypeID;
  if (linkTypeId != null) {
    pushInput(relPrefix, 'link_type_id', '' + linkTypeId);

    const linkType = linkedEntities.link_type[linkTypeId];
    if (linkType.orderable_direction !== 0) {
      pushInput(relPrefix, 'link_order', '' + relationship.linkOrder);
    }
  }
}

export function appendHiddenRelationshipInputs(
  hiddenInputsContainerId: string,
  callback: ((string, string, string) => void) => void,
): number {
  const hiddenInputs = document.createDocumentFragment();
  let fieldCount = 0;

  const pushInput = (
    prefix: string,
    name: string,
    value: string,
  ): void => {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = prefix + '.' + name;
    input.value = value;
    hiddenInputs.appendChild(input);
    ++fieldCount;
  };

  callback(pushInput);

  const page = document.getElementById('page');
  invariant(page);

  const submitButton: HTMLButtonElement | null =
    // $FlowIgnore[incompatible-type]
    page.querySelector('button[type=submit');
  if (submitButton) {
    submitButton.disabled = true;
  }

  const hiddenInputsContainer =
    document.getElementById(hiddenInputsContainerId);
  invariant(hiddenInputsContainer);

  const existingHiddenInputs =
    hiddenInputsContainer.querySelectorAll('input[type=hidden]');

  for (const input of existingHiddenInputs) {
    hiddenInputsContainer.removeChild(input);
  }

  hiddenInputsContainer.appendChild(hiddenInputs);
  return fieldCount;
}

export default function prepareHtmlFormSubmission(
  formName: string,
  state: RelationshipEditorStateT,
): void {
  appendHiddenRelationshipInputs(
    'relationship-editor',
    function (pushInput) {
      const targetTypeGroups = findTargetTypeGroups(
        state.relationshipsBySource,
        state.entity,
      );

      let relIndex = 0;
      for (
        const relationship of
        iterateRelationshipsInTargetTypeGroups(targetTypeGroups)
      ) {
        if (relationship._status === REL_STATUS_NOOP) {
          continue;
        }
        pushRelationshipHiddenInputs(
          formName,
          state.entity,
          relationship,
          relIndex++,
          pushInput,
        );
      }

      if (hasSessionStorage) {
        window.sessionStorage.setItem(
          'relationshipEditorState',
          JSON.stringify(compactEntityJson(state)),
        );
      }
    },
  );
}
