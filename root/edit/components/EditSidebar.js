/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ExpirationTime from '../../components/ExpirationTime';
import {
  EDIT_STATUS_OPEN,
  EDIT_STATUS_TOBEDELETED,
} from '../../constants';
import {withCatalystContext} from '../../context';
import {
  SidebarProperties,
  SidebarProperty,
} from '../../layout/components/sidebar/SidebarProperties';
import {QUALITY_NAMES} from '../../static/scripts/common/constants';
import {addColon, l, ln, lp} from '../../static/scripts/common/i18n';
import {
  getEditExpireAction,
  getEditStatusName,
  getEditStatusDescription,
} from '../../utility/edit';
import formatUserDate from '../../utility/formatUserDate';

type Props = {|
  +$c: CatalystContextT,
  +edit: EditT,
|};

const EditSidebar = ({$c, edit}: Props) => (
  <div id="sidebar">
    <SidebarProperties className="edit-status">
      <SidebarProperty className="" label={lp('Status:', 'edit status')}>
        {getEditStatusName(edit)}
      </SidebarProperty>
    </SidebarProperties>

    <p>{getEditStatusDescription(edit)}</p>

    <SidebarProperties>
      <SidebarProperty className="" label={l('Opened:')}>
        {formatUserDate($c.user, edit.created_time)}
      </SidebarProperty>

      {edit.status === EDIT_STATUS_OPEN ? (
        <SidebarProperty className="" label={addColon(l('Expiration'))}>
          <div className="edit-expiration">
            <ExpirationTime date={edit.expires_time} user={$c.user} />
          </div>
        </SidebarProperty>
      ) : (
        <SidebarProperty className="" label={l('Closed:')}>
          <div className="edit-expiration">
            {edit.status === EDIT_STATUS_TOBEDELETED
              ? l('<em>Cancelling</em>')
              : formatUserDate($c.user, edit.close_time)}
          </div>
        </SidebarProperty>
      )}

      <SidebarProperty className="" label={l('Data Quality:')}>
        {QUALITY_NAMES.get(edit.quality) || ''}
      </SidebarProperty>

      <SidebarProperty className="" label={l('Requires:')}>
        {ln(
          '1 vote',
          '{n} unanimous votes',
          edit.conditions.votes,
          {n: edit.conditions.votes},
        )}
      </SidebarProperty>

      <SidebarProperty className="" label={l('Conditions:')}>
        {getEditExpireAction(edit)}
      </SidebarProperty>
    </SidebarProperties>

    <p>
      <a href={`/edit/${edit.id}/data`}>
        <bdi>{l('Raw edit data for this edit')}</bdi>
      </a>
    </p>

    <p>{l('For more information:')}</p>

    <ul className="links">
      <li><a href="/doc/Introduction_to_Voting">{l('Voting FAQ')}</a></li>
      <li><a href="/doc/Editing_FAQ">{l('Editing FAQ')}</a></li>
      <li><a href="/doc/Edit_Types">{l('Edit Types')}</a></li>
    </ul>
  </div>
);

export default withCatalystContext(EditSidebar);
