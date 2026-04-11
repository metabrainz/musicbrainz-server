/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDStubInfo from '../cdstub/CDStubInfo.js';
import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import CDTocLink from '../static/scripts/common/components/CDTocLink.js';
import CDTocMediumListTable
  from '../static/scripts/common/components/CDTocMediumListTable.js';
import CDTocPossibleMediumListTable
  from '../static/scripts/common/components/CDTocPossibleMediumListTable.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

component CDTocLookup(
  cdStub?: CDStubT,
  cdToc: CDTocT,
  mediumCDTocs: $ReadOnlyArray<MediumCDTocT>,
  possibleMediums: $ReadOnlyArray<MediumT>,
  searchArtistForm: SearchFormT,
  searchReleaseForm: SearchFormT,
  tocString: StrOrNum,
) {
  const title = l('Lookup CD');
  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>

      <h2>{l('Matching CDs')}</h2>
      {mediumCDTocs.length > 0 ? (
        <>
          <p>
            {l(`We found discs matching the information you requested, listed
                below. If none of these are the release you are looking for,
                you can search using the form below in order to attach this
                disc to another MusicBrainz release, or to add a new one
                if the search shows it is missing from the database.`)}
          </p>
          <CDTocMediumListTable
            mediumCDTocs={mediumCDTocs}
            releaseMap={linkedEntities.release}
          />
          <p>
            {exp.l(
              `We used disc ID <code>{discid}</code>
               to look up this information.`,
              {discid: <CDTocLink cdToc={cdToc} />},
            )}
          </p>
        </>
      ) : (
        <p>
          {l(`There are currently no discs in MusicBrainz associated with
              the information you provided. You can search using the form
              below in order to attach this disc to another MusicBrainz
              release, or to add a new one if the search shows it is
              missing from the database.`)}
        </p>
      )}

      {cdStub ? (
        <>
          <h2>{l('CD stub found')}</h2>
          <p>
            {l(`A CD stub was found that matches the disc ID you provided.
                If the below tracklist appears correct, you may use it as
                a starting point for a new MusicBrainz release.`)}
          </p>
          <h3>
            {texp.l(
              '{artist} - {name}',
              {artist: cdStub.artist, name: cdStub.title},
            )}
          </h3>
          <CDStubInfo cdstub={cdStub} />
          <form action={`/cdstub/${cdStub.discid}/import`} method="get">
            <p>
              <FormSubmit label={lp('Import CD stub', 'interactive')} />
            </p>
          </form>
          {possibleMediums.length > 0 ? (
            <>
              <h2>{l('Possible mediums')}</h2>
              <p>
                {l(`Based on the above CD stub, we also found the following
                    releases in MusicBrainz that may be related:`)}
              </p>
              <form method="GET">
                <input name="toc" type="hidden" value={tocString} />
                <CDTocPossibleMediumListTable
                  possibleMediums={possibleMediums}
                  releaseMap={linkedEntities.release}
                />
                <p>
                  <FormSubmit label={l('Attach disc ID')} />
                </p>
              </form>
            </>
          ) : null}
        </>
      ) : null}

      <h2>{l('Search by artist')}</h2>
      <form action="/cdtoc/attach" method="get">
        <input name="toc" type="hidden" value={tocString} />
        <FormRowText
          field={searchArtistForm.field.query}
          label={addColonText(l('Artist'))}
          required
          uncontrolled
        />
        <FormRow hasNoLabel>
          <FormSubmit label={l('Search')} />
        </FormRow>
      </form>

      <h2>{l('Search by release')}</h2>
      <form action="/cdtoc/attach" method="get">
        <input name="toc" type="hidden" value={tocString} />
        <FormRowText
          field={searchReleaseForm.field.query}
          label={addColonText(l('Release title or MBID'))}
          required
          uncontrolled
        />
        <FormRow hasNoLabel>
          <FormSubmit label={l('Search')} />
        </FormRow>
      </form>

      {manifest(
        'common/components/CDTocMediumListTable',
        {async: true},
      )}
      {manifest(
        'common/components/CDTocPossibleMediumListTable',
        {async: true},
      )}
      {manifest(
        'common/components/ReleaseEvents',
        {async: true},
      )}
    </Layout>
  );
}

export default CDTocLookup;
