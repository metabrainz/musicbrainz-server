/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import RemoveArt from './RemoveArt.js';

component RemoveEventArt(edit: RemoveEventArtEditT) {
  return (
    <RemoveArt
      archiveName="event"
      edit={edit}
      entityType="event"
      formattedEntityType={l('Event')}
    />
  );
}

export default RemoveEventArt;
