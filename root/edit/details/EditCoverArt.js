/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditArtwork from '../components/EditArtwork';
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';

type Props = {
  +edit: EditCoverArtEditT,
};

function displayCoverArtTypes(types) {
  if (types?.length) {
    return commaOnlyListText(types.map(
      type => lp_attributes(type.name, 'cover_art_type'),
    ));
  }
  return '';
}

const EditCoverArt = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const comment = display.comment;
  const types = display.types;

  return (
    <table className="details remove-cover-art">
      <tr>
        <th>{addColonText(l('Release'))}</th>
        <td colSpan="2">
          <DescriptiveLink entity={display.release} />
        </td>
      </tr>

      {nonEmpty(display.artwork.filename) ? (
        <tr>
          <th>{l('Filename:')}</th>
          <td colSpan="2">
            <code>
              {display.artwork.filename}
            </code>
          </td>
        </tr>
      ) : null}

      {types ? (
        <Diff
          label={l('Types:')}
          newText={displayCoverArtTypes(types.new)}
          oldText={displayCoverArtTypes(types.old)}
          split=", "
        />
      ) : null}

      {comment ? (
        <WordDiff
          label={l('Comment:')}
          newText={comment.new ?? ''}
          oldText={comment.old ?? ''}
        />
      ) : null}

      <EditArtwork
        artwork={display.artwork}
        colSpan={2}
        release={display.release}
      />
    </table>
  );
};

export default EditCoverArt;
