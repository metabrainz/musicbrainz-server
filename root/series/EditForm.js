// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useState, useEffect} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import DuplicateEntitiesSection from '../components/DuplicateEntitiesSection';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import GuessCaseOptions from '../components/GuessCaseOptions';
import hydrate from '../utility/hydrate';
import FormRowTextLong from '../components/FormRowTextLong';
import FormRowSelect from '../components/FormRowSelect';
import AddSeries from '../edit/details/AddSeries';
import EditSeries from '../edit/details/EditSeries';

type Props = {
  editEntity: SeriesT,
  entityType: string,
  form: SeriesFormT,
  formType: string,
  optionsOrderingTypeId: SelectOptionsT,
  optionsTypeId: SelectOptionsT,
  relationshipEditorHTML?: string,
  seriesOrderingTypes: SeriesOrderingTypeT,
  seriesTypes: SeriesTypeT,
  uri: string,
};

const EditForm = ({
  form,
  formType,
  editEntity,
  entityType,
  uri,
  optionsOrderingTypeId,
  optionsTypeId,
  relationshipEditorHTML,
  seriesTypes,
  seriesOrderingTypes,
}: Props) => {
  const guess = MB.GuessCase[entityType];
  const [
    name,
    setName,
  ] = useState(form.field.name.value ? form.field.name : {...form.field.name, value: ''});
  const [comment, setComment] = useState(form.field.comment);
  const [typeId, setTypeId] = useState(form.field.type_id);
  const [
    orderingTypeId,
    setOrderingTypeId,
  ] = useState(form.field.ordering_type_id);

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

  const orderingTypeOptions = {
    grouped: false,
    options: optionsOrderingTypeId,
  };

  const script = `$(function () {
    MB.seriesTypesByID = ${JSON.stringify(seriesTypes)};
    MB.orderingTypesByID = ${JSON.stringify(seriesOrderingTypes)};
  });`;

  function typeUsed(optionNo) {
    const type = optionsTypeId.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  function orderingTypeUsed(optionNo) {
    const type = optionsOrderingTypeId.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  function generateAddPreview() {
    return {
      display_data: {
        comment: comment.value,
        name: name.value,
        ordering_type: orderingTypeUsed(orderingTypeId.value),
        series: {
          comment: comment.value,
          entityType: 'series',
          name: name.value,
          orderingTypeID: orderingTypeId.value,
          typeID: typeId.value,
        },
        type: typeUsed(typeId.value),
      },
    };
  }

  function generateEditPreview() {
    return {
      display_data: {
        comment: {
          new: comment.value,
          old: form.field.comment.value,
        },
        name: {
          new: name.value,
          old: form.field.name.value,
        },
        ordering_type: {
          new: orderingTypeUsed(orderingTypeId.value),
          old: orderingTypeUsed(form.field.ordering_type_id.value),
        },
        series: editEntity,
        type: {
          new: typeUsed(typeId.value),
          old: typeUsed(form.field.type_id.value),
        },
      },
    };
  }
  return (
    <>
      <p>{exp.l('For more information, check the {doc_doc|documentation} and {doc_styleguide|style guidelines}.', {doc_doc: '/doc/Series', doc_styleguide: '/doc/Style/Series'})}</p>
      <form action={uri} className="edit-series" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Series Details')}</legend>
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
            <FormRowSelect
              field={orderingTypeId}
              label={l('Ordering Type:')}
              onChange={(e) => {
                setOrderingTypeId({
                  ...orderingTypeId,
                  // $FlowFixMe
                  value: e.target.value,
                });
              }}
              options={orderingTypeOptions}
            />
          </fieldset>
          <div dangerouslySetInnerHTML={{__html: relationshipEditorHTML}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <fieldset>
            <legend>{l('Changes')}</legend>
            {formType === 'edit'
              ? <EditSeries edit={generateEditPreview()} />
              : <AddSeries edit={generateAddPreview()} />}
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>

        <div className="documentation">
          <div className="bubble" data-bind="bubble: typeBubble" id="series-type-bubble">
            <p data-bind="text: target() &amp;&amp; target().type() ? target().type().description : ''" />
          </div>

          <div className="bubble" data-bind="bubble: orderingTypeBubble" id="ordering-type-bubble">
            <p data-bind="text: target() ? target().orderingTypeDescription() : ''" />
          </div>
        </div>
      </form>
      <script dangerouslySetInnerHTML={{__html: script}} />
    </>
  );
};

export default hydrate<Props>('div.series-edit-form', EditForm);
