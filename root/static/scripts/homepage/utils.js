/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type EntityT = {
  name: N_l_T,
  statKey: string,
  value: string,
};

const entities: Array<EntityT> = [
  {name: N_l('Artist'), statKey: 'count.artist', value: 'artist'},
  {name: N_l('Event'), statKey: 'count.event', value: 'event'},
  {name: N_l('Release'), statKey: 'count.release', value: 'release'},
  {
    name: N_l('Release group'),
    statKey: 'count.releasegroup',
    value: 'release_group',
  },
  {
    name: N_l('Recording'),
    statKey: 'count.recording',
    value: 'recording',
  },
  {name: N_l('Series'), statKey: 'count.series', value: 'series'},
  {name: N_l('Work'), statKey: 'count.work', value: 'work'},
  {name: N_l('Area'), statKey: 'count.area', value: 'area'},
  {name: N_l('Instrument'), statKey: 'count.instrument', value: 'instrument'},
  {name: N_l('Label'), statKey: 'count.label', value: 'label'},
  {name: N_l('Place'), statKey: 'count.place', value: 'place'},
  {name: N_l('Annotation'), statKey: 'count.annotation', value: 'annotation'},
  {name: N_l('Tag'), statKey: 'count.tag', value: 'tag'},
  {name: N_l('CD Stub'), statKey: 'count.cdstub', value: 'cdstub'},
  {name: N_l('Editor'), statKey: 'count.editor', value: 'editor'},
];

export default entities;
