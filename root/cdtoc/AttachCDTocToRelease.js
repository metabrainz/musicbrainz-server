/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import Layout from '../layout/index.js';
import type {SearchResultT} from '../search/types.js';
import * as manifest from '../static/manifest.mjs';
import CDTocLink from '../static/scripts/common/components/CDTocLink.js';
import CDTocReleaseListTable
  from '../static/scripts/common/components/CDTocReleaseListTable.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import InlineSubmitButton
  from '../static/scripts/edit/components/InlineSubmitButton.js';
import type {ReleaseWithMediumsAndReleaseGroupT}
  from '../static/scripts/relationship-editor/types.js';

type Props = {
  +action: 'add' | 'move',
  +associatedMedium?: number,
  +cdToc: CDTocT,
  +form: SearchFormT,
  +pager?: PagerT,
  +results?: $ReadOnlyArray<
    SearchResultT<ReleaseWithMediumsAndReleaseGroupT>
  >,
  +tocString: StrOrNum,
  +wasMbidSearch?: boolean,
};

const AttachCDTocToRelease = ({
  action,
  associatedMedium,
  cdToc,
  form,
  pager,
  results,
  tocString,
  wasMbidSearch = false,
}: Props): React.Element<typeof Layout> => {
  const title = (action === 'move') ? l('Move Disc ID') : l('Attach CD TOC');
  const cdTocTrackCount = cdToc.track_count;

  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>

      {action === 'move' ? (
        <>
          <p>
            {exp.l(
              `Select a release to which the disc ID <code>{discid}</code>
               should be moved to.`,
              {discid: <CDTocLink cdToc={cdToc} />},
            )}
          </p>

          <p>
            {exp.l(
              `Only releases with the same amount of tracks ({n}) as
               the release the disc ID is currently attached to are shown.`,
              {n: cdTocTrackCount.toString()},
            )}
          </p>
        </>
      ) : null}

      <form method="GET">
        <input name="toc" type="hidden" value={tocString} />

        <FormRowText
          field={form.field.query}
          label={addColonText(l('Release title or MBID'))}
          required
          uncontrolled
        >
          <InlineSubmitButton label={l('Search')} />
        </FormRowText>
      </form>

      <form method="GET">
        <input name="toc" type="hidden" value={tocString} />
        <input
          name="filter-release.query"
          type="hidden"
          value={form.field.query.value}
        />

        {results ? (
          results.length > 0 ? (
            <>
              <p>
                {exp.ln('{num} release found matching your query.',
                        '{num} releases found matching your query.',
                        results.length,
                        {num: results.length})}
              </p>

              {pager ? (
                <PaginatedResults pager={pager}>
                  <CDTocReleaseListTable
                    associatedMedium={associatedMedium}
                    cdTocTrackCount={cdTocTrackCount}
                    results={results}
                    wasMbidSearch={wasMbidSearch}
                  />
                  {manifest.js(
                    'common/components/CDTocReleaseListTable',
                    {async: 'async'},
                  )}
                  {manifest.js(
                    'common/components/ReleaseEvents',
                    {async: 'async'},
                  )}
                </PaginatedResults>
              ) : null}
              <p>
                <FormSubmit label={lp('Attach CD TOC', 'button/menu')} />
              </p>
            </>
          ) : (
            <div className="row">
              <div className="label required">{l('Results:')}</div>
              <div className="no-label">
                <p>
                  {wasMbidSearch ? (
                    l('We couldn’t find a release matching that MBID.')
                  ) : (
                    l('No results found. Try refining your search query.')
                  )}
                </p>
              </div>
            </div>
          )
        ) : null}
      </form>

      {action === 'add' ? (
        <>
          <h2>{l('Add a new release')}</h2>
          <p>
            {l(`If you don't see the release you are looking for,
                you can still add a new one, using this CD TOC:`)}
          </p>

          <form action="/release/add" method="post">
            <input name="name" type="hidden" value={form.field.query.value} />
            <input
              name="mediums.0.toc"
              type="hidden"
              value={tocString}
            />
            <FormSubmit label={l('Add a new release')} />
          </form>
        </>
      ) : null}
    </Layout>
  );
};

export default AttachCDTocToRelease;
