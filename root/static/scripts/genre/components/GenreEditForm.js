/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {GenreFormT} from '../../../../genre/types.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {
  ExternalLinksEditor,
  prepareExternalLinksHtmlFormSubmission,
} from '../../edit/externalLinks.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

type Props = {
  +form: GenreFormT,
};

const GenreEditForm = ({
  form,
}: Props): React.Element<'form'> => {
  const $c = React.useContext(SanitizedCatalystContext);

  const genre = $c.stash.source_entity;
  invariant(genre && genre.entityType === 'genre');

  const externalLinksEditorRef = React.createRef();

  const handleSubmit = () => {
    invariant(externalLinksEditorRef.current);
    prepareExternalLinksHtmlFormSubmission(
      'edit-genre',
      externalLinksEditorRef.current,
    );
  };

  return (
    <form
      className="edit-genre"
      method="post"
      onSubmit={handleSubmit}
    >
      <div className="half-width">
        <fieldset>
          <legend>{l('Genre details')}</legend>
          <FormRowTextLong
            field={form.field.name}
            label={addColonText(l('Name'))}
            required
            uncontrolled
          />
          <FormRowTextLong
            field={form.field.comment}
            label={addColonText(l('Disambiguation'))}
            uncontrolled
          />
        </fieldset>
        <RelationshipEditorWrapper
          formName={form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />
        <fieldset>
          <legend>{l('External Links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!genre.id}
            ref={externalLinksEditorRef}
            sourceData={genre}
          />
        </fieldset>

        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </div>
    </form>
  );
};

export default (hydrate<Props>(
  'div.genre-edit-form',
  GenreEditForm,
): React.AbstractComponent<Props, void>);
