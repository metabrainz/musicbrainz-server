/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink.js';

component ReorderMediums(edit: ReorderMediumsEditT) {
  const display = edit.display_data;
  let isFirstMediumChange = true;

  return (
    <table className="details reorder-mediums">
      {edit.preview /*:: === true */ ? null : (
        <tr>
          <th>{addColonText(l('Release'))}</th>
          <td colSpan={2}>
            <DescriptiveLink entity={display.release} />
          </td>
        </tr>
      )}

      {display.mediums.map((mediumEdit, index) => {
        if (mediumEdit.new === mediumEdit.old) {
          return null;
        }

        const showHeader = isFirstMediumChange;
        isFirstMediumChange = false;
        return (
          <tr key={'medium-change-' + index}>
            <th>
              {showHeader ? addColonText(l('Mediums')) : null}
            </th>
            <td>
              {nonEmpty(mediumEdit.title) && mediumEdit.old === 'new' ? (
                exp.l(`Medium <span class="new">{new}</span>: {title}
                       (new medium)`,
                      {new: mediumEdit.new, title: mediumEdit.title})
              ) : nonEmpty(mediumEdit.title) ? (
                exp.l(`Medium <span class="new">{new}</span>: {title}
                       (moved from position <span class="old">{old}</span>)`,
                      {
                        new: mediumEdit.new,
                        old: mediumEdit.old,
                        title: mediumEdit.title,
                      })
              ) : mediumEdit.old === 'new' ? (
                exp.l('Medium <span class="new">{new}</span> (new medium)',
                      {new: mediumEdit.new})
              ) : (
                exp.l(`Medium <span class="new">{new}</span>
                       (moved from position <span class="old">{old}</span>)`,
                      {new: mediumEdit.new, old: mediumEdit.old})
              )}
            </td>
          </tr>
        );
      })}
    </table>
  );
}

export default ReorderMediums;
