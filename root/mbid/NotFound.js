/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import NotFound from '../components/NotFound.js';

component MbidNotFound(isGuid: boolean, mbid?: string,
) {
  return (
    <NotFound title={isGuid ? l('MBID not found') : l('Invalid MBID')}>
      <p>
        {nonEmpty(mbid) && isGuid ? (
          exp.l(
            `No MusicBrainz {entity_doc|entities} match the {mbid_doc|MBID}
             {mbid}. Either it’s incorrect, it was for an entity that has
             since been removed, or it is an ID for something else than an
             entity (for example, a {rel_type_table|relationship type}).`,
            {
              entity_doc: '/doc/MusicBrainz_Entity',
              mbid: mbid,
              mbid_doc: '/doc/MusicBrainz_Identifier',
              rel_type_table: '/relationships',
            },
          )
        ) : (
          nonEmpty(mbid) ? (
            exp.l(
              '{mbid} is not a valid {mbid_doc|MBID}.',
              {
                mbid: mbid,
                mbid_doc: '/doc/MusicBrainz_Identifier',
              },
            )
          ) : (
            exp.l(
              'No {mbid_doc|MBID} selected.',
              {mbid_doc: '/doc/MusicBrainz_Identifier'},
            )

          )
        )}
      </p>
    </NotFound>
  );
}

export default MbidNotFound;
