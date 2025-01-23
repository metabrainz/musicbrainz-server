/*
 * @flow strict
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
import manifest from '../static/manifest.mjs';
import CDTocLink from '../static/scripts/common/components/CDTocLink.js';
import CDTocReleaseListTable
  from '../static/scripts/common/components/CDTocReleaseListTable.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import InlineSubmitButton
  from '../static/scripts/edit/components/InlineSubmitButton.js';
import type {ReleaseWithMediumsAndReleaseGroupT}
  from '../static/scripts/relationship-editor/types.js';

component AttachCDTocToRelease(
  action: 'add' | 'move',
  associatedMedium?: number,
  cdToc: CDTocT,
  form: SearchFormT,
  pager?: PagerT,
  results?: $ReadOnlyArray<
    SearchResultT<ReleaseWithMediumsAndReleaseGroupT>
  >,
  tocString: StrOrNum,
  wasMbidSearch: boolean = false,
) {
  const title = action === 'move'
    ? lp('Move Disc ID', 'header')
    : lp('Attach CD TOC', 'header');
  const cdTocTrackCount = cdToc.track_count;
  const searchLink = '/search?query=' +
    form.field.query.value +
    '&type=release&method=indexed';

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
                  {manifest(
                    'common/components/CDTocReleaseListTable',
                    {async: 'async'},
                  )}
                  {manifest(
                    'common/components/ReleaseEvents',
                    {async: 'async'},
                  )}
                </PaginatedResults>
              ) : null}
              <p>
                <FormSubmit label={lp('Attach CD TOC', 'interactive')} />
              </p>
            </>
          ) : (
            <div className="row">
              <div className="label required">{l('Results:')}</div>
              <div className="no-label">
                {wasMbidSearch ? (
                  <p>{l('We couldn’t find a release matching that MBID.')}</p>
                ) : (
                  <>
                    <p>
                      {l('No results found. Try refining your search query.')}
                    </p>
                    {/* Can be removed if limits dropped with MBS-12971 */}
                    <p>
                      {l(
                        `For performance reasons, this search only checks the
                         appropriateness of a limited amount of releases with
                         titles closest to your entered query.
                         To ensure a better result, search for the full
                         release title or as close to it as possible.`,
                      )}
                    </p>
                    <p>
                      {exp.l(
                        `You can also {search_link|search manually}
                         and paste the link to the release here.`,
                        {search_link: {href: searchLink, target: '_blank'}},
                      )}
                    </p>
                  </>
                )}
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
}

export default AttachCDTocToRelease;
