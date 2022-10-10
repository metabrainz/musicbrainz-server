/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink.js';
import {DeletedLink}
  from '../../static/scripts/common/components/EntityLink.js';
import ExpandedArtistCredit from
  '../../static/scripts/common/components/ExpandedArtistCredit.js';
import formatBarcode
  from '../../static/scripts/common/utility/formatBarcode.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';
import FullChangeDiff
  from '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import ReleaseEventsDiff
  from '../../static/scripts/edit/components/edit/ReleaseEventsDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';

type Props = {
  +edit: EditReleaseEditT,
};

const EditRelease = ({edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const name = display.name;
  const artistCredit = display.artist_credit;
  const releaseGroup = display.release_group;
  const comment = display.comment;
  const language = display.language;
  const packaging = display.packaging;
  const script = display.script;
  const status = display.status;
  const barcode = display.barcode;
  const releaseEvents = display.events;

  return (
    <table className="details edit-release">
      {edit.preview /*:: === true */ ? null : (
        <tr>
          <th>{l('Release:')}</th>
          <td colSpan="2">
            {display.release
              ? <DescriptiveLink entity={display.release} />
              : null}
          </td>
        </tr>
      )}

      {name ? (
        <WordDiff
          label={addColonText(l('Name'))}
          newText={name.new}
          oldText={name.old}
        />
      ) : null}

      {artistCredit ? (
        <tr>
          <th>{addColonText(l('Artist'))}</th>
          <td className="old">
            <ExpandedArtistCredit
              artistCredit={artistCredit.old}
            />
          </td>
          <td className="new">
            <ExpandedArtistCredit
              artistCredit={artistCredit.new}
            />
          </td>
        </tr>
      ) : null}

      {releaseGroup ? (
        <FullChangeDiff
          label={addColonText(l('Release group'))}
          newContent={releaseGroup.new
            ? <DescriptiveLink entity={releaseGroup.new} />
            : <DeletedLink allowNew={false} name={null} />}
          oldContent={releaseGroup.old
            ? <DescriptiveLink entity={releaseGroup.old} />
            : <DeletedLink allowNew={false} name={null} />}
        />
      ) : null}

      {comment ? (
        <WordDiff
          label={addColonText(l('Disambiguation'))}
          newText={comment.new ?? ''}
          oldText={comment.old ?? ''}
        />
      ) : null}

      {status ? (
        <FullChangeDiff
          label={lp('Status:', 'release status')}
          newContent={status.new?.name
            ? lp_attributes(status.new.name, 'release_status')
            : ''}
          oldContent={status.old?.name
            ? lp_attributes(status.old.name, 'release_status')
            : ''}
        />
      ) : null}

      {language ? (
        <FullChangeDiff
          label={addColonText(l('Language'))}
          newContent={language.new?.name
            ? l_languages(language.new.name)
            : ''}
          oldContent={language.old?.name
            ? l_languages(language.old.name)
            : ''}
        />
      ) : null}

      {script ? (
        <FullChangeDiff
          label={addColonText(l('Script'))}
          newContent={script.new?.name
            ? l_scripts(script.new.name)
            : ''}
          oldContent={script.old?.name
            ? l_scripts(script.old.name)
            : ''}
        />
      ) : null}

      {packaging ? (
        <FullChangeDiff
          label={addColonText(l('Packaging'))}
          newContent={packaging.new?.name
            ? l_scripts(packaging.new.name)
            : ''}
          oldContent={packaging.old?.name
            ? l_scripts(packaging.old.name)
            : ''}
        />
      ) : null}

      {barcode ? (
        <Diff
          label={addColonText(l('Barcode'))}
          newText={formatBarcode(barcode.new)}
          oldText={formatBarcode(barcode.old)}
        />
      ) : null}

      {releaseEvents ? (
        <ReleaseEventsDiff
          newEvents={releaseEvents.new}
          oldEvents={releaseEvents.old}
        />
      ) : null}

      {display.update_tracklists /*:: === true */ ? (
        <tr>
          <th>{addColonText(l('Note'))}</th>
          <td>{l('This edit also changed the track artists.')}</td>
        </tr>
      ) : null}
    </table>
  );
};

export default EditRelease;
