/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DBDefs from '../../static/scripts/common/DBDefs.mjs';

type Props = {
  +edit: ChangeWikiDocEditT,
};

const ChangeWikiDoc = ({
  edit,
}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const page = display.page;
  const oldVersion = display.old_version;
  const newVersion = display.new_version;
  const basePath = DBDefs.WIKITRANS_SERVER;
  const baseLink =
    `//${basePath}/index.php?title=${encodeURIComponent(page)}`;
  const oldLink = oldVersion == null
    ? null
    : baseLink + `&oldid=${oldVersion}`;
  const newLink = newVersion == null
    ? null
    : baseLink + `&oldid=${newVersion}`;
  const diffLink = (oldVersion == null || newVersion == null)
    ? null
    : baseLink + `&diff=${newVersion}&oldid=${oldVersion}`;

  return (
    <table className="details change-wikidoc">
      <tr>
        <th>{l('WikiDoc:')}</th>
        <td>
          <a href={`/doc/${page}`}>
            {page}
          </a>
        </td>
      </tr>

      <tr>
        <th>{l('Old version:')}</th>
        {oldVersion == null ? (
          <td className="new">{l('New page')}</td>
        ) : (
          <td className="old">
            <a href={oldLink}>
              {oldVersion}
            </a>
          </td>
        )}
      </tr>

      <tr>
        <th>{l('New version:')}</th>
        {newVersion == null ? (
          <td className="old">{l('Page removed')}</td>
        ) : (
          <td className="new">
            <a href={newLink}>
              {newVersion}
            </a>
          </td>
        )}
      </tr>

      {oldVersion != null && newVersion != null ? (
        <tr>
          <th>{addColonText(l('Diff'))}</th>
          <td>
            <a href={diffLink}>
              {l('View diff')}
            </a>
          </td>
        </tr>
      ) : null}
    </table>
  );
};

export default ChangeWikiDoc;
