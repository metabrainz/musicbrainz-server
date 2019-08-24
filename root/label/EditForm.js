// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useEffect, useState} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import GuessCaseOptions from '../components/GuessCaseOptions';
import DateRangeFieldset from '../components/DateRangeFieldset';
import FormLabel from '../components/FormLabel';
import FormRow from '../components/FormRow';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import FormRowSelect from '../components/FormRowSelect';
import FormRowTextList from '../components/FormRowTextList';
import FormRowTextLong from '../components/FormRowTextLong';
import HiddenField from '../components/HiddenField';
import Autocomplete from '../static/scripts/common/components/Autocomplete';
import DuplicateEntitiesSection from '../components/DuplicateEntitiesSection';
import hydrate from '../utility/hydrate';
import FieldErrors from '../components/FieldErrors';
import parseIntegerOrNull from '../static/scripts/common/utility/parseIntegerOrNull';
import AreaBubble from '../components/AreaBubble';
import AddLabel from '../edit/details/AddLabel';
import EditLabel from '../edit/details/EditLabel';

type Props = {
  editEntity: LabelT,
  entityType: string,
  form: LabelFormT,
  formType: string,
  optionsTypeId: SelectOptionsT,
  relationshipEditorHTML: string,
  uri: string,
};

const EditForm = ({
  editEntity,
  entityType,
  form,
  formType,
  optionsTypeId,
  relationshipEditorHTML,
  uri,
}: Props) => {
  const guess = MB.GuessCase[entityType];
  console.log(form);

  const [
    name,
    setName,
  ] = useState(form.field.name.value
    ? form.field.name
    : {...form.field.name, value: ''});
  const [comment, setComment] = useState(form.field.comment);
  const [typeId, setTypeId] = useState(form.field.type_id);
  const [areaName, setAreaName] = useState(form.field.area.field.name);
  const [areaGID, setAreaGID] = useState(form.field.area.field.gid);
  const [areaID, setAreaID] = useState(form.field.area_id);
  const [labelCode, setLabelCode] = useState(form.field.label_code);
  const [ipiCodes, setIpiCodes] = useState(form.field.ipi_codes);
  const [isniCodes, setIsniCodes] = useState(form.field.isni_codes);

  console.log(labelCode);

  const [endDate, setEndDate] = useState(refractorDate('end_date'));
  const [beginDate, setBeginDate] = useState(refractorDate('begin_date'));
  const [ended, setEnded] = useState(
    form.field.period.field.ended,
  );

  const period = {
    ...form.field.period,
    field: {
      begin_date: beginDate,
      end_date: endDate,
      ended,
    },
  };

  useEffect(() => {
    const $ = require('jquery');
    const $options = $('#guesscase-options');
    if ($options.length && !$options.data('ui-dialog')) {
      $options.dialog({autoOpen: false, title: l('Guess Case Options')});
      ReactDOM.render(<GuessCaseOptions />, $options[0]);
    }
  }, []);

  const typeOptions = {
    grouped: false,
    options: optionsTypeId,
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

  function typeUsed(optionNo) {
    const type = optionsTypeId.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  function generateAddPreviewData() {
    return {
      display_data: {
        area: {
          entityType: 'area',
          gid: areaGID.value ? areaGID.value : '',
          id: areaID.value ? areaID.value : null,
          name: areaName.value ? areaName.value : '',
        },
        begin_date: {
          day: beginDate.field.day.value,
          month: beginDate.field.month.value,
          year: beginDate.field.year.value,
        },
        comment: comment.value,
        end_date: {
          day: endDate.field.day.value,
          month: endDate.field.month.value,
          year: endDate.field.year.value,
        },
        ended: ended.value,
        ipi_codes: ipiCodes.value,
        isniCodes: isniCodes.value,
        label: {
          comment: comment.value,
          name: name.value,
          type: typeUsed(typeId.value),
        },
        label_code: labelCode.value,
        name: name.value,
        type: typeUsed(typeId.value),
      },
    };
  }

  function generateEditPreview() {
    return {
      display_data: {
        area: {
          new: {
            entityType: 'area',
            gid: areaGID.value ? areaGID.value : '',
            name: areaName.value ? areaName.value : '',
          },
          old: {
            entityType: 'area',
            gid: form.field.area.field.gid.value,
            name: form.field.area.field.name.value,
          },
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
        comment: {
          new: comment.value,
          old: form.field.comment.value,
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
        label: editEntity,
        label_code: {
          new: labelCode.value,
          old: form.field.label_code.value,
        },
        name: {
          new: name.value,
          old: form.field.name.value,
        },
        type: {
          new: typeUsed(typeId.value),
          old: typeUsed(form.field.type_id.value),
        },
      },
    };
  }

  return (
    <>
      <p>{exp.l('For more information, check the {doc_doc|documentation}.', {doc_doc: '/doc/Label'})}</p>
      <form action={uri} className="edit-label" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Label Details')}</legend>
            <FormRowNameWithGuesscase
              field={name}
              label={l('Name:')}
              onChangeInput={(e) => setName({
                ...name,
                value: e.target.value,
              })}
              onPressGuessCaseOptions={() => {
                const $ = require('jquery');
                return $('#guesscase-options').dialog('open');
              }}
              onPressGuessCaseTitle={() => setName({
                ...name,
                value: guess.guess(name.value),
              })}
              options={{label: l('Name')}}
              required
            />
            <DuplicateEntitiesSection />
            <FormRowTextLong
              field={comment}
              label={addColonText(l('Disambiguation'))}
              onChange={(e) => {
                setComment({
                  ...comment,
                  value: e.target.value,
                });
              }}
            />
            <FormRowSelect
              allowEmpty
              field={typeId}
              label={l('Type:')}
              onChange={(e) => {
                setTypeId({
                  ...typeId,
                  // $FlowFixMe
                  value: e.target.value,
                });
              }}
              options={typeOptions}
            />
            <FormRow>
              <label htmlFor="id-edit-label.area.name">{l('Area:')}</label>
              <Autocomplete
                currentSelection={{
                  gid: areaGID.value,
                  id: areaID.value,
                  name: areaName.value,
                }}
                entity="area"
                inputID={'id-' + form.field.area.field.name.html_name}
                onChange={(area) => {
                  setAreaName({
                    ...areaName,
                    value: area.name,
                  });
                  setAreaGID({
                    ...areaGID,
                    value: area.gid,
                  });
                  setAreaID({
                    ...areaID,
                    value: area.id,
                  });
                }}
              >
                <HiddenField className="gid" field={areaGID} />
                <HiddenField className="id" field={areaID} />
              </Autocomplete>
              <FieldErrors field={areaName} />
              <FieldErrors field={areaGID} />
              <FieldErrors field={areaID} />
            </FormRow>
            <FormRow>
              <FormLabel forField={labelCode} label={l('Label code:')} />
              <input
                className="label-code"
                defaultValue={labelCode.value || ''}
                id={'id-' + labelCode.html_name}
                name={labelCode.html_name}
                onChange={(e) => {
                  setLabelCode({
                    ...labelCode,
                    value: e.target.value,
                  });
                }}
                pattern="[0-9]*"
                size={5}
                type="text"
              />
              <FieldErrors field={labelCode} />
            </FormRow>
            <FormRowTextList
              field={ipiCodes}
              itemName={l('IPI code')}
              label={l('IPI codes:')}
            />
            <FormRowTextList
              field={isniCodes}
              itemName={l('ISNI code')}
              label={l('ISNI codes:')}
            />
          </fieldset>
          <DateRangeFieldset
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
            endedLabel={l('This label has ended.')}
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
          />
          <div dangerouslySetInnerHTML={{__html: relationshipEditorHTML}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <fieldset>
            <legend>{l('Changes')}</legend>
            {formType === 'add'
              ? <AddLabel edit={generateAddPreviewData()} />
              : <EditLabel edit={generateEditPreview()} />}
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>
        <div className="documentation">
          <AreaBubble />
        </div>
      </form>
    </>
  );
};

export default hydrate<Props>('div.label-edit-form', EditForm);
