const Immutable = require('immutable');
const ko = require('knockout');
const _ = require('lodash');
const React = require('react');
const ReactDOM = require('react-dom');
const {createStore} = require('redux');

const {
    createField,
    formFromHash,
    FormRowSelectList,
  } = require('../../components/forms');
const {l} = require('./common/i18n');
const {lp_attributes} = require('./common/i18n/attributes');
const {
    form,
    work,
    workAttributeTypeTree,
    workAttributeValueTree,
    workLanguageOptions,
  } = require('./common/utility/getScriptArgs')();

function addLanguageAction(state) {
  return state.updateIn(
    ['field', 'languages', 'field'],
    x => x.push(createField(null))
  );
}

const store = createStore(function (state = formFromHash(form), action) {
  switch (action.type) {
    case 'ADD_LANGUAGE':
      state = addLanguageAction(state);
      break;

    case 'EDIT_LANGUAGE':
      state = state.setIn(
        ['field', 'languages', 'field', action.index, 'value'],
        action.languageId
      );
      break;

    case 'REMOVE_LANGUAGE':
      state = state.deleteIn(['field', 'languages', 'field', action.index]);
      break;
  }

  if (!state.getIn(['field', 'languages', 'field']).size) {
    state = addLanguageAction(state);
  }

  return state;
});

class WorkAttribute {
  constructor(data, parent) {
    this.attributeValue = ko.observable(_.get(data, ['field', 'value', 'value']));
    this.errors = ko.observableArray(data.errors);
    this.parent = parent;
    this.typeHasFocus = ko.observable(false);
    this.typeID = ko.observable(_.get(data, ['field', 'type_id', 'value']));

    this.allowedValues = ko.computed(() => {
      let typeID = this.typeID();

      if (this.allowsFreeText()) {
        return [];
      } else {
        return MB.forms.buildOptionsTree({
          children: _.filter(this.parent.allowedValues.children, function (value) {
            return value.workAttributeTypeID == typeID;
          })
        }, 'value', 'id');
      }
    });

    this.typeID.subscribe(newTypeID => {
      // != is used intentionally for type coercion.
      if (this.typeID() != newTypeID) {
        this.attributeValue("");
        this.resetErrors();
      }
    });

    this.attributeValue.subscribe(() => this.resetErrors());
  }

  allowsFreeText() {
    return !this.typeID() || this.parent.attributeTypesByID[this.typeID()].freeText;
  }

  isGroupingType() {
    return !this.allowsFreeText() && this.allowedValues().length == 0;
  }

  remove() {
    this.parent.attributes.remove(this);
  }

  resetErrors() {
    this.errors([]);
  }
}

class ViewModel {
  constructor(attributeTypes, allowedValues, attributes) {
    attributeTypes.children.forEach(type => {
      type.name = lp_attributes(type.name, 'work_attribute_type');
    });

    allowedValues.children.forEach(value => {
      value.value = lp_attributes(value.value, 'work_attribute_type_allowed_value');
    });

    this.attributeTypes = MB.forms.buildOptionsTree(attributeTypes, 'name', 'id');
    this.attributeTypesByID = _.transform(attributeTypes.children, byID, {});
    this.allowedValues = allowedValues;

    if (_.isEmpty(attributes)) {
      attributes = [{}];
    }

    this.attributes = ko.observableArray(_.map(attributes, data => new WorkAttribute(data, this)));
  }

  newAttribute() {
    let attr = new WorkAttribute({}, this);
    attr.typeHasFocus(true);
    this.attributes.push(attr);
  }
}

function byID(result, parent) {
  result[parent.id] = parent;
  _.transform(parent.children, byID, result);
}

ko.applyBindings(
  new ViewModel(
    workAttributeTypeTree,
    workAttributeValueTree,
    _.get(form, ['field', 'attributes', 'field']),
  ),
  $('#work-attributes')[0]
);

MB.Control.initialize_guess_case('work', 'id-edit-work');

const workLanguagesNode = document.getElementById('work-languages-editor');

function addLanguage() {
  store.dispatch({type: 'ADD_LANGUAGE'});
}

function editLanguage(index, languageId) {
  store.dispatch({
    type: 'EDIT_LANGUAGE',
    index: index,
    languageId: languageId,
  });
}

function removeLanguage(index) {
  store.dispatch({
    type: 'REMOVE_LANGUAGE',
    index: index,
  });
}

function renderWorkLanguages() {
  const form = store.getState();
  ReactDOM.render(
    <FormRowSelectList
      addLabel={l('Add Language')}
      fieldName={null}
      label={l('Lyrics Languages')}
      name={form.name + '.languages'}
      onAdd={addLanguage}
      onEdit={editLanguage}
      onRemove={removeLanguage}
      options={workLanguageOptions}
      removeLabel={l('Remove Language')}
      repeatable={form.field.get('languages')}
    />,
    workLanguagesNode
  );
}

store.subscribe(renderWorkLanguages);
renderWorkLanguages();

MB.Control.initializeBubble('#iswcs-bubble', 'input[name=edit-work\\.iswcs\\.0]');

let typeIdField = 'select[name=edit-work\\.type_id]';
MB.Control.initializeBubble('#type-bubble', typeIdField);
$(typeIdField).on('change', function() {
  if (!this.value.match(/\S/g)) {
    $('.type-bubble-description').hide();
    $('#type-bubble-default').show();
  } else {
    $('#type-bubble-default').hide();
    $('.type-bubble-description').hide();
    $(`#type-bubble-description-${this.value}`).show();
  }
});
