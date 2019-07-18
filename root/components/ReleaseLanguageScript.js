/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const ReleaseLanguageScript = ({
  release,
}: {release: ReleaseT}): React.Element<typeof React.Fragment> => {
  const language = release.language;
  const script = release.script;

  return (
    <>
      {language ? (
        <abbr title={l_languages(language.name)}>
          {language.iso_code_3}
        </abbr>
      ) : lp('-', 'missing data')}
      {' / '}
      {script ? (
        <abbr title={l_scripts(script.name)}>
          {script.iso_code}
        </abbr>
      ) : lp('-', 'missing data')}
    </>
  );
}

export default ReleaseLanguageScript;
