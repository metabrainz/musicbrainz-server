/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {isTabbable, tabbable} from 'tabbable';
import * as tree from 'weight-balanced-tree';

import {expect} from '../../../../utility/invariant.js';
import {
  EMPTY_PARTIAL_DATE,
  ENTITIES_WITH_RELATIONSHIP_CREDITS,
  VIDEO_ATTRIBUTE_GID,
} from '../../common/constants.js';
import MB from '../../common/MB.js';
import isObjectEmpty from '../../common/utility/isObjectEmpty.js';
import {
  hasSessionStorage,
  sessionStorageWrapper,
} from '../../common/utility/storage.js';
import withLoadedTypeInfo from '../../edit/components/withLoadedTypeInfo.js';
import {
  compactEntityJson,
} from '../../edit/utility/compactEntityJson.js';
import {
  appendHiddenRelationshipInputs,
} from '../../relationship-editor/utility/prepareHtmlFormSubmission.js';
import {getSubmittedLinksKey} from '../state.js';
import type {
  LinksEditorActionT,
  LinksEditorStateT,
  LinkStateT,
} from '../types.js';
import getLinkRelationshipStatus
  from '../utility/getLinkRelationshipStatus.js';
import {
  hasErrorsOnNewOrChangedLink,
} from '../validation.js';

import ExternalLink from './ExternalLink.js';

function getFormData(
  sourceType: RelatableEntityTypeT,
  links: tree.ImmutableTree<LinkStateT>,
  startingPrefix: string,
  startingIndex: number,
  pushInput: (string, string, string) => void,
) {
  let index = 0;
  const backward = sourceType > 'url';

  for (const link of tree.iterate(links)) {
    if (empty(link.url) || hasErrorsOnNewOrChangedLink(link)) {
      continue;
    }
    for (const relationship of link.relationships) {
      const status = getLinkRelationshipStatus(relationship);
      if (
        !status.isNew &&
        !status.removed &&
        isObjectEmpty(status.changes)
      ) {
        continue;
      }
      const prefix = startingPrefix + '.' + (startingIndex + (index++));

      if (!status.isNew) {
        pushInput(prefix, 'relationship_id', String(relationship.id));

        if (status.removed) {
          pushInput(prefix, 'removed', '1');
        }
      }

      pushInput(prefix, 'text', link.url);

      if (relationship.video) {
        pushInput(prefix + '.attributes.0', 'type.gid', VIDEO_ATTRIBUTE_GID);
      } else if (status.changes.video) {
        // The video flag has changed and is unset, so it's being removed.
        pushInput(prefix + '.attributes.0', 'type.gid', VIDEO_ATTRIBUTE_GID);
        pushInput(prefix + '.attributes.0', 'removed', '1');
      }

      if (backward) {
        pushInput(prefix, 'backward', '1');
      }

      pushInput(
        prefix,
        'link_type_id',
        String(relationship.linkTypeID ?? ''),
      );

      if (ENTITIES_WITH_RELATIONSHIP_CREDITS[sourceType]) {
        const creditableEntityProp = backward
          ? 'entity1_credit'
          : 'entity0_credit';
        pushInput(
          prefix,
          creditableEntityProp,
          relationship.entityCredit,
        );
      }

      const beginDate = relationship.beginDate ?? EMPTY_PARTIAL_DATE;
      const endDate = relationship.endDate ?? EMPTY_PARTIAL_DATE;

      pushInput(
        prefix,
        'period.begin_date.year',
        String(beginDate.year ?? ''),
      );
      pushInput(
        prefix,
        'period.begin_date.month',
        String(beginDate.month ?? ''),
      );
      pushInput(
        prefix,
        'period.begin_date.day',
        String(beginDate.day ?? ''),
      );
      pushInput(
        prefix,
        'period.end_date.year',
        String(endDate.year ?? ''),
      );
      pushInput(
        prefix,
        'period.end_date.month',
        String(endDate.month ?? ''),
      );
      pushInput(
        prefix,
        'period.end_date.day',
        String(endDate.day ?? ''),
      );
      pushInput(prefix, 'period.ended', relationship.ended ? '1' : '0');
    }
  }
}

function prepareExternalLinksHtmlFormSubmission(
  state: LinksEditorStateT,
): void {
  /*
   * This function is currently only expected to run once, so the hidden
   * inputs container shouldn't exist here, though that could conceivably
   * change. Removing the check only introduces a hidden dependency.
   */
  let hiddenInputsContainer = document.getElementById(
    'external-links-editor-submission',
  );
  if (!hiddenInputsContainer) {
    hiddenInputsContainer = document.createElement('div');
    hiddenInputsContainer.setAttribute(
      'id',
      'external-links-editor-submission',
    );
    document.querySelector('#page form')?.appendChild(
      hiddenInputsContainer,
    );
  }
  appendHiddenRelationshipInputs(
    'external-links-editor-submission',
    function (pushInput) {
      const source = state.source;
      const sourceType = source.entityType;
      getFormData(
        sourceType,
        state.links,
        'edit-' + sourceType.replace('_', '-') + '.url',
        0,
        pushInput,
      );
      if (state.links.size && hasSessionStorage) {
        sessionStorageWrapper.set(
          getSubmittedLinksKey(source),
          JSON.stringify(compactEntityJson(state.links)),
        );
      }
    },
  );
}

component _ExternalLinksEditor(
  /*:: ref: React.RefSetter<void>, */
  dispatch: (LinksEditorActionT) => void,
  state: LinksEditorStateT,
) {
  const {focus, links, source} = state;

  const tableRef = React.useRef<HTMLTableElement | null>(null);

  React.useEffect(() => {
    const table = expect(tableRef.current);
    let selector: string = focus;
    if (!selector) {
      return;
    }
    let elementToFocus: ?HTMLElement;
    if (selector === 'empty') {
      const emptyLink = tree.maxValue(links);
      selector = `#external-link-${emptyLink.key} input.value`;
    }
    /*
     * If you set 'focus' to a container element (or any non-tabbable
     * element), then we look for the first tabbable element in its children.
     * Generally this is only used to move focus to another link section
     * below or above the current one, in which case we prefer not to focus
     * links or "remove" buttons.
     */
    // $FlowExpectedError[incompatible-type]
    elementToFocus = table.querySelector(selector) as HTMLElement;
    if (elementToFocus && !isTabbable(elementToFocus)) {
      elementToFocus = tabbable(elementToFocus).find(node => (
        node.nodeName !== 'A' &&
        !node.matches('button.remove-item')
      ));
    }
    if (elementToFocus) {
      elementToFocus.focus();
    }
    dispatch({focus: '', type: 'set-focus'});
  }, [dispatch, focus, links]);

  React.useEffect(() => {
    const releaseEditor = MB._releaseEditor;
    if (releaseEditor) {
      /*
       * `externalLinksData` is an observable hooked into the release
       * editor's edit generation code.
       */
      // $FlowExpectedError[prop-missing]
      releaseEditor.externalLinksData(links);
    }
  }, [links]);

  const submissionInProgress = React.useRef(false);

  React.useEffect(() => {
    const handleSubmission = () => {
      if (!submissionInProgress.current) {
        submissionInProgress.current = true;
        prepareExternalLinksHtmlFormSubmission(state);
      }
    };
    document.addEventListener('submit', handleSubmission);
    return () => {
      document.removeEventListener('submit', handleSubmission);
    };
  }, [state]);

  const linkElements = [];
  let linkIndex = 0;

  for (const link of tree.iterate(links)) {
    linkElements.push(
      <ExternalLink
        dispatch={dispatch}
        isLastLink={(++linkIndex) === links.size}
        isOnlyLink={links.size === 1}
        key={link.key}
        link={link}
        source={source}
      />,
    );
  }

  return (
    <table
      className="row-form"
      id="external-links-editor"
      ref={tableRef}
    >
      <tbody>
        {linkElements}
      </tbody>
    </table>
  );
}

const ExternalLinksEditor:
  component(
    ref: React.RefSetter<void>,
    ...React.PropsOf<_ExternalLinksEditor>
  ) =
    withLoadedTypeInfo<React.PropsOf<_ExternalLinksEditor>, void>(
      _ExternalLinksEditor,
      new Set(['link_type', 'link_attribute_type']),
    );

export default ExternalLinksEditor;
