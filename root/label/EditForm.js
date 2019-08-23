// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useEffect, useState} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
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

type Props = {
  entityType: string,
  form: LabelFormT,
  optionsTypeId: SelectOptionsT,
  uri: string,
};

const EditForm = ({
  entityType,
  form,
  optionsTypeId,
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
  const [areaName, setAreaName] = useState(form.field.area.field.name);
  const [areaGID, setAreaGID] = useState(form.field.area.field.gid);
  const [areaID, setAreaID] = useState(form.field.area_id);
  const [labelCode, setLabelCode] = useState(form.field.label_code);
  const [ipiCodes, setIpiCodes] = useState(form.field.ipi_codes);
  const [isniCodes, setIsniCodes] = useState(form.field.isni_codes);

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
        </div>
      </form>
    </>
  );
};

export default hydrate<Props>('div.label-edit-form', EditForm);
