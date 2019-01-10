/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {ENTITIES} from '../static/scripts/common/constants';
import DBDefs from '../static/scripts/common/DBDefs';
import {withCatalystContext} from '../context';
import {l, lp} from '../static/scripts/common/i18n';
import EntityLink from '../static/scripts/common/components/EntityLink';
import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import formatUserDate from '../utility/formatUserDate';

type Props = {|
  +$c: CatalystContextT,
  +canonicalURL: string,
  +entity: CoreEntityT,
  +lastUpdated: string,
|};

const XMLLink = ({entityGid, entityProperties, entityType}) => {
  const xmlInc = [];
  const entityTypeForUrl = entityProperties.url ? entityProperties.url : entityType;
  entityProperties.aliases && xmlInc.push('aliases');
  entityProperties.artist_credits && xmlInc.push('artist-credits');
  (entityType === 'recording' || entityType === 'release_group') && xmlInc.push('releases');
  entityType === 'release' && xmlInc.push('labels', 'discids', 'recordings');
  const link = '/ws/2/' + entityTypeForUrl + '/' + entityGid + '?inc=' + xmlInc.sort().join('+');
  return (
    <a href={link}>{'https://' + DBDefs.WEB_SERVER + link}</a>
  );
};

const Details = ({
  $c,
  canonicalURL,
  entity,
  lastUpdated,
}: Props) => {
  const entityType = entity.entityType;
  const entityProperties = ENTITIES[entityType];
  const entityTypeForUrl = entityProperties.url ? entityProperties.url : entityType;
  const canonicalLink = DBDefs.CANONICAL_SERVER + '/' + entityTypeForUrl + '/' + entity.gid;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent canonicalURL={canonicalURL} page="details" releaseGroup={entity} title={l('Details')}>
      <h2>{l('Details')}</h2>
      <table className="details">
        <tr>
          <th>{l('Name:')}</th>
          <td>
            <EntityLink entity={entity} />
          </td>
        </tr>
        <tr>
          <th>{l('{mbid|<abbr title="MusicBrainz Identifier">MBID</abbr>}:',
            {__react: true, mbid: '/doc/MusicBrainz_Identifier'})}
          </th>
          <td><code>{entity.gid}</code></td>
        </tr>
        <tr>
          <th>{l('Last updated:')}</th>
          <td>{lastUpdated ? formatUserDate($c.user, lastUpdated) : l('(unknown)')}
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
            <XMLLink entityGid={entity.gid} entityProperties={entityProperties} entityType={entityType} />
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
