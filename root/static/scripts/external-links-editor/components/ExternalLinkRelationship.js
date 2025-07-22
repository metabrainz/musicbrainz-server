/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  VIDEO_ATTRIBUTE_ID,
} from '../../common/constants.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import {bracketedText} from '../../common/utility/bracketed.js';
import formatDatePeriod from '../../common/utility/formatDatePeriod.js';
import {isDateNonEmpty} from '../../common/utility/isDateEmpty.js';
import RelationshipPendingEditsWarning
  from '../../edit/components/RelationshipPendingEditsWarning.js';
import RemoveButton from '../../edit/components/RemoveButton.js';
import {stripAttributes} from '../../edit/utility/linkPhrase.js';
import type {
  HighlightT,
  LinkRelationshipT,
  LinkStateT,
  LinkTypeOptionT,
} from '../types.js';

import ExternalLinkAttributeDialog
  from './ExternalLinkAttributeDialog.js';
import LinkTypeSelect from './LinkTypeSelect.js';
import TypeDescription from './TypeDescription.js';

type ExternalLinkRelationshipPropsT = {
  +creditableEntityProp: 'entity0_credit' | 'entity1_credit' | null,
  +hasUrlError: boolean,
  +highlight: HighlightT,
  +isOnlyRelationship: boolean,
  +link: LinkRelationshipT,
  +onAttributesChange: (number, $ReadOnly<Partial<LinkStateT>>) => void,
  +onLinkRemove: (number) => void,
  +onTypeBlur: (number, SyntheticFocusEvent<HTMLSelectElement>) => void,
  +onTypeChange: (number, SyntheticEvent<HTMLSelectElement>) => void,
  +onVideoChange: (number, SyntheticEvent<HTMLInputElement>) => void,
  +typeOptions: $ReadOnlyArray<LinkTypeOptionT>,
  +urlMatchesType: boolean,
};

function isEmpty(link: LinkRelationshipT) {
  return !(link.type || link.url);
}

const ExternalLinkRelationship =
  (props: ExternalLinkRelationshipPropsT): React.MixedElement => {
    const {
      creditableEntityProp,
      link,
      hasUrlError,
      highlight,
      urlMatchesType,
    } = props;
    const linkType = link.type ? linkedEntities.link_type[link.type] : null;
    const backward = linkType && linkType.type1 > 'url';
    const hasDate = isDateNonEmpty(link.begin_date) ||
                    isDateNonEmpty(link.end_date) ||
                    link.ended;

    const showTypeSelection = (link.error || hasUrlError)
      ? true
      : !(urlMatchesType || isEmpty(link));

    const creditedName = creditableEntityProp
      ? link[creditableEntityProp]
      : null;

    return (
      <tr className="relationship-item" key={link.relationship}>
        <td />
        <td className="link-actions">
          {!props.isOnlyRelationship && !props.urlMatchesType ? (
            <RemoveButton
              onClick={() => props.onLinkRemove(link.index)}
              title={lp('Remove relationship', 'interactive')}
            />
          ) : null}
          <ExternalLinkAttributeDialog
            creditableEntityProp={creditableEntityProp}
            onConfirm={
              (attributes) => props.onAttributesChange(link.index, attributes)
            }
            relationship={link}
          />
        </td>
        <td>
          <div className={`relationship-content ${highlight}`}>
            <label>{addColonText(l('Type'))}</label>
            <label className="relationship-name">
              {/* If the URL matches its type or is just empty,
                  display either a favicon
                  or a prompt for a new link as appropriate. */
                showTypeSelection
                  ? (
                    <LinkTypeSelect
                      handleTypeBlur={
                        (event) => props.onTypeBlur(link.index, event)
                      }
                      handleTypeChange={
                        (event) => props.onTypeChange(link.index, event)
                      }
                      options={
                        props.typeOptions.reduce((options, option, index) => {
                          const nextOption = props.typeOptions[index + 1];
                          if (!option.disabled ||
                          /*
                           * Ignore empty groups by checking
                           * if the next option is an item in current group,
                           * if not, then it's an empty group.
                           */
                          (nextOption &&
                            nextOption.data.parent_id === option.value)) {
                            options.push(option);
                          }
                          return options;
                        }, [])
                      }
                      type={link.type}
                    />
                  ) : (
                    linkType ? (
                      backward ? (
                        stripAttributes(
                          linkType,
                          linkType.l_reverse_link_phrase ?? '',
                        )
                      ) : (
                        stripAttributes(
                          linkType,
                          linkType.l_link_phrase ?? '',
                        )
                      )
                    ) : null
                  )
              }
              {link.url && !link.error && !hasUrlError
                ? <TypeDescription type={link.type} />
                : null}
              <RelationshipPendingEditsWarning relationship={link} />
              {hasDate ? (
                <span className="date-period">
                  {' '}
                  {bracketedText(formatDatePeriod(link))}
                </span>
              ) : null}
              {nonEmpty(creditedName) ? (
                <span className="entity-credit">
                  {' '}
                  {bracketedText(texp.lp(
                    'credited as “{credit}”',
                    'relationship credit',
                    {credit: creditedName},
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
                    checked={link.video}
                    onChange={
                      (event) => props.onVideoChange(link.index, event)
                    }
                    style={{verticalAlign: 'text-top'}}
                    type="checkbox"
                  />
                  {' '}
                  {l('video')}
                </label>
              </div>
            ) : null}
          {link.error ? (
            <div className="error field-error" data-visible="1">
              {link.error.message}
            </div>
          ) : null}
        </td>
      </tr>
    );
  };

export default ExternalLinkRelationship;
