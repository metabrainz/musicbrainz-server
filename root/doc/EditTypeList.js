/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import {compare} from '../static/scripts/common/i18n.js';

type EditTypesByCategoryT = {
  +[editCategory: string]: $ReadOnlyArray<{
    +id: number,
    +l_edit_name: string,
  }>,
};

// We want Historic to be sorted last, but otherwise alphabetical order
function cmpCategories(a: string, b: string) {
  if (a === l('Historic')) {
    return 1;
  }
  if (b === l('Historic')) {
    return -1;
  }
  return compare(a, b);
}

component EditTypeList(editTypesByCategory: EditTypesByCategoryT) {
  const sortedCategories =
    Object.keys(editTypesByCategory).sort(cmpCategories);
  return (
    <Layout fullWidth noIcons title={lp('Edit types', 'noun')}>
      <div className="wikicontent" id="content">
        <h1>{lp('Edit types', 'noun')}</h1>

        {sortedCategories.map(category => {
          const editTypes = editTypesByCategory[category];
          return (
            <>
              <h2>{category}</h2>
              <ul>
                {editTypes.map(editType => (
                  <li key={editType.id}>
                    <a href={`/doc/Edit_Types/${editType.id}`}>
                      {editType.l_edit_name}
                    </a>
                  </li>
                ))}
              </ul>
            </>
          );
        })}
      </div>
    </Layout>
  );
}

export default EditTypeList;
