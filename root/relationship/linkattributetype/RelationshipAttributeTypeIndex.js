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
import expand2react from '../../static/scripts/common/i18n/expand2react.js';
import linkedEntities from '../../static/scripts/common/linkedEntities.mjs';
import bracketed, {bracketedText}
  from '../../static/scripts/common/utility/bracketed.js';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import {isRelationshipEditor}
  from '../../static/scripts/common/utility/privileges.js';
import {upperFirst} from '../../static/scripts/common/utility/strings.js';
import compareChildren from '../utility/compareChildren.js';

component AttributeTree(attribute: LinkAttrTypeT) {
  const childrenAttrs = attribute.children || [];
  return (
    <li style={{marginTop: '0.25em'}}>
      <strong>
        <a href={'/relationship-attribute/' + attribute.gid}>
          {upperFirst(l_relationships(attribute.name))}
        </a>
      </strong>
      {' '}
      {attribute.description ? (
        <>
          {bracketed(expand2react(l_relationships(attribute.description)))}
          {' '}
        </>
      ) : null}
      {bracketedText(attribute.child_order.toString())}

      {childrenAttrs.length ? (
        <ul>
          {childrenAttrs
            .slice(0)
            .sort(compareChildren)
            .map(attribute => (
              <AttributeTree
                attribute={attribute}
                key={attribute.gid}
              />
            ))}
        </ul>
      ) : null}
    </li>
  );
}

component RelationshipAttributeTypeIndex(
  attribute: LinkAttrTypeT,
  relationships: Array<LinkTypeT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const isInstrumentRoot = attribute.id === 14;
  const isInstrumentChild = attribute.root_id === 14 && !isInstrumentRoot;

  const childrenAttrs = attribute.children || [];
  const attrName = upperFirst(l_relationships(attribute.name));
  const title = l('Relationship attribute') + ' / ' + attrName;
  const parent = attribute.parent_id == null
    ? null
    : linkedEntities.link_attribute_type[attribute.parent_id];

  return (
    <Layout fullWidth noIcons title={title}>
      <div id="content">
        <h1 className="hierarchy-links">
          <a href="/relationship-attributes">
            {l('Relationship attributes')}
          </a>
          {' / '}
          {attrName}
        </h1>

        {isRelationshipEditor($c.user) && !isInstrumentChild ? (
          <span className="buttons" style={{float: 'right'}}>
            <a href={'/relationship-attribute/' + attribute.gid + '/edit'}>
              {lp('Edit', 'verb, interactive')}
            </a>
            {childrenAttrs.length ? null : (
              <a
                href={'/relationship-attribute/' + attribute.gid + '/delete'}
              >
                {l('Remove')}
              </a>
            )}
          </span>
        ) : null}

        {attribute.description ? (
          <>
            <h2>{l('Description')}</h2>
            <p>{expand2react(l_relationships(attribute.description))}</p>
          </>
        ) : null}

        <p>
          {isRelationshipEditor($c.user) ? (
            <>
              <strong>{addColonText(l('ID'))}</strong>
              {' '}
              {attribute.id}
              <br />
              <strong>{addColonText(l('Child order'))}</strong>
              {' '}
              {attribute.child_order}
              <br />
            </>
          ) : null}
          <strong>{l('UUID:')}</strong>
          {' '}
          {attribute.gid}
          <br />
          {parent ? (
            <>
              <strong>{addColonText(l('Parent attribute'))}</strong>
              {' '}
              <a href={'/relationship-attribute/' + parent.gid}>
                {upperFirst(l_relationships(parent.name))}
              </a>
            </>
          ) : null}
        </p>

        {attribute.creditable ? (
          <p>
            {l('This attribute supports free text credits')}
          </p>
        ) : null}

        {attribute.free_text ? (
          <p>
            {l('This attribute uses free text values')}
          </p>
        ) : null}

        {childrenAttrs.length ? (
          <>
            <h2>{l('Possible values')}</h2>
            {isInstrumentRoot ? (
              <p>
                {exp.l(
                  `The possible values for this attribute can be seen
                   from the {instrument_list|instrument list}.`,
                  {instrument_list: '/instruments'},
                )}
              </p>
            ) : (
              <ul>
                {childrenAttrs
                  .slice(0)
                  .sort(compareChildren)
                  .map(attribute => (
                    <AttributeTree
                      attribute={attribute}
                      key={attribute.gid}
                    />
                  ))}
              </ul>
            )}
          </>
        ) : null}

        <h2>{l('Relationship usage')}</h2>
        {relationships.length ? (
          <>
            <p>
              {l(`This attribute is being used
                  by the following relationship types:`)}
            </p>

            {relationships.map(relationship => (
              <React.Fragment key={relationship.gid}>
                <h3>
                  <a
                    href={'/relationship/' + relationship.gid}
                  >
                    {upperFirst(l_relationships(relationship.name))}
                  </a>
                  {' '}
                  {bracketedText(texp.l(
                    '{type0} - {type1}',
                    {
                      type0: formatEntityTypeName(relationship.type0),
                      type1: formatEntityTypeName(relationship.type1),
                    },
                  ))}
                </h3>
                {relationship.description ? (
                  <p>
                    {expand2react(l_relationships(relationship.description))}
                  </p>
                ) : null}
              </React.Fragment>
            ))}
          </>
        ) : (
          <p>
            {l(`This attribute isn’t directly being used
                by any relationship types.`)}
          </p>
        )}
      </div>
    </Layout>
  );
}

export default RelationshipAttributeTypeIndex;
