/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function artistBeginAreaLabel(typeId: ?number): string {
  return match (typeId) {
    1 => l('Born in:'),
    2 | 5 | 6 => addColonText(lp('Founded in', 'group artist')),
    4 => addColonText(lp('Created in', 'character artist')),
    _ => addColonText(l('Begin area')),
  };
}

export function artistBeginLabel(typeId: ?number): string {
  return match (typeId) {
    1 => l('Born:'),
    2 | 5 | 6 => addColonText(lp('Founded', 'group artist')),
    4 => addColonText(lp('Created', 'character artist')),
    _ => addColonText(l('Begin date')),
  };
}

export function artistEndAreaLabel(typeId: ?number): string {
  return match (typeId) {
    1 => l('Died in:'),
    2 | 5 | 6 => addColonText(lp('Dissolved in', 'group artist')),
    _ => addColonText(l('End area')),
  };
}

export function artistEndLabel(
  typeId: ?number,
  future: boolean = false,
): string {
  return match ([typeId, future]) {
    [1, true | false] => l('Died:'),
    [2 | 5 | 6, true] => addColonText(lp('Dissolving', 'group artist')),
    [2 | 5 | 6, false] => addColonText(lp('Dissolved', 'group artist')),
    _ => addColonText(l('End date')),
  };
}
