/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistLayout from '../artist/ArtistLayout';
import LabelLayout from '../label/LabelLayout';
import PlaceLayout from '../place/PlaceLayout';
import ReleaseGroupLayout from '../release_group/ReleaseGroupLayout';
import SeriesLayout from '../series/SeriesLayout';

const layoutPicker = {
  artist: ArtistLayout,
  label: LabelLayout,
  place: PlaceLayout,
  release_group: ReleaseGroupLayout,
  series: SeriesLayout,
};

export default function chooseLayoutComponent(typeName: string) {
  return layoutPicker[typeName];
}
