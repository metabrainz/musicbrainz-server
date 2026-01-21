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
import type {ReleaseGroupFormT} from '../../../../release_group/types.js';
import Bubble from '../../common/components/Bubble.js';
import useFormUnloadWarning from '../../common/hooks/useFormUnloadWarning.js';
import {
  getSourceEntityDataForRelationshipEditor,
} from '../../common/utility/catalyst.js';
import isBlank from '../../common/utility/isBlank.js';
import {
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
import FormRowArtistCredit
  from '../../edit/components/FormRowArtistCredit.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
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
  | {+type: 'update-name', +action: NameActionT}
  | {+type: 'update-artist-credit', +action: ArtistCreditActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +actionName: string,
  +artistCredit: ArtistCreditStateT,
  +form: ReleaseGroupFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +releaseGroup: ReleaseGroupT,
  +shownBubble: string,
};

type CreateInitialStatePropsT = {
  +$c: SanitizedCatalystContextT,
  +form: ReleaseGroupFormT,
};

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
  const releaseGroup = getSourceEntityDataForRelationshipEditor($c);
  const actionName = $c.action.name;
  invariant(releaseGroup && releaseGroup.entityType === 'release_group');

  const formCtx = mutate(form);
  // $FlowExpectedError[incompatible-call]
  const nameFieldCtx = formCtx.get('field', 'name');
  updateNameFieldErrors(nameFieldCtx);
  const editNoteFieldCtx = formCtx.get('field', 'edit_note');
  updateNoteFieldErrors(actionName, editNoteFieldCtx);

  return {
    actionName,
    artistCredit: createArtistCreditState({
      artistCredit: $c.stash.artist_credit,
      entity: releaseGroup,
      formName: form.name,
      id: 'source',
    }),
    form: formCtx.final(),
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    releaseGroup,
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
        entityType: 'release_group',
        name: state.form.field.name.value || '',
        relationships: state.releaseGroup.relationships,
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

component ReleaseGroupEditForm(
  form as initialForm: ReleaseGroupFormT,
  primaryTypeDescriptions: {+[id: string]: string},
  primaryTypes: SelectOptionsT,
  secondaryTypeDescriptions: {+[id: string]: string},
  secondaryTypes: SelectOptionsT,
) {
  const $c = React.useContext(SanitizedCatalystContext);

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

  const handleEditNoteChange = React.useCallback((
    event: SyntheticEvent<HTMLTextAreaElement>,
  ) => {
    dispatch({
      editNote: event.currentTarget.value,
      type: 'update-edit-note',
    });
  }, [dispatch]);

  function handleArtistFocus() {
    dispatch({bubble: 'artist', type: 'toggle-bubble'});
  }

  function handleCommentFocus() {
    dispatch({bubble: 'comment', type: 'toggle-bubble'});
  }

  function handleGuessFeat() {
    dispatch({type: 'guess-feat'});
  }

  function handleNameFocus() {
    dispatch({bubble: 'name', type: 'toggle-bubble'});
  }

  function handlePrimaryTypeFocus() {
    dispatch({bubble: 'primary-type', type: 'toggle-bubble'});
  }

  function handleSecondaryTypeFocus() {
    dispatch({bubble: 'secondary-types', type: 'toggle-bubble'});
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
  const primaryTypeSelectRef = React.useRef<HTMLDivElement | null>(null);
  const secondaryTypeSelectRef = React.useRef<HTMLDivElement | null>(null);
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
          `For more information, check the {doc_doc|documentation}
           and {doc_styleguide|style guidelines}.`,
          {
            doc_doc: {href: '/doc/Release_Group', target: '_blank'},
            doc_styleguide: {
              href: '/doc/Style/Release_Group',
              target: '_blank',
            },
          },
        )}
      </p>

      <div className="half-width">
        <fieldset>
          <legend>{l('Release group details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={state.releaseGroup}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            guessFeat
            handleGuessFeat={handleGuessFeat}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label={addColonText(l('Name'))}
            onFocus={handleNameFocus}
            rowRef={nameFieldRef}
          />
          <FormRowArtistCredit
            artistCreditField={state.form.field.artist_credit}
            dispatch={artistCreditEditorDispatch}
            onFocus={handleArtistFocus}
            rowRef={artistFieldRef}
            state={state.artistCredit}
          />
          <FormRowTextLong
            field={state.form.field.comment}
            label={addColonText(l('Disambiguation'))}
            onFocus={handleCommentFocus}
            rowRef={commentFieldRef}
            uncontrolled
          />
          <FormRowSelect
            allowEmpty
            field={state.form.field.primary_type_id}
            label={addColonText(l('Primary type'))}
            onChange={setPrimaryType}
            onFocus={handlePrimaryTypeFocus}
            options={primaryTypeOptions}
            rowRef={primaryTypeSelectRef}
          />
          <FormRowSelect
            allowEmpty
            field={state.form.field.secondary_type_ids}
            label={addColonText(l('Secondary types'))}
            onChange={setSecondaryTypes}
            onFocus={handleSecondaryTypeFocus}
            options={secondaryTypeOptions}
            rowRef={secondaryTypeSelectRef}
          />
        </fieldset>

        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />

        <fieldset>
          <legend>{l('External links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!state.releaseGroup.id}
            onFocus={handleExternalLinksFocus}
            ref={externalLinksEditorRef}
            sourceData={state.releaseGroup}
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
                `The {doc|name} usually the title from the
                 earliest official release in the release group.`,
                {doc: {href: '/doc/Release_Group#Title', target: '_blank'}},
              )}
            </p>
            <p>
              {exp.l(
                'Please see the {doc|style guidelines} for more information.',
                {
                  doc: {
                    href: '/doc/Style/Release_Group#Title',
                    target: '_blank',
                  },
                },
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
                `The {doc|artist} should usually match the
                 earliest official release in the release group.`,
                {doc: {href: '/doc/Release_Group#Artist', target: '_blank'}},
              )}
            </p>
            <p>
              {exp.l(
                'Please see the {doc|style guidelines} for more information.',
                {
                  doc: {
                    href: '/doc/Style/Release_Group#Artist',
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
                 between similarly-named release groups,
                 such as multiple self-titled albums by the same artist.`,
                {
                  doc: {
                    href: '/doc/Disambiguation_Comment',
                    target: '_blank',
                  },
                },
              )}
            </p>
            <p>
              {l(`Please leave it blank if other information such as
                  artist or type (album, single, etc.) already
                  distinguishes between the release groups.`)}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'primary-type' ? (
          <Bubble
            controlRef={primaryTypeSelectRef}
            id="primary-typè-bubble"
          >
            <p>
              {exp.l(
                `The {doc|primary type} describes
                 how the release group is categorized.`,
                {doc: {href: '/doc/Release_Group/Type', target: '_blank'}},
              )}
            </p>
          </Bubble>
        ) : null}

        {state.shownBubble === 'secondary-types' ? (
          <Bubble
            controlRef={secondaryTypeSelectRef}
            id="secondary-types-bubble"
          >
            <p>
              {exp.l(
                `{doc|Secondary types} are additional attributes describing
                 the release group. Leave this blank if none apply. You can
                 select multiple types by using Ctrl + click
                 (or Cmd + click on a Mac).`,
                {doc: {href: '/doc/Release_Group/Type', target: '_blank'}},
              )}
            </p>
            <p>
              {exp.l(
                'Please see the {doc|style guidelines} for more information.',
                {
                  doc: {
                    href: '/doc/Style/Release_Group#Secondary_types',
                    target: '_blank',
                  },
                },
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
              {l(`External links are URLs associated with the release group,
                  such as official pages, Wikipedia articles, reviews,
                  and entries in other databases.`)}
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

export default (hydrate<React.PropsOf<ReleaseGroupEditForm>>(
  'div.release-group-edit-form',
  ReleaseGroupEditForm,
): component(...React.PropsOf<ReleaseGroupEditForm>));
