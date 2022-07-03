/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import * as React from 'react';

import MB from '../../common/MB.js';
import {getSourceEntityData} from '../../common/utility/catalyst.js';
import type {GenreFormT} from '../../../../genre/types.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {createExternalLinksEditor} from '../../edit/externalLinks.js';
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
  const externalLinksEditorContainerRef = React.useRef(null);
  const isMounted = React.useRef(false);

  const handleSubmit = () => {
    prepareSubmission('edit-genre');
  };

  /*
   * TODO: We should just be rendering <ExternalLinksEditor /> inline
   * instead of hackishly mounting/unmounting it inside an effect. This
   * should be possible if we can factor out functionality from
   * `createExternalLinksEditor` and generate the props for it in advance.
   */
  React.useEffect(() => {
    isMounted.current = true;

    const externalLinksEditorContainer =
      externalLinksEditorContainerRef.current;

    exportTypeInfo(typeInfo, attrInfo);

    invariant(externalLinksEditorContainer != null);

    const genre = getSourceEntityData();
    invariant(genre != null, 'genre data not found');

    const {externalLinksEditorRef, root} = createExternalLinksEditor({
      mountPoint: externalLinksEditorContainer,
      sourceData: genre,
    });

    // $FlowIgnore[incompatible-type]
    MB.sourceExternalLinksEditor = externalLinksEditorRef;

    return () => {
      isMounted.current = false;

      /*
       * XXX React cannot synchronously unmount the root while a render is
       * already in progress, so delay it via `setTimeout`.
       */
      setTimeout(() => {
        if (!isMounted.current) {
          root.unmount();
          $(externalLinksEditorContainer).data('react-root', null);
        }
      }, 0);
    };
  }, [attrInfo, typeInfo]);

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
