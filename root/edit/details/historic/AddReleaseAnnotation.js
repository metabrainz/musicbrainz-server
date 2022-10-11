/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import HistoricReleaseList from '../../components/HistoricReleaseList.js';

type Props = {
  +edit: AddReleaseAnnotationHistoricEditT,
};

const AddReleaseAnnotation = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className="details add-release-annotation">
      <HistoricReleaseList
        releases={display.releases}
      />
      <tr>
        <th>{addColonText(l('Text'))}</th>
        <td>
          {display.html
            ? (
              <span
                dangerouslySetInnerHTML={{__html: display.html}}
              />
            ) : (
              <p>
                <span className="comment">
                  {l('This annotation is empty.')}
                </span>
              </p>
            )}
        </td>
      </tr>
      {display.changelog ? (
        <tr>
          <th>{addColonText(l('Summary'))}</th>
          <td>
            {display.changelog}
          </td>
        </tr>
      ) : null}
    </table>
  );
};

export default AddReleaseAnnotation;
