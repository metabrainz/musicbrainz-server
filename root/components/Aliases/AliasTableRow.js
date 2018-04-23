/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const Frag = require('../Frag');
const isolateText = require('../../static/scripts/common/utility/isolateText');
import formatDate from '../../static/scripts/common/utility/formatDate';
const entityHref = require('../../static/scripts/common/utility/entityHref');
import bracketed from '../../static/scripts/common/utility/bracketed';
const locales = require('../../static/scripts/common/constants/locales');
const {l} = require('../../static/scripts/common/i18n');
const {lp_attributes} = require('../../static/scripts/common/i18n/attributes');

type Props = {
  +alias: AliasT,
  +allowEditing: boolean,
  +entity: $Subtype<CoreEntityT>,
  +row: string,
};

const AliasTableRow = ({alias, allowEditing, entity, row}: Props) => (
  <tr className={row} key={alias.id}>
    <td colSpan={alias.name === alias.sort_name ? 2 : 1}>
      {alias.editsPending
        ? <span className="mp">{isolateText(alias.name)}</span>
        : isolateText(alias.name)}
    </td>
    {alias.name === alias.sort_name
      ? null
      : <td>{isolateText(alias.sort_name)}</td>}
    <td>{formatDate(alias.begin_date)}</td>
    <td>
      {alias.ended
        ? alias.end_date ? formatDate(alias.end_date) : l('[unknown]')
        : null}
    </td>
    <td>{alias.typeName ? lp_attributes(alias.typeName, 'alias_type') : ''}</td>
    <td>
      {alias.locale ? locales[alias.locale] : null}
      {alias.primary_for_locale
        ? bracketed(<span className="comment">{l('primary')}</span>, {__react: true})
        : null}
    </td>
    <td>
      {allowEditing
        ? (
          <Frag>
            <a href={entityHref(entity, `/alias/${alias.id}/edit`)}>
              {l('Edit')}
            </a>
            {' | '}
            <a href={entityHref(entity, `/alias/${alias.id}/delete`)}>
              {l('Remove')}
            </a>
          </Frag>
        )
        : null
      }
    </td>
  </tr>
);

module.exports = AliasTableRow;
