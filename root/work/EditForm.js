// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useState, useEffect, useReducer} from 'react';
import ReactDOM from 'react-dom';
import mutate from 'mutate-cow';
import _ from 'lodash';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import FormRowTextLong from '../components/FormRowTextLong';
import GuessCaseOptions from '../components/GuessCaseOptions';
import hydrate from '../utility/hydrate';
import SelectField from '../components/SelectField';
import FormRowSelect from '../components/FormRowSelect';
import FormRowSelectList from '../components/FormRowSelectList';
import FormRowTextList from '../components/FormRowTextList';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import {pushField} from '../static/scripts/edit/utility/pushField';

type WorkAttributeField = ReadOnlyCompoundFieldT<{|
  +type_id: ReadOnlyFieldT<?number>,
  +value: ReadOnlyFieldT<?StrOrNum>,
|}>;

type WorkFormT = {|
  field: {
    attributes: ReadOnlyRepeatableFieldT<WorkAttributeField>,
    comment: ReadOnlyFieldT<string>,
    edit_note: ReadOnlyFieldT<string>,
    iswcs: ReadOnlyRepeatableFieldT<ReadOnlyFieldT<string>>,
    languages: ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?number>>,
    make_votable: ReadOnlyFieldT<boolean>,
    name: ReadOnlyFieldT<string>,
    type_id: ReadOnlyFieldT<number>,
  },
  has_errors: boolean,
  name: string,
|};

type Props = {
  entityType: string,
  form: WorkFormT,
  optionsLanguageId: GroupedOptionsT,
  optionsTypeId: SelectOptionsT,
  relationshipEditorHTML: string,
  uri: string,
};

const EditForm = ({
  entityType,
  form,
  uri,
  temp,
  optionsLanguageId,
  optionsTypeId,
  relationshipEditorHTML,
}: Props) => {
  const guess = MB.GuessCase[entityType];
  const [
    name,
    setName,
  ] = useState(form.field.name.value ? form.field.name : {...form.field.name, value: ''});
  const [comment, setComment] = useState(form.field.comment);
  const [typeId, setTypeId] = useState(form.field.type_id);

  const {buildOptionsTree} = require('../static/scripts/edit/forms.js');
  const attributeOptions = buildOptionsTree(
    temp.workAttributeTypeTree,
    x => lp_attributes(x.name, 'work_attribute_type'),
    'id',
  );

  const groupedAttrOptions = {
    grouped: false,
    options: attributeOptions.map(element => {
      element.label = element.text;
      return element;
    }),
  };

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

  function addLanguageToState(languages) {
    return mutate<RepeatableFieldT<FieldT<?number>>, ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?number>>>(languages, newLanguages => {
      pushField(newLanguages, null);
    });
  }

  function removeLanguageFromState(languages, i) {
    return mutate<RepeatableFieldT<FieldT<?number>>, ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?number>>>(languages, newLanguages => {
      newLanguages.field.splice(i, 1);
    });
  }

  function languageFieldReducer(state, action) {
    switch (action.type) {
      case 'ADD_LANGUAGE':
        state = addLanguageToState(state);
        return state;
      case 'EDIT_LANGUAGE':
        state = mutate<RepeatableFieldT<FieldT<?number>>, ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?number>>>(state, newState => {
          newState.field[action.index].value = Number(action.languageId);
        });
        return state;
      case 'REMOVE_LANGUAGE':
        state = removeLanguageFromState(state, action.index);
        return state;
      default:
        throw new Error();
    }
  }

  function addISWCToState(state) {
    return mutate<
      RepeatableFieldT<FieldT<?string>>,
      ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?string>>,
    >(state, newState => {
      pushField(newState, null);
    });
  }

  function removeISWCFromState(state, i) {
    return mutate<RepeatableFieldT<FieldT<?string>>,
    ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?string>>>(state, newState => {
      newState.field.splice(i, 1);
    });
  }

  function iswcFieldReducer(state, action) {
    switch (action.type) {
      case 'ADD_ISWC':
        state = addISWCToState(state);
        return state;
      case 'EDIT_ISWC':
        state = mutate<RepeatableFieldT<FieldT<?string>>,
      ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?string>>>(state, newState => {
        newState.field[action.index].value = action.iswc;
      });
        return state;
      case 'REMOVE_ISWC':
        state = removeISWCFromState(state, action.index);
        return state;
      default:
        throw new Error();
    }
  }

  function onChangeAttributesSelect() {
    return undefined;
  }

  const allowedValuesByTypeID = _(allowedValues.children)
    .groupBy(x => x.workAttributeTypeID)
    .mapValues(function (children) {
      return buildOptionsTree(
        {children},
        x => lp_attributes(x.value, 'work_attribute_type_allowed_value'),
        'id',
      );
    })
    .value();

  const attributeTypesById = attributeOptions.reduce(byID, {});

  function byID(result, parent) {
    result[parent.id] = parent;
    if (parent.children) {
      parent.reduce(byID, result);
    }
    return result;
  }

  function allowFreeText(attr) {
    return !attr.field.type_id.value || attributeTypesById[attr.field.type_id.value].free_text;
  }

  function allowedValues(attr) {
    if (allowFreeText(attr.field.type_id.value)) {
      return [];
    }
    return allowedValuesByTypeId[attr.field.type_id.value];
  }

  function isGroupingType(attr) {
    return !allowFreeText(attr) || allowedValues(attr).length === 0;
  }

  function renderAttributes(attributes) {
    return attributes.field.map((attr, index) => {
      return (
        <tr key={attr.id}>
          <td>
            <SelectField
              allowEmpty
              field={attr.field.type_id}
              onChange={onChangeAttributesSelect}
              options={groupedAttrOptions}
            />
          </td>
          {console.log(attributes)}
          <td>
            {allowFreeText(attr) ? (
              <input
                value={attr.field.value.value}
              />
            ) : allowedValues(attr) ? null : (
              <SelectField
                allowEmpty
                field={attr.field.value}
                options={allowedValues(attr)}
              />
            )}
            {allowedValues(attr) ? (
              <p>{l('This attribute type is only used for grouping, please select a subtype')}</p>
            ) : null}
          </td>
        </tr>
      );
    });
  }

  const [languageState, languageDispatch] = useReducer<
    ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?number>>,
    _
  >(languageFieldReducer, form.field.languages);

  const [iswcState, iswcDispatch] = useReducer<
    ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?string>>,
    _
  >(iswcFieldReducer, form.field.iswcs);

  console.log(attributeOptions);

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
            <FormRowSelectList
              addId="add-language"
              addLabel={l('Add Language')}
              getSelectField={_.identity}
              hideAddButton={_.intersection(form.field.languages.field.map(lang => String(lang.value)), ['486', '284']).length > 0}
              label={l('Lyrics Languages')}
              onAdd={() => {
                languageDispatch({type: 'ADD_LANGUAGE'});
              }}
              onEdit={(i, languageId) => {
                languageDispatch({
                  index: i,
                  languageId,
                  type: 'EDIT_LANGUAGE',
                });
              }}
              onRemove={(i) => {
                languageDispatch({
                  index: i,
                  type: 'REMOVE_LANGUAGE',
                });
              }}
              options={optionsLanguageId}
              removeClassName="remove-language"
              removeLabel={l('Remove Language')}
              repeatable={languageState}
            />
            <FormRowTextList
              itemName={l('ISWC')}
              label={l('ISWCs:')}
              onAdd={() => iswcDispatch({
                type: 'ADD_ISWC',
              })}
              onEdit={(index, iswc) => {
                iswcDispatch({
                  index,
                  iswc,
                  type: 'EDIT_ISWC',
                });
              }}
              onRemove={(index) => iswcDispatch({
                index,
                type: 'REMOVE_ISWC',
              })}
              textList={iswcState}
            />
          </fieldset>
          <fieldset>
            <legend>{l('Work Attributes')}</legend>
            <table className="row-form" id="work-attributes">
              <tbody>
                {renderAttributes(form.field.attributes)}
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
