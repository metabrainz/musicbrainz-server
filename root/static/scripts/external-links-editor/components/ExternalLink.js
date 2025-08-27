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
import linkedEntities from '../../common/linkedEntities.mjs';
import EntityPendingEditsWarning
  from '../../edit/components/EntityPendingEditsWarning.js';
import RemoveButton from '../../edit/components/RemoveButton.js';
import {stripAttributes} from '../../edit/utility/linkPhrase.js';
import type {
  CreditableEntityOptionsT,
  ErrorT,
  HighlightT,
  LinkRelationshipT,
  LinkStateT,
  LinkTypeOptionT,
} from '../types.js';

import ExternalLinkRelationship from './ExternalLinkRelationship.js';
import URLInputPopover from './URLInputPopover.js';

export type ExternalLinkPropsT = {
  +canMerge: boolean,
  +cleanupUrl: (string) => string,
  +creditableEntityProp: CreditableEntityOptionsT,
  +duplicate: number | null,
  +error: ErrorT | null,
  +getRelationshipHighlightType: (
    LinkRelationshipT,
    CreditableEntityOptionsT
  ) => HighlightT,
  +handleAttributesChange: (number, $ReadOnly<Partial<LinkStateT>>) => void,
  +handleLinkRemove: (number) => void,
  +handleLinkSubmit: (SyntheticKeyboardEvent<HTMLInputElement>) => void,
  +handleUrlBlur: (SyntheticFocusEvent<HTMLInputElement>) => void,
  +handleUrlChange: (string) => void,
  +highlight: HighlightT,
  +index: number,
  +isLastLink: boolean,
  +isOnlyLink: boolean,
  +onAddRelationship: (string) => void,
  +onTypeBlur: (number, SyntheticFocusEvent<HTMLSelectElement>) => void,
  +onTypeChange: (number, SyntheticEvent<HTMLSelectElement>) => void,
  +onUrlRemove: () => void,
  +onVideoChange:
    (number, SyntheticEvent<HTMLInputElement>) => void,
  +rawUrl: string,
  +relationships: $ReadOnlyArray<LinkRelationshipT>,
  +typeOptions: $ReadOnlyArray<LinkTypeOptionT>,
  +url: string,
  +urlEntity: RelatableEntityT | null,
  +urlMatchesType: boolean,
  +validateLink: (LinkRelationshipT | LinkStateT) => ErrorT | null,
};

function getFaviconClass(
  relationships: $ReadOnlyArray<LinkRelationshipT>,
  url: string,
) {
  let faviconClass = '';

  for (const relationship of relationships) {
    const linkType = relationship.type
      ? linkedEntities.link_type[relationship.type]
      : null;

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

function isEmpty(link: LinkRelationshipT | ExternalLinkPropsT) {
  return !(link.type || link.url);
}

class ExternalLink extends React.Component<ExternalLinkPropsT> {
  handleKeyDown(event: SyntheticKeyboardEvent<HTMLInputElement>) {
    if (event.key === 'Enter' && this.props.url) {
      /*
       * If there's a link, prevent default and submit it,
       * otherwise allow submitting the form from empty field.
       */
      event.preventDefault();
      this.props.handleLinkSubmit(event);
    }
  }

  highlightDuplicate(index: number | null) {
    if (index === null) {
      return;
    }
    const target = document.getElementById(`external-link-${index}`);
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

  render(): React.MixedElement {
    const props = this.props;
    const notEmpty = props.relationships.some(link => {
      return !isEmpty(link);
    });
    const firstLink = props.relationships[0];

    const faviconClass = notEmpty
      ? getFaviconClass(props.relationships, props.url)
      : null;

    return (
      <>
        <tr
          className="external-link-item"
          id={`external-link-${props.index}`}
        >
          <td>
            {faviconClass ? (
              <span
                className={'favicon ' + faviconClass + '-favicon'}
              />
            ) : null}
          </td>
          <td className="link-actions">
            {notEmpty ? (
              <RemoveButton
                dataIndex={props.index}
                onClick={() => props.onUrlRemove()}
                title={l('Remove link')}
              />
            ) : null}
            {isEmpty(props) ? null : (
              <URLInputPopover
                cleanupUrl={props.cleanupUrl}
                /*
                 * Randomly choose a link because relationship errors
                 * are not displayed, thus link type doesn't matter.
                 */
                link={firstLink}
                onConfirm={props.handleUrlChange}
                validateLink={props.validateLink}
              />
            )}
          </td>
          <td>
            {/* Links that are not submitted will not be grouped,
              * so it's safe to check the first link only.
              */}
            {(!firstLink.submitted || !props.url) ? (
              <input
                className="value with-button"
                data-index={props.index}
                onBlur={props.handleUrlBlur}
                onChange={(event) => {
                  props.handleUrlChange(event.currentTarget.value);
                }}
                onKeyDown={(event) => this.handleKeyDown(event)}
                placeholder={props.isOnlyLink
                  ? l('Add link')
                  : (
                    props.isLastLink
                      ? l('Add another link')
                      : ''
                  )}
                type="url"
                // Don't interrupt user input with clean URL
                value={props.rawUrl}
              />
            ) : (
              <a
                className={`url ${props.highlight}`}
                href={props.url}
                rel="noreferrer"
                style={{overflowWrap: 'anywhere'}}
                target="_blank"
              >
                {props.url}
              </a>
            )}
            {props.urlEntity ? (
              <EntityPendingEditsWarning entity={props.urlEntity} />
            ) : null}
            {props.url && props.duplicate !== null ? (
              <div
                className="error field-error"
                data-visible="1"
              >
                {exp.l(
                  props.canMerge
                    ? `Note: This link already exists
                       at position {position}.
                       To merge, press enter or select a type.`
                    : `Note: This link already exists
                       at position {position}.`,
                  {
                    position: (
                      <a
                        href={`#external-link-${props.duplicate}`}
                        onClick={
                          () => this.highlightDuplicate(props.duplicate)
                        }
                      >
                        {`#${props.duplicate + 1}`}
                      </a>
                    ),
                  },
                )}
              </div>
            ) : null}
            {props.error ? (
              <div
                className={`error field-error target-${props.error.target}`}
                data-visible="1"
              >
                {props.error.message}
              </div>
            ) : null}
          </td>
        </tr>
        {notEmpty &&
          props.relationships.map((link, index) => (
            <ExternalLinkRelationship
              creditableEntityProp={props.creditableEntityProp}
              hasUrlError={props.error != null}
              highlight={props.getRelationshipHighlightType(
                link,
                props.creditableEntityProp,
              )}
              isOnlyRelationship={props.relationships.length === 1}
              key={index}
              link={link}
              onAttributesChange={props.handleAttributesChange}
              onLinkRemove={props.handleLinkRemove}
              onTypeBlur={props.onTypeBlur}
              onTypeChange={props.onTypeChange}
              onVideoChange={props.onVideoChange}
              typeOptions={props.typeOptions}
              urlMatchesType={props.urlMatchesType}
            />
        ))}
        {firstLink.pendingTypes &&
          firstLink.pendingTypes.map((type) => {
            const relType = linkedEntities.link_type[type];
            return (
              <tr className="relationship-item" key={type}>
                <td />
                <td>
                  <div className="relationship-content">
                    <label>{addColonText(l('Type'))}</label>
                    <label className="relationship-name">
                      {stripAttributes(
                        relType,
                        relType.l_link_phrase ?? '',
                      )}
                    </label>
                  </div>
                </td>
              </tr>
            );
          })}
        {/*
          * Hide the button when link is not submitted
          * or link type is auto-selected.
          */}
        {notEmpty && firstLink.submitted && !props.urlMatchesType ? (
          <tr className="add-relationship">
            <td />
            <td />
            <td className="add-item">
              <button
                className="add-item with-label"
                onClick={() => props.onAddRelationship(props.url)}
                type="button"
              >
                {l('Add another relationship')}
              </button>
            </td>
          </tr>
        ) : null}
      </>
    );
  }
}

export default ExternalLink;
