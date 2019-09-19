// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useState, useEffect} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import FormRowTextLong from '../components/FormRowTextLong';
import GuessCaseOptions from '../components/GuessCaseOptions';
import hydrate from '../utility/hydrate';
import FormRowSelect from '../components/FormRowSelect';
import FormRowTextList from '../components/FormRowTextList';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';

type WorkFormT = {|
  field: {
    comment: FieldT<string>,
    edit_note: FieldT<string>,
    iswc: FieldT<Array<Object>>,
    make_votable: FieldT<boolean>,
    name: FieldT<string>,
    type_id: FieldT<number>,
  },
  has_errors: boolean,
  name: string,
|};

type Props = {
  entityType: string,
  form: WorkFormT,
  optionsTypeId: SelectOptionsT,
  relationshipEditorHTML: string,
  uri: string,
};

const EditForm = ({entityType, form, uri, optionsTypeId, relationshipEditorHTML}: Props) => {
  const guess = MB.GuessCase[entityType];
  const [
    name,
    setName,
  ] = useState(form.field.name.value ? form.field.name : {...form.field.name, value: ''});
  const [comment, setComment] = useState(form.field.comment);
  const [typeId, setTypeId] = useState(form.field.type_id);

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

  return (
    <>
      <p>{exp.l('For more information, check the {doc_doc|documentation}.', {doc_doc: '/doc/Work'})}</p>

      <form action={uri} className="edit-work" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Work Details')}</legend>
            <FormRowNameWithGuesscase
              field={name}
              label={l('Name')}
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
            <div id="work-languages-editor" />
            <FormRowTextList
              field={form.field.iswcs}
              itemName={l('ISWC')}
              label={l('ISWCs:')}
            />
          </fieldset>
          <fieldset>
            <legend>{l('Work Attributes')}</legend>
            <table className="row-form" data-bind="delegatedHandler: 'click'" id="work-attributes">
              <tbody>
                <div data-bind="foreach: attributes">
                  <tr>
                    <td>
                      <select data-bind="
                        value: typeID,
                        options: $parent.attributeTypes,
                        optionsText: 'text',
                        optionsValue: 'value',
                        optionsCaption: '',
                        attr: {name: 'edit-work.attributes.' + $index() + '.type_id'},
                        hasFocus: typeHasFocus
                        "
                      />
                    </td>
                    <td>
                      <div data-bind="if: allowsFreeText()">
                        <input
                          data-bind="
                          value: attributeValue,
                          attr: { name: 'edit-work.attributes.' + $index() + '.value' }
                          "
                          type="text"
                        />
                      </div>
                      <div data-bind="if: !allowsFreeText() && !isGroupingType()">
                        <select data-bind="
                        value: attributeValue,
                        options: allowedValues,
                        optionsText: 'text',
                        optionsValue: 'value',
                        optionsCaption: '',
                        attr: { name: 'edit-work.attributes.' + $index() + '.value' }"
                        />
                      </div>
                      <div data-bind="if: isGroupingType()">
                        <p>{l('This attribute type is only used for grouping, please select a subtype')}</p>
                      </div>
                    </td>
                    <td>
                      <button className="icon remove-item" data-click="remove" title={l('Remove attribute')} type="button" />
                    </td>
                  </tr>
                  <div data-bind="if: errors().length">
                    <tr>
                      <td />
                      <td colSpan="2">
                        <ul className="errors" data-bind="foreach: errors" style={{marginLeft: 0}}>
                          <li data-bind="text: $data" />
                        </ul>
                      </td>
                    </tr>
                  </div>
                </div>
                <tr>
                  <td />
                  <td className="add-item" colSpan="2">
                    <button className="with-label add-item" data-click="newAttribute" id="add-work-attribute" title={lp('Add Work Attribute', 'button/menu')} type="button">
                      {lp('Add Work Attribute', 'button/menu')}
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </fieldset>
          <div dangerouslySetInnerHTML={{__html: relationshipEditorHTML}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <EnterEditNote field={form.field.edit_note} />
          <EnterEdit form={form} />
        </div>
        <div className="documentation">
          <div className="bubble" id="iswcs-bubble">
            <p>{l('You are about to add an ISWC to this work. The ISWC must be entered instandard <code>T-DDD.DDD.DDD-C</code> format:')}</p>
            <ul>
              <li>{l('"DDD" is a nine digit work identifier.')}</li>
              <li>{l('"C" is a single check digit.')}</li>
            </ul>
          </div>
          <div className="bubble" id="type-bubble">
            <span id="type-bubble-default">
              {l('Select any type from the list to see its description. If the work doesn’t seem to match any type, just leave this blank.')}
            </span>
          </div>
        </div>
      </form>
    </>
  );
};

export default hydrate<Props>('div.work-edit-form', EditForm);
