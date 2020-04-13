/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportReleaseT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

type Props = {|
  +items: $ReadOnlyArray<ReportReleaseT>,
  +pager: PagerT,
  +showLanguageAndScript?: boolean,
|};

const ReleaseList = ({
  items,
  pager,
  showLanguageAndScript,
}: Props) => {
  const colSpan = showLanguageAndScript ? 3 : 2;

  return (
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Release')}</th>
            <th>{l('Artist')}</th>
            {showLanguageAndScript ? <th>{l('Language/Script')}</th> : null}
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => {
            const language = item.release?.language;
            const script = item.release?.script;
            return (
              <tr className={loopParity(index)} key={item.release_id}>
                {item.release ? (
                  <>
                    <td>
                      <EntityLink entity={item.release} />
                    </td>
                    <td>
                      <ArtistCreditLink
                        artistCredit={item.release.artistCredit}
                      />
                    </td>
                    {showLanguageAndScript ? (
                      <td>
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
                      </td>
                    ) : null}
                  </>
                ) : (
                  <td colSpan={colSpan}>
                    {l('This release no longer exists.')}
                  </td>
                )}
              </tr>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  );
};

export default ReleaseList;
