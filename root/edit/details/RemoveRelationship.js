/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationship
  from '../../static/scripts/common/components/Relationship';

type RemoveRelationshipEditT = {
  ...EditT,
  +data: {
    +edit_version?: number,
    +relationship: {
      +entity0: {
        +gid?: string,
        +id: number,
        +name: string,
      },
      +entity0_credit?: string,
      +entity1: {
        +gid?: string,
        +id: number,
        +name: string,
      },
      +entity1_credit?: string,
      +extra_phrase_attributes?: string,
      +id: number,
      +link: {
        +attributes?: $ReadOnlyArray<{
          +credited_as?: string,
          +gid?: string,
          +id?: string | number,
          +name?: string,
          +root_gid?: string,
          +root_id?: string | number,
          +root_name?: string,
          +text_value?: string,
          +type?: {
            +gid: string,
            +id: string | number,
            +name: string,
            +root: {
              +gid: string,
              +id: string | number,
              +name: string,
            },
          },
        }>,
        +begin_date: {
          +day: number | null,
          +month: number | null,
          +year: string | number | null,
        },
        +end_date: {
          +day: number | null,
          +month: number | null,
          +year: string | number | null,
        },
        +ended?: string,
        +type: {
          +entity0_type: string,
          +entity1_type: string,
          +id?: string | number,
          +long_link_phrase?: string,
        },
      },
      +phrase?: string,
    },
  },
  +display_data: {
    +relationship: RelationshipT,
  },
};

type Props = {
  +edit: RemoveRelationshipEditT,
};

const RemoveRelationship = ({edit}: Props): React.MixedElement => (
  <table className="details remove-relationship">
    <tr>
      <th>{l('Relationship:')}</th>
      <td><Relationship relationship={edit.display_data.relationship} /></td>
    </tr>
  </table>
);

export default RemoveRelationship;
