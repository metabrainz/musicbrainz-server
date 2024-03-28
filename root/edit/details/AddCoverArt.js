/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AddArt from './AddArt.js';

type Props = {
  +edit: AddCoverArtEditT,
};

const AddCoverArt = ({edit}: Props): React$Element<typeof AddArt> => (
  <AddArt
    archiveName="cover"
    edit={edit}
    entityType="release"
    formattedEntityType={l('Release')}
  />
);

export default AddCoverArt;
