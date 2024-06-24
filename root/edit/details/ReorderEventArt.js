/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReorderArt from './ReorderArt.js';

type Props = {
  +edit: ReorderEventArtEditT,
};

const ReorderEventArt = ({
  edit,
}: Props): React$Element<typeof ReorderArt> => (
  <ReorderArt
    archiveName="event"
    edit={edit}
    entityType="event"
    formattedEntityType={l('Event')}
  />
);

export default ReorderEventArt;
