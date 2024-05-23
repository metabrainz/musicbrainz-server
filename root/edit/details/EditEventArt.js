/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EditArt from './EditArt.js';

type Props = {
  +edit: EditEventArtEditT,
};

const EditEventArt = ({
  edit,
}: Props): React$Element<typeof EditArt> => (
  <EditArt
    archiveName="event"
    edit={edit}
    entityType="event"
    formattedEntityType={l('Event')}
  />
);

export default EditEventArt;
