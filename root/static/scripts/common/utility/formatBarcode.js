/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function formatBarcode(code) {
  if (code == null) {
    return '';
  }
  if (code === '') {
    return l('[none]');
  }
  return code;
}

export default formatBarcode;
