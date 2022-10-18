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
import CodeLink from '../static/scripts/common/components/CodeLink.js';
import WorkListEntry
  from '../static/scripts/common/components/WorkListEntry.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

type Props = {
  +iswcs: $ReadOnlyArray<IswcT>,
  +works: $ReadOnlyArray<WorkT>,
};

const Index = ({iswcs, works}: Props): React.Element<typeof Layout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const userExists = !!$c.user;
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
        <table className="tbl">
          <thead>
            <tr>
              {userExists ? (
                <th>
                  <input type="checkbox" />
                </th>
              ) : null}
              <th>{l('Title')}</th>
              <th>{l('Writers')}</th>
              <th>{l('Artists')}</th>
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
          <div className="row">
            <span className="buttons">
              <button type="submit">
                {l('Add selected works for merging')}
              </button>
            </span>
          </div>
        ) : null}
      </form>
    </Layout>
  );
};

export default Index;
