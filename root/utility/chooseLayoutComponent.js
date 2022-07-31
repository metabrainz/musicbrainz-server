/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AreaLayout from '../area/AreaLayout';
import ArtistLayout from '../artist/ArtistLayout';
import CollectionLayout from '../collection/CollectionLayout';
import EventLayout from '../event/EventLayout';
import GenreLayout from '../genre/GenreLayout';
import InstrumentLayout from '../instrument/InstrumentLayout';
import LabelLayout from '../label/LabelLayout';
import MoodLayout from '../mood/MoodLayout';
import PlaceLayout from '../place/PlaceLayout';
import RecordingLayout from '../recording/RecordingLayout';
import ReleaseGroupLayout from '../release_group/ReleaseGroupLayout';
import ReleaseLayout from '../release/ReleaseLayout';
import SeriesLayout from '../series/SeriesLayout';
import UserAccountLayout from '../components/UserAccountLayout';
import WorkLayout from '../work/WorkLayout';

const layoutPicker = {
  area: AreaLayout,
  artist: ArtistLayout,
  collection: CollectionLayout,
  editor: UserAccountLayout,
  event: EventLayout,
  genre: GenreLayout,
  instrument: InstrumentLayout,
  label: LabelLayout,
  mood: MoodLayout,
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
  +entity: CoreEntityT | EditorT | CollectionT,
  +fullWidth?: boolean,
  +page?: string,
  +title: string,
}> {
  return layoutPicker[typeName];
}
