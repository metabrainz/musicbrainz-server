// @flow
import React, {useEffect} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import * as manifest from '../static/manifest';
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
import SearchIcon from '../static/scripts/common/components/SearchIcon';
import HiddenField from '../components/HiddenField';
import FieldErrors from '../components/FieldErrors';
import AreaBubble from '../components/AreaBubble';

type Props = {
  $c: CatalystContextT,
  entityType: string,
  form: PlaceFormT,
  optionsTypeId: SelectOptionsT,
};

const EditForm = ({$c, entityType, form, optionsTypeId}: Props) => {
  const guess = MB.GuessCase[entityType];

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
  console.log(form);
  return (
    <>
      {manifest.js('edit.js')}
      <p>
        {exp.l('For more information, check the {doc_doc|documentation}.', {doc_doc: '/doc/Place'})}
      </p>
      <form action={$c.req.uri} className="edit-place" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Place Details')}</legend>
            <FormRowNameWithGuesscase
              field={form.field.name}
              label={l('name')}
              // eslint-disable-next-line react/jsx-no-bind
              onPressGuessCaseOptions={() => {
                const $ = require('jquery');
                return $('#guesscase-options').dialog('open');
              }}
              options={{label: l('Name')}}
              required
            />
            <DuplicateEntitiesSection />
            <FormRowTextLong
              field={form.field.comment}
              label={addColonText(l('Disambiguation'))}
            />
            <FormRowSelect
              allowEmpty
              field={form.field.type_id}
              label={l('Type:')}
              options={typeOptions}
            />
            <FormRowTextLong
              field={form.field.address}
              label={l('Address:')}
            />
            <FormRow>
              <label htmlFor="id-edit-place.area.name">{l('Area:')}</label>
              <span className="area autocomplete">
                <SearchIcon />
                <HiddenField className="gid" field={form.field.area.field.gid} />
                <HiddenField className="id" field={form.field.area_id} />
                <input className="name" value={form.field.area.name} />
              </span>
              <FieldErrors field={form.field.area.name} />
            </FormRow>
            <FormRowTextLong
              field={form.field.coordinates}
              label={l('Coordinates')}
            />
            <ul className="errors coordinates-errors" style={{display: 'none'}}><li>{l('These coordinates could not be parsed.')}</li></ul>
          </fieldset>
          <DateRangeFieldset endedLabel={l('This place has ended.')} period={form.field.period} />
          <div dangerouslySetInnerHTML={{__html: $c.stash.relationship_editor_html}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>

        <div className="documentation">
          <AreaBubble />
          <div className="bubble" id="coordinates-bubble">
            <p>{l('Enter coordinates manually or drag the marker to get coordinates from the map.')}</p>
            <div id="largemap" />
            {manifest.js('place/map.js')}
          </div>
        </div>
      </form>
      {manifest.js('place.js')}
    </>
  );
};

export default hydrate<Props>('div.alias-edit-form', EditForm);
