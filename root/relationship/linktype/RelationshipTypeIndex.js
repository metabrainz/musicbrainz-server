/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';
import Cardinality from '../../static/scripts/common/components/Cardinality';
import OrderableDirection
  from '../../static/scripts/common/components/OrderableDirection';
import Relationship
  from '../../static/scripts/common/components/Relationship';
import linkedEntities from '../../static/scripts/common/linkedEntities';
import {compare} from '../../static/scripts/common/i18n';
import expand2react from '../../static/scripts/common/i18n/expand2react';
import localizeLinkAttributeTypeName
  from '../../static/scripts/common/i18n/localizeLinkAttributeTypeName';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName';
import {isRelationshipEditor}
  from '../../static/scripts/common/utility/privileges';
import {upperFirst} from '../../static/scripts/common/utility/strings';

type Props = {
  +$c: CatalystContextT,
  +relType: LinkTypeT,
};

const RelationshipTypeIndex = ({
  $c,
  relType,
}: Props): React.Element<typeof Layout> => {
  const childrenTypes = relType.children || [];
  const typeName = upperFirst(l_relationships(relType.name));
  const title = l('Relationship Type') + ' / ' + typeName;
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
  let lastExampleName = '';

  return (
    <Layout $c={$c} fullWidth noIcons title={title}>
      <div id="content">
        <h1 className="hierarchy-links">
          <a href="/relationships">
            {l('Relationship Types')}
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
            <a href={'/relationship/' + relType.gid + '/edit'}>
              {l('Edit')}
            </a>
            {childrenTypes.length ? null : (
              <a
                href={'/relationship/' + relType.gid + '/delete'}
              >
                {l('Remove')}
              </a>
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
              <strong>{l('ID:')}</strong>
              {' '}
              {relType.id}
              <br />
              {isRelationshipEditor($c.user) ? (
                <>
                  <strong>{l('Child order:')}</strong>
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

            <h2>{l('Attributes')}</h2>
            <p>
              {!possibleAttributes.length && !relType.has_dates ? (
                l('This relationship type doesn\'t allow any attributes.')
              ) : (
                <>
                  {l(`The following attributes can be used
                      with this relationship type:`)}
                  {possibleAttributes ? (
                    possibleAttributes.map(attributeType => (
                      <React.Fragment key={attributeType.id}>
                        <h3>{l_relationships(attributeType.name)}</h3>
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
            </p>

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

            {relType.examples.length ? (
              <>
                <h2>{l('Examples')}</h2>
                {relType.examples.map(example => {
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
};

export default RelationshipTypeIndex;
