/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {ENTITIES} from '../static/scripts/common/constants';
import DBDefs from '../static/scripts/common/DBDefs';
import {withCatalystContext} from '../context';
import EntityLink from '../static/scripts/common/components/EntityLink';
import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import formatUserDate from '../utility/formatUserDate';

type Props = {|
  +$c: CatalystContextT,
  +entity: CoreEntityT,
|};

const XMLLink = ({
  entityGid,
  entityProperties,
  entityType,
  isSecureConnection,
}) => {
  const xmlInc = [];
  const entityTypeForUrl = entityProperties.url
    ? entityProperties.url : entityType;
  entityProperties.aliases && xmlInc.push('aliases');
  entityProperties.artist_credits && xmlInc.push('artist-credits');
  (entityType === 'recording' || entityType === 'release_group') && xmlInc.push('releases');
  entityType === 'release' && xmlInc.push('labels', 'discids', 'recordings');
  const protocol = isSecureConnection ? 'https://' : 'http://';
  const link = '/ws/2/' + entityTypeForUrl + '/' + entityGid + '?inc=' + xmlInc.join('+');
  return (
    <a href={link}>{protocol + DBDefs.WEB_SERVER + link}</a>
  );
};

const Details = ({
  $c,
  entity,
}: Props) => {
  const entityType = entity.entityType;
  const entityProperties = ENTITIES[entityType];
  const entityTypeForUrl = entityProperties.url
    ? entityProperties.url : entityType;
  const canonicalLink = DBDefs.CANONICAL_SERVER +
    '/' + entityTypeForUrl + '/' + entity.gid;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent entity={entity} page="details" title={l('Details')}>
      <h2>{l('Details')}</h2>
      <table className="details">
        <tr>
          <th>{l('Name:')}</th>
          <td>
            <EntityLink entity={entity} />
          </td>
        </tr>
        <tr>
          <th>
            {exp.l('{mbid|<abbr title="MusicBrainz Identifier">MBID</abbr>}:',
              {mbid: '/doc/MusicBrainz_Identifier'})}
          </th>
          <td><code>{entity.gid}</code></td>
        </tr>
        <tr>
          <th>{l('Last updated:')}</th>
          <td>
            {entity.last_updated ? formatUserDate($c.user, entity.last_updated) : l('(unknown)')}
          </td>
        </tr>
        <tr>
          <th>{l('Permanent link:')}</th>
          <td>
            <a href={canonicalLink}>{canonicalLink}</a>
          </td>
        </tr>
        <tr>
          <th>{l('XML:')}</th>
          <td>
            <XMLLink
              entityGid={entity.gid}
              entityProperties={entityProperties}
              entityType={entityType}
              isSecureConnection={$c.req.secure}
            />
          </td>
        </tr>
        {entityType === 'recording' ? (
          <tr>
            <th>{l('AcousticBrainz entry:')}</th>
            <td>
              <a href={'https://acousticbrainz.org/' + entity.gid}>{'https://acousticbrainz.org/' + entity.gid}</a>
            </td>
          </tr>
        ) : null}
      </table>
    </LayoutComponent>
  );
};

export default withCatalystContext(Details);
