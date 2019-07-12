// @flow
/* eslint-disable react/jsx-no-bind */

import React, {useState, useEffect} from 'react';
import noop from 'lodash/noop';
import ReactDOM from 'react-dom';

import gc from '../../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../../static/scripts/common/MB';
import DataRangeFieldset from '../../components/DateRangeFieldset';
import {ENTITIES} from '../../static/scripts/common/constants';
import EnterEdit from '../../components/EnterEdit';
import EnterEditNote from '../../components/EnterEditNote';
import FormRowCheckbox from '../../components/FormRowCheckbox';
import FormRowSelect from '../../components/FormRowSelect';
import FormRowNameWithGuesscase from '../../components/FormRowNameWithGuesscase';
import hydrate from '../../utility/hydrate';
import FormRowSortNameWithGuessCase from '../../components/FormRowSortNameWithGuessCase';
import GuessCaseOptions from '../../components/GuessCaseOptions';
import AddRemoveAlias from '../../edit/details/AddRemoveAlias';
import EditAlias from '../../edit/details/EditAlias';
import parseIntegerOrNull from '../../static/scripts/common/utility/parseIntegerOrNull';

type Props = {
  editKind: string,
  entity: AliasT,
  entityType: string,
  form: AliasFormT,
  localeOptions: Array<{|label: string, value: string|}>,
  typeId: number | null,
  typeOptions: Array<{|label: string, value: string|}>,
  uri: string,
};

const EditForm = ({
  uri,
  form,
  entity,
  typeOptions,
  localeOptions,
  entityType,
  typeId,
  editKind,
}: Props) => {
  const guess = MB.GuessCase[entityType];

  useEffect(() => {
    const $ = require('jquery');
    const $options = $('#guesscase-options');
    if ($options.length && !$options.data('ui-dialog')) {
      $options.dialog({autoOpen: false, title: l('Guess Case Options')});
      ReactDOM.render(<GuessCaseOptions />, $options[0]);
    }
  }, []);
  const formOptions = (prop: Array<{|label: string, value: string|}>) => {
    return {
      grouped: false,
      options: prop,
    };
  };

  function refractorDate(date) {
    return {
      ...form.field.period.field[date],
      field: {
        day: {
          ...form.field.period.field[date].field.day,
          value: (form.field.period.field[date].field.day.value
            ? form.field.period.field[date].field.day.value : undefined),
        },
        month: {
          ...form.field.period.field[date].field.month,
          value: (form.field.period.field[date].field.month.value
            ? form.field.period.field[date].field.month.value : undefined),
        },
        year: {
          ...form.field.period.field[date].field.year,
          value: (form.field.period.field[date].field.year.value
            ? form.field.period.field[date].field.year.value : undefined),
        },
      },
    };
  }

  const [aliasName, setAliasName] = useState<FieldT<string>>(
    form.field.name.value ? form.field.name : {...form.field.name, value: ''},
  );
  const [locale, setLocale] = useState<FieldT<string>>(
    form.field.locale.value ? form.field.locale
      : {...form.field.locale, value: ''},
  );
  const [sortName, setSortName] = useState<FieldT<string>>(
    form.field.sort_name.value ? form.field.sort_name : {...form.field.sort_name, value: ''},
  );
  const [entityTypeId, setEntityTypeId] = useState<FieldT<string>>(
    form.field.type_id.value ? form.field.type_id : {...form.field.type_id, value: ''},
  );
  const [endDate, setEndDate] = useState(refractorDate('end_date'));
  const [beginDate, setBeginDate] = useState(refractorDate('begin_date'));
  const [ended, setEnded] = useState<FieldT<boolean>>(
    form.field.period.field.ended,
  );
  const [
    primaryForLocale,
    setPrimaryForLocale,
  ] = useState(form.field.primary_for_locale);

  const period = {
    ...form.field.period,
    field: {
      begin_date: beginDate,
      end_date: endDate,
      ended,
    },
  };

  const entityProperties = ENTITIES[entityType];
  const disabler = parseInt(entityTypeId.value, 10) ===
      entityProperties.aliases.search_hint_type;

  const args = [aliasName.value];

  function typeUsed(optionNo) {
    const type = typeOptions.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  if (entityType === 'artist') {
    args.push(typeId !== 2);
  }

  function generateEditPreviewData() {
    const edit = {
      alias: {
        ended: ended.value,
        locale: locale.value,
        name: aliasName.value,
        primary_for_locale: primaryForLocale.value,
        sort_name: sortName.value,
        typeID: entityTypeId.value,
      },
      display_data: {
        alias: {
          new: aliasName.value,
          old: form.field.name.value,
        },
        begin_date: {
          new: {
            day: beginDate.field.day.value,
            month: beginDate.field.month.value,
            year: beginDate.field.year.value,
          },
          old: {
            day: refractorDate('begin_date').field.day.value,
            month: refractorDate('begin_date').field.month.value,
            year: refractorDate('begin_date').field.year.value,
          },
        },
        end_date: {
          new: {
            day: endDate.field.day.value,
            month: endDate.field.month.value,
            year: endDate.field.year.value,
          },
          old: {
            day: refractorDate('end_date').field.day.value,
            month: refractorDate('end_date').field.month.value,
            year: refractorDate('end_date').field.year.value,
          },
        },
        ended: {
          new: ended.value,
          old: form.field.period.field.ended.value,
        },
        entity_type: entityType,
        locale: {
          new: locale.value === '' ? null : locale.value,
          old: form.field.locale.value,
        },
        primary_for_locale: {
          new: primaryForLocale.value,
          old: form.field.primary_for_locale.value,
        },
        sort_name: {
          new: sortName.value,
          old: form.field.sort_name.value,
        },
        type: {
          new: typeUsed(entityTypeId.value),
          old: typeUsed(form.field.type_id.value),
        },
      },
      edit_kind: editKind,
    };
    edit.display_data[entityType] = entity;
    return edit;
  }

  function generateAddPreviewData() {
    const edit = {
      display_data: {
        alias: aliasName.value,
        begin_date: {
          day: beginDate.field.day.value,
          month: beginDate.field.month.value,
          year: beginDate.field.year.value,
        },
        end_date: {
          day: endDate.field.day.value,
          month: endDate.field.month.value,
          year: endDate.field.year.value,
        },
        ended: ended.value,
        entity_type: entityType,
        locale: locale.value,
        primary_for_locale: primaryForLocale.value,
        sort_name: sortName.value,
        type: typeUsed(entityTypeId.value),
      },
      edit_kind: editKind,
    };
    edit.display_data[entityType] = entity;
    return edit;
  }

  return (
    <>
      <p>
        {exp.l('An alias is an alternate name for an entity. They typically contain\
        common mispellings or variations of the name and are also used to improve search results.\
        View the {doc|alias documentation} for more details.', {doc:  '/doc/Aliases'})}
      </p>
      <form action={uri} className="edit-alias" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Alias Details')}</legend>
            <FormRowNameWithGuesscase
              field={aliasName}
              onChangeInput={(e) => setAliasName({
                ...aliasName,
                value: e.target.value,
              })}
              onPressGuessCaseOptions={() => {
                const $ = require('jquery');
                return $('#guesscase-options').dialog('open');
              }}
              onPressGuessCaseTitle={() => setAliasName({
                ...aliasName,
                value: guess.guess(aliasName.value),
              })}
              options={noop}
              required
            />
            <FormRowSortNameWithGuessCase
              disabled={disabler}
              field={sortName}
              onChange={(e) => setSortName({
                ...sortName,
                value: e.target.value,
              })}
              onPressGuessCaseCopy={() => setSortName({
                ...sortName,
                value: aliasName.value,
              })}
              onPressGuessCaseSortName={() => setSortName({
                ...sortName,
                value: guess.sortname.apply(guess, args),
              })}
            />
            <FormRowSelect
              allowEmpty
              field={locale}
              frozen={disabler}
              label={l('Locale:')}
              onChange={function (e) {
                setLocale({
                  ...locale,
                  // $FlowFixMe
                  value: e.target.value,
                });
              }}
              options={formOptions(localeOptions)}
            />
            {locale.value === '' ? null : (
              <span id="allow_primary_for_locale" style={{display: 'block'}}>
                <FormRowCheckbox
                  disabled={disabler}
                  field={primaryForLocale}
                  label={l('This is the primary alias for this locale')}
                  onChange={function (e) {
                    setPrimaryForLocale({
                      ...primaryForLocale,
                      // $FlowFixMe
                      value: e.target.checked,
                    });
                  }}
                />
              </span>
            )}
            <FormRowSelect
              allowEmpty
              field={entityTypeId}
              label={l('Type:')}
              onChange={(e) => {
                setEntityTypeId({
                  ...entityTypeId,
                  // $FlowFixMe
                  value: e.target.value,
                });
              }}
              options={formOptions(typeOptions)}
            />
          </fieldset>
          <DataRangeFieldset
            disabled={disabler}
            endDateOnChangeDay={function (e) {
              setEndDate({
                ...endDate,
                field: {
                  ...endDate.field,
                  day: {
                    ...endDate.field.day,
                    value: parseIntegerOrNull(e.target.value),
                  },
                },
              });
            }}
            endDateOnChangeMonth={function (e) {
              setEndDate({
                ...endDate,
                field: {
                  ...endDate.field,
                  month: {
                    ...endDate.field.month,
                    value: parseIntegerOrNull(e.target.value),
                  },
                },
              });
            }}
            endDateOnChangeYear={function (e) {
              setEndDate({
                ...endDate,
                field: {
                  ...endDate.field,
                  year: {
                    ...endDate.field.year,
                    value: parseIntegerOrNull(e.target.value),
                  },
                },
              });
            }}
            endedLabel={l('This alias is no longer current.')}
            onChangeEnded={function (e) {
              setEnded({
                ...ended,
                // $FlowFixMe
                value: e.target.checked,
              });
            }}
            period={period}
            startDateOnChangeDay={function (e) {
              setBeginDate({
                ...beginDate,
                field: {
                  ...beginDate.field,
                  day: {
                    ...beginDate.field.day,
                    value: parseIntegerOrNull(e.target.value),
                  },
                },
              });
            }}
            startDateOnChangeMonth={function (e) {
              setBeginDate({
                ...beginDate,
                field: {
                  ...beginDate.field,
                  month: {
                    ...beginDate.field.month,
                    value: parseIntegerOrNull(e.target.value),
                  },
                },
              });
            }}
            startDateOnChangeYear={function (e) {
              setBeginDate({
                ...beginDate,
                field: {
                  ...beginDate.field,
                  year: {
                    ...beginDate.field.year,
                    value: parseIntegerOrNull(e.target.value),
                  },
                },
              });
            }}
            type="alias"
          />
          <fieldset>
            <legend>{l('Changes')}</legend>
            {editKind === 'add'
              ? <AddRemoveAlias edit={generateAddPreviewData()} />
              : <EditAlias edit={generateEditPreviewData()} />
            }
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>
      </form>
    </>
  );
};

export default hydrate<Props>('div.edit-form', EditForm);
