/*
 * @flow
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import * as React from 'react';

import MB from '../../common/MB';
import EnterEdit from '../../../../components/EnterEdit';
import EnterEditNote from '../../../../components/EnterEditNote';
import FormRowTextLong from '../../../../components/FormRowTextLong';
import type {MoodFormT} from '../../../../mood/types';
import {createExternalLinksEditor} from '../../edit/externalLinks';
import {exportTypeInfo} from '../../relationship-editor/common/viewModel';
import {prepareSubmission} from '../../relationship-editor/generic';

type Props = {
  +$c: CatalystContextT,
  +attrInfo: LinkAttrTypeOptionsT,
  +form: MoodFormT,
  +sourceEntity: MoodT | {entityType: 'mood'},
  +typeInfo: LinkTypeOptionsT,
};

const MoodEditForm = ({
  $c,
  attrInfo,
  form,
  sourceEntity,
  typeInfo,
}: Props): React.Element<'form'> => {
  const externalLinksEditorContainerRef = React.useRef(null);
  const isMounted = React.useRef(false);

  const handleSubmit = () => {
    prepareSubmission('edit-mood');
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

    const {externalLinksEditorRef, root} = createExternalLinksEditor({
      mountPoint: externalLinksEditorContainer,
      sourceData: sourceEntity,
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
  }, [attrInfo, sourceEntity, typeInfo]);

  return (
    <form
      action={$c.req.uri}
      className="edit-mood"
      method="post"
      onSubmit={handleSubmit}
    >
      <div className="half-width">
        <fieldset>
          <legend>{l('Mood details')}</legend>
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

        <div data-form-name="edit-mood" id="relationship-editor" />

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
  'div.mood-edit-form',
  MoodEditForm,
): React.AbstractComponent<Props, void>);
