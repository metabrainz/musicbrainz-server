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
import type {RecordingFormT} from '../../../../recording/types.js';
import Bubble from '../../common/components/Bubble.js';
import useFormUnloadWarning from '../../common/hooks/useFormUnloadWarning.js';
import {
  getSourceEntityDataForRelationshipEditor,
} from '../../common/utility/catalyst.js';
import formatTrackLength
  from '../../common/utility/formatTrackLength.js';
import isBlank from '../../common/utility/isBlank.js';
import ArtistCreditEditor, {
  createInitialState as createArtistCreditState,
  reducer as runArtistCreditReducer,
} from '../../edit/components/ArtistCreditEditor.js';
import {
  type ActionT as ArtistCreditActionT,
  type StateT as ArtistCreditStateT,
} from '../../edit/components/ArtistCreditEditor/types.js';
import {
  incompleteArtistCreditFromState,
  isArtistCreditStateComplete,
} from '../../edit/components/ArtistCreditEditor/utilities.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FieldErrors from '../../edit/components/FieldErrors.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowTextList, {
  type ActionT as IsrcActionT,
  createInitialState as createIsrcState,
  runReducer as runIsrcReducer,
} from '../../edit/components/FormRowTextList.js';
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
import guessFeat from '../../edit/utility/guessFeat.js';
import isInvalidEditNote from '../../edit/utility/isInvalidEditNote.js';
import isInvalidLength from '../../edit/utility/isInvalidLength.js';
import isValidIsrc from '../../edit/utility/isValidIsrc.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../edit/utility/subfieldErrors.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'guess-feat'}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'toggle-bubble', +bubble: string}
  | {+type: 'update-edit-note', +editNote: string}
  | {+type: 'update-length', +length: string}
  | {+type: 'update-name', +action: NameActionT}
  | {+type: 'update-isrcs', +action: IsrcActionT}
  | {+type: 'update-artist-credit', +action: ArtistCreditActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +actionName: string,
  +artistCredit: ArtistCreditStateT,
  +form: RecordingFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +recording: RecordingT,
  +shownBubble: string,
};

type CreateInitialStatePropsT = {
  +$c: SanitizedCatalystContextT,
  +form: RecordingFormT,
};

function updateIsrcFieldErrors(
  fieldCtx: CowContext<TextListFieldT>,
) {
  const innerFieldCtx = fieldCtx.get('field');
  const innerFieldLength = innerFieldCtx.read().length;
  for (let i = 0; i < innerFieldLength; i++) {
    const subFieldCtx = innerFieldCtx.get(i);
    const value = subFieldCtx.get('field', 'value', 'value').read();

    if (empty(value) || isValidIsrc(value)) {
      subFieldCtx.set('has_errors', false);
      subFieldCtx.set('pendingErrors', []);
      subFieldCtx.set('errors', []);
    } else {
      subFieldCtx.set('has_errors', true);
      subFieldCtx.set('errors', [
        l('This is not a valid ISRC.'),
      ]);
    }
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

function updateLengthFieldErrors(
  lengthFieldCtx: CowContext<FieldT<string | null>>,
) {
  const length = lengthFieldCtx.get('value').read();
  if (length && isInvalidLength(length)) {
    lengthFieldCtx.set('has_errors', true);
    lengthFieldCtx.set('errors', [
      l('Not a valid time. Must be in the format MM:SS'),
    ]);
  } else {
    lengthFieldCtx.set('has_errors', false);
    lengthFieldCtx.set('pendingErrors', []);
    lengthFieldCtx.set('errors', []);
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
  } else if (actionName === 'create' && empty(editNote)) {
    editNoteFieldCtx.set('has_errors', true);
    editNoteFieldCtx.set('errors', [
      l(`You must provide an edit note when adding
         a standalone recording`),
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
  const recording = getSourceEntityDataForRelationshipEditor($c);
  const actionName = $c.action.name;
  invariant(recording && recording.entityType === 'recording');

  const formCtx = mutate(form);
  // $FlowExpectedError[incompatible-call]
  const nameFieldCtx = formCtx.get('field', 'name');
  updateNameFieldErrors(nameFieldCtx);
  const lengthFieldCtx = formCtx.get('field', 'length');
  updateLengthFieldErrors(lengthFieldCtx);
  formCtx
    .update('field', 'isrcs', (isrcCtx) => {
      isrcCtx.set(createIsrcState(isrcCtx.read()));
      updateIsrcFieldErrors(isrcCtx);
    });
  const editNoteFieldCtx = formCtx.get('field', 'edit_note');
  updateNoteFieldErrors(actionName, editNoteFieldCtx);

  return {
    actionName,
    artistCredit: createArtistCreditState({
      artistCredit: $c.stash.artist_credit,
      entity: recording,
      formName: form.name,
      id: 'source',
    }),
    form: formCtx.final(),
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    recording,
    shownBubble: '',
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);

  match (action) {
    {type: 'update-edit-note', const editNote} => {
      newStateCtx
        .update('form', 'field', 'edit_note', (editNoteFieldCtx) => {
          editNoteFieldCtx.set('value', editNote);
          updateNoteFieldErrors(state.actionName, editNoteFieldCtx);
        });
    }
    {type: 'update-length', const length} => {
      newStateCtx
        .update('form', 'field', 'length', (lengthFieldCtx) => {
          lengthFieldCtx.set('value', length);
          updateLengthFieldErrors(lengthFieldCtx);
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
    {type: 'update-isrcs', const action} => {
      const isrcStateCtx = mutate(state.form.field.isrcs);
      runIsrcReducer(isrcStateCtx, action);

      const isrcState = isrcStateCtx.read();
      newStateCtx
        .update('form', 'field', 'isrcs', (isrcFieldCtx) => {
          isrcFieldCtx.set(isrcState);
          updateIsrcFieldErrors(isrcFieldCtx);
        });
    }
    {type: 'toggle-bubble', const bubble} => {
      newStateCtx.set('shownBubble', bubble);
    }
    {type: 'show-all-pending-errors'} => {
      applyAllPendingErrors(newStateCtx.get('form'));
    }
    {type: 'update-artist-credit', const action} => {
      newStateCtx.set(
        'artistCredit',
        runArtistCreditReducer(state.artistCredit, action),
      );
    }
    {type: 'guess-feat'} => {
      const results = guessFeat({
        artistCredit: incompleteArtistCreditFromState(
          state.artistCredit.names,
        ),
        entityType: 'recording',
        name: state.form.field.name.value || '',
        relationships: state.recording.relationships,
      });
      if (results) {
        newStateCtx
          .set('form', 'field', 'name', 'value', results.name);
        newStateCtx.set(
          'artistCredit',
          runArtistCreditReducer(
            state.artistCredit,
            {
              artistCredit: {names: results.artistCreditNames},
              type: 'set-names-from-artist-credit',
            },
          ),
        );
      }
    }
  }
  return newStateCtx.final();
}

component RecordingEditForm(
  form as initialForm: RecordingFormT,
  usedByTracks: boolean,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const currentIsrcs = React.useMemo(() => (
    $c.stash.current_isrcs || []
  ), [$c]);

  useFormUnloadWarning();

  const [state, dispatch] = React.useReducer(
    reducer,
    {$c, form: initialForm},
    createInitialState,
  );

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const artistCreditEditorDispatch = React.useCallback((
    action: ArtistCreditActionT,
  ) => {
    dispatch({action, type: 'update-artist-credit'});
  }, [dispatch]);

  const isrcDispatch = React.useCallback((action: IsrcActionT) => {
    dispatch({action, type: 'update-isrcs'});
  }, [dispatch]);

  const handleEditNoteChange = React.useCallback((
    event: SyntheticEvent<HTMLTextAreaElement>,
  ) => {
    dispatch({
      editNote: event.currentTarget.value,
      type: 'update-edit-note',
    });
  }, [dispatch]);

  function handleCommentFocus() {
    dispatch({bubble: 'comment', type: 'toggle-bubble'});
  }

  function handleIsrcFocus() {
    dispatch({bubble: 'isrc', type: 'toggle-bubble'});
  }

  function handleGuessFeat() {
    dispatch({type: 'guess-feat'});
  }

  const handleLengthChange = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      length: event.currentTarget.value,
      type: 'update-length',
    });
  }, [dispatch]);

  function handleLengthFocus() {
    dispatch({bubble: 'length', type: 'toggle-bubble'});
  }

  function handleNameFocus() {
    dispatch({bubble: 'name', type: 'toggle-bubble'});
  }

  function handleExternalLinksFocus() {
    dispatch({bubble: 'external-links', type: 'toggle-bubble'});
  }

  const hasErrors = hasSubfieldErrors(state.form) ||
                    !isArtistCreditStateComplete(state.artistCredit.names);

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
      'edit-recording',
      externalLinksEditorRef.current,
    );
  };

  const nameFieldRef = React.useRef<HTMLDivElement | null>(null);
  const artistFieldRef = React.useRef<HTMLDivElement | null>(null);
  const commentFieldRef = React.useRef<HTMLDivElement | null>(null);
  const lengthFieldRef = React.useRef<HTMLDivElement | null>(null);
  const isrcFieldRef = React.useRef<HTMLDivElement | null>(null);
  const externalLinksTableRef = React.useRef<HTMLTableElement | null>(null);

  return (
    <form
      className="edit-recording"
      method="post"
      onKeyDown={handleKeyDown}
      onSubmit={handleSubmit}
    >
      <p>
        {exp.l(
          'For more information, check the {doc_doc|documentation}.',
          {doc_doc: {href: '/doc/Recording', target: '_blank'}},
        )}
      </p>

      <div className="half-width">
        <fieldset>
          <legend>{l('Recording details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={state.recording}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            guessFeat
            handleGuessFeat={handleGuessFeat}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label={addColonText(l('Name'))}
            onFocus={handleNameFocus}
            rowRef={nameFieldRef}
          />
          <FormRow>
            <label className="required" htmlFor="ac-source-single-artist">
              {addColonText(l('Artist'))}
            </label>
            <ArtistCreditEditor
              dispatch={artistCreditEditorDispatch}
              state={state.artistCredit}
            />
            <FieldErrors field={state.form.field.artist_credit} />
          </FormRow>
          <FormRowTextLong
            field={state.form.field.comment}
            label={addColonText(l('Disambiguation'))}
            onFocus={handleCommentFocus}
            rowRef={commentFieldRef}
            uncontrolled
          />
          {(!usedByTracks || state.form.field.length.has_errors) ? (
            <FormRowTextLong
              field={state.form.field.length}
              label={addColonText(l('Length'))}
              onChange={handleLengthChange}
              onFocus={handleLengthFocus}
              rowRef={lengthFieldRef}
            />
          ) : (
            <FormRow>
              <label>{addColonText(l('Length'))}</label>
              {exp.l(
                `{recording_length}
                 ({length_info|derived} from the associated track lengths)`,
                {
                  length_info: {href: '/doc/Recording', target: '_blank'},
                  recording_length: formatTrackLength(
                    nonEmpty(state.form.field.length.value)
                      ? parseInt(state.form.field.length.value, 10)
                      : null,
                  ),
                },
              )}
            </FormRow>

          )}
          <FormRowCheckbox
            field={state.form.field.video}
            label={l('Video')}
            uncontrolled
          />
          <FormRowTextList
            addButtonId="add-isrc"
            addButtonLabel={lp('Add ISRC', 'interactive')}
            currentTextValues={currentIsrcs}
            dispatch={isrcDispatch}
            label={addColonText(l('ISRCs'))}
            onFocus={handleIsrcFocus}
            removeButtonLabel={lp('Remove ISRC', 'interactive')}
            rowRef={isrcFieldRef}
            state={state.form.field.isrcs}
          />
        </fieldset>

        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />

        <fieldset>
          <legend>{l('External links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!state.recording.id}
            onFocus={handleExternalLinksFocus}
            ref={externalLinksEditorRef}
            sourceData={state.recording}
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
                `The {doc|name} is usually the most common title
                 from track listings on official releases.`,
                {doc: {href: '/doc/Recording#Title', target: '_blank'}},
              )}
            </p>
            <p>
              {exp.l(
                'Please see the {doc|style guidelines} for more information.',
                {doc: {href: '/doc/Style/Recording#Title', target: '_blank'}},
              )}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'artist' ? (
          <Bubble
            controlRef={artistFieldRef}
            id="artist-bubble"
          >
            <p>
              {exp.l(
                `For popular music, the {doc|artist} should usually match
                 the track artist on the earliest release
                 containing the recording.`,
                {doc: {href: '/doc/Recording#Artist', target: '_blank'}},
              )}
            </p>
            <p>
              {l(`For classical music, it should contain
                  the most important performers.`)}
            </p>
            <p>
              {exp.l(
                `Please see the {doc_style|style guidelines} and the
                 {doc_classical|classical guidelines} for more information.`,
                {
                  doc_classical: {
                    href: '/doc/Style/Classical/Recording_Artist',
                    target: '_blank',
                  },
                  doc_style: {
                    href: '/doc/Style/Recording#Artist',
                    target: '_blank',
                  },
                },
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
                 between similarly-named recordings by the same artist.`,
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
                `If this is a live recording, please also see
                 the {doc|live recording} guidelines.`,
                {
                  doc: {
                    href: '/doc/Style/Recording#Live_recordings',
                    target: '_blank',
                  },
                },
              )}
            </p>
            <p>
              {l(`It’s okay to leave it blank if there are
                  no other recordings with similar names,
                  and this isn’t a live recording.`)}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'length' ? (
          <Bubble
            controlRef={lengthFieldRef}
            id="length-bubble"
          >
            <p>
              {exp.l(
                `The {doc|length} is the recording’s duration
                 in MM:SS format.`,
                {doc: {href: '/doc/Recording#Length', target: '_blank'}},
              )}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'isrc' ? (
          <Bubble
            controlRef={isrcFieldRef}
            id="isrcs-bubble"
          >
            <p>
              {exp.l(
                `The {doc|ISRC} is a 12-character alphanumeric string
                 identifying this recording.`,
                {doc: {href: '/doc/ISRC', target: '_blank'}},
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
              {l(`External links are URLs associated with the recording,
                  such as purchase or streaming pages,
                  or entries in other databases.`)}
            </p>
          </Bubble>
        ) : null}
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<RecordingEditForm>>(
  'div.recording-edit-form',
  RecordingEditForm,
): component(...React.PropsOf<RecordingEditForm>));
