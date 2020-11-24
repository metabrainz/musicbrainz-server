/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityTabLink from '../components/EntityTabLink';
import SubHeader from '../components/SubHeader';
import Tabs from '../components/Tabs';
import EditorLink from '../static/scripts/common/components/EditorLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import bracketed from '../static/scripts/common/utility/bracketed';

type Props = {
  +$c: CatalystContextT,
  +collection: CollectionT,
  +page: string,
};

const CollectionHeader = ({
  $c,
  collection,
  page,
}: Props): React.Element<typeof React.Fragment> => {
  const owner = collection.editor;
  const viewingOwnCollection = Boolean(
    $c.user && owner && owner.id === $c.user.id,
  );
  const subHeading = (
    <>
      {collection.public ? (
        exp.l('Public collection by {owner}',
              {owner: <EditorLink editor={owner} />})
      ) : (
        exp.l('Private collection by {owner}',
              {owner: <EditorLink editor={owner} />})
      )}
      {owner ? (
        <span className="small">
          {' '}
          {bracketed(
            <a
              href={
                '/user/' +
                encodeURIComponent(owner.name) +
                '/collections'
              }
            >
              {viewingOwnCollection ? (
                l('See all of your collections')
              ) : (
                texp.l("See all of {editor}'s public collections",
                       {editor: owner.name})
              )}
            </a>,
          )}
        </span>
      ) : null}
    </>
  );
  return (
    <>
      <div className="collectionheader">
        <h1>
          <EntityLink entity={collection} />
        </h1>
        <SubHeader subHeading={subHeading} />
      </div>

      <Tabs>
        <EntityTabLink
          content={l('Overview')}
          entity={collection}
          key=""
          selected={'index' === page}
          subPath=""
        />
        {viewingOwnCollection ? (
          <>
            <EntityTabLink
              content={l('Edit')}
              entity={collection}
              key="own_collection/edit"
              selected={'edit' === page}
              subPath="own_collection/edit"
            />
            <EntityTabLink
              content={l('Remove')}
              entity={collection}
              key="own_collection/delete"
              selected={'delete' === page}
              subPath="own_collection/delete"
            />
          </>
        ) : null}
      </Tabs>
    </>
  );
};

export default CollectionHeader;
