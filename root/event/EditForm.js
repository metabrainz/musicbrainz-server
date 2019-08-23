// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useState, useEffect} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import FormRowPartialDate from '../components/FormRowPartialDate';
import FormRowSelect from '../components/FormRowSelect';
import FormRowTextLong from '../components/FormRowTextLong';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import parseIntegerOrNull from '../static/scripts/common/utility/parseIntegerOrNull';
import GuessCaseOptions from '../components/GuessCaseOptions';
import hydrate from '../utility/hydrate';
import FormRowCheckbox from '../components/FormRowCheckbox';
import FormRow from '../components/FormRow';
import FormLabel from '../components/FormLabel';
import FieldErrors from '../components/FieldErrors';
import FormRowTime from '../components/FormRowTime';

type Props = {
  entityType: string,
  form: EventFormT,
  optionsTypeId: SelectOptionsT,
  relationshipEditorHTML: string,
  uri: string,
};

const EditForm = ({
  entityType,
  form,
  optionsTypeId,
  relationshipEditorHTML,
  uri,
}: Props) => {
  const guess = MB.GuessCase[entityType];

  const [
    name,
    setName,
  ] = useState(form.field.name.value
    ? form.field.name
    : {...form.field.name, value: ''});

  const [comment, setComment] = useState(form.field.comment);
  const [typeId, setTypeId] = useState(form.field.type_id);
  const [cancelled, setCancelled] = useState(form.field.cancelled);
  const [endDate, setEndDate] = useState(refractorDate('end_date'));
  const [beginDate, setBeginDate] = useState(refractorDate('begin_date'));
  const [setlist, setSetlist] = useState(form.field.setlist);
  const [time, setTime] = useState(form.field.time);

  const typeOptions = {
    grouped: false,
    options: optionsTypeId,
  };

  useEffect(() => {
    const $ = require('jquery');
    const $options = $('#guesscase-options');
    if ($options.length && !$options.data('ui-dialog')) {
      $options.dialog({autoOpen: false, title: l('Guess Case Options')});
      ReactDOM.render(<GuessCaseOptions />, $options[0]);
    }
  }, []);

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

  function startDateOnChangeDay(e) {
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
  }

  function startDateOnChangeMonth(e) {
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
  }

  function startDateOnChangeYear(e) {
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
  }

  function endDateOnChangeDay(e) {
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
  }
  function endDateOnChangeMonth(e) {
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
  }
  function endDateOnChangeYear(e) {
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
  }

  function generateAddPreviewData() {
    return {
      display_data: {
        event: {
          
        },
      },
    };
  }

  return (
    <>
      <p>{exp.l('For more information, check the {doc_doc|documentation}.', {doc_doc: '/doc/Event'})}</p>
      <form action={uri} className="edit-event" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Event Details')}</legend>
            <FormRowNameWithGuesscase
              field={name}
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
            <FormRowCheckbox
              field={cancelled}
              label={l('This event was cancelled.')}
              onChange={(e) => {
                setCancelled({
                  ...cancelled,
                  value: e.target.checked,
                });
              }}
            />
            <FormRow>
              <FormLabel forField={setlist} label={l('Setlist:')} />
              <textarea
                cols={80}
                defaultValue={setlist.value || ''}
                id={'id-' + setlist.html_name}
                name={setlist.html_name}
                onChange={(e) => {
                  setSetlist({
                    ...setlist,
                    value: e.target.value,
                  });
                }}
                rows={10}
              />
              <FieldErrors field={setlist} />
            </FormRow>
            <p>{l('Add "@ " at line start to indicate artists, "* " for a work/song, "# " for additional info (such as "Encore").[mbid|name] allows linking to artists and works.')}</p>
          </fieldset>
          <fieldset>
            <legend>{l('Date Period')}</legend>
            <p>{l('Dates are in the format YYYY-MM-DD. Partial dates such as YYYY-MM or just YYYY are OK, or you can omit the date entirely.')}</p>
            <FormRowPartialDate
              field={beginDate}
              label={l('Begin date:')}
              onChangeDay={startDateOnChangeDay}
              onChangeMonth={startDateOnChangeMonth}
              onChangeYear={startDateOnChangeYear}
            />
            <FormRowPartialDate
              field={endDate}
              label={l('End date:')}
              onChangeDay={endDateOnChangeDay}
              onChangeMonth={endDateOnChangeMonth}
              onChangeYear={endDateOnChangeYear}
            />
            <FormRowTime
              field={time}
              label={l('Time:')}
              onChange={(e) => {
                setTime({
                  ...time,
                  value: e.target.value,
                });
              }}
            />
          </fieldset>
          <div dangerouslySetInnerHTML={{__html: relationshipEditorHTML}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>
      </form>
    </>
  );
};

export default hydrate<Props>('div.event-edit-form', EditForm);
