// @flow

import React from 'react';
import _ from 'lodash';

import formatEntityTypeName from '../../static/scripts/common/utility/formatEntityTypeName';
import bracketed from '../../static/scripts/common/utility/bracketed';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import isolateText from '../../static/scripts/common/utility/isolateText';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import locales from '../../static/scripts/common/constants/locales';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';

type CompT<T> = {
  new: T,
  old: T,
};

type OnlyNameT = {
  name: string,
} | null;

type DisplayDataT = {
  alias: CompT<string>,
  artist?: OnlyNameT,
  begin_date: CompT<PartialDateT>,
  end_date: CompT<PartialDateT>,
  ended: CompT<boolean>,
  entity_type: string,
  locale: CompT<string | null>,
  primary_for_locale: CompT<boolean>,
  sort_name: CompT<string>,
  type: {
    new: OnlyNameT,
    old: OnlyNameT,
  },
};

type EditAliasT = {
  locale: string,
  name: string,
  primary_for_locale: boolean,
};

type Props = {
  alias: EditAliasT,
  display_data: DisplayDataT,
  edit_kind: string,
};

const EditAlias = ({edit}: {edit: Props}) => {
  const display = edit.display_data;
  const entityType = display.entity_type;
  const entity = display[entityType];
  const aliasName = edit.alias.name;
  const changesExist = display.alias.new === display.alias.old &&
    display.sort_name.new === display.sort_name.old &&
    display.locale.new === display.locale.old &&
    _.isEqual(display.type.new, display.type.old) &&
    _.isEqual(display.begin_date.new, display.begin_date.old) &&
    _.isEqual(display.end_date.new, display.end_date.old) &&
    display.ended.new === display.ended.old;
  return (
    <>
      {changesExist ? (
        <p>{l('There are no changes')}</p>
      ) : (
        <table className={`details edit-${entityType}-alias`}>
          <tbody>
            <tr>
              <th>{addColon(formatEntityTypeName(entityType))}</th>
              <td colSpan="2">
                <DescriptiveLink entity={entity} />
                {' '}
                {(entity && entity.gid) ? bracketed(<EntityLink content={l('view all aliases')} entity={entity} subPath="aliases" />) : null}
              </td>
            </tr>
            {(entity && entity.gid) ? (
              <tr>
                <th>{addColon(l('Alias'))}</th>
                <td colSpan="2">
                  {aliasName ? (
                    <>
                      {isolateText(aliasName)}
                      {' '}
                      {bracketed(edit.alias.primary_for_locale ? l(`primary for ${locales[edit.alias.locale]}`) : locales[edit.alias.locale])}
                    </>
                  ) : <span className="deleted">{l('[removed]')}</span>}
                </td>
              </tr>) : null}
            <Diff label={addColonText(l('Alias'))} newText={display.alias.new} oldText={display.alias.old} split="\s+" />
            <Diff label={addColonText(l('Sort name'))} newText={display.sort_name.new} oldText={display.sort_name.old} split="\s+" />
            <FullChangeDiff label={addColonText(l('Locale'))} newText={locales[display.locale.new]} oldText={locales[display.locale.old]} />
            <FullChangeDiff label={addColonText(l('Primary for locale'))} newText={yesNo(display.primary_for_locale.new)} oldText={yesNo(display.primary_for_locale.old)} />
            <FullChangeDiff label={addColonText(l('Type'))} newText={display.type.new ? display.type.new.name : ''} oldText={display.type.old ? display.type.old.name : ''} />
            <Diff label={addColonText(l('Begin date'))} newText={formatDate(display.begin_date.new)} oldText={formatDate(display.begin_date.old)} split="\s+" />
            <Diff label={addColonText(l('End date'))} newText={formatDate(display.end_date.new)} oldText={formatDate(display.end_date.old)} split="\s+" />
            <FullChangeDiff label={addColonText(l('Ended'))} newText={yesNo(display.ended.new)} oldText={yesNo(display.ended.old)} />
          </tbody>
        </table>
      )}
    </>
  );
};

export default EditAlias;
