/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AreaLayout from '../area/AreaLayout.js';
import ArtistLayout from '../artist/ArtistLayout.js';
import CollectionLayout from '../collection/CollectionLayout.js';
import UserAccountLayout from '../components/UserAccountLayout.js';
import EventLayout from '../event/EventLayout.js';
import GenreLayout from '../genre/GenreLayout.js';
import InstrumentLayout from '../instrument/InstrumentLayout.js';
import LabelLayout from '../label/LabelLayout.js';
import PlaceLayout from '../place/PlaceLayout.js';
import RecordingLayout from '../recording/RecordingLayout.js';
import ReleaseLayout from '../release/ReleaseLayout.js';
import ReleaseGroupLayout from '../release_group/ReleaseGroupLayout.js';
import SeriesLayout from '../series/SeriesLayout.js';
import WorkLayout from '../work/WorkLayout.js';

const layoutPicker = {
  area: AreaLayout,
  artist: ArtistLayout,
  collection: CollectionLayout,
  editor: UserAccountLayout,
  event: EventLayout,
  genre: GenreLayout,
  instrument: InstrumentLayout,
  label: LabelLayout,
  place: PlaceLayout,
  recording: RecordingLayout,
  release: ReleaseLayout,
  release_group: ReleaseGroupLayout,
  series: SeriesLayout,
  work: WorkLayout,
};

export default function chooseLayoutComponent(
  typeName: string,
): React$ComponentType<{
  +children: React$Node,
  +entity: CentralEntityT | EditorT | CollectionT,
  +fullWidth?: boolean,
  +page?: string,
  +title: string,
}> {
  return layoutPicker[typeName];
}
