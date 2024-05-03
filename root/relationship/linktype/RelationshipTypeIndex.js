/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../context.mjs';
import Layout from '../../layout/index.js';
import Cardinality
  from '../../static/scripts/common/components/Cardinality.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import OrderableDirection
  from '../../static/scripts/common/components/OrderableDirection.js';
import Relationship
  from '../../static/scripts/common/components/Relationship.js';
import {compare} from '../../static/scripts/common/i18n.js';
import expand2react from '../../static/scripts/common/i18n/expand2react.js';
import localizeLinkAttributeTypeName
  from '../../static/scripts/common/i18n/localizeLinkAttributeTypeName.js';
import linkedEntities from '../../static/scripts/common/linkedEntities.mjs';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import {isRelationshipEditor}
  from '../../static/scripts/common/utility/privileges.js';
import {upperFirst} from '../../static/scripts/common/utility/strings.js';

component UsedAttributesList(
  attributes?: $ReadOnlyArray<LinkAttrTypeT>,
  relType: LinkTypeT,
) {
  return (
    <>
      <h2>{l('Attributes')}</h2>
      {!attributes?.length && !relType.has_dates ? (
        <p>{l('This relationship type doesn\'t allow any attributes.')}</p>
      ) : (
        <>
          <p>
            {l(`The following attributes can be used
                with this relationship type:`)}
          </p>
          {attributes ? (
            attributes.map(attributeType => (
              <React.Fragment key={attributeType.id}>
                <h3>
                  <a href={'/relationship-attribute/' + attributeType.gid}>
                    {l_relationships(attributeType.name)}
                  </a>
                </h3>
                <p>
                  {expand2react(l_relationships(
                    attributeType.description,
                  ))}
                </p>
              </React.Fragment>
            ))
          ) : null}
          {relType.has_dates ? (
            <>
              <h3>{l('start date')}</h3>
              <p />

              <h3>{l('end date')}</h3>
              <p />
            </>
          ) : null}
        </>
      )}
    </>
  );
}

component RelationshipTypeIndex(relType: LinkTypeT) {
  const $c = React.useContext(SanitizedCatalystContext);
  const childrenTypes = relType.children || [];
  const typeName = upperFirst(l_relationships(relType.name));
  const title = l('Relationship type') + ' / ' + typeName;
  const type0 = relType.type0;
  const type1 = relType.type1;
  const formattedType0 = formatEntityTypeName(type0);
  const formattedType1 = formatEntityTypeName(type1);
  const possibleAttributes = Object.keys(relType.attributes)
    .map(attributeTypeId => (
      linkedEntities.link_attribute_type[parseInt(attributeTypeId, 10)]
    ));
  possibleAttributes.sort((a, b) => compare(
    localizeLinkAttributeTypeName(a),
    localizeLinkAttributeTypeName(b),
  ));
  const examples = relType.examples;
  let lastExampleName = '';

  return (
    <Layout fullWidth noIcons title={title}>
      <div id="content">
        <h1 className="hierarchy-links">
          <a href="/relationships">
            {l('Relationship types')}
          </a>
          {' / '}
          <a href={'/relationships/' + type0 + '-' + type1}>
            {texp.l(
              '{entity0}-{entity1}',
              {entity0: formattedType0, entity1: formattedType1},
            )}
          </a>
          {' / '}
          {typeName}
        </h1>

        {relType.deprecated ? (
          <p className="cleanup">
            {l(`This relationship type is deprecated
                and should not be used.`)}
          </p>
        ) : null}

        {isRelationshipEditor($c.user) ? (
          <span className="buttons" style={{float: 'right'}}>
            <EntityLink
              content={l_admin('Edit')}
              entity={relType}
              subPath="edit"
            />
            {childrenTypes.length ? null : (
              <EntityLink
                content={l_admin('Remove')}
                entity={relType}
                subPath="delete"
              />
            )}
          </span>
        ) : null}

        {relType.description ? (
          <>
            <h2>{l('Description')}</h2>
            <p>{expand2react(l_relationships(relType.description))}</p>

            <p>
              {/*
                * We need to show this to users because it is needed
                * for release editor seeding. Once that can be done
                * with the MBID (MBS-11175), this should be hidden
                * if the user is not a relationship editor.
                */}
              <strong>{addColonText(l('ID'))}</strong>
              {' '}
              {relType.id}
              <br />
              {isRelationshipEditor($c.user) ? (
                <>
                  <strong>{addColonText(l('Child order'))}</strong>
                  {' '}
                  {relType.child_order}
                  <br />
                </>
              ) : null}
              <strong>
                {addColon(exp.l('Cardinality of {entity_placeholder}', {
                  entity_placeholder: <code>{'{entity0}'}</code>,
                }))}
              </strong>
              {' '}
              <Cardinality cardinality={relType.cardinality0} />
              <br />
              <strong>
                {addColon(exp.l('Cardinality of {entity_placeholder}', {
                  entity_placeholder: <code>{'{entity1}'}</code>,
                }))}
              </strong>
              {' '}
              <Cardinality cardinality={relType.cardinality1} />
              <br />
              <strong>{l('Orderable direction:')}</strong>
              {' '}
              <OrderableDirection direction={relType.orderable_direction} />
              <br />
              <strong>{l('UUID:')}</strong>
              {' '}
              {relType.gid}
              <br />
            </p>

            <h2>{l('Link phrases')}</h2>
            <p>
              <ul>
                <li>
                  <strong>{l('Forward link phrase:')}</strong>
                  {' '}
                  {l_relationships(relType.link_phrase)}
                </li>
                <li>
                  <strong>{l('Reverse link phrase:')}</strong>
                  {' '}
                  {l_relationships(relType.reverse_link_phrase)}
                </li>
                <li>
                  <strong>{l('Long link phrase:')}</strong>
                  {' '}
                  {l_relationships(relType.long_link_phrase)}
                </li>
              </ul>
            </p>

            <UsedAttributesList
              attributes={possibleAttributes}
              relType={relType}
            />

            {nonEmpty(relType.documentation) ||
              type0 === 'url' || type1 === 'url' ? (
                <>
                  <h2>{l('Guidelines')}</h2>
                  <p>
                    {type0 === 'url' || type1 === 'url' ? (
                      exp.l(
                        'See the general {url|guidelines for URLs}.',
                        {url: '/doc/Style/Relationships/URLs'},
                      )
                    ) : null}
                    {nonEmpty(relType.documentation) ? (
                      expand2react(relType.documentation)
                    ) : null}
                  </p>
                </>
              ) : null}

            {examples?.length ? (
              <>
                <h2>{l('Examples')}</h2>
                {examples.map(example => {
                  const isSameName = (lastExampleName === example.name);
                  lastExampleName = example.name;
                  return (
                    <React.Fragment key={example.relationship.id}>
                      {isSameName
                        ? null
                        : <h3>{example.name}</h3>}
                      <p>
                        <Relationship relationship={example.relationship} />
                      </p>
                    </React.Fragment>
                  );
                })}
              </>
            ) : null}
          </>
        ) : (
          <p>
            {l(`This relationship type is only used
                for grouping other relationship types.`)}
          </p>
        )}
      </div>
    </Layout>
  );
}

export default RelationshipTypeIndex;
