/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import MB from '../../common/MB';
import EnterEdit from '../../../../components/EnterEdit';
import EnterEditNote from '../../../../components/EnterEditNote';
import FormRowTextLong from '../../../../components/FormRowTextLong';
import type {GenreFormT} from '../../../../genre/types';
import {createExternalLinksEditor} from '../../edit/externalLinks';
import {exportTypeInfo} from '../../relationship-editor/common/viewModel';
import {prepareSubmission} from '../../relationship-editor/generic';

type Props = {
  +$c: CatalystContextT,
  +attrInfo: LinkAttrTypeOptionsT,
  +form: GenreFormT,
  +sourceEntity: GenreT | {entityType: 'genre'},
  +typeInfo: LinkTypeOptionsT,
};

const GenreEditForm = ({
  $c,
  attrInfo,
  form,
  sourceEntity,
  typeInfo,
}: Props): React.Element<'form'> => {
  const externalLinksEditorContainerRef = React.useRef(null);

  const handleSubmit = () => {
    prepareSubmission('edit-genre');
  };

  React.useEffect(() => {
    exportTypeInfo(typeInfo, attrInfo);
    invariant(externalLinksEditorContainerRef.current != null);

    const {externalLinksEditorRef, root} = createExternalLinksEditor({
      mountPoint: externalLinksEditorContainerRef.current,
      sourceData: sourceEntity,
    });

    // $FlowIgnore[incompatible-type]
    MB.sourceExternalLinksEditor = externalLinksEditorRef;

    return () => {
      root.unmount();
    };
  }, [attrInfo, sourceEntity, typeInfo]);

  return (
    <form
      action={$c.req.uri}
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
          <div
            id="external-links-editor-container"
            ref={externalLinksEditorContainerRef}
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
