/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import formatBarcode
  from '../../static/scripts/common/utility/formatBarcode.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';

type Props = {
  +edit: EditBarcodesEditT,
};

const EditBarcodes = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className="details edit-barcodes">
      {nonEmpty(display.client_version) ? (
        <tr>
          <th>{l('Client:')}</th>
          <td>{display.client_version}</td>
        </tr>
      ) : null}

      {display.submissions.map(submission => {
        const hasOldBarcodeProp = hasOwnProp(submission, 'old_barcode');
        const oldBarcode = submission.old_barcode;
        return (
          <>
            <tr>
              <th>{addColonText(l('Release'))}</th>
              <td colSpan="2">
                <DescriptiveLink entity={submission.release} />
              </td>
            </tr>
            {hasOldBarcodeProp && oldBarcode !== undefined ? (
              <Diff
                label={addColonText(l('Barcode'))}
                newText={formatBarcode(submission.new_barcode)}
                oldText={formatBarcode(oldBarcode)}
              />
            ) : (
              <tr>
                <th>{addColonText(l('Barcode'))}</th>
                <td colSpan="2">{formatBarcode(submission.new_barcode)}</td>
              </tr>
            )}
          </>
        );
      })}
    </table>
  );
};

export default EditBarcodes;
