/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import {addColonText} from '../../static/scripts/common/i18n/addColon.js';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';

type Props = {
  +edit: AddAnnotationEditT,
};

const AddAnnotation = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const entityType = display.entity_type;
  const oldAnnotation = display.old_annotation;

  return (
    <table
      className={`details add-${entityType}-annotation`}
    >
      {display[entityType] || !edit.preview /*:: === true */ ? (
        <tr>
          <th>
            {addColonText(formatEntityTypeName(entityType))}
          </th>
          <td colSpan={2}>
            <DescriptiveLink
              entity={display[entityType]}
            />
          </td>
        </tr>
      ) : null}
      <tr>
        <th>{addColonText(l('Text'))}</th>
        <td colSpan={2}>
          {display.html
            ? (
              <span
                className="annotation-body"
                dangerouslySetInnerHTML={{__html: display.html}}
              />
            ) : (
              <p>
                <span
                  className="comment"
                >
                  {l('This annotation is empty.')}
                </span>
              </p>
            )}
        </td>
      </tr>
      {oldAnnotation == null ? null : (
        <Diff
          label={l(addColonText('Annotation comparison'))}
          newText={display.text}
          oldText={oldAnnotation}
          split="\s+"
        />
      )}
      {display.changelog ? (
        <tr>
          <th>{addColonText(l('Summary'))}</th>
          <td colSpan={2}>
            {display.changelog}
          </td>
        </tr>
      ) : null}
    </table>
  );
};

export default AddAnnotation;
