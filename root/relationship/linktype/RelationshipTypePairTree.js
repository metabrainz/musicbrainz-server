/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';
import * as manifest from '../../static/manifest';
import Cardinality from '../../static/scripts/common/components/Cardinality';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import expand2react from '../../static/scripts/common/i18n/expand2react';
import bracketed from '../../static/scripts/common/utility/bracketed';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName';
import {isRelationshipEditor}
  from '../../static/scripts/common/utility/privileges';
import compareChildren from '../utility/compareChildren';
import RelationshipsHeader from '../RelationshipsHeader';

type RelationshipTypeDetailsProps = {
  +$c: CatalystContextT,
  +relType: LinkTypeT,
};

type RelationshipTypePairTreeProps = {
  +$c: CatalystContextT,
  +root: LinkTypeT,
};

const RelationshipTypeDetails = ({
  $c,
  relType,
}: RelationshipTypeDetailsProps) => {
  const childrenTypes = relType.children || [];
  return (
    <li style={{paddingTop: '0.5em'}}>
      <span>
        <strong>{l_relationships(relType.name)}</strong>
        {' '}
        {bracketed(
          <a className="toggle" style={{cursor: 'pointer'}}>
            {l('more')}
          </a>,
        )}
      </span>

      <div
        className="reldetails"
        style={{marginLeft: '20px', padding: '3px'}}
      >
        {isRelationshipEditor($c.user) ? (
          <>
            <strong>{l('Child order:')}</strong>
            {' '}
            {relType.child_order}
            <br />
          </>
        ) : null}

        <strong>{l('Forward link phrase:')}</strong>
        {' '}
        {relType.link_phrase
          ? l_relationships(relType.link_phrase)
          : lp('(none)', 'link phrase')}
        <br />

        <strong>{l('Reverse link phrase:')}</strong>
        {' '}
        {relType.reverse_link_phrase
          ? l_relationships(relType.reverse_link_phrase)
          : lp('(none)', 'link phrase')}
        <br />

        <strong>{l('Long link phrase:')}</strong>
        {' '}
        {relType.long_link_phrase
          ? l_relationships(relType.long_link_phrase)
          : lp('(none)', 'link phrase')}
        <br />

        <strong>{l('Description:')}</strong>
        {' '}
        {relType.description
          ? expand2react(l_relationships(relType.description))
          : lp('(none)', 'description')}
        <br />

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

        <strong>{l('UUID:')}</strong>
        {' '}
        {relType.gid}
        <br />

        {'[ '}
        {isRelationshipEditor($c.user) ? (
          <>
            <EntityLink content={l('Edit')} entity={relType} subPath="edit" />
            {childrenTypes.length ? null : (
              <>
                {' | '}
                <EntityLink
                  content={l('Remove')}
                  entity={relType}
                  subPath="delete"
                />
              </>
            )}
            {' | '}
          </>
        ) : null}
        {exp.l(
          '{relationship_documentation_url|Documentation}',
          {relationship_documentation_url: '/relationship/' + relType.gid},
        )}
        {' ]'}
      </div>

      {childrenTypes.length ? (
        <ul>
          {childrenTypes
            .slice(0)
            .sort(compareChildren)
            .map(childrenType => (
              <RelationshipTypeDetails
                $c={$c}
                key={childrenType.gid}
                relType={childrenType}
              />
            ))}
        </ul>
      ) : null}
    </li>
  );
};

const RelationshipTypePairTree = ({
  $c,
  root,
}: RelationshipTypePairTreeProps): React.Element<typeof Layout> => {
  const childrenTypes = root.children || [];
  const type0 = root.type0;
  const type1 = root.type1;
  const formattedType0 = formatEntityTypeName(type0);
  const formattedType1 = formatEntityTypeName(type1);

  return (
    <Layout
      $c={$c}
      fullWidth
      noIcons
      title={texp.l(
        '{type0}-{type1} Relationship Types',
        {type0: formattedType0, type1: formattedType1},
      )}
    >
      {manifest.js('edit.js')}
      <div id="content">
        <RelationshipsHeader />

        <p>
          <small>
            <a href="/relationships">
              {expand2react(l('&lt; Back to all relationship types'))}
            </a>
          </small>
        </p>

        <h2>
          {exp.l(
            '{type0}-{type1} relationship types',
            {type0: formattedType0, type1: formattedType1},
          )}
        </h2>

        {isRelationshipEditor($c.user) ? (
          <p>
            <a href={'/relationships/' + type0 + '-' + type1 + '/create'}>
              {exp.l(
                'Create a new {type0}-{type1} relationship',
                {type0: formattedType0, type1: formattedType1},
              )}
            </a>
          </p>
        ) : null}

        {childrenTypes.length ? (
          <>
            <p>
              <a href="#" id="showAll">
                {l('Expand all descriptions')}
              </a>
              <a href="#" id="hideAll" style={{display: 'none'}}>
                {l('Collapse all descriptions')}
              </a>
            </p>

            <ul>
              {childrenTypes
                .slice(0)
                .sort(compareChildren)
                .map(childrenType => (
                  <RelationshipTypeDetails
                    $c={$c}
                    key={childrenType.gid}
                    relType={childrenType}
                  />
                ))}
            </ul>
          </>
        ) : (
          <p>
            {exp.l(
              'No {type0}-{type1} relationship types found.',
              {type0: formattedType0, type1: formattedType1},
            )}
          </p>
        )}
      </div>
    </Layout>
  );
};

export default RelationshipTypePairTree;
