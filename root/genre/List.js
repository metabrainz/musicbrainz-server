/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const Frag = require('../components/Frag');
const Layout = require('../layout');
const TagLink = require('../static/scripts/common/components/TagLink');
const {l} = require('../static/scripts/common/i18n');
const {lp_attributes} = require('../static/scripts/common/i18n/attributes');

type PropsT = {|
  +genres: $ReadOnlyArray<string>,
|};

const Genre = ({genre}) => (
  <li>
    <TagLink tag={genre} />
  </li>
);

const GenreList = ({
  genres: genres,
}: PropsT) => {

  return (
    <Layout fullWidth title={l('Genre List')}>
      <div id="content">
        <h1>{l('Genre List')}</h1>
            <p>These are all the tags that will be understood as genres by the tag system.</p>
            <ul>
              {genres.map(genre => (
                <Genre genre={genre} key={genre} />
              ))}
            </ul>
      </div>
    </Layout>
  );
};

module.exports = GenreList;