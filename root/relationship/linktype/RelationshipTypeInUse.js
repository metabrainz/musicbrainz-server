/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';

type Props = {
  +type: LinkTypeT,
};

const RelationshipTypeInUse = ({
  type,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title="Relationship type in use">
    <div className="content">
      <h1>{'Relationship type in use'}</h1>
      <p>
        {texp.l_admin(
          `The relationship type “{type}” can’t be removed
           because it’s still in use.`,
          {type: type.name},
        )}
      </p>
    </div>
  </Layout>
);

export default RelationshipTypeInUse;
