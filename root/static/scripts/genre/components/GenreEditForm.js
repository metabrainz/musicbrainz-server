/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../../context.mjs';
import type {GenreFormT} from '../../../../genre/types.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {ExternalLinksEditor} from '../../edit/externalLinks.js';
import {exportTypeInfo} from '../../relationship-editor/common/viewModel.js';
import {prepareSubmission} from '../../relationship-editor/generic.js';

type Props = {
  +attrInfo: LinkAttrTypeOptionsT,
  +form: GenreFormT,
  +typeInfo: LinkTypeOptionsT,
};

const GenreEditForm = ({
  attrInfo,
  form,
  typeInfo,
}: Props): React.Element<'form'> => {
  const $c = React.useContext(CatalystContext);

  const genre = $c.stash.source_entity;
  invariant(genre && genre.entityType === 'genre');

  const [isTypeInfoExported, setTypeInfoExported] = React.useState(false);

  React.useEffect(() => {
    if (!isTypeInfoExported) {
      exportTypeInfo(typeInfo, attrInfo);
      setTypeInfoExported(true);
    }
  }, [isTypeInfoExported, attrInfo, typeInfo]);

  const handleSubmit = () => {
    prepareSubmission('edit-genre');
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

        <div data-form-name="edit-genre" id="relationship-editor" />

        <fieldset>
          <legend>{l('External Links')}</legend>
          {isTypeInfoExported ? (
            <ExternalLinksEditor
              isNewEntity={!genre.id}
              sourceData={genre}
            />
          ) : null}
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
