/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  ENTITIES_WITH_RELATIONSHIP_CREDITS,
  VIDEO_ATTRIBUTE_ID,
} from '../../common/constants.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import {bracketedText} from '../../common/utility/bracketed.js';
import formatDatePeriod from '../../common/utility/formatDatePeriod.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {isDateNonEmpty} from '../../common/utility/isDateEmpty.js';
import isObjectEmpty from '../../common/utility/isObjectEmpty.js';
import RelationshipPendingEditsWarning
  from '../../edit/components/RelationshipPendingEditsWarning.js';
import RemoveButton from '../../edit/components/RemoveButton.js';
import {linkTypeOptions} from '../../edit/forms.js';
import {
  RESTRICTED_LINK_TYPES,
} from '../../edit/URLCleanup.js';
import {HIGHLIGHTS} from '../constants.js';
import type {
  LinkRelationshipStateT,
  LinksEditorActionT,
  LinkStateT,
  LinkTypeOptionT,
} from '../types.js';
import canMergeLink from '../utility/canMergeLink.js';
import doesUrlMatchType from '../utility/doesUrlMatchType.js';
import getLinkChecker from '../utility/getLinkChecker.js';
import getLinkPhrase from '../utility/getLinkPhrase.js';
import shouldShowTypeSelection from '../utility/shouldShowTypeSelection.js';
import {getLinkRelationshipStatus} from '../validation.js';

import ExternalLinkAttributeDialog from './ExternalLinkAttributeDialog.js';
import LinkTypeSelect from './LinkTypeSelect.js';
import TypeDescription from './TypeDescription.js';

type ExternalLinkRelationshipPropsT = {
  +dispatch: (LinksEditorActionT) => void,
  +link: LinkStateT,
  +relationship: LinkRelationshipStateT,
  +source: RelatableEntityT,
};

type LinksEditorTypeOptionsT = {
  +generalTypeOptions: $ReadOnlyArray<LinkTypeOptionT>,
  +typeOptions: $ReadOnlyArray<LinkTypeOptionT>,
};

const typeOptionsCache: Map<string, LinksEditorTypeOptionsT> = new Map();

export function getLinkTypeOptions(
  sourceType: RelatableEntityTypeT,
): LinksEditorTypeOptionsT {
  let result = typeOptionsCache.get(sourceType);
  if (result) {
    return result;
  }
  const entityTypes = [sourceType, 'url'].sort().join('-');
  const typeOptions = linkTypeOptions(
    {children: linkedEntities.link_type_tree[entityTypes]},
    /^url-/.test(entityTypes),
  );
  const generalTypeOptions = typeOptions.filter(
    // Keep disabled options for grouping
    (option) => option.disabled ||
    !RESTRICTED_LINK_TYPES.includes(option.data.gid),
  );
  result = {
    generalTypeOptions,
    typeOptions,
  };
  typeOptionsCache.set(sourceType, result);
  return result;
}

component _ExternalLinkRelationship(
  ...props: ExternalLinkRelationshipPropsT
) {
  const {
    dispatch,
    link,
    relationship,
    source,
  } = props;

  const {
    error: linkError,
    originalUrlEntity,
    url,
  } = link;

  const {
    editsPending,
    error: relationshipError,
    entityCredit,
    id: relationshipId,
    linkTypeID,
    beginDate,
    endDate,
    ended,
  } = relationship;

  const status = getLinkRelationshipStatus(relationship);
  const highlight = (status.isNew && isDatabaseRowId(source.id))
    ? HIGHLIGHTS.ADD
    : (
      isObjectEmpty(status.changes)
        ? (status.removed ? HIGHLIGHTS.REMOVE : HIGHLIGHTS.NONE)
        : HIGHLIGHTS.EDIT
    );

  const linkType = status.linkType;
  const hasDate = isDateNonEmpty(beginDate) ||
                  isDateNonEmpty(endDate) ||
                  ended;

  const handleVideoChange = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      link,
      relationship,
      type: 'set-video',
      video: event.currentTarget.checked,
    });
  }, [dispatch, link, relationship]);

  const handleRemove = React.useCallback(() => {
    dispatch({
      link,
      relationship,
      type: 'toggle-remove-relationship',
    });
  }, [dispatch, link, relationship]);

  const handleTypeBlur = React.useCallback(() => {
    if (canMergeLink(link)) {
      dispatch({link, type: 'merge-link'});
    } else {
      dispatch({link, type: 'submit-link'});
    }
  }, [dispatch, link]);

  const handleTypeChange = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    const value = event.currentTarget.value;
    dispatch({
      link,
      linkTypeID: value === '' ? null : parseInt(value, 10),
      relationship,
      type: 'set-type',
    });
  }, [dispatch, link, relationship]);

  const typeOptions = React.useMemo(() => {
    const checker = getLinkChecker(source.entityType, link);
    const possibleTypesGids = new Set(checker.possibleTypes.flat());
    const allTypeOptions = getLinkTypeOptions(source.entityType);

    const possibleTypeOptions = possibleTypesGids.size ? (
      allTypeOptions.typeOptions.filter((option) => {
        // Keep disabled options for grouping.
        return option.disabled || possibleTypesGids.has(option.data.gid);
      })
    ) : allTypeOptions.generalTypeOptions;

    return possibleTypeOptions.filter((option, index) => {
      const nextOption = possibleTypeOptions[index + 1];
      return (
        !option.disabled ||
        /*
         * Ignore empty groups by checking if the next option is an item in
         * the current group; if not, then it's an empty group.
         */
        (nextOption && nextOption.data.parent_id === option.value)
      );
    });
  }, [source.entityType, link]);

  const datePeriod = React.useMemo(() => ({
    begin_date: beginDate,
    end_date: endDate,
    ended,
  }), [beginDate, endDate, ended]);

  const pendingEditsProps = React.useMemo(
    () => ({
      ...(
        source.entityType > 'url'
          ? {entity0: originalUrlEntity, entity1: source}
          : {entity0: source, entity1: originalUrlEntity}
      ),
      editsPending,
    } as React.PropsOf<RelationshipPendingEditsWarning>['relationship']),
    [source, originalUrlEntity, editsPending],
  );

  return (
    <tr className="relationship-item" key={relationshipId}>
      <td />
      <td className="link-actions">
        {(
          link.relationships.length > 1 &&
          !doesUrlMatchType(source.entityType, link)
        ) ? (
          <RemoveButton
            onClick={handleRemove}
            title={lp('Remove relationship', 'interactive')}
          />
          ) : null}
        <ExternalLinkAttributeDialog
          creditable={ENTITIES_WITH_RELATIONSHIP_CREDITS[source.entityType]}
          dispatch={dispatch}
          link={link}
          relationship={relationship}
        />
      </td>
      <td>
        <div className={`relationship-content ${highlight}`}>
          <label>{addColonText(l('Type'))}</label>
          <label className="relationship-name">
            {/*
              * If the URL matches its type or is just empty, display either
              * a favicon or a prompt for a new link as appropriate.
              */
              shouldShowTypeSelection(source.entityType, link, relationship)
                ? (
                  <LinkTypeSelect
                    handleTypeBlur={handleTypeBlur}
                    handleTypeChange={handleTypeChange}
                    id={'url-link-type-' + relationshipId}
                    options={typeOptions}
                    type={linkTypeID}
                  />
                ) : getLinkPhrase(relationship)
            }
            {(url && linkError === null && relationshipError === null)
              ? <TypeDescription type={linkTypeID} />
              : null}
            <RelationshipPendingEditsWarning
              relationship={pendingEditsProps}
            />
            {hasDate ? (
              <span className="date-period">
                {' '}
                {bracketedText(formatDatePeriod(datePeriod))}
              </span>
            ) : null}
            {nonEmpty(entityCredit) ? (
              <span className="entity-credit">
                {' '}
                {bracketedText(texp.lp(
                  'credited as “{credit}”',
                  'relationship credit',
                  {credit: entityCredit},
                ))}
              </span>
            ) : null}
          </label>
        </div>
        {linkType &&
          Object.hasOwn(
            linkType.attributes,
            String(VIDEO_ATTRIBUTE_ID),
          ) ? (
            <div className="attribute-container">
              <label>
                <input
                  checked={relationship.video}
                  onChange={handleVideoChange}
                  style={{verticalAlign: 'text-top'}}
                  type="checkbox"
                />
                {' '}
                {l('video')}
              </label>
            </div>
          ) : null}
        {relationshipError ? (
          <div className="error field-error" data-visible="1">
            {relationshipError.message}
          </div>
        ) : null}
      </td>
    </tr>
  );
}

const ExternalLinkRelationship:
  component(...React.PropsOf<_ExternalLinkRelationship>) =
  React.memo(_ExternalLinkRelationship);

export default ExternalLinkRelationship;
