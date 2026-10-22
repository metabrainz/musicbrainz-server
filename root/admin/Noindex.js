/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {ENTITY_NAMES} from '../static/scripts/common/constants.js';
import * as exp from '../static/scripts/common/i18n/expand2react.js';
import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import formatUserDate from '../utility/formatUserDate.js';

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

type NoindexEntryT = {
  readonly added: string,
  readonly editor: EditorT,
  readonly entity: NoindexableEntityT,
};

component Noindex(
  entityType: NoindexableEntityT['entityType'],
  form: NoindexFormT,
  noindexEntries: {readonly [gid: string]: NoindexEntryT},
) {
  const $c = React.useContext(CatalystContext);

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
                <th>{l_admin('Date added')}</th>
                <th className="checkbox-cell">{l_admin('Remove')}</th>
              </tr>
            </thead>
            <tbody>
              {form.field.entity.field.map((entityField) => {
                const gidField = entityField.field.gid;
                const removedField = entityField.field.removed;
                const gid = gidField.value;
                const entry = nonEmpty(gid) ? noindexEntries[gid] : null;

                return (
                  <tr key={entityField.id}>
                    <td>
                      {entry == null ? (
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
                          <EntityLink entity={entry.entity} />
                        </>
                      )}
                      <FieldErrors field={gidField} />
                    </td>
                    <td>
                      {entry == null ? null : (
                        <EditorLink editor={entry.editor} />
                      )}
                    </td>
                    <td>
                      {entry == null ? null : formatUserDate($c, entry.added)}
                    </td>
                    <td className="checkbox-cell">
                      {entry == null ? null : (
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
