/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationships from '../components/Relationships';
import Annotation from '../static/scripts/common/components/Annotation';
import TagLink from '../static/scripts/common/components/TagLink';
import * as manifest from '../static/manifest';

import MoodLayout from './MoodLayout';

type Props = {
  +mood: MoodT,
  +numberOfRevisions: number,
};

const MoodIndex = ({
  mood,
  numberOfRevisions,
}: Props): React.Element<typeof MoodLayout> => (
  <MoodLayout
    entity={mood}
    page="index"
    title={l('Mood information')}
  >
    <h2>{l('Associated tags')}</h2>
    <table className="details">
      <tr>
        <th>{addColonText(l('Primary tag'))}</th>
        <td><TagLink tag={mood.name} /></td>
      </tr>
    </table>
    <Annotation
      annotation={mood.latest_annotation}
      collapse
      entity={mood}
      numberOfRevisions={numberOfRevisions}
    />
    <Relationships source={mood} />
    {manifest.js('mood/index', {async: 'async'})}
  </MoodLayout>
);

export default MoodIndex;
