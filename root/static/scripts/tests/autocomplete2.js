// @flow

const $ = require('jquery');
const React = require('react');
const ReactDOM = require('react-dom');
const {
  default: Autocomplete2,
  createInitialState: createInitialAutocompleteState,
} = require('../common/components/Autocomplete2');
const {
  default: autocompleteReducer,
} = require('../common/components/Autocomplete2/reducer');
const {keyBy} = require('../common/utility/arrays');

const {linkAttributeTypes} = require('./typeInfo');

const attributeTypesById = keyBy(
  (linkAttributeTypes: $ReadOnlyArray<LinkAttrTypeT>),
  x => String(x.id),
);

const attributeTypeOptions = (
  linkAttributeTypes: $ReadOnlyArray<LinkAttrTypeT>
).map((type) => {
  let level = 0;
  let parentId = type.parent_id;
  let parentType =
    parentId == null ? null : attributeTypesById[String(parentId)];
  while (parentType) {
    level++;
    parentId = parentType.parent_id;
    parentType =
      parentId == null ? null : attributeTypesById[String(parentId)];
  }
  return {
    entity: type,
    id: type.id,
    level,
    name: type.name,
    type: 'option',
  };
});

$(function () {
  const container = document.createElement('div');
  document.body?.insertBefore(container, document.getElementById('page'));

  function reducer(state, action) {
    switch (action.type) {
      case 'update-autocomplete':
        state = {...state};
        state[action.prop] = autocompleteReducer(
          (state[action.prop]: any),
          action.action,
        );
        break;
    }
    return state;
  }

  function createInitialState() {
    return {
      entityAutocomplete: createInitialAutocompleteState<NonUrlCoreEntityT>({
        canChangeType: () => true,
        entityType: 'artist',
        id: 'entity-test',
        width: '200px',
      }),
      vocalAutocomplete: createInitialAutocompleteState<LinkAttrTypeT>({
        entityType: 'link_attribute_type',
        id: 'vocal-test',
        placeholder: 'Choose an attribute type',
        staticItems: attributeTypeOptions,
        width: '200px',
      }),
    };
  }

  const AutocompleteTest = () => {
    const [state, dispatch] = React.useReducer(
      reducer,
      null,
      createInitialState,
    );

    const entityAutocompleteDispatch = React.useCallback((action) => {
      dispatch({
        action,
        prop: 'entityAutocomplete',
        type: 'update-autocomplete',
      });
    }, []);

    const vocalAutocompleteDispatch = React.useCallback((action) => {
      dispatch({
        action,
        prop: 'vocalAutocomplete',
        type: 'update-autocomplete',
      });
    }, []);

    return (
      <>
        <div>
          <h2>{'Entity autocomplete'}</h2>
          <p>
            {'Current entity type:'}
            {' '}
            <select
              onChange={(event) => entityAutocompleteDispatch({
                type: 'change-entity-type',
                entityType: event.target.value,
              })}
              value={state.entityAutocomplete.entityType}
            >
              <option value="area">{'Area'}</option>
              <option value="artist">{'Artist'}</option>
              <option value="event">{'Event'}</option>
              <option value="instrument">{'Instrument'}</option>
              <option value="label">{'Label'}</option>
              <option value="place">{'Place'}</option>
              <option value="recording">{'Recording'}</option>
              <option value="release">{'Release'}</option>
              <option value="release_group">{'Release Group'}</option>
              <option value="series">{'Series'}</option>
              <option value="work">{'Work'}</option>
            </select>
          </p>
          <Autocomplete2
            dispatch={entityAutocompleteDispatch}
            {...state.entityAutocomplete}
          />
        </div>
        <div>
          <h2>{'Vocal autocomplete'}</h2>
          {/* $FlowIssue[incompatible-type] */}
          <Autocomplete2
            dispatch={vocalAutocompleteDispatch}
            {...state.vocalAutocomplete}
          />
        </div>
      </>
    );
  };

  ReactDOM.render(<AutocompleteTest />, container);
});
