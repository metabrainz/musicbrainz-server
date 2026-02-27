/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {FAVICON_CLASSES} from '../../common/constants.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import EntityPendingEditsWarning
  from '../../edit/components/EntityPendingEditsWarning.js';
import RemoveButton from '../../edit/components/RemoveButton.js';
import getRelationshipLinkType
  from '../../relationship-editor/utility/getRelationshipLinkType.js';
import {HIGHLIGHTS} from '../constants.js';
import {isLinkRemoved} from '../state.js';
import type {
  LinkRelationshipStateT,
  LinksEditorActionT,
  LinkStateT,
} from '../types.js';
import canMergeLink from '../utility/canMergeLink.js';
import doesUrlMatchOnlyOnePossibleType
  from '../utility/doesUrlMatchOnlyOnePossibleType.js';
import isLinkStateEmpty from '../utility/isLinkStateEmpty.js';

import ExternalLinkRelationship from './ExternalLinkRelationship.js';
import URLInputPopover from './URLInputPopover.js';

function getFaviconClass(
  relationships: $ReadOnlyArray<LinkRelationshipStateT>,
  url: string,
) {
  let faviconClass = '';

  for (const relationship of relationships) {
    const linkType = getRelationshipLinkType(relationship);
    if (linkType) {
      // If we find a homepage, that's the icon we want and we're done
      if (/^official (?:homepage|site)$/.test(linkType.name)) {
        return 'home';
      } else if (linkType.name === 'blog') {
        faviconClass = 'blog';
      } else if (linkType.name === 'review') {
        faviconClass = 'review';
      }
    }
  }

  if (nonEmpty(faviconClass)) {
    return faviconClass;
  }

  for (const key of Object.keys(FAVICON_CLASSES)) {
    if (url.indexOf(key) > 0) {
      return FAVICON_CLASSES[key];
    }
  }

  return 'no';
}

function highlightDuplicate(link: LinkStateT): void {
  const key = link.key;
  const target = document.getElementById(`external-link-${key}`);
  if (!target) {
    return;
  }
  target.scrollIntoView();
  target.style.backgroundColor = 'yellow';
  setTimeout(
    () => {
      target.style.backgroundColor = 'initial';
    },
    1000,
  );
}

component _ExternalLink(
  dispatch: (LinksEditorActionT) => void,
  isLastLink: boolean,
  isOnlyLink: boolean,
  link: LinkStateT,
  source: RelatableEntityT,
) {
  const {
    duplicateOf,
    error,
    isSubmitted,
    relationships,
    url,
  } = link;

  const highlight = React.useMemo(() => {
    if (isDatabaseRowId(source.id)) {
      if (link.isNew) {
        return HIGHLIGHTS.ADD;
      }
      invariant(link.originalUrlEntity != null);
      if (url !== link.originalUrlEntity.name) {
        return HIGHLIGHTS.EDIT;
      }
      if (isLinkRemoved(link)) {
        return HIGHLIGHTS.REMOVE;
      }
    }
    return HIGHLIGHTS.NONE;
  }, [link, source.id, url]);

  const addRelationship = React.useCallback(() => {
    dispatch({link, type: 'add-relationship'});
  }, [dispatch, link]);

  const submitLink = React.useCallback(() => {
    dispatch({link, type: 'submit-link'});
  }, [dispatch, link]);

  const handleKeyDown = React.useCallback((
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ) => {
    if (event.key === 'Enter' && url) {
      /*
       * If there's a link, prevent default and submit it,
       * otherwise allow submitting the form from empty field.
       */
      event.preventDefault();
      if (canMergeLink(link)) {
        dispatch({link, type: 'merge-link'});
      } else {
        submitLink();
      }
    }
  }, [url, dispatch, link, submitLink]);

  const isEmpty = React.useMemo(() => (
    isLinkStateEmpty(link)
  ), [link]);

  const faviconClass = isEmpty
    ? null
    : getFaviconClass(relationships, url);

  const handleUrlChange = React.useCallback((
    event: SyntheticInputEvent<HTMLInputElement>,
  ) => {
    dispatch({
      link,
      rawUrl: event.currentTarget.value,
      type: 'handle-url-change',
    });
  }, [dispatch, link]);

  const removeLink = React.useCallback(() => {
    dispatch({link, type: 'toggle-remove-link'});
  }, [dispatch, link]);

  const relationshipElements = React.useMemo(() => {
    const elements = [];
    for (const relationship of relationships) {
      elements.push(
        <ExternalLinkRelationship
          dispatch={dispatch}
          key={relationship.id}
          link={link}
          relationship={relationship}
          source={source}
        />,
      );
    }
    return elements;
  }, [relationships, dispatch, link, source]);

  const addRelationshipButton = React.useMemo(() => {
    /*
     * Hide the button when the link is not submitted,
     * or the link does not match only a single type.
     */
    if (
      isEmpty ||
      !isSubmitted ||
      doesUrlMatchOnlyOnePossibleType(source.entityType, link)
    ) {
      return null;
    }
    return (
      <tr className="add-relationship">
        <td />
        <td />
        <td className="add-item">
          <button
            className="add-item with-label"
            onClick={addRelationship}
            type="button"
          >
            {l('Add another relationship')}
          </button>
        </td>
      </tr>
    );
  }, [isEmpty, isSubmitted, source.entityType, link, addRelationship]);

  return (
    <>
      <tr className="external-link-item" id={`external-link-${link.key}`}>
        <td>
          {faviconClass ? (
            <span className={`favicon ${faviconClass}-favicon`} />
          ) : null}
        </td>
        <td className="link-actions">
          {(isEmpty && isLastLink) ? null : (
            <RemoveButton
              onClick={removeLink}
              title={l('Remove link')}
            />
          )}
          <URLInputPopover
            dispatch={dispatch}
            link={link}
          />
        </td>
        <td>
          {isSubmitted ? (
            <a
              className={`url ${highlight}`}
              href={url}
              rel="noreferrer"
              style={{overflowWrap: 'anywhere'}}
              target="_blank"
            >
              {url}
            </a>
          ) : (
            <input
              className="value with-button"
              onBlur={submitLink}
              onChange={handleUrlChange}
              onKeyDown={handleKeyDown}
              placeholder={isOnlyLink
                ? l('Add link')
                : (
                  isLastLink
                    ? l('Add another link')
                    /*
                     * The only time an empty '' placeholder would be shown
                     * to the user is when blanking an existing link
                     * (on an existing entity). A "required field" error is
                     * also shown below the field in that case.
                     *
                     * Blanking any link on a new entity would simply
                     * remove the field.
                     */
                    : '')}
              type="url"
              /*
               * Show the URL as-entered rather than the cleaned version, as
               * long as the user is still editing it, so as not to interrupt
               * their typing.
               */
              value={link.rawUrl}
            />
          )}
          {link.originalUrlEntity ? (
            <EntityPendingEditsWarning entity={link.originalUrlEntity} />
          ) : null}
          {url && duplicateOf != null ? (
            <div
              className="error field-error"
              data-visible="1"
            >
              {exp.l(
                canMergeLink(link)
                  ? `Note: This link already exists at position {position}.
                     To merge, press enter or select a type.`
                  : 'Note: This link already exists at position {position}.',
                {
                  position: (
                    <a
                      href={`#external-link-${duplicateOf.link.key}`}
                      onClick={() => highlightDuplicate(duplicateOf.link)}
                    >
                      {`#${duplicateOf.index + 1}`}
                    </a>
                  ),
                },
              )}
            </div>
          ) : null}
          {error == null ? null : (
            <div
              className={`error field-error target-${error.target}`}
              data-visible="1"
            >
              {error.message}
            </div>
          )}
        </td>
      </tr>
      {relationshipElements}
      {addRelationshipButton}
    </>
  );
}

const ExternalLink:
  component(...React.PropsOf<_ExternalLink>) =
    React.memo(_ExternalLink);

export default ExternalLink;
