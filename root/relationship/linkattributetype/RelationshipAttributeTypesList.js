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
import expand2react from '../../static/scripts/common/i18n/expand2react';
import bracketed, {bracketedText}
  from '../../static/scripts/common/utility/bracketed';
import {isRelationshipEditor}
  from '../../static/scripts/common/utility/privileges';
import {upperFirst} from '../../static/scripts/common/utility/strings';
import compareChildren from '../utility/compareChildren';
import RelationshipsHeader from '../RelationshipsHeader';

type AttributeTreeProps = {
  +$c: CatalystContextT,
  +attribute: LinkAttrTypeT,
};

type AttributeDetailsProps = {
  +$c: CatalystContextT,
  +attribute: LinkAttrTypeT,
  +topLevel?: boolean,
};

type AttributesListProps = {
  +$c: CatalystContextT,
  +root: LinkAttrTypeT,
};

const AttributeDetails = ({
  $c,
  attribute,
  topLevel = false,
}: AttributeDetailsProps) => {
  const childrenAttrs = attribute.children || [];
  const translatedDescription = attribute.description
    ? expand2react(l_relationships(attribute.description))
    : l('none');
  const descriptionSection = topLevel
    ? translatedDescription
    : bracketed(translatedDescription);

  return (
    isRelationshipEditor($c.user) ? (
      <>
        {descriptionSection}
        {' '}
        {bracketedText(attribute.child_order.toString())}
        {' [ '}
        <a href={'/relationship-attributes/create?parent=' + attribute.gid}>
          {l('Add child')}
        </a>
        {' | '}
        <a href={'/relationship-attribute/' + attribute.gid + '/edit'}>
          {l('Edit')}
        </a>
        {childrenAttrs.length ? null : (
          <>
            {' | '}
            <a href={'/relationship-attribute/' + attribute.gid + '/delete'}>
              {l('Remove')}
            </a>
          </>
        )}
        {' | '}
        <a href={'/relationship-attribute/' + attribute.gid}>
          {l('Documentation')}
        </a>
        {' ]'}

      </>
    ) : (
      <>
        {attribute.description && attribute.description !== attribute.name
          ? descriptionSection
          : null}
        {' [ '}
        <a href={'/relationship-attribute/' + attribute.gid}>
          {l('Documentation')}
        </a>
        {' ]'}
      </>
    )
  );
};

const AttributeTree = ({$c, attribute}: AttributeTreeProps) => {
  const childrenAttrs = attribute.children || [];
  return (
    <li style={{marginTop: '0.25em'}}>
      <strong>{upperFirst(l_relationships(attribute.name))}</strong>

      {' '}

      <AttributeDetails $c={$c} attribute={attribute} />

      {childrenAttrs.length ? (
        <ul>
          {childrenAttrs
            .slice(0)
            .sort(compareChildren)
            .map(attribute => (
              <AttributeTree
                $c={$c}
                attribute={attribute}
                key={attribute.id}
              />
            ))}
        </ul>
      ) : null}
    </li>
  );
};

const AttributesList = ({$c, root}: AttributesListProps) => {
  const childrenAttrs = root.children || [];
  return (
    childrenAttrs.length ? (
      childrenAttrs
        .slice(0)
        .sort(compareChildren)
        .map(attribute => {
          const childrenAttrs = attribute.children || [];
          return (
            <>
              <h2 id={attribute.name}>
                {upperFirst(l_relationships(attribute.name))}
              </h2>

              <AttributeDetails $c={$c} attribute={attribute} topLevel />

              {childrenAttrs.length ? (
                <>
                  <br />
                  <br />
                  {l('Possible values:')}
                  <ul>
                    {childrenAttrs
                      .slice(0)
                      .sort(compareChildren)
                      .map(attribute => (
                        <AttributeTree
                          $c={$c}
                          attribute={attribute}
                          key={attribute.id}
                        />
                      ))}
                  </ul>
                </>
              ) : null}
            </>
          );
        })
    ) : (
      <p>{l('No relationship attributes found.')}</p>
    )
  );
};

const RelationshipAttributeTypesList = ({
  $c,
  root,
}: AttributesListProps): React.Element<typeof Layout> => (
  <Layout fullWidth noIcons title={l('Relationship Attributes')}>
    <div id="content">
      <RelationshipsHeader page="attributes" />
      {isRelationshipEditor($c.user) ? (
        <p>
          <a href="/relationship-attributes/create">
            {l('Create a new relationship attribute')}
          </a>
        </p>
      ) : null}
      <AttributesList $c={$c} root={root} />
    </div>
  </Layout>
);

export default RelationshipAttributeTypesList;
