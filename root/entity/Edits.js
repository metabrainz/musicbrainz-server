/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import SubHeader from '../components/SubHeader.js';
import EditList from '../edit/components/EditList.js';
import Layout from '../layout/index.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import localizeTypeNameForEntity
  from '../static/scripts/common/i18n/localizeTypeNameForEntity.js';

type Props = {
  +editCountLimit: number,
  +edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  +entity: CoreEntityT | CollectionT,
  +pager: PagerT,
  +refineUrlArgs?: {+[argument: string]: string},
  +showingOpenOnly: boolean,
  +user: UnsanitizedEditorT,
};

const Edits = ({
  editCountLimit,
  edits,
  entity,
  pager,
  refineUrlArgs,
  showingOpenOnly,
}: Props): React.Element<typeof Layout> => {
  const entityTypeClass = entity.entityType === 'release_group'
    ? 'rg'
    : entity.entityType;
  const className = entityTypeClass + 'header';

  const titleName = entity.entityType === 'instrument'
    ? l_instruments(entity.name)
    : entity.entityType === 'url'
      ? entity.pretty_name
      : entity.name;

  const headingLink = entity.entityType === 'url'
    ? <EntityLink content={entity.decoded} entity={entity} />
    : <EntityLink entity={entity} />;

  const pageTitle = showingOpenOnly
    ? texp.l('Open Edits for {name}', {name: titleName})
    : texp.l('Edits for {name}', {name: titleName});

  const pageHeading = showingOpenOnly
    ? exp.l('Open Edits for {name}', {name: headingLink})
    : exp.l('Edits for {name}', {name: headingLink});

  const subHeadingTypeName = localizeTypeNameForEntity(entity);
  let pageSubHeading: Expand2ReactOutput = subHeadingTypeName;
  if (hasOwnProp(entity, 'artistCredit')) {
    // $FlowIgnore[prop-missing] as per hasOwnProp above
    const artistCredit = entity.artistCredit;
    if (!artistCredit) {
      throw new Error(
        'Missing artist credit: ' + JSON.stringify(entity),
      );
    }
    pageSubHeading = exp.l(
      '{entity_type} by {artist}',
      {
        artist: <ArtistCreditLink artistCredit={artistCredit} />,
        entity_type: subHeadingTypeName,
      },
    );
  }

  return (
    <Layout fullWidth title={pageTitle}>
      <div id="content">
        <div className={className}>
          <h1>{pageHeading}</h1>
          <SubHeader subHeading={pageSubHeading} />
        </div>
        <EditList
          editCountLimit={editCountLimit}
          edits={edits}
          entity={entity}
          guessSearch
          page={entity.entityType + '_' + (showingOpenOnly ? 'open' : 'all')}
          pager={pager}
          refineUrlArgs={refineUrlArgs}
        />
      </div>
    </Layout>
  );
};

export default Edits;
