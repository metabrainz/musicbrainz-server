/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const entities = [
  {name: 'Artist', statKey: 'count.artist', value: 'artist'},
  {name: 'Event', statKey: 'count.event', value: 'event'},
  {name: 'Release', statKey: 'count.release', value: 'release'},
  {
    name: 'Release group',
    statKey: 'count.releasegroup',
    value: 'release_group',
  },
  {
    name: 'Recording',
    statKey: 'count.recording',
    value: 'recording',
  },
  {name: 'Series', statKey: 'count.series', value: 'series'},
  {name: 'Work', statKey: 'count.work', value: 'work'},
  {name: 'Area', statKey: 'count.area', value: 'area'},
  {name: 'Instrument', statKey: 'count.instrument', value: 'instrument'},
  {name: 'Label', statKey: 'count.label', value: 'label'},
  {name: 'Place', statKey: 'count.place', value: 'place'},
  {name: 'Annotation', statKey: 'count.annotation', value: 'annotation'},
  {name: 'Tag', statKey: 'count.tag', value: 'tag'},
  {name: 'CD Stub', statKey: 'count.cdstub', value: 'cdstub'},
  {name: 'Editor', statKey: 'count.editor', value: 'editor'},
];

export default entities;
