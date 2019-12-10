/*
 * @flow
 * Copyright (C) 2019 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName';
import bracketed from '../../static/scripts/common/utility/bracketed';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import isolateText from '../../static/scripts/common/utility/isolateText';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import locales from '../../static/scripts/common/constants/locales';
import FullChangeDiff
  from '../../static/scripts/edit/components/edit/FullChangeDiff';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';

type EditAliasEditT = $ReadOnly<{
  ...EditT,
  +alias: AliasT | null,
  +display_data: {
    +[core_entity: CoreEntityTypeT]: CoreEntityT,
    +alias: CompT<string>,
    +begin_date: CompT<PartialDateT>,
    +end_date: CompT<PartialDateT>,
    +ended: CompT<boolean>,
    +entity_type: CoreEntityTypeT,
    +locale: CompT<string | null>,
    +primary_for_locale: CompT<boolean>,
    +sort_name: CompT<string>,
    +type: CompT<AliasTypeT | null>,
  },
}>;

type Props = {
  +edit: EditAliasEditT,
};

const EditAlias = ({edit}: Props) => {
  const display = edit.display_data;
  const entityType = display.entity_type;
  const entity = display[entityType];
  const aliasName = edit.alias ? edit.alias.name : '';
  const aliasPrimaryForLocale = edit.alias
    ? edit.alias.primary_for_locale
    : false;
  const entityWithGid = entity && entity.gid ? entity : null;
  const aliasLocale = edit.alias ? edit.alias.locale : null;

  return (
    <table className={`details edit-${entityType}-alias`}>
      <tbody>
        <tr>
          <th>{addColonText(formatEntityTypeName(entityType))}</th>
          <td colSpan="2">
            <DescriptiveLink entity={entity} />
            {entityWithGid ? (
              <>
                {' '}
                {bracketed(
                  <EntityLink
                    content={l('view all aliases')}
                    entity={entityWithGid}
                    subPath="aliases"
                  />,
                )}
              </>
            ) : null}
          </td>
        </tr>

        {entityWithGid ? (
          <tr>
            <th>{addColonText(l('Alias'))}</th>
            <td colSpan="2">
              {aliasName ? (
                <>
                  {isolateText(aliasName)}
                  {' '}
                  {bracketed(
                    aliasPrimaryForLocale
                      ? texp.l('primary for {locale}',
                               {locale: locales[aliasLocale]})
                      : locales[aliasLocale],
                  )}
                </>
              ) : <span className="deleted">{l('[removed]')}</span>}
            </td>
          </tr>) : null}

        <Diff
          label={addColonText(l('Alias'))}
          newText={display.alias.new}
          oldText={display.alias.old}
          split="\s+"
        />

        <Diff
          label={addColonText(l('Sort name'))}
          newText={display.sort_name.new}
          oldText={display.sort_name.old}
          split="\s+"
        />

        <FullChangeDiff
          label={addColonText(l('Locale'))}
          newText={locales[display.locale.new]}
          oldText={locales[display.locale.old]}
        />

        <FullChangeDiff
          label={addColonText(l('Primary for locale'))}
          newText={yesNo(display.primary_for_locale.new)}
          oldText={yesNo(display.primary_for_locale.old)}
        />

        <FullChangeDiff
          label={addColonText(l('Type'))}
          newText={display.type.new ? display.type.new.name : ''}
          oldText={display.type.old ? display.type.old.name : ''}
        />

        <Diff
          label={addColonText(l('Begin date'))}
          newText={formatDate(display.begin_date.new)}
          oldText={formatDate(display.begin_date.old)}
          split="\s+"
        />

        <Diff
          label={addColonText(l('End date'))}
          newText={formatDate(display.end_date.new)}
          oldText={formatDate(display.end_date.old)}
          split="\s+"
        />

        <FullChangeDiff
          label={addColonText(l('Ended'))}
          newText={yesNo(display.ended.new)}
          oldText={yesNo(display.ended.old)}
        />
      </tbody>
    </table>
  );
};

export default EditAlias;
