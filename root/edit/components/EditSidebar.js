/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import VotingPeriod from '../../components/VotingPeriod';
import {
  EDIT_STATUS_OPEN,
  EDIT_STATUS_TOBEDELETED,
} from '../../constants';
import {withCatalystContext} from '../../context';
import SidebarDataQuality from '../../layout/components/sidebar/SidebarDataQuality';
import {
  SidebarProperties,
  SidebarProperty,
} from '../../layout/components/sidebar/SidebarProperties';
import expand2react from '../../static/scripts/common/i18n/expand2react';
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
        <SidebarProperty className="" label={addColonText(l('Voting'))}>
          <div className="edit-expiration">
            <VotingPeriod closingDate={edit.expires_time} user={$c.user} />
          </div>
        </SidebarProperty>
      ) : (
        <SidebarProperty className="" label={l('Closed:')}>
          <div className="edit-expiration">
            {edit.status === EDIT_STATUS_TOBEDELETED
              ? expand2react(l('<em>Cancelling</em>'))
              : formatUserDate($c.user, edit.close_time)}
          </div>
        </SidebarProperty>
      )}

      <SidebarDataQuality quality={edit.quality} />

      <SidebarProperty className="" label={addColonText(l('For quicker closing'))}>
        {texp.ln(
          '1 vote',
          '{n} unanimous votes',
          edit.conditions.votes,
          {n: edit.conditions.votes},
        )}
      </SidebarProperty>

      <SidebarProperty className="" label={addColonText(l('If no votes cast'))}>
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
