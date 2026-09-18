/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {ENTITY_NAMES} from '../static/scripts/common/constants.js';
import * as exp from '../static/scripts/common/i18n/expand2react.js';
import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type NoindexFormT = FormT<{
  readonly csrf_session_key: FieldT<string>,
  readonly csrf_token: FieldT<string>,
  readonly entity: RepeatableFieldT<CompoundFieldT<{
    readonly gid: FieldT<string | null>,
    readonly removed: FieldT<boolean>,
  }>>,
}>;

type NoindexableEntityT =
  | ArtistT;

component Noindex(
  editors: {readonly [entityId: number]: EditorT},
  entities: {readonly [gid: string]: NoindexableEntityT},
  entityType: NoindexableEntityT['entityType'],
  form: NoindexFormT,
) {
  return (
    <Layout fullWidth title="Noindex">
      <div id="content">
        <h1>{'Noindex'}</h1>
        <p>
          {exp.l_admin(
            `Pages for the entities added here will be served from the
             website with a {noindex_wiki|noindex} meta tag.`,
            {
              noindex_wiki: 'https://en.wikipedia.org/wiki/Noindex',
            },
          )}
        </p>
        <form action={'/admin/noindex/' + entityType} method="post">
          <FormCsrfToken form={form} />
          <FieldErrors field={form.field.entity} includeSubFields={false} />
          <table className="tbl">
            <thead>
              <tr>
                <th>{ENTITY_NAMES[entityType]()}</th>
                <th>{l_admin('Added by')}</th>
                <th className="checkbox-cell">{l_admin('Remove')}</th>
              </tr>
            </thead>
            <tbody>
              {form.field.entity.field.map((entityField) => {
                const gidField = entityField.field.gid;
                const removedField = entityField.field.removed;
                const gid = gidField.value;
                const entity = nonEmpty(gid) ? entities[gid] : null;
                const editor = entity == null ? null : editors[entity.id];

                return (
                  <tr key={entityField.id}>
                    <td>
                      {entity == null ? (
                        <input
                          defaultValue={gid ?? ''}
                          id={'id-' + gidField.html_name}
                          name={gidField.html_name}
                          placeholder={l_admin('MBID')}
                          size={36}
                          type="text"
                        />
                      ) : (
                        <>
                          <input
                            name={gidField.html_name}
                            type="hidden"
                            value={gid}
                          />
                          <EntityLink entity={entity} />
                        </>
                      )}
                      <FieldErrors field={gidField} />
                    </td>
                    <td>
                      {editor == null ? null : <EditorLink editor={editor} />}
                    </td>
                    <td className="checkbox-cell">
                      {entity == null ? null : (
                        <input
                          defaultChecked={removedField.value}
                          id={'id-' + removedField.html_name}
                          name={removedField.html_name}
                          type="checkbox"
                          value="1"
                        />
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <div className="row">
            <FormSubmit label={l_admin('Submit')} />
          </div>
        </form>
      </div>
    </Layout>
  );
}

export default Noindex;
