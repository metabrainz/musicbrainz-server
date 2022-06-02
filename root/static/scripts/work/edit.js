/*
 * @flow
 * Copyright (C) 2015-2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import mutate from 'mutate-cow';
// $FlowIgnore[missing-export]
import {flushSync} from 'react-dom';
import * as ReactDOMClient from 'react-dom/client';
import {createStore} from 'redux';

import FormRowSelectList from '../../../components/FormRowSelectList';
import subfieldErrors from '../../../utility/subfieldErrors';
import {groupBy} from '../common/utility/arrays';
import getScriptArgs from '../common/utility/getScriptArgs';
import {buildOptionsTree} from '../edit/forms';
import typeBubble from '../edit/typeBubble';
import {initializeBubble} from '../edit/MB/Control/Bubble';
import {createCompoundField} from '../edit/utility/createField';
import {pushCompoundField, pushField} from '../edit/utility/pushField';
import {initializeGuessCase} from '../guess-case/MB/Control/GuessCase';
import {LANGUAGE_MUL_ID, LANGUAGE_ZXX_ID} from '../common/constants';

const scriptArgs = getScriptArgs();

type WorkAttributeField = ReadOnlyCompoundFieldT<{
  +type_id: ReadOnlyFieldT<?number>,
  +value: ReadOnlyFieldT<?StrOrNum>,
}>;

type WorkForm = FormT<{
  +attributes: ReadOnlyRepeatableFieldT<WorkAttributeField>,
  +languages: ReadOnlyRepeatableFieldT<ReadOnlyFieldT<?number>>,
}>;

type WritableWorkAttributeField = CompoundFieldT<{
  +type_id: FieldT<?number>,
  +value: FieldT<?StrOrNum>,
}>;

type WritableWorkForm = FormT<{
  +attributes: RepeatableFieldT<WritableWorkAttributeField>,
  +languages: RepeatableFieldT<FieldT<?number>>,
}>;

/*
 * Flow does not support assigning types within destructuring assignments:
 * https://github.com/facebook/flow/issues/235
 */
let form: WorkForm = scriptArgs.form;
const workAttributeTypeTree: WorkAttributeTypeTreeRootT =
  scriptArgs.workAttributeTypeTree;
const workAttributeValueTree: WorkAttributeTypeAllowedValueTreeRootT =
  scriptArgs.workAttributeValueTree;
const workLanguageOptions: MaybeGroupedOptionsT = {
  grouped: true,
  options: scriptArgs.workLanguageOptions,
};

const store = createStore(function (state: WorkForm = form, action) {
  switch (action.type) {
    case 'ADD_LANGUAGE':
      state = addLanguageToState(state);
      break;

    case 'EDIT_LANGUAGE':
      state = mutate<WorkForm, _>(state, newState => {
        newState.field.languages.field[action.index].value =
          action.languageId;
      });
      break;

    case 'REMOVE_LANGUAGE':
      state = removeLanguageFromState(state, action.index);
      break;
  }

  if (!state.field.languages.field.length) {
    state = addLanguageToState(state);
  }

  return state;
});

function addLanguageToState(form: WorkForm): WorkForm {
  return mutate<WritableWorkForm, _>(form, newForm => {
    pushField(newForm.field.languages, null);
  });
}

function removeLanguageFromState(form: WorkForm, i: number): WorkForm {
  return mutate<WritableWorkForm, _>(form, newForm => {
    newForm.field.languages.field.splice(i, 1);
  });
}

class WorkAttribute {
  allowedValues: () => OptionListT;

  attributeValue: KnockoutObservable<string>;

  errors: KnockoutObservableArray<string>;

  parent: ViewModel;

  previousTypeID: number | null;

  previousValue: string | null;

  typeHasFocus: KnockoutObservable<boolean>;

  typeID: KnockoutObservable<number>;

  constructor(
    data: WorkAttributeField,
    parent: ViewModel,
  ) {
    this.attributeValue = ko.observable(data.field.value.value);
    this.errors = ko.observableArray(subfieldErrors(data));
    this.parent = parent;
    this.previousTypeID = null;
    this.previousValue = null;
    this.typeHasFocus = ko.observable(false);
    this.typeID = ko.observable(data.field.type_id.value);

    this.allowedValues = ko.computed(() => {
      const typeID = this.typeID();

      if (this.allowsFreeText(typeID)) {
        return [];
      }
      return this.parent.allowedValuesByTypeID.get(String(typeID)) ?? [];
    });

    this.typeID.subscribe((previousTypeID => {
      this.previousTypeID = previousTypeID;
    }), this, 'beforeChange');

    this.typeID.subscribe(newTypeID => {
      // != is used intentionally for type coercion.
      if (this.previousTypeID != newTypeID) { // eslint-disable-line eqeqeq
        // Don't blank text value if user e.g. misclicked and corrects type
        if (!(this.allowsFreeText(this.previousTypeID) &&
              this.allowsFreeText(newTypeID))) {
          this.attributeValue('');
        }
        this.resetErrors();
      }
    });

    this.attributeValue.subscribe((previousValue => {
      this.previousValue = previousValue;
    }), this, 'beforeChange');

    this.attributeValue.subscribe(newValue => {
      // != is used intentionally for type coercion.
      if (this.previousValue != newValue) { // eslint-disable-line eqeqeq
        this.resetErrors();
      }
    });
  }

  allowsFreeText(typeID) {
    return !typeID ||
      this.parent.attributeTypesByID[typeID].free_text;
  }

  isGroupingType() {
    return !this.allowsFreeText(this.typeID()) &&
           this.allowedValues().length === 0;
  }

  remove() {
    this.parent.attributes.remove(this);
  }

  resetErrors() {
    this.errors([]);
  }
}

class ViewModel {
  attributeTypes: OptionListT;

  attributeTypesByID: {[typeId: StrOrNum]: WorkAttributeTypeTreeT, ...};

  allowedValuesByTypeID: $ReadOnlyMap<string, OptionListT>;

  attributes: KnockoutObservableArray<WorkAttribute>;

  constructor(
    attributeTypes: WorkAttributeTypeTreeRootT,
    allowedValues: WorkAttributeTypeAllowedValueTreeRootT,
    attributes: $ReadOnlyArray<WorkAttributeField>,
  ) {
    this.attributeTypes = buildOptionsTree(
      attributeTypes,
      x => lp_attributes(x.name, 'work_attribute_type'),
      'id',
    );

    this.attributeTypesByID = attributeTypes.children.reduce(byID, {});

    this.allowedValuesByTypeID = new Map(
      Array.from(
        groupBy(
          allowedValues.children,
          x => String(x.workAttributeTypeID),
        ).entries(),
      ).map(([typeId, children]) => [
        typeId,
        buildOptionsTree(
          {children},
          x => lp_attributes(x.value, 'work_attribute_type_allowed_value'),
          'id',
        ),
      ]),
    );

    this.attributes = ko.observableArray(
      attributes.map(data => new WorkAttribute(data, this)),
    );
  }

  newAttribute() {
    const attributesField = form.field.attributes;
    const fieldName = attributesField.html_name + '.' +
      String(attributesField.field.length);
    const attr = new WorkAttribute(createCompoundField(fieldName, {
      type_id: null,
      value: null,
    }), this);
    attr.typeHasFocus(true);
    this.attributes.push(attr);
  }
}

function byID(result, parent) {
  result[parent.id] = parent;
  if (parent.children) {
    parent.children.reduce(byID, result);
  }
  return result;
}

{
  const attributes = form.field.attributes;
  if (!attributes.field.length) {
    form = mutate<WritableWorkForm, _>(form, newForm => {
      pushCompoundField(newForm.field.attributes, {
        type_id: null,
        value: null,
      });
    });
  }
}

ko.applyBindings(
  new ViewModel(
    workAttributeTypeTree,
    workAttributeValueTree,
    form.field.attributes.field,
  ),
  $('#work-attributes')[0],
);

initializeGuessCase('work', 'id-edit-work');

function addLanguage() {
  store.dispatch({type: 'ADD_LANGUAGE'});
}

function editLanguage(i, languageId) {
  store.dispatch({
    index: i,
    languageId: languageId,
    type: 'EDIT_LANGUAGE',
  });
}

function removeLanguage(i) {
  store.dispatch({
    index: i,
    type: 'REMOVE_LANGUAGE',
  });
}

const getSelectField = field => field;

const workLanguagesNode = document.getElementById('work-languages-editor');
if (!workLanguagesNode) {
  throw new Error('Mount point #work-languages-editor does not exist');
}
const workLanguagesRoot = ReactDOMClient.createRoot(workLanguagesNode);

function renderWorkLanguages() {
  const form: WorkForm = store.getState();
  const selectedLanguageIds =
    form.field.languages.field.map(lang => String(lang.value));
  flushSync(() => {
    workLanguagesRoot.render(
      <FormRowSelectList
        addId="add-language"
        addLabel={l('Add Language')}
        getSelectField={getSelectField}
        hideAddButton={
          selectedLanguageIds.includes(String(LANGUAGE_MUL_ID)) ||
          selectedLanguageIds.includes(String(LANGUAGE_ZXX_ID))
        }
        label={l('Lyrics Languages')}
        onAdd={addLanguage}
        onEdit={editLanguage}
        onRemove={removeLanguage}
        options={workLanguageOptions}
        removeClassName="remove-language"
        removeLabel={l('Remove Language')}
        repeatable={form.field.languages}
      />,
    );
  });
}

store.subscribe(renderWorkLanguages);
renderWorkLanguages();

initializeBubble('#iswcs-bubble', 'input[name=edit-work\\.iswcs\\.0]');

const typeIdField = 'select[name=edit-work\\.type_id]';
typeBubble(typeIdField);
