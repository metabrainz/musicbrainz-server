/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import CodeLink from '../static/scripts/common/components/CodeLink.js';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import WorkListEntry
  from '../static/scripts/common/components/WorkListEntry.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

component Index(
  iswcs: $ReadOnlyArray<IswcT>,
  works: $ReadOnlyArray<WorkT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const userExists = $c.user != null;
  const iswc = iswcs[0];
  return (
    <Layout
      fullWidth
      title={texp.l('ISWC “{iswc}”', {iswc: iswc.iswc})}
    >
      <h1>
        {exp.l('ISWC “{iswc}”',
               {iswc: <CodeLink code={iswc} key="iswc" />})}
      </h1>
      <h2>
        {texp.ln(
          'Associated with {num} work',
          'Associated with {num} works',
          works.length,
          {num: works.length},
        )}
      </h2>
      <form
        action={'/work/merge_queue?' + returnToCurrentPage($c)}
        method="post"
      >
        <table className="tbl mergeable-table">
          <thead>
            <tr>
              {userExists ? (
                <th>
                  <input type="checkbox" />
                </th>
              ) : null}
              <th>{l('Title')}</th>
              <th>{l('Authors')}</th>
              <th>{l('Recording artists')}</th>
              <th>{l('Other artists')}</th>
              <th>{l('Type')}</th>
              <th>{l('Language')}</th>
            </tr>
          </thead>
          <tbody>
            {works.map((work, index) => (
              <WorkListEntry
                checkboxes="add-to-merge"
                index={index}
                key={work.id}
                work={work}
              />
            ))}
          </tbody>
        </table>
        {userExists ? (
          <>
            <ListMergeButtonsRow
              label={l('Add selected works for merging')}
            />
            {manifest(
              'common/components/ListMergeButtonsRow',
              {async: true},
            )}
          </>
        ) : null}
      </form>
      {manifest('common/MB/Control/SelectAll', {async: true})}
    </Layout>
  );
}

export default Index;
