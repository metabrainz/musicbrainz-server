/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Cardinality
  from '../../static/scripts/common/components/Cardinality.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import EntityLink, {
  DeletedLink,
} from '../../static/scripts/common/components/EntityLink.js';
import OrderableDirection
  from '../../static/scripts/common/components/OrderableDirection.js';
import Warning from '../../static/scripts/common/components/Warning.js';
import {ENTITY_NAMES} from '../../static/scripts/common/constants.js';
import expand2react from '../../static/scripts/common/i18n/expand2react.js';
import linkedEntities from '../../static/scripts/common/linkedEntities.mjs';
import relationshipDateText
  from '../../static/scripts/common/utility/relationshipDateText.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import IntentionallyRawIcon from '../components/IntentionallyRawIcon.js';

type Props = {
  +edit: EditRelationshipTypeEditT,
};

function formatLongLinkPhrase(longLinkPhrase: string): string {
  let formattedPhrase = longLinkPhrase;
  if (longLinkPhrase && !longLinkPhrase.match('{entity0}')) {
    formattedPhrase = '{entity0} ' + formattedPhrase;
  }
  if (longLinkPhrase && !longLinkPhrase.match('{entity1}')) {
    formattedPhrase += ' {entity1}';
  }
  return formattedPhrase;
}

function formatAttribute(
  attribute: EditRelationshipTypeEditDisplayAttributeT,
  index: number,
) {
  return (
    <li key={'attribute-' + index}>
      {addColonText(l_relationships(attribute.typeName))}
      {' '}
      {attribute.min}
      {'-'}
      {attribute.max}
    </li>
  );
}

function formatExample(
  example: EditRelationshipTypeEditDisplayExampleT,
  index: number,
) {
  const sourceId = example.relationship.source_id;
  const sourceType = example.relationship.source_type;
  const source = sourceId == null
    ? null
    : linkedEntities[sourceType][sourceId];
  const target = example.relationship.target;

  return (
    <li key={'example-' + index}>
      {exp.l(
        formatLongLinkPhrase(
          example.relationship.verbosePhrase,
        ),
        {
          entity0: source
            ? <DescriptiveLink entity={source} />
            : <DeletedLink allowNew={false} name={null} />,
          entity1: <DescriptiveLink entity={target} />,
        },
      )}
      {' '}
      {relationshipDateText(example.relationship)}
    </li>
  );
}

const EditRelationshipType = ({
  edit,
}: Props): React.Element<typeof React.Fragment> => {
  const display = edit.display_data;
  const name = display.name;
  const oldDescription = display.description?.old ?? '';
  const newDescription = display.description?.new ?? '';
  const descriptionChanges = newDescription !== oldDescription;
  const relType = display.relationship_type;
  const entity0Type = relType ? ENTITY_NAMES[relType.type0]() : '';
  const entity1Type = relType ? ENTITY_NAMES[relType.type1]() : '';
  // If types do not match stored ones, this is probably an old broken edit
  const oldSchoolTypes = edit.data.types;
  const isDataBroken = oldSchoolTypes != null && relType != null &&
                       (relType.type0 !== oldSchoolTypes[0] ||
                       relType.type1 !== oldSchoolTypes[1]);

  const entity0Cardinality = display.entity0_cardinality;
  const entity0CardinalityChanges = entity0Cardinality &&
    entity0Cardinality.new !== entity0Cardinality.old;
  const entity1Cardinality = display.entity1_cardinality;
  const entity1CardinalityChanges = entity1Cardinality &&
    entity1Cardinality.new !== entity1Cardinality.old;
  const orderableDirection = display.orderable_direction;
  const orderableDirectionChanges = orderableDirection &&
    orderableDirection.new !== orderableDirection.old;
  const documentation = display.documentation;
  const deprecated = display.is_deprecated;
  const hasDates = display.has_dates;
  const parent = display.parent;
  const linkPhrase = display.link_phrase;
  const reverseLinkPhrase = display.reverse_link_phrase;
  const longLinkPhrase = display.long_link_phrase;
  const childOrder = display.child_order;

  // Always display entity placeholders for ease of understanding
  const oldLongLinkPhrase =
    formatLongLinkPhrase(longLinkPhrase?.old ?? '');
  const newLongLinkPhrase =
    formatLongLinkPhrase(longLinkPhrase?.new ?? '');

  const rawIconSection = (
    <>
      {' '}
      <IntentionallyRawIcon />
    </>
  );

  return (
    <>
      {isDataBroken ? (
        <Warning
          message={
            l(`The data for this edit seems to have been damaged
               during the 2011 transition to the current MusicBrainz
               schema. The remaining data is displayed below, but
               might not be fully accurate.`)
          }
        />
      ) : null}
      {relType ? (
        <table className="details">
          <tr>
            <th>{addColonText(l('Relationship Type'))}</th>
            <td>
              <EntityLink entity={relType} />
            </td>
          </tr>
          <tr>
            <th>
              {addColon(exp.l('Type of {entity_placeholder}', {
                entity_placeholder: <code>{'{entity0}'}</code>,
              }))}
            </th>
            <td>{entity0Type}</td>
          </tr>

          <tr>
            <th>
              {addColon(exp.l('Type of {entity_placeholder}', {
                entity_placeholder: <code>{'{entity1}'}</code>,
              }))}
            </th>
            <td>{entity1Type}</td>
          </tr>
        </table>
      ) : null}

      <table className="details add-relationship-type">
        {name ? (
          <WordDiff
            extraNew={rawIconSection}
            extraOld={rawIconSection}
            label={addColonText(l('Name'))}
            newText={name.new}
            oldText={name.old}
          />
        ) : null}

        {descriptionChanges ? (
          <WordDiff
            extraNew={nonEmpty(newDescription) ? rawIconSection : null}
            extraOld={nonEmpty(oldDescription) ? rawIconSection : null}
            label={addColonText(l('Description'))}
            newText={newDescription}
            oldText={oldDescription}
          />
        ) : nonEmpty(oldDescription) ? (
          <tr>
            <th>{addColonText(l('Description'))}</th>
            <td colSpan="2">
              {expand2react(l_relationships(oldDescription))}
            </td>
          </tr>
        ) : null}

        {linkPhrase ? (
          <WordDiff
            extraNew={rawIconSection}
            extraOld={rawIconSection}
            label={l('Link phrase:')}
            newText={linkPhrase.new}
            oldText={linkPhrase.old}
          />
        ) : null}

        {reverseLinkPhrase ? (
          <WordDiff
            extraNew={rawIconSection}
            extraOld={rawIconSection}
            label={l('Reverse link phrase:')}
            newText={reverseLinkPhrase.new}
            oldText={reverseLinkPhrase.old}
          />
        ) : null}

        {longLinkPhrase ? (
          <WordDiff
            extraNew={rawIconSection}
            extraOld={rawIconSection}
            label={l('Long link phrase:')}
            newText={newLongLinkPhrase}
            oldText={oldLongLinkPhrase}
          />
        ) : null}

        {childOrder ? (
          <FullChangeDiff
            label={l('Child order:')}
            newContent={childOrder.new}
            oldContent={childOrder.old}
          />
        ) : null}

        {deprecated ? (
          <FullChangeDiff
            label={l('Deprecated:')}
            newContent={yesNo(deprecated.new)}
            oldContent={yesNo(deprecated.old)}
          />
        ) : null}

        {hasDates ? (
          <FullChangeDiff
            label={l('Deprecated:')}
            newContent={yesNo(hasDates.new)}
            oldContent={yesNo(hasDates.old)}
          />
        ) : null}

        {entity0Cardinality && entity0CardinalityChanges /*:: === true */ ? (
          <FullChangeDiff
            label={addColon(exp.l('Cardinality of {entity_placeholder}', {
              entity_placeholder: <code>{'{entity0}'}</code>,
            }))}
            newContent={<Cardinality cardinality={entity0Cardinality.new} />}
            oldContent={<Cardinality cardinality={entity0Cardinality.old} />}
          />
        ) : null}

        {entity1Cardinality && entity1CardinalityChanges /*:: === true */ ? (
          <FullChangeDiff
            label={addColon(exp.l('Cardinality of {entity_placeholder}', {
              entity_placeholder: <code>{'{entity1}'}</code>,
            }))}
            newContent={<Cardinality cardinality={entity1Cardinality.new} />}
            oldContent={<Cardinality cardinality={entity1Cardinality.old} />}
          />
        ) : null}

        {orderableDirection && orderableDirectionChanges /*:: === true */ ? (
          <FullChangeDiff
            label={l('Orderable direction:')}
            newContent={
              <OrderableDirection direction={orderableDirection.new} />
            }
            oldContent={
              <OrderableDirection direction={orderableDirection.old} />
            }
          />
        ) : null}

        {display.attributes ? (
          <tr>
            <th>{addColonText(l('Attributes'))}</th>
            <td className="old">
              <ul>
                {display.attributes.old.map(
                  (attribute, index) => formatAttribute(attribute, index),
                )}
              </ul>
            </td>
            <td className="new">
              <ul>
                {display.attributes.new.map(
                  (attribute, index) => formatAttribute(attribute, index),
                )}
              </ul>
            </td>
          </tr>
        ) : null}

        {parent ? (
          <FullChangeDiff
            label={l('Parent:')}
            newContent={parent.new ? <EntityLink entity={parent.new} /> : ''}
            oldContent={parent.old ? <EntityLink entity={parent.old} /> : ''}
          />
        ) : null}

        {documentation ? (
          <WordDiff
            extraNew={nonEmpty(documentation.new) ? rawIconSection : null}
            extraOld={nonEmpty(documentation.old) ? rawIconSection : null}
            label={addColonText(l('Documentation'))}
            newText={documentation.new ?? ''}
            oldText={documentation.old ?? ''}
          />
        ) : null}

        {display.examples ? (
          <tr>
            <th>{addColonText(l('Examples'))}</th>
            <td className="old">
              <ul>
                {display.examples.old.map(
                  (example, index) => formatExample(example, index),
                )}
              </ul>
            </td>
            <td className="new">
              <ul>
                {display.examples.new.map(
                  (example, index) => formatExample(example, index),
                )}
              </ul>
            </td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default EditRelationshipType;
