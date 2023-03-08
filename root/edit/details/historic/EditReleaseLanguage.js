/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {HistoricReleaseListContent}
  from '../../components/HistoricReleaseList.js';

type Props = {
  +edit: EditReleaseLanguageHistoricEditT,
};

const EditReleaseLanguage = ({edit}: Props): React$Element<'table'> => (
  <table className="details edit-release">
    <tr>
      <th>{l('Old:')}</th>
      <td>
        <table>
          {edit.display_data.old.map((change, index) => (
            <tr key={index}>
              <td className="old">
                {texp.l(
                  'Language: {language}, script: {script}',
                  {
                    language: change.language
                      ? l_languages(change.language.name)
                      : '?',
                    script: change.script
                      ? l_scripts(change.script.name)
                      : '?',
                  },
                )}
              </td>
              <td>
                <HistoricReleaseListContent releases={change.releases} />
              </td>
            </tr>
          ))}
        </table>
      </td>
    </tr>

    <tr>
      <th>{l('New language:')}</th>
      <td className="new">
        {edit.display_data.language
          ? l_languages(edit.display_data.language.name)
          : '?'}
      </td>
    </tr>

    <tr>
      <th>{l('New script:')}</th>
      <td className="new">
        {edit.display_data.script
          ? l_scripts(edit.display_data.script.name)
          : '?'}
      </td>
    </tr>
  </table>
);

export default EditReleaseLanguage;
