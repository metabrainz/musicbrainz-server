/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';

type Props = {
  +edit: EditGenreEditT,
};

const EditGenre = ({edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const comment = display.comment;
  const name = display.name;

  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Genre'))}</th>
            <td><DescriptiveLink entity={display.genre} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details edit-genre">
        <tbody>
          {name ? (
            <WordDiff
              label={addColonText(l('Name'))}
              newText={name.new}
              oldText={name.old}
            />
          ) : null}
          {comment ? (
            <WordDiff
              label={addColonText(l('Disambiguation'))}
              newText={comment.new ?? ''}
              oldText={comment.old ?? ''}
            />
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default EditGenre;
