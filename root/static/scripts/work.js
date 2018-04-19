/*
 * @flow
 * Copyright (C) 2015-2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const $ = require('jquery');
const _ = require('lodash');
const ko = require('knockout');
const React = require('react');
const ReactDOM = require('react-dom');
const {createStore} = require('redux');

const {
  createField,
  FormRowSelectList,
  subfieldErrors,
} = require('../../components/forms');
const {l} = require('./common/i18n');
const {lp_attributes} = require('./common/i18n/attributes');
const MB = require('./common/MB');
const scriptArgs = require('./common/utility/getScriptArgs')();
const {Lens, prop, index, set, compose3} = require('./common/utility/lens');
const {buildOptionsTree} = require('./edit/forms');
const {initializeBubble} = require('./edit/MB/Control/Bubble');
const {initialize_guess_case} = require('./guess-case/MB/Control/GuessCase');

type LanguageField = FieldT<number>;

type LanguageFields = $ReadOnlyArray<LanguageField>;

type WorkAttributeField = CompoundFieldT<{|
  +type_id: FieldT<number | null>,
  +value: FieldT<number | string | null>,
|}>;

type WorkForm = FormT<{|
  +attributes: RepeatableFieldT<WorkAttributeField>,
  +languages: RepeatableFieldT<LanguageField>,
|}>;

/*
 * Flow does not support assigning types within destructuring assignments:
 * https://github.com/facebook/flow/issues/235
 */
const form: WorkForm = scriptArgs.form;
const workAttributeTypeTree: WorkAttributeTypeTreeRootT =
  scriptArgs.workAttributeTypeTree;
const workAttributeValueTree: WorkAttributeTypeAllowedValueTreeRootT =
  scriptArgs.workAttributeValueTree;
const workLanguageOptions: GroupedOptionsT = scriptArgs.workLanguageOptions;

const languagesField: Lens<WorkForm, LanguageFields> =
  compose3(prop('field'), prop('languages'), prop('field'));

const store = createStore(function (state: WorkForm = form, action) {
  switch (action.type) {
    case 'ADD_LANGUAGE':
      state = addLanguageToState(state);
      break;

    case 'EDIT_LANGUAGE':
      state = set(
        (compose3(languagesField, index(action.index), prop('value')):
          Lens<WorkForm, number>),
        action.languageId,
        state,
      );
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
  const languages = form.field.languages.field.slice(0);
  const newForm = set(languagesField, languages, form);
  languages.push(createField(newForm, null));
  return newForm;
}

function removeLanguageFromState(form: WorkForm, i: number): WorkForm {
  const languages = form.field.languages.field.slice(0);
  languages.splice(i, 1);
  return set(languagesField, languages, form);
}

class WorkAttribute {
  allowedValues: () => OptionListT;

  allowedValuesByTypeID: {[number]: OptionListT};

  attributeValue: (?string) => string;

  errors: (?$ReadOnlyArray<string>) => $ReadOnlyArray<string>;

  parent: ViewModel;

  typeHasFocus: (?boolean) => boolean;

  typeID: (?number) => number;

  constructor(
    data: WorkAttributeField,
    parent: ViewModel,
  ) {
    this.attributeValue = ko.observable(data.field.value.value);
    this.errors = ko.observableArray(subfieldErrors(data));
    this.parent = parent;
    this.typeHasFocus = ko.observable(false);
    this.typeID = ko.observable(data.field.type_id.value);

    this.allowedValues = ko.computed(() => {
      const typeID = this.typeID();

      if (this.allowsFreeText()) {
        return [];
      }
      return this.parent.allowedValuesByTypeID[typeID];
    });

    this.typeID.subscribe(newTypeID => {
      // != is used intentionally for type coercion.
      if (this.typeID() != newTypeID) { // eslint-disable-line eqeqeq
        this.attributeValue('');
        this.resetErrors();
      }
    });

    this.attributeValue.subscribe(() => this.resetErrors());
  }

  allowsFreeText() {
    return !this.typeID() ||
      this.parent.attributeTypesByID[this.typeID()].freeText;
  }

  isGroupingType() {
    return !this.allowsFreeText() && this.allowedValues().length === 0;
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

  attributeTypesByID: {[number]: WorkAttributeTypeTreeT};

  allowedValuesByTypeID: {[number]: OptionListT};

  attributes: (?$ReadOnlyArray<WorkAttribute>) =>
    $ReadOnlyArray<WorkAttribute>;

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

    this.allowedValuesByTypeID = _(allowedValues.children)
      .groupBy(x => x.workAttributeTypeID)
      .mapValues(function (children) {
        return buildOptionsTree(
          {children},
          x => lp_attributes(x.value, 'work_attribute_type_allowed_value'),
          'id',
        );
      })
      .value();

    if (_.isEmpty(attributes)) {
      attributes = [
        createField(form, {
          type_id: null,
          value: null,
        }),
      ];
    }

    this.attributes = ko.observableArray(
      _.map(attributes, data => new WorkAttribute(data, this)),
    );
  }

  newAttribute() {
    const attr = new WorkAttribute(createField(form, {
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

ko.applyBindings(
  new ViewModel(
    workAttributeTypeTree,
    workAttributeValueTree,
    form.field.attributes.field,
  ),
  $('#work-attributes')[0],
);

initialize_guess_case('work', 'id-edit-work');

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

function renderWorkLanguages() {
  const workLanguagesNode = document.getElementById('work-languages-editor');
  if (!workLanguagesNode) {
    throw new Error('Mount point #work-languages-editor does not exist');
  }
  const form: WorkForm = store.getState();
  ReactDOM.render(
    <FormRowSelectList
      addId="add-language"
      addLabel={l('Add Language')}
      fieldName={null}
      label={l('Lyrics Languages')}
      name={form.name + '.languages'}
      onAdd={addLanguage}
      onEdit={editLanguage}
      onRemove={removeLanguage}
      options={workLanguageOptions}
      removeClassName="remove-language"
      removeLabel={l('Remove Language')}
      repeatable={form.field.languages}
    />,
    workLanguagesNode,
  );
}

store.subscribe(renderWorkLanguages);
renderWorkLanguages();

initializeBubble('#iswcs-bubble', 'input[name=edit-work\\.iswcs\\.0]');

const typeIdField = 'select[name=edit-work\\.type_id]';
initializeBubble('#type-bubble', typeIdField);
$(typeIdField).on('change', function () {
  if (this.value.match(/\S/g)) {
    $('#type-bubble-default').hide();
    $('.type-bubble-description').hide();
    $(`#type-bubble-description-${this.value}`).show();
  } else {
    $('.type-bubble-description').hide();
    $('#type-bubble-default').show();
  }
});
