/*
 * @flow
 * Copyright (C) 2015-2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko, {
  type Observable as KnockoutObservable,
  type ObservableArray as KnockoutObservableArray,
} from 'knockout';
import mutate from 'mutate-cow';
import {flushSync} from 'react-dom';
import * as ReactDOMClient from 'react-dom/client';
import {legacy_createStore as createStore} from 'redux';

import '../edit/components/FormRowTextList.js';

import {LANGUAGE_MUL_ID, LANGUAGE_ZXX_ID} from '../common/constants.js';
import {groupBy} from '../common/utility/arrays.js';
import getScriptArgs from '../common/utility/getScriptArgs.js';
import parseIntegerOrNull from '../common/utility/parseIntegerOrNull.js';
import FormRowSelectList from '../edit/components/FormRowSelectList.js';
import {buildOptionsTree} from '../edit/forms.js';
import initializeBubble from '../edit/MB/Control/Bubble.js';
import typeBubble from '../edit/typeBubble.js';
import {createCompoundFieldFromObject} from '../edit/utility/createField.js';
import {pushCompoundField, pushField} from '../edit/utility/pushField.js';
import subfieldErrors from '../edit/utility/subfieldErrors.js';
import initializeGuessCase from '../guess-case/MB/Control/GuessCase.js';

const scriptArgs = getScriptArgs();

type WorkAttributeField = CompoundFieldT<{
  +type_id: FieldT<?number>,
  +value: FieldT<?StrOrNum>,
}>;

type WorkForm = FormT<{
  +attributes: RepeatableFieldT<WorkAttributeField>,
  +languages: RepeatableFieldT<FieldT<?number>>,
}>;

type ActionT =
  | {+type: 'ADD_LANGUAGE'}
  | {
      +index: number,
      +languageId: string,
      +type: 'EDIT_LANGUAGE',
    }
  | {
      index: number,
      type: 'REMOVE_LANGUAGE',
    };

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

/*
 * Without this, ESLint compplains about unexpected whitespace after
 * `ActionT, `, which seems to be an ESLint-related bug, or a bug in
 * the parser we use.
 */
// eslint-disable-next-line @stylistic/js/function-call-spacing
const store = createStore<WorkForm, ActionT, (ActionT) => empty>(function (
  state: WorkForm = form, // eslint-disable-line default-param-last
  action: ActionT,
) {
  switch (action.type) {
    case 'ADD_LANGUAGE':
      state = addLanguageToState(state);
      break;

    case 'EDIT_LANGUAGE':
      state = mutate(state)
        .set(
          'field',
          'languages',
          'field',
          action.index,
          'value',
          parseIntegerOrNull(action.languageId),
        )
        .final();
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
  return mutate(form).update('field', 'languages', (fieldCtx) => {
    pushField(fieldCtx, null);
  }).final();
}

function removeLanguageFromState(form: WorkForm, i: number): WorkForm {
  return mutate(form).update('field', 'languages', 'field', (fieldCtx) => {
    fieldCtx.write().splice(i, 1);
  }).final();
}

class WorkAttribute {
  allowedValues: () => OptionListT;

  attributeValue: KnockoutObservable<?StrOrNum>;

  errors: KnockoutObservableArray<string>;

  parent: ViewModel;

  previousTypeID: ?StrOrNum;

  previousValue: ?StrOrNum;

  typeHasFocus: KnockoutObservable<boolean>;

  typeID: KnockoutObservable<?StrOrNum>;

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
      if (String(this.previousTypeID ?? '') !== String(newTypeID ?? '')) {
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
      if (String(this.previousValue ?? '') !== String(newValue ?? '')) {
        this.resetErrors();
      }
    });
  }

  allowsFreeText(typeID: ?StrOrNum): boolean {
    return !typeID ||
      this.parent.attributeTypesByID[typeID].free_text;
  }

  isGroupingType(): boolean {
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
    const attr = new WorkAttribute(createCompoundFieldFromObject(fieldName, {
      type_id: null,
      value: null,
    }), this);
    attr.typeHasFocus(true);
    this.attributes.push(attr);
  }
}

function byID(
  result: {[id: StrOrNum]: WorkAttributeTypeTreeT},
  parent: WorkAttributeTypeTreeT,
): {[id: StrOrNum]: WorkAttributeTypeTreeT} {
  result[parent.id] = parent;
  if (parent.children) {
    parent.children.reduce(byID, result);
  }
  return result;
}

{
  const attributes = form.field.attributes;
  if (!attributes.field.length) {
    form = mutate(form).update('field', 'attributes', (attributesCtx) => {
      pushCompoundField<{
        +type_id: ?number,
        +value: ?StrOrNum,
      }>(attributesCtx, {
        type_id: null,
        value: null,
      });
    }).final();
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

function editLanguage(i: number, languageId: string) {
  store.dispatch({
    index: i,
    languageId,
    type: 'EDIT_LANGUAGE',
  });
}

function removeLanguage(i: number) {
  store.dispatch({
    index: i,
    type: 'REMOVE_LANGUAGE',
  });
}

const getSelectField = (field: FieldT<?number>) => field;

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
        addLabel={lp('Add language', 'interactive')}
        getSelectField={getSelectField}
        hideAddButton={
          selectedLanguageIds.includes(String(LANGUAGE_MUL_ID)) ||
          selectedLanguageIds.includes(String(LANGUAGE_ZXX_ID))
        }
        label={addColonText(l('Lyrics languages'))}
        onAdd={addLanguage}
        onEdit={editLanguage}
        onRemove={removeLanguage}
        options={workLanguageOptions}
        removeClassName="remove-language"
        removeLabel={lp('Remove language', 'interactive')}
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
