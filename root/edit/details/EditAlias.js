/*
 * @flow
 * Copyright (C) 2019 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import locales from '../../static/scripts/common/constants/locales.json';
import bracketed, {bracketedText}
  from '../../static/scripts/common/utility/bracketed.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import isolateText from '../../static/scripts/common/utility/isolateText.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';
import FullChangeDiff
  from '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';

type Props = {
  +edit: EditAliasEditT,
};

const EditAlias = ({edit}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const entityType = display.entity_type;
  const entity = display[entityType];
  const aliasName = edit.alias?.name ?? '';
  const aliasPrimaryForLocale = edit.alias?.primary_for_locale ?? false;
  const entityWithGid = entity?.gid ? entity : null;
  const aliasLocale = edit.alias?.locale;

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
                  {bracketedText(
                    aliasPrimaryForLocale
                      ? texp.l('primary for {locale}',
                               {locale: locales[aliasLocale]})
                      : locales[aliasLocale],
                  )}
                </>
              ) : <span className="deleted">{l('[removed]')}</span>}
            </td>
          </tr>) : null}

        <WordDiff
          label={addColonText(l('Alias'))}
          newText={display.alias.new}
          oldText={display.alias.old}
        />

        <WordDiff
          label={addColonText(l('Sort name'))}
          newText={display.sort_name.new}
          oldText={display.sort_name.old}
        />

        <FullChangeDiff
          label={addColonText(l('Locale'))}
          newContent={locales[display.locale.new]}
          oldContent={locales[display.locale.old]}
        />

        <FullChangeDiff
          label={addColonText(l('Primary for locale'))}
          newContent={yesNo(display.primary_for_locale.new)}
          oldContent={yesNo(display.primary_for_locale.old)}
        />

        <FullChangeDiff
          label={addColonText(l('Type'))}
          newContent={display.type.new ? display.type.new.name : ''}
          oldContent={display.type.old ? display.type.old.name : ''}
        />

        <Diff
          label={addColonText(l('Begin date'))}
          newText={formatDate(display.begin_date.new)}
          oldText={formatDate(display.begin_date.old)}
          split="-"
        />

        <Diff
          label={addColonText(l('End date'))}
          newText={formatDate(display.end_date.new)}
          oldText={formatDate(display.end_date.old)}
          split="-"
        />

        <FullChangeDiff
          label={addColonText(l('Ended'))}
          newContent={yesNo(display.ended.new)}
          oldContent={yesNo(display.ended.old)}
        />
      </tbody>
    </table>
  );
};

export default EditAlias;
