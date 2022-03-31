/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import AppDownload from '../components/home/AppDownload';
import About from '../components/home/About';
import Facts from '../components/home/Facts';
import Explore from '../components/home/Explore';
import Intro from '../components/home/Intro';

type BlogEntryT = {
  +title: string,
  +url: string,
};

type Props = {
  +blogEntries: $ReadOnlyArray<BlogEntryT> | null,
  +newestReleases: $ReadOnlyArray<ArtworkT>,
};

const Homepage = ({
  blogEntries,
  newestReleases,
}: Props): React.Element<typeof Layout> => (
  <Layout
    fullWidth
    homepage
    title={l('MusicBrainz - The Open Music Encyclopedia')}
  >
    <div className="bs" id="intro">
      <Intro
        blogs={blogEntries}
        recentAdditions={newestReleases}
      />
    </div>
    <div className="bs" id="about">
      <About />
    </div>
    <div className="bs" id="facts">
      <Facts />
    </div>
    <Explore />
    <div className="bs" id="app-download">
      <AppDownload />
    </div>

  </Layout>
);

export default Homepage;
