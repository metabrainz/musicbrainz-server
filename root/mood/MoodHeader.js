/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityHeader from '../components/EntityHeader';
import EntityLink from '../static/scripts/common/components/EntityLink';

type Props = {
  mood: MoodT,
  page: string,
};

const MoodHeader = ({
  mood,
  page,
}: Props): React.Element<typeof EntityHeader> => (
  <EntityHeader
    entity={mood}
    headerClass="moodheader"
    heading={
      <EntityLink entity={mood} />
    }
    page={page}
    subHeading={l('Mood')}
  />
);

export default MoodHeader;
