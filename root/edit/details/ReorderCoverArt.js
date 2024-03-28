/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReorderArt from './ReorderArt.js';

type Props = {
  +edit: ReorderCoverArtEditT,
};

const ReorderCoverArt = ({
  edit,
}: Props): React$Element<typeof ReorderArt> => (
  <ReorderArt
    archiveName="cover"
    edit={edit}
    entityType="release"
    formattedEntityType={l('Release')}
  />
);

export default ReorderCoverArt;
