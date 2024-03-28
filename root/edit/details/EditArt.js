/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import EditArtwork from '../components/EditArtwork.js';

type Props = {
  +archiveName: 'cover' | 'event',
  +edit:
    | EditCoverArtEditT
    | EditEventArtEditT,
  +entityType: 'event' | 'release',
  +formattedEntityType: string,
};

function displayArtTypes(
  types: $ReadOnlyArray<CoverArtTypeT | EventArtTypeT>,
  archiveName: 'cover' | 'event',
) {
  if (types?.length) {
    return commaOnlyListText(types.map(
      type => lp_attributes(type.name, archiveName + '_art_type'),
    ));
  }
  return '';
}

const EditArt = ({
  archiveName,
  edit,
  entityType,
  formattedEntityType,
}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const comment = display.comment;
  const types = display.types;

  return (
    <table className={'details remove-' + archiveName + '-art'}>
      <tr>
        <th>{addColonText(formattedEntityType)}</th>
        <td colSpan="2">
          {/* $FlowIgnore[prop-missing] */}
          <DescriptiveLink entity={display[entityType]} />
        </td>
      </tr>

      {nonEmpty(display.artwork.filename) ? (
        <tr>
          <th>{addColonText(l('Filename'))}</th>
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
          newText={displayArtTypes(types.new, archiveName)}
          oldText={displayArtTypes(types.old, archiveName)}
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
        // $FlowIgnore[prop-missing]
        entity={display[entityType]}
      />
    </table>
  );
};

export default EditArt;
