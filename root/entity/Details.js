/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ENTITIES} from '../static/scripts/common/constants.js';
import DBDefs from '../static/scripts/common/DBDefs.mjs';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';
import formatUserDate from '../utility/formatUserDate.js';

type WSLinkProps = {
  +entityGid: string,
  +entityProperties: {
    aliases: {[edit_type: string]: number},
    artist_credits: boolean,
    url: string,
    ...
  },
  +entityType: CoreEntityTypeT,
  +isJson?: boolean,
  +isSecureConnection: boolean,
};
type DetailsProps = {
  +$c: CatalystContextT,
  +entity: CoreEntityT,
};

const WSLink = ({
  entityGid,
  entityProperties,
  entityType,
  isJson = false,
  isSecureConnection,
}: WSLinkProps) => {
  const inc = [];
  const entityTypeForUrl = entityProperties.url
    ? entityProperties.url : entityType;
  if (entityProperties.aliases) {
    inc.push('aliases');
  }
  if (entityProperties.artist_credits) {
    inc.push('artist-credits');
  }
  if (entityType === 'recording' || entityType === 'release_group') {
    inc.push('releases');
  }
  if (entityType === 'release') {
    inc.push('labels', 'discids', 'recordings');
  }
  const searchParams = new URLSearchParams();
  if (inc.length) {
    searchParams.set('inc', inc.join('+'));
  }
  if (isJson) {
    searchParams.set('fmt', 'json');
  }
  const protocol = isSecureConnection ? 'https://' : 'http://';
  const urlObject = new URL(protocol + DBDefs.WEB_SERVER +
                            '/ws/2/' + entityTypeForUrl + '/' + entityGid);
  urlObject.search = searchParams.toString();

  return (
    <a href={urlObject.href}>{urlObject.href}</a>
  );
};

const Details = ({
  $c,
  entity,
}: DetailsProps): React.MixedElement => {
  const entityType = entity.entityType;
  const entityProperties = ENTITIES[entityType];
  const entityTypeForUrl = entityProperties.url
    ? entityProperties.url : entityType;
  const canonicalLink = DBDefs.CANONICAL_SERVER +
    '/' + entityTypeForUrl + '/' + entity.gid;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent
      entity={entity}
      page="details"
      title={l('Details')}
    >
      <h2>{l('Details')}</h2>
      <table className="details">
        <tr>
          <th>{addColonText(l('Name'))}</th>
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
          <th>{addColonText(l('Last updated'))}</th>
          <td>
            {nonEmpty(entity.last_updated)
              ? formatUserDate($c, entity.last_updated)
              : lp('(unknown)', 'last updated')}
          </td>
        </tr>
        <tr>
          <th>{l('Permanent link:')}</th>
          <td>
            <a href={canonicalLink}>{canonicalLink}</a>
          </td>
        </tr>
        <tr>
          <th>
            {addColon(exp.l(
              '{xml_ws_docs|XML}',
              {xml_ws_docs: '/doc/MusicBrainz_API'},
            ))}
          </th>
          <td>
            <WSLink
              entityGid={entity.gid}
              entityProperties={entityProperties}
              entityType={entityType}
              isSecureConnection={$c.req.secure}
            />
          </td>
        </tr>
        <tr>
          <th>
            {addColon(exp.l(
              '{json_ws_docs|JSON}',
              {json_ws_docs: '/doc/MusicBrainz_API'},
            ))}
          </th>
          <td>
            <WSLink
              entityGid={entity.gid}
              entityProperties={entityProperties}
              entityType={entityType}
              isJson
              isSecureConnection={$c.req.secure}
            />
          </td>
        </tr>
      </table>
    </LayoutComponent>
  );
};

export default Details;
