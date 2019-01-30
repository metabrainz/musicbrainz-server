/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AreaLayout from '../area/AreaLayout';
import ArtistLayout from '../artist/ArtistLayout';
import EventLayout from '../event/EventLayout';
import InstrumentLayout from '../instrument/InstrumentLayout';
import LabelLayout from '../label/LabelLayout';
import PlaceLayout from '../place/PlaceLayout';
import RecordingLayout from '../recording/RecordingLayout';
import ReleaseGroupLayout from '../release_group/ReleaseGroupLayout';
import ReleaseLayout from '../release/ReleaseLayout';
import SeriesLayout from '../series/SeriesLayout';

const layoutPicker = {
  area: AreaLayout,
  artist: ArtistLayout,
  event: EventLayout,
  instrument: InstrumentLayout,
  label: LabelLayout,
  place: PlaceLayout,
  recording: RecordingLayout,
  release_group: ReleaseGroupLayout,
  release: ReleaseLayout,
  series: SeriesLayout,
};

export default function chooseLayoutComponent(typeName: string) {
  return layoutPicker[typeName];
}
