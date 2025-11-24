/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import mutate from 'mutate-cow';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {LabelFormT} from '../../../../label/types.js';
import {
  createInitialState as createInitialAutocompleteState,
} from '../../common/components/Autocomplete2.js';
import autocompleteReducer
  from '../../common/components/Autocomplete2/reducer.js';
import type {
  ActionT as AutocompleteActionT,
  StateT as AutocompleteStateT,
} from '../../common/components/Autocomplete2/types.js';
import Bubble from '../../common/components/Bubble.js';
import SelectedAreaMessage
  from '../../common/components/SelectedAreaMessage.js';
import TypeBubble from '../../common/components/TypeBubble.js';
import {createAreaObject} from '../../common/entity2.js';
import useFormUnloadWarning from '../../common/hooks/useFormUnloadWarning.js';
import {
  getSourceEntityDataForRelationshipEditor,
} from '../../common/utility/catalyst.js';
import debounce from '../../common/utility/debounce.js';
import isBlank from '../../common/utility/isBlank.js';
import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  runReducer as runDateRangeFieldsetReducer,
} from '../../edit/components/DateRangeFieldset.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowAreaAutocomplete
  from '../../edit/components/FormRowAreaAutocomplete.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import {
  createInitialState as createInitialDuplicatesState,
} from '../../edit/components/PossibleDuplicates.js';
import FormRowPossibleDuplicates
  from '../../edit/components/FormRowPossibleDuplicates.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowText from '../../edit/components/FormRowText.js';
import FormRowTextListSimple, {
  type ActionT as CodesActionT,
  type StateT as CodesStateT,
  createInitialState as createCodesState,
  runReducer as runCodesReducer,
} from '../../edit/components/FormRowTextListSimple.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {
  type StateT as GuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
} from '../../edit/components/GuessCaseOptions.js';
import {
  _ExternalLinksEditor,
  ExternalLinksEditor,
  prepareExternalLinksHtmlFormSubmission,
} from '../../edit/externalLinks.js';
import isInvalidEditNote from '../../edit/utility/isInvalidEditNote.js';
import isValidIpi from '../../edit/utility/isValidIpi.js';
import isValidIsni from '../../edit/utility/isValidIsni.js';
import isValidLabelCode from '../../edit/utility/isValidLabelCode.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../edit/utility/subfieldErrors.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'set-type', +type_id: string}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'toggle-bubble', +bubble: string}
  | {
      +action: AutocompleteActionT<AreaT>,
      +type: 'update-area',
    }
  | {+type: 'update-date-range', +action: DateRangeFieldsetActionT}
  | {+type: 'update-edit-note', +editNote: string}
  | {+type: 'update-ipis', +action: CodesActionT}
  | {+type: 'update-isnis', +action: CodesActionT}
  | {+type: 'update-label-code', +labelCode: string}
  | {+type: 'update-name', +action: NameActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +actionName: string,
  +area: AutocompleteStateT<AreaT>,
  +form: LabelFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +label: LabelT,
  +shownBubble: string,
};

type CreateInitialStatePropsT = {
  +$c: SanitizedCatalystContextT,
  +form: LabelFormT,
};

function updateIpiFieldErrors(
  fieldCtx: CowContext<CodesStateT>,
) {
  const innerFieldCtx = fieldCtx.get('field');
  const innerFieldLength = innerFieldCtx.read().length;
  for (let i = 0; i < innerFieldLength; i++) {
    const subFieldCtx = innerFieldCtx.get(i);
    const value = subFieldCtx.get('value').read();

    if (empty(value) || isValidIpi(value)) {
      subFieldCtx.set('has_errors', false);
      subFieldCtx.set('pendingErrors', []);
      subFieldCtx.set('errors', []);
    } else {
      subFieldCtx.set('has_errors', true);
      subFieldCtx.set('errors', [
        l('This is not a valid IPI.'),
      ]);
    }
  }
}

function updateIsniFieldErrors(
  fieldCtx: CowContext<CodesStateT>,
) {
  const innerFieldCtx = fieldCtx.get('field');
  const innerFieldLength = innerFieldCtx.read().length;
  for (let i = 0; i < innerFieldLength; i++) {
    const subFieldCtx = innerFieldCtx.get(i);
    const value = subFieldCtx.get('value').read();

    if (empty(value) || isValidIsni(value)) {
      subFieldCtx.set('has_errors', false);
      subFieldCtx.set('pendingErrors', []);
      subFieldCtx.set('errors', []);
    } else {
      subFieldCtx.set('has_errors', true);
      subFieldCtx.set('errors', [
        l('This is not a valid ISNI.'),
      ]);
    }
  }
}

function updateLabelCodeFieldErrors(
  labelCodeFieldCtx: CowContext<FieldT<string | null>>,
) {
  const labelCode = labelCodeFieldCtx.get('value').read();
  if (labelCode && !isValidLabelCode(labelCode)) {
    labelCodeFieldCtx.set('has_errors', true);
    labelCodeFieldCtx.set('errors', [
      l('Label codes must be greater than 0 and 6 digits at most'),
    ]);
  } else {
    labelCodeFieldCtx.set('has_errors', false);
    labelCodeFieldCtx.set('pendingErrors', []);
    labelCodeFieldCtx.set('errors', []);
  }
}

function updateNameFieldErrors(
  nameFieldCtx: CowContext<FieldT<string | null>>,
) {
  if (isBlank(nameFieldCtx.get('value').read())) {
    nameFieldCtx.set('has_errors', true);
    nameFieldCtx.set('pendingErrors', [
      l('Required field.'),
    ]);
  } else {
    nameFieldCtx.set('has_errors', false);
    nameFieldCtx.set('pendingErrors', []);
    nameFieldCtx.set('errors', []);
  }
}

function updateNoteFieldErrors(
  actionName: string,
  editNoteFieldCtx: CowContext<FieldT<string>>,
) {
  const editNote = editNoteFieldCtx.get('value').read();
  if (isInvalidEditNote(editNote)) {
    editNoteFieldCtx.set('has_errors', true);
    editNoteFieldCtx.set('errors', [
      l(`Your edit note seems to have no actual content.
         Please provide a note that will be helpful to
         your fellow editors!`),
    ]);
  } else {
    editNoteFieldCtx.set('has_errors', false);
    editNoteFieldCtx.set('pendingErrors', []);
    editNoteFieldCtx.set('errors', []);
  }
}

function createInitialState({
  $c,
  form,
}: CreateInitialStatePropsT): StateT {
  const areaField = form.field.area;
  const areaSubfields = areaField.field;
  const areaGid = areaSubfields.gid.value ?? '';
  const areaId = parseInt(areaSubfields.id.value ?? '0', 10);
  const areaName = areaSubfields.name.value;
  const label = getSourceEntityDataForRelationshipEditor($c);
  const actionName = $c.action.name;
  invariant(label && label.entityType === 'label');

  const formCtx = mutate(form);
  // $FlowExpectedError[incompatible-call]
  const nameFieldCtx = formCtx.get('field', 'name');
  updateNameFieldErrors(nameFieldCtx);
  formCtx
    .update('field', 'ipi_codes', (ipiCtx) => {
      ipiCtx.set(createCodesState(ipiCtx.read()));
      updateIpiFieldErrors(ipiCtx);
    });
  formCtx
    .update('field', 'isni_codes', (isniCtx) => {
      isniCtx.set(createCodesState(isniCtx.read()));
      updateIsniFieldErrors(isniCtx);
    });
  const editNoteFieldCtx = formCtx.get('field', 'edit_note');
  updateNoteFieldErrors(actionName, editNoteFieldCtx);

  return {
    actionName,
    area: createInitialAutocompleteState({
      containerClass: 'area-field',
      entityType: 'area',
      htmlName: areaField.html_name,
      id: 'id-' + areaField.html_name,
      inputValue: areaName,
      label: l('Area'),
      selectedItem: areaId ? {
        entity: createAreaObject({gid: areaGid, id: areaId, name: areaName}),
        id: areaId,
        name: areaName,
        type: 'option',
      } : null,
      showLabel: true,
    }),
    duplicates: createInitialDuplicatesState(),
    form: formCtx.final(),
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    label,
    shownBubble: '',
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);

  match (action) {
    {type: 'update-area', const action} => {
      const areaAutocomplete = autocompleteReducer(state.area, action);
      const areaId = areaAutocomplete.selectedItem?.entity?.id ?? '';
      newStateCtx.set(
        'area',
        areaAutocomplete,
      ).set('form', 'field', 'area_id', 'value', String(areaId));
    }
    {type: 'update-date-range', const action} => {
      runDateRangeFieldsetReducer(
        newStateCtx.get('form', 'field', 'period'),
        action,
      );
    }
    {type: 'update-edit-note', const editNote} => {
      newStateCtx
        .update('form', 'field', 'edit_note', (editNoteFieldCtx) => {
          editNoteFieldCtx.set('value', editNote);
          updateNoteFieldErrors(state.actionName, editNoteFieldCtx);
        });
    }
    {type: 'update-label-code', const labelCode} => {
      newStateCtx
        .update('form', 'field', 'label_code', (labelCodeFieldCtx) => {
          labelCodeFieldCtx.set('value', labelCode);
          updateLabelCodeFieldErrors(labelCodeFieldCtx);
        });
    }
    {type: 'update-name', const action} => {
      const nameStateCtx = mutate({
        field: state.form.field.name,
        guessCaseOptions: state.guessCaseOptions,
        isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
      });
      runNameReducer(nameStateCtx, action);

      const nameState = nameStateCtx.final();
      newStateCtx
        .update('form', 'field', 'name', (nameFieldCtx) => {
          nameFieldCtx.set(nameState.field);
          updateNameFieldErrors(nameFieldCtx);
        })
        .set('guessCaseOptions', nameState.guessCaseOptions)
        .set('isGuessCaseOptionsOpen', nameState.isGuessCaseOptionsOpen);
    }
    {type: 'set-type', const type_id} => {
      newStateCtx
        .update('form', 'field', 'type_id', (typeIdFieldCtx) => {
          typeIdFieldCtx.set('value', type_id);
        });
    }
    {type: 'update-ipis', const action} => {
      const ipiStateCtx = mutate(state.form.field.ipi_codes);
      runCodesReducer(ipiStateCtx, action);

      const ipiState = ipiStateCtx.read();
      newStateCtx
        .update('form', 'field', 'ipi_codes', (ipiFieldCtx) => {
          ipiFieldCtx.set(ipiState);
          updateIpiFieldErrors(ipiFieldCtx);
        });
    }
    {type: 'update-isnis', const action} => {
      const isniStateCtx = mutate(state.form.field.isni_codes);
      runCodesReducer(isniStateCtx, action);

      const isniState = isniStateCtx.read();
      newStateCtx
        .update('form', 'field', 'isni_codes', (isniFieldCtx) => {
          isniFieldCtx.set(isniState);
          updateIsniFieldErrors(isniFieldCtx);
        });
    }
    {type: 'toggle-bubble', const bubble} => {
      newStateCtx.set('shownBubble', bubble);
    }
    {type: 'show-all-pending-errors'} => {
      applyAllPendingErrors(newStateCtx.get('form'));
    }
  }
  return newStateCtx.final();
}

component LabelEditForm(
  labelDescriptions: {+[id: string]: string},
  form as initialForm: LabelFormT,
  labelTypes: SelectOptionsT,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const typeOptions = {
    grouped: false as const,
    options: labelTypes,
  };

  useFormUnloadWarning();

  const [state, dispatch] = React.useReducer(
    reducer,
    {$c, form: initialForm},
    createInitialState,
  );

  const origName = React.useRef(state.form.field.name.value || '');

  React.useEffect(() => {
    let cancelled = false;
    fetchPossibleDuplicates(
      entityType,
      state.recentItemsKey,
    ).then((loadedRecentItems) => {
      if (cancelled) {
        return [];
      }
      if (loadedRecentItems !== state.recentItems) {
        setTimeout(() => {
          dispatch({
            items: loadedRecentItems,
            type: 'set-recent-items',
          });
        }, 1);
      }
      return loadedRecentItems;
    }).catch((error) => {
      console.error(error);
      Sentry.captureException(error);
    });
    return () => {
      cancelled = true;
    };
  }, [
    dispatch,
    entityType,
    origName,
    state.duplicates,
    state.form.field.name.value,
  ]);

  const areaDispatch = React.useCallback((
    action: AutocompleteActionT<AreaT>,
  ) => {
    dispatch({action, type: 'update-area'});
  }, [dispatch]);

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const ipiDispatch = React.useCallback((action: CodesActionT) => {
    dispatch({action, type: 'update-ipis'});
  }, [dispatch]);

  const isniDispatch = React.useCallback((action: CodesActionT) => {
    dispatch({action, type: 'update-isnis'});
  }, [dispatch]);

  const handleEditNoteChange = React.useCallback((
    event: SyntheticEvent<HTMLTextAreaElement>,
  ) => {
    dispatch({
      editNote: event.currentTarget.value,
      type: 'update-edit-note',
    });
  }, [dispatch]);

  const handleLabelCodeChange = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      labelCode: event.currentTarget.value,
      type: 'update-label-code',
    });
  }, [dispatch]);

  function handleCommentFocus() {
    dispatch({bubble: 'comment', type: 'toggle-bubble'});
  }

  function handleAreaFocus() {
    dispatch({bubble: 'area', type: 'toggle-bubble'});
  }

  function handleIpiFocus() {
    dispatch({bubble: 'ipi', type: 'toggle-bubble'});
  }

  function handleIsniFocus() {
    dispatch({bubble: 'isni', type: 'toggle-bubble'});
  }

  function handleLabelCodeFocus() {
    dispatch({bubble: 'label-code', type: 'toggle-bubble'});
  }

  function handleNameFocus() {
    dispatch({bubble: 'name', type: 'toggle-bubble'});
  }

  function handleTypeFocus() {
    dispatch({bubble: 'type', type: 'toggle-bubble'});
  }

  function handleExternalLinksFocus() {
    dispatch({bubble: 'external-links', type: 'toggle-bubble'});
  }

  const setType = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    dispatch({type: 'set-type', type_id: event.currentTarget.value});
  }, [dispatch]);

  const dispatchDateRange = React.useCallback((
    action: DateRangeFieldsetActionT,
  ) => {
    dispatch({action, type: 'update-date-range'});
  }, [dispatch]);

  const hasErrors = hasSubfieldErrors(state.form);

  const externalLinksEditorRef = React.createRef<_ExternalLinksEditor>();

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event: SyntheticKeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter' && hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
    }
  };

  const handleSubmit = (event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
    invariant(externalLinksEditorRef.current);
    prepareExternalLinksHtmlFormSubmission(
      'edit-label',
      externalLinksEditorRef.current,
    );
  };

  const areaField = state.form.field.area;

  const nameFieldRef = React.useRef<HTMLDivElement | null>(null);
  const commentFieldRef = React.useRef<HTMLDivElement | null>(null);
  const labelCodeFieldRef = React.useRef<HTMLDivElement | null>(null);
  const areaFieldRef = React.useRef<HTMLDivElement | null>(null);
  const ipiFieldRef = React.useRef<HTMLDivElement | null>(null);
  const isniFieldRef = React.useRef<HTMLDivElement | null>(null);
  const typeSelectRef = React.useRef<HTMLDivElement | null>(null);
  const dateFieldRef = React.useRef<HTMLFieldSetElement | null>(null);
  const externalLinksTableRef = React.useRef<HTMLTableElement | null>(null);

  return (
    <form
      className="edit-label"
      method="post"
      onKeyDown={handleKeyDown}
      onSubmit={handleSubmit}
    >
      <p>
        {exp.l(
          'For more information, check the {doc_doc|documentation}.',
          {doc_doc: {href: '/doc/Label', target: '_blank'}},
        )}
      </p>

      <div className="half-width">
        <fieldset>
          <legend>{l('Label details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={state.label}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label={addColonText(l('Name'))}
            onFocus={handleNameFocus}
            rowRef={nameFieldRef}
          />
          <FormRowPossibleDuplicates />
          <FormRowTextLong
            field={state.form.field.comment}
            label={addColonText(l('Disambiguation'))}
            onFocus={handleCommentFocus}
            rowRef={commentFieldRef}
            uncontrolled
          />
          {/*         [%- disambiguation_error() -%] */}
          <FormRowSelect
            allowEmpty
            field={state.form.field.type_id}
            label={addColonText(l('Type'))}
            onChange={setType}
            onFocus={handleTypeFocus}
            options={typeOptions}
            rowRef={typeSelectRef}
          />
          <input
            name={state.form.field.area_id.html_name}
            type="hidden"
            value={state.form.field.area_id.value}
          />
          <FormRowAreaAutocomplete
            areaField={areaField}
            dispatch={areaDispatch}
            onFocus={handleAreaFocus}
            rowRef={areaFieldRef}
            state={state.area}
          />
          <FormRowText
            className="label-code"
            field={state.form.field.label_code}
            label={addColonText(l('Label code'))}
            onChange={handleLabelCodeChange}
            onFocus={handleLabelCodeFocus}
            preInput="LC- "
            rowRef={labelCodeFieldRef}
            size={5}
          />
          <FormRowTextListSimple
            addButtonId="add-ipi-code"
            addButtonLabel={lp('Add IPI code', 'interactive')}
            dispatch={ipiDispatch}
            label={addColonText(l('IPI codes'))}
            onFocus={handleIpiFocus}
            removeButtonLabel={lp('Remove IPI code', 'interactive')}
            rowRef={ipiFieldRef}
            state={state.form.field.ipi_codes}
          />
          <FormRowTextListSimple
            addButtonId="add-isni-code"
            addButtonLabel={lp('Add ISNI code', 'interactive')}
            dispatch={isniDispatch}
            label={addColonText(l('ISNI codes'))}
            onFocus={handleIsniFocus}
            removeButtonLabel={lp('Remove ISNI code', 'interactive')}
            rowRef={isniFieldRef}
            state={state.form.field.isni_codes}
          />
        </fieldset>

        <DateRangeFieldset
          dispatch={dispatchDateRange}
          field={state.form.field.period}
          fieldSetRef={dateFieldRef}
        />

        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />

        <fieldset>
          <legend>{l('External links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!state.label.id}
            onFocus={handleExternalLinksFocus}
            ref={externalLinksEditorRef}
            sourceData={state.label}
            tableRef={externalLinksTableRef}
          />
        </fieldset>

        <EnterEditNote
          controlled
          field={state.form.field.edit_note}
          onChange={handleEditNoteChange}
        />
        <EnterEdit disabled={hasErrors} form={state.form} />
      </div>

      <div className="documentation">
        {state.shownBubble === 'name' ? (
          <Bubble
            controlRef={nameFieldRef}
            id="name-bubble"
          >
            <p>
              {exp.l(
                `The {doc|name} is the label’s official name.`,
                {doc: {href: '/doc/Label#Name', target: '_blank'}},
              )}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'comment' ? (
          <Bubble
            controlRef={commentFieldRef}
            id="comment-bubble"
          >
            <p>
              {exp.l(
                `The {doc|disambiguation} field helps users distinguish
                 between labels with identical or similar names.
                 Feel free to leave it blank if you aren’t warned
                 about possible duplicates.`,
                {
                  doc: {
                    href: '/doc/Disambiguation_Comment',
                    target: '_blank',
                  },
                },
              )}
            </p>
            <p>
              {exp.l(
                `This field is not a place to store general background
                 information. That kind of information should go
                 in an {doc|annotation}.`,
                {doc: {href: '/doc/Annotation', target: '_blank'}},
              )}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'type' ? (
          <TypeBubble
            controlRef={typeSelectRef}
            descriptions={labelDescriptions}
            field={state.form.field.type_id}
            types={labelTypes}
          />
        ) : null}

        {state.shownBubble === 'area' ? (
          <Bubble
            controlRef={areaFieldRef}
            id="area-bubble"
          >
            <p>
              {exp.l(
                `The {doc|area} indicates the geographical
                 origin of the label.`,
                {doc: {href: '/doc/Label/Country', target: '_blank'}},
              )}
            </p>
            {state.area.selectedItem?.entity ? (
              <SelectedAreaMessage area={state.area.selectedItem.entity} />
            ) : null}
          </Bubble>
        ) : null}

        {state.shownBubble === 'label-code' ? (
          <Bubble
            controlRef={labelCodeFieldRef}
            id="label-code-bubble"
          >
            <p>
              {exp.l(
                `The {doc|label code} is a 4 to 6 digit number
                 uniquely identifying the label.`,
                {doc: {href: '/doc/Label/Label_Code', target: '_blank'}},
              )}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'ipi' ? (
          <Bubble
            controlRef={ipiFieldRef}
            id="ipi-bubble"
          >
            <p>
              {exp.l(
                `{doc|IPI codes} are assigned by CISAC to “interested parties”
                 in musical rights management.`,
                {doc: {href: '/doc/IPI', target: '_blank'}},
              )}
            </p>
            <p>
              {l(`If you don’t know the code for this entity,
                  just leave the field blank.`)}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'isni' ? (
          <Bubble
            controlRef={isniFieldRef}
            id="isni-bubble"
          >
            <p>
              {exp.l(
                `{doc|ISNI codes} are an ISO standard used to
                 uniquely identify persons and organizations.`,
                {doc: {href: '/doc/ISNI', target: '_blank'}},
              )}
            </p>
            <p>
              {l(`If you don’t know the code for this entity,
                  just leave the field blank.`)}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'date' ? (
          <Bubble
            controlRef={dateFieldRef}
            id="begin-end-date-bubble"
          >
            <p>
              {exp.l(
                `The {doc|begin and end dates} describe the period
                 during which the label existed or was active.`,
                {doc: {href: '/doc/Label#Date_period', target: '_blank'}},
              )}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'external-links' ? (
          <Bubble
            controlRef={externalLinksTableRef}
            id="external-link-bubble"
          >
            <p>
              {l(`External links are URLs associated with the label.
                  These can include the label’s official homepage and
                  social networking pages, catalogs, order pages,
                  and unofficial pages like Wikipedia entries,
                  histories, and fan sites.`)}
            </p>
            <p>
              {l(`Please don’t add a Wikipedia page if a Wikidata item
                  linking to the same article already exists.`)}
            </p>
          </Bubble>
        ) : null}
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<LabelEditForm>>(
  'div.label-edit-form',
  LabelEditForm,
): component(...React.PropsOf<LabelEditForm>));
