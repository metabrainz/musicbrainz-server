/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {addColon, l} from '../../static/scripts/common/i18n';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import formatEntityTypeName from '../../static/scripts/common/utility/formatEntityTypeName';

type AnnotatedEntityTypeT = $ElementType<AnnotatedEntityT, 'entityType'>;

type AddAnnotationEditT = {|
  ...EditT,
  +display_data: {|
    +annotation_id: number,
    +changelog: string,
    +entity_type: AnnotatedEntityTypeT,
    [AnnotatedEntityTypeT]: AnnotatedEntityT,
    +html: string,
    +text: string,
  |},
|};

const AddAnnotation = ({edit}: {edit: AddAnnotationEditT}) => {
  const display = edit.display_data;
  const entityType = display.entity_type;

  return (
    <table
      className={`details add-${entityType}-annotation`}
    >
      <table
        className={`details add-${entityType}-annotation`}
      >
        {display[entityType] || !edit.preview ? (
          <tr>
            <th>
              {addColon(formatEntityTypeName(entityType))}
            </th>
            <td>
              <DescriptiveLink
                entity={display[entityType]}
              />
            </td>
          </tr>
        ) : null}
        <tr>
          <th>{addColon(l('Text'))}</th>
          <td>
            {display.html
              ? (
                <span
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
        {display.changelog ? (
          <tr>
            <th>{addColon(l('Summary'))}</th>
            <td>
              {display.changelog}
            </td>
          </tr>
        ) : null}
      </table>
    </table>
  );
};

export default AddAnnotation;
