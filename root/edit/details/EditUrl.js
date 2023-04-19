/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  EDIT_STATUS_OPEN,
} from '../../constants.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import DiffSide from '../../static/scripts/edit/components/edit/DiffSide.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import {DELETE, INSERT} from '../../static/scripts/edit/utility/editDiff.js';

type Props = {
  +edit: EditUrlEditT,
};

const EditUrl = ({edit}: Props): React$Element<typeof React.Fragment> => {
  const display = edit.display_data;
  const description = display.description;
  const uri = display.uri;
  const encodedUri = uri ? encodeURIComponent(uri.new) : null;

  return (
    <>
      <table className="details edit-url">
        <tr>
          <th>{addColonText(l('URL'))}</th>
          <td><EntityLink entity={display.url} /></td>
        </tr>
        {uri ? (
          <tr>
            <th>{addColonText(l('URL'))}</th>
            <td className="old">
              <a className="wrap-anywhere" href={uri.old}>
                <DiffSide
                  filter={DELETE}
                  newText={uri.new}
                  oldText={uri.old}
                />
              </a>
            </td>
            <td className="new">
              <a className="wrap-anywhere" href={uri.new}>
                <DiffSide
                  filter={INSERT}
                  newText={uri.new}
                  oldText={uri.old}
                />
              </a>
            </td>
          </tr>
        ) : null}
        {description ? (
          <WordDiff
            label={addColonText(l('Description'))}
            newText={description.new ?? ''}
            oldText={description.old ?? ''}
          />
        ) : null}
      </table>
      {display.affects > 1 ? (
        <p>
          {texp.ln('This change affects {num} relationship.',
                   'This change affects {num} relationships.',
                   display.affects,
                   {num: display.affects})}
        </p>
      ) : null}
      {nonEmpty(encodedUri) && display.isMerge ? (
        <p>
          {edit.status === EDIT_STATUS_OPEN ? (
            l(`The new URL already exists in the database.
               This edit will therefore merge the two URL entities.`)
          ) : (
            l('This edit was a merge.')
          )}
          {' '}
          <a href={`/otherlookup/url?other-lookup.url=${encodedUri}`}>
            {l('Search for the target URL.')}
          </a>
        </p>
      ) : null}
    </>
  );
};

export default EditUrl;
