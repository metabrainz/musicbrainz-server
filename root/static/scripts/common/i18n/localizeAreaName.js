/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function localizeAreaName(area: AreaT): string {
  /*
   * Areas with iso_3166_1 codes are the ones we export for translation
   * in the countries domain. See po/extract_pot_db.
   */
  if (area.iso_3166_1_codes.length) {
    return l_countries(area.name);
  }
  return area.name;
}

export default localizeAreaName;
