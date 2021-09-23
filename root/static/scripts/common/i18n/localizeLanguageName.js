/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function localizeLanguageName(
  language: LanguageT | null,
  isWork?: boolean = false,
): string {
  if (!language) {
    return l('[removed]');
  }
  // For works, "No linguistic content" is meant as "No lyrics"
  if (isWork && language.iso_code_3 === 'zxx') {
    return l('[No lyrics]');
  }
  return l_languages(language.name);
}

export default localizeLanguageName;
