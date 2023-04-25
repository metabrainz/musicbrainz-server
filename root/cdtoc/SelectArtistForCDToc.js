/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PaginatedResults from '../components/PaginatedResults.js';
import Layout from '../layout/index.js';
import type {SearchResultT} from '../search/types.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import InlineSubmitButton
  from '../static/scripts/edit/components/InlineSubmitButton.js';

type Props = {
  +form: SearchFormT,
  +pager?: PagerT,
  +results?: $ReadOnlyArray<SearchResultT<ArtistT>>,
  +tocString: StrOrNum,
};

const SelectArtistForCDToc = ({
  form,
  pager,
  results,
  tocString,
}: Props): React$Element<typeof Layout> => {
  const title = lp('Attach CD TOC', 'header');

  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>
      <h2>{l('Search for an artist')}</h2>
      <form method="GET">
        <input name="toc" type="hidden" value={tocString} />

        <FormRowText
          field={form.field.query}
          label={addColonText(l('Artist'))}
          required
          uncontrolled
        >
          <InlineSubmitButton label={l('Search')} />
        </FormRowText>
      </form>

      <form method="GET">
        <input name="toc" type="hidden" value={tocString} />
        <input
          name="filter-artist.query"
          type="hidden"
          value={form.field.query.value}
        />

        {results ? (
          results.length > 0 ? (
            <>
              <div className="row">
                <div className="label required">{l('Results:')}</div>
                <div className="no-label">
                  <p>
                    {l(
                      `Click the radio button to select the appropriate
                       artist, or click the artist’s name to get more info.`,
                    )}
                  </p>
                </div>

                {pager ? (
                  <div className="no-label">
                    <PaginatedResults pager={pager}>
                      <ul className="radio-list">
                        {results.map(artist => (
                          <li key={artist.entity.id}>
                            <input
                              name="artist"
                              type="radio"
                              value={artist.entity.id}
                            />
                            {' '}
                            <EntityLink entity={artist.entity} />
                          </li>
                        ))}
                      </ul>
                    </PaginatedResults>
                  </div>
                ) : null}
              </div>
              <div className="row no-label">
                <FormSubmit label={l('Select')} />
              </div>
            </>
          ) : (
            <div className="row">
              <div className="label required">{l('Results:')}</div>
              <div className="no-label">
                <p>
                  {l('No results found. Try refining your search query.')}
                </p>
              </div>
            </div>
          )
        ) : null}
      </form>

      <h2>{l('Add a new release')}</h2>
      <p>
        {l(
          `If you don't see the artist you are looking for,
           you can still add a new release. This will allow you
           to create this artist and a release at the same time`,
        )}
      </p>

      <form action="/release/add" method="post">
        <input
          name="artist_credit.names.0.name"
          type="hidden"
          value={form.field.query.value}
        />
        <input
          name="mediums.0.toc"
          type="hidden"
          value={tocString}
        />
        <FormSubmit label={l('Add a new release')} />
      </form>
    </Layout>
  );
};

export default SelectArtistForCDToc;
