/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function artistBeginAreaLabel(typeId: ?number) {
  switch (typeId) {
    case 1:
      return l('Born in:');
    case 2:
    case 5:
    case 6:
      return l('Founded in:');
    default:
      return l('Begin area:');
  }
}

export function artistBeginLabel(typeId: ?number) {
  switch (typeId) {
    case 1:
      return l('Born:');
    case 2:
    case 5:
    case 6:
      return l('Founded:');
    default:
      return l('Begin date:');
  }
}

export function artistEndAreaLabel(typeId: ?number) {
  switch (typeId) {
    case 1:
      return l('Died in:');
    case 2:
    case 5:
    case 6:
      return l('Dissolved in:');
    default:
      return l('End area:');
  }
}

export function artistEndLabel(typeId: ?number) {
  switch (typeId) {
    case 1:
      return l('Died:');
    case 2:
    case 5:
    case 6:
      return l('Dissolved:');
    default:
      return l('End date:');
  }
}
