/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import IntentionallyRawIcon from '../components/IntentionallyRawIcon';
import Cardinality from '../../static/scripts/common/components/Cardinality';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import OrderableDirection
  from '../../static/scripts/common/components/OrderableDirection';
import Warning from '../../static/scripts/common/components/Warning';
import {ENTITY_NAMES} from '../../static/scripts/common/constants';
import linkedEntities from '../../static/scripts/common/linkedEntities';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';
import expand2react from '../../static/scripts/common/i18n/expand2react';
import yesNo from '../../static/scripts/common/utility/yesNo';
import relationshipDateText
  from '../../utility/relationshipDateText';

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

function formatAttribute(attribute, index) {
  return (
    <li key={'attribute-' + index}>
      {addColon(l_relationships(attribute.typeName))}
      {' '}
      {attribute.min}
      {'-'}
      {attribute.max}
    </li>
  );
}

function formatExample(example, index) {
  const sourceId = example.relationship.source_id;
  const sourceType = example.relationship.source_type;
  const source = linkedEntities[sourceType][sourceId];
  const target = example.relationship.target;

  return (
    <li key={'example-' + index}>
      {exp.l(
        formatLongLinkPhrase(
          example.relationship.verbosePhrase,
        ),
        {
          entity0: <DescriptiveLink entity={source} />,
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
  const parentId = display.parent_id;
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
            <th>{addColon(l('Relationship Type'))}</th>
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

        {parentId ? (
          <FullChangeDiff
            label={l('Parent:')}
            newContent={parentId.new}
            oldContent={parentId.old}
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
