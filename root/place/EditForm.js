// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useEffect, useState} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import FormRowTextLong from '../components/FormRowTextLong';
import FormRowSelect from '../components/FormRowSelect';
import GuessCaseOptions from '../components/GuessCaseOptions';
import hydrate from '../utility/hydrate';
import DuplicateEntitiesSection from '../components/DuplicateEntitiesSection';
import DateRangeFieldset from '../components/DateRangeFieldset';
import FormRow from '../components/FormRow';
import HiddenField from '../components/HiddenField';
import FieldErrors from '../components/FieldErrors';
import AreaBubble from '../components/AreaBubble';
import parseIntegerOrNull from '../static/scripts/common/utility/parseIntegerOrNull';
import AddPlace from '../edit/details/AddPlace';
import EditPlace from '../edit/details/EditPlace';
import * as manifest from '../static/manifest';
import {formatCoordinates} from '../utility/coordinates';
import Autocomplete from '../static/scripts/common/components/Autocomplete';

type Props = {
  entityType: string,
  form: PlaceFormT,
  formType: string,
  optionsTypeId: SelectOptionsT,
  relationshipEditorHTML?: string,
  uri: string,
};

const EditForm = ({
  editEntity,
  entityType,
  form,
  optionsTypeId,
  relationshipEditorHTML,
  uri,
  formType,
}: Props) => {
  const guess = MB.GuessCase[entityType];

  const [name, setName] = useState(form.field.name.value ? form.field.name : {...form.field.name, value: ''});
  const [comment, setComment] = useState(form.field.comment);
  const [typeId, setTypeId] = useState(form.field.type_id);
  const [address, setAddress] = useState(form.field.address);
  const [coordinates, setCoordinates] = useState(form.field.coordinates);
  const [endDate, setEndDate] = useState(refractorDate('end_date'));
  const [beginDate, setBeginDate] = useState(refractorDate('begin_date'));
  const [ended, setEnded] = useState(form.field.period.field.ended);
  const [areaName, setAreaName] = useState(form.field.area.field.name);
  const [areaId, setAreaId] = useState(form.field.area_id.value ? form.field.area_id : {...form.field.area_id, value: ''});
  const [areaGID, setAreaGID] = useState(form.field.area.field.gid.value ? form.field.area.field.gid : {...form.field.area.field.gid, value: ''});

  const period = {
    ...form.field.period,
    field: {
      begin_date: beginDate,
      end_date: endDate,
      ended,
    },
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

  function typeUsed(optionNo) {
    const type = optionsTypeId.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  function generateAddPreview() {
    return {
      display_data: {
        address: address.value,
        area: {
          entityType: 'area',
          gid: areaGID.value ? areaGID.value : '',
          name: areaName.value ? areaName.value : '',
        },
        begin_date: {
          day: beginDate.field.day.value,
          month: beginDate.field.month.value,
          year: beginDate.field.year.value,
        },
        comment: comment.value,
        coordinates: coordinates.value,
        end_date: {
          day: endDate.field.day.value,
          month: endDate.field.month.value,
          year: endDate.field.year.value,
        },
        ended: ended.value,
        name: name.value,
        place: {
          address: address.value,
          begin_date: {
            day: beginDate.field.day.value,
            month: beginDate.field.month.value,
            year: beginDate.field.year.value,
          },
          comment: comment.value,
          coordinates: coordinates.value,
          end_date: {
            day: endDate.field.day.value,
            month: endDate.field.month.value,
            year: endDate.field.year.value,
          },
          entityType: 'place',
          name: name.value,
          typeID: typeId.value,
        },
        type: typeUsed(typeId.value),
      },
    };
  }

  function generateEditPreview() {
    return {
      display_data: {
        address: {
          new: address.value,
          old: form.field.address.value,
        },
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
        coordinates: {
          new: coordinates.value,
          old: form.field.coordinates.value,
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
        name: {
          new: name.value,
          old: form.field.name.value,
        },
        place: editEntity,
        type: {
          new: typeUsed(typeId.value),
          old: typeUsed(form.field.type_id.value),
        },
      },
    };
  }

  return (
    <>
      <p>
        {exp.l('For more information, check the {doc_doc|documentation}.', {doc_doc: '/doc/Place'})}
      </p>
      <form action={uri} className="edit-place" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Place Details')}</legend>
            <FormRowNameWithGuesscase
              field={name}
              label={l('name')}
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
            <FormRowTextLong
              field={address}
              label={l('Address:')}
              onChange={(e) => {
                setAddress({
                  ...address,
                  value: e.target.value,
                });
              }}
            />
            <FormRow>
              <label htmlFor="id-edit-place.area.name">{l('Area:')}</label>
              <Autocomplete
                currentSelection={{
                  gid: areaGID.value,
                  id: areaId.value,
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
                  setAreaId({
                    ...areaId,
                    value: area.id,
                  });
                }}
              >
                <HiddenField className="gid" field={areaGID} />
                <HiddenField className="id" field={areaId} />
              </Autocomplete>
              <FieldErrors field={areaName} />
              <FieldErrors field={areaGID} />
              <FieldErrors field={areaId} />
            </FormRow>
            <FormRowTextLong
              defaultValue={coordinates.value ? formatCoordinates(coordinates.value) : ''}
              field={coordinates}
              label={l('Coordinates')}
              onChange={(e) => {
                if (e.target.value) {
                  const latlng = e.target.value.split(',');
                  setCoordinates({
                    ...coordinates,
                    value: {
                      latitude: latlng[0].split('°')[0],
                      longitude: latlng[1].split('°')[0],
                    },
                  });
                }
              }}
            />
            <ul className="errors coordinates-errors" style={{display: 'none'}}><li>{l('These coordinates could not be parsed.')}</li></ul>
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
            endedLabel={l('This place has ended.')}
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
              ? <AddPlace edit={generateAddPreview()} />
              : <EditPlace edit={generateEditPreview()} />}
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>

        <div className="documentation">
          <AreaBubble />
          <div className="bubble" id="coordinates-bubble">
            <p>{l('Enter coordinates manually or drag the marker to get coordinates from the map.')}</p>
            <div id="largemap" />
          </div>
        </div>
      </form>
    </>
  );
};

export default hydrate<Props>('div.alias-edit-form', EditForm);
