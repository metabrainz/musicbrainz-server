// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useState, useEffect} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import hydrate from '../utility/hydrate';
import HiddenField from '../components/HiddenField';
import FieldErrors from '../components/FieldErrors';
import GuessCaseOptions from '../components/GuessCaseOptions';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import FormRowSortNameWithGuessCase from '../components/FormRowSortNameWithGuessCase';
import DuplicateEntitiesSection from '../components/DuplicateEntitiesSection';
import FormRowTextLong from '../components/FormRowTextLong';
import FormRowSelect from '../components/FormRowSelect';
import FormRow from '../components/FormRow';
import AreaBubble from '../components/AreaBubble';
import Autocomplete from '../static/scripts/common/components/Autocomplete';
import FormRowTextList from '../components/FormRowTextList';
import FormRowCheckbox from '../components/FormRowCheckbox';
import parseIntegerOrNull from '../static/scripts/common/utility/parseIntegerOrNull';
import FormRowPartialDate from '../components/FormRowPartialDate';
import AddArtist from '../edit/details/AddArtist';
import EditArtist from '../edit/details/EditArtist';

type Props = {
  editEntity: ArtistT,
  entityType: string,
  form: ArtistFormT,
  formType: string,
  optionsGenderId: SelectOptionsT,
  optionsTypeId: SelectOptionsT,
  relationshipEditorHTML: string,
  uri: string,
};

const EditForm = ({
  editEntity,
  entityType,
  form,
  formType,
  optionsGenderId,
  optionsTypeId,
  relationshipEditorHTML,
  uri,
}) => {
  const guess = MB.GuessCase["artist"];
  console.log(form);

  const [
    name,
    setName,
  ] = useState(form.field.name.value
    ? form.field.name
    : {...form.field.name, value: ''});
  const [areaName, setAreaName] = useState(form.field.area.field.name);
  const [areaGID, setAreaGID] = useState(form.field.area.field.gid);
  const [areaID, setAreaID] = useState(form.field.area_id);
  const [
    beginAreaName,
    setBeginAreaName,
  ] = useState(form.field.begin_area.field.name);
  const [
    beginAreaGID,
    setBeginAreaGID,
  ] = useState(form.field.begin_area.field.gid);
  const [beginAreaID, setBeginAreaID] = useState(form.field.begin_area_id);
  const [
    endAreaName,
    setEndAreaName,
  ] = useState(form.field.end_area.field.name);
  const [
    endAreaGID,
    setEndAreaGID,
  ] = useState(form.field.end_area.field.gid);
  const [endAreaID, setEndAreaID] = useState(form.field.end_area_id);
  const [endDate, setEndDate] = useState(refractorDate('end_date'));
  const [ended, setEnded] = useState(form.field.period.field.ended);
  const [beginDate, setBeginDate] = useState(refractorDate('begin_date'));
  const [comment, setComment] = useState(form.field.comment);
  const [typeId, setTypeId] = useState(form.field.type_id);
  const [genderId, setGenderId] = useState(form.field.gender_id);
  const [ipiCodes, setIpiCodes] = useState(form.field.ipi_codes);
  const [isniCodes, setIsniCodes] = useState(form.field.isni_codes);
  const [
    sortName,
    setSortName,
  ] = useState(form.field.sort_name.value ? form.field.sort_name : {...form.field.sort_name, value: ''});

  const typeOptions = {
    grouped: false,
    options: optionsTypeId,
  };

  const genderOptions = {
    grouped: false,
    options: optionsGenderId,
  };

  const args = [name.value];
  if (entityType === 'artist') {
    args.push(typeId !== 2);
  }

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
  function onChangeEnded(e) {
    setEnded({
      ...ended,
      // $FlowFixMe
      value: e.target.checked,
    });
  }

  function typeUsed(optionNo) {
    const type = optionsTypeId.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  function genderChoosen(optionNo) {
    const type = optionsGenderId.find((option) => {
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
          gid: areaGID.value,
          id: areaID.value,
          name: areaName.value,
        },
        artist: {
          begin_data: beginDate.value,
          comment: comment.value,
          end_date: endDate.value,
          entityType: 'artist',
          name: name.value,
        },
        begin_area: {
          entityType: 'area',
          gid: beginAreaGID.value,
          id: beginAreaID.value,
          name: beginAreaName.value,
        },
        begin_date: {
          day: beginDate.field.day.value,
          month: beginDate.field.month.value,
          year: beginDate.field.year.value,
        },
        comment: comment.value,
        end_area: {
          entityType: 'area',
          gid: endAreaGID.value,
          id: endAreaID.value,
          name: endAreaName.value,
        },
        end_date: {
          day: endDate.field.day.value,
          month: endDate.field.month.value,
          year: endDate.field.year.value,
        },
        ended: ended.value,
        gender: genderId.value ? genderChoosen(genderId.value) : {
          name: '',
        },
        ipi_codes: ipiCodes.value,
        isni_codes: isniCodes.value,
        sort_name: sortName.value,
        type: typeUsed(typeId.value),

      },
    };
  }

  function generateEditPreviewData() {
    return {
      display_data: {
        area: {
          new: {
            entityType: 'area',
            gid: areaGID.value,
            id: areaID.value,
            name: areaName.value,
          },
          old: {
            entityType: 'area',
            gid: form.field.area.field.gid.value,
            id: form.field.area_id.value,
            name: form.field.area.field.name.value,
          },
        },
        artist: editEntity,
        begin_area: beginAreaGID ? {
          new: {
            entityType: 'area',
            gid: beginAreaGID.value,
            id: beginAreaID.value,
            name: beginAreaName.value,
          },
          old: {
            entityType: 'area',
            gid: form.field.begin_area.field.gid.value,
            id: form.field.begin_area_id.value,
            name: form.field.begin_area.field.name.value,
          },
        } : null,
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
        end_area: endAreaGID ? {
          new: {
            entityType: 'area',
            gid: endAreaGID.value,
            id: endAreaID.value,
            name: endAreaName.value,
          },
          old: {
            entityType: 'area',
            gid: form.field.end_area.field.gid.value,
            id: form.field.end_area_id.value,
            name: form.field.end_area.field.name.value,
          },
        } : null,
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
        gender: {
          new: genderId.value ? genderChoosen(genderId.value) : {
            name: '',
          },
          old: form.field.gender_id.value ? genderChoosen(form.field.gender_id.value) : {
            name: '',
          },
        },
        ipi_codes: {
          new: ipiCodes.value,
          old: form.field.ipi_codes.value,
        },
        isni_codes: {
          new: isniCodes.value,
          old: form.field.isni_codes.value,
        },
        sort_name: {
          new: sortName.value,
          old: form.field.sort_name.value,
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
      <p>{exp.l('For more information, check the {doc_doc|documentation} and {doc_styleguide|style guidelines}.', {doc_doc: '/doc/Artist', doc_styleguide: '/doc/Style/Artist'})}</p>
      <form action={uri} className="edit-artist" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Artist Details')}</legend>
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
            <FormRowSortNameWithGuessCase
              field={sortName}
              onChange={(e) => setSortName({
                ...sortName,
                value: e.target.value,
              })}
              onPressGuessCaseCopy={() => setSortName({
                ...sortName,
                value: name.value,
              })}
              onPressGuessCaseSortName={() => setSortName({
                ...sortName,
                value: guess.sortname.apply(guess, args),
              })}
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
            <FormRowSelect
              allowEmpty
              field={genderId}
              label={l('Gender:')}
              onChange={(e) => {
                setGenderId({
                  ...genderId,
                  // $FlowFixMe
                  value: e.target.value,
                });
              }}
              options={genderOptions}
            />
            <FormRow>
              <label htmlFor="id-edit-artist.area.name">{l('Area:')}</label>
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
            <FormRowTextList
              field={ipiCodes}
              itemName={l('IPI code')}
              label={l('IPI codes:')}
            />
            <FormRowTextList
              field={form.field.isni_codes}
              itemName={l('ISNI code')}
              label={l('ISNI code:')}
            />
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
            <FormRow>
              <label htmlFor="id-edit-artist.begin_area.name" id="label-id-edit-artist.begin_area.name">{l('Begin Area:')}</label>
              <Autocomplete
                currentSelection={{
                  gid: beginAreaGID.value,
                  id: beginAreaID.value,
                  name: beginAreaName.value,
                }}
                entity="area"
                inputID={'id-' + form.field.begin_area.field.name.html_name}
                onChange={(area) => {
                  setBeginAreaName({
                    ...beginAreaName,
                    value: area.name,
                  });
                  setBeginAreaGID({
                    ...beginAreaGID,
                    value: area.gid,
                  });
                  setBeginAreaID({
                    ...beginAreaID,
                    value: area.id,
                  });
                }}
              >
                <HiddenField className="gid" field={beginAreaGID} />
                <HiddenField className="id" field={beginAreaID} />
              </Autocomplete>
              <FieldErrors field={beginAreaName} />
              <FieldErrors field={beginAreaGID} />
              <FieldErrors field={beginAreaID} />
            </FormRow>
            <FormRowPartialDate
              field={endDate}
              label={l('End date:')}
              onChangeDay={endDateOnChangeDay}
              onChangeMonth={endDateOnChangeMonth}
              onChangeYear={endDateOnChangeYear}
            />
            <FormRowCheckbox
              field={ended}
              label={l('This artist has ended.')}
              onChange={onChangeEnded}
            />
            <FormRow>
              <label htmlFor="id-edit-artist.end_area.name" id="label-id-edit-artist.end_area.name">{l('End Area:')}</label>
              <Autocomplete
                currentSelection={{
                  gid: endAreaGID.value,
                  id: endAreaID.value,
                  name: endAreaName.value,
                }}
                entity="area"
                inputID={'id-' + form.field.end_area.field.name.html_name}
                onChange={(area) => {
                  setEndAreaName({
                    ...endAreaName,
                    value: area.name,
                  });
                  setEndAreaGID({
                    ...endAreaGID,
                    value: area.gid,
                  });
                  setEndAreaID({
                    ...endAreaID,
                    value: area.id,
                  });
                }}
              >
                <HiddenField className="gid" field={endAreaGID} />
                <HiddenField className="id" field={endAreaID} />
              </Autocomplete>
              <FieldErrors field={endAreaName} />
              <FieldErrors field={endAreaGID} />
              <FieldErrors field={endAreaID} />
            </FormRow>
          </fieldset>
          <div dangerouslySetInnerHTML={{__html: relationshipEditorHTML}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <fieldset>
            <legend>{l('Changes')}</legend>
            {formType === 'add' ? <AddArtist edit={generateAddPreviewData()} /> : <EditArtist edit={generateEditPreviewData()} />}
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

export default hydrate<Props>('div.artist-edit-form', EditForm);
