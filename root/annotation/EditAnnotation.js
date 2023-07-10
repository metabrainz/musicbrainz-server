/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormRowTextArea
  from '../static/scripts/edit/components/FormRowTextArea.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';

type EditAnnotationFormT = FormT<{
  +changelog: ReadOnlyFieldT<string>,
  +edit_note: ReadOnlyFieldT<string>,
  +make_votable: ReadOnlyFieldT<boolean>,
  +preview: ReadOnlyFieldT<string>,
  +text: ReadOnlyFieldT<string>,
}>;

type EditAnnotationProps = {
  +entity: AnnotatedEntityT,
  +form: EditAnnotationFormT,
  +preview?: string,
  +showPreview?: boolean,
};

const EditAnnotation = ({
  entity,
  form,
  preview,
  showPreview = false,
}: EditAnnotationProps): React$MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent
      entity={entity}
      fullWidth
      page="edit-annotation"
      title={l('Edit annotation')}
    >
      <h2>{l('Edit annotation')}</h2>

      <p>
        {exp.l(
          `Please note that any content submitted to MusicBrainz will be
           made available to the public under {open|open licenses},
           do not submit any copyrighted text here!`,
          {open: '/doc/About/Data_License'},
        )}
      </p>

      {showPreview ? (
        <>
          <h3>{l('Preview:')}</h3>
          <div
            className="annotation-preview"
            dangerouslySetInnerHTML={{__html: preview}}
          />
        </>
      ) : null}

      <form method="post">
        <FormRowTextArea
          cols={80}
          field={form.field.text}
          label={addColonText(l('Annotation'))}
          rows={10}
        />

        <FormRowText
          field={form.field.changelog}
          label={l('Changelog:')}
          size={50}
          uncontrolled
        />

        <EnterEditNote field={form.field.edit_note} />

        <EnterEdit childrenFirst form={form}>
          <button
            name={form.field.preview.html_name}
            type="submit"
            value="preview"
          >
            {l('Preview')}
          </button>
        </EnterEdit>
      </form>

      <h3>{l('Annotation Formatting')}</h3>
      <p>
        {l('Annotations support a limited set of wiki formatting options:')}
      </p>
      <table className="details">
        <tbody>
          <tr>
            <th>{l('Emphasis:')}</th>
            <td>
              {l(`''italics''; '''bold'''; '''''bold italics''''';
                 ---- horizontal rule`)}
            </td>
          </tr>
          <tr>
            <th>{l('Headings:')}</th>
            <td>
              {l('= Title 1 =; == Title 2 ==; === Title 3 ===')}
            </td>
          </tr>
          <tr>
            <th>{l('Lists:')}</th>
            <td>
              {l(`tab or 4 spaces and: * bullets or
                  1., a., A., i., I. numbered items (rendered with 1.)`)}
            </td>
          </tr>
          <tr>
            <th>{l('Links:')}</th>
            <td>
              {l('URL; [URL]; [URL|label]; [entity-type:MBID|label]')}
            </td>
          </tr>
        </tbody>
      </table>

      <p>
        {exp.l(
          `Because square brackets [] are used to create hyperlinks,
           you have to use the encoded html equivalents
           (<code>&amp;#91;</code> for [) and (<code>&amp;#93;</code> for ])
           if you want them not be converted into hyperlinks.
           Example: If you want to use [unknown] in the annotation, you'll
           have to write <code>&amp;#91;unknown&amp;#93;</code>
           then it will appear the way you intended it to show.`,
        )}
      </p>
    </LayoutComponent>
  );
};

export default EditAnnotation;
