/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';

import {ArtworkImage} from '../components/Artwork.js';
import About from '../components/home/About.js';
import AppDownload from '../components/home/AppDownload.js';
import Explore from '../components/home/Explore.js';
import Facts from '../components/home/Facts.js';
import Layout from '../layout/index.js';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities.js';
import entityHref from '../static/scripts/common/utility/entityHref.js';

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
}: Props): React$Element<typeof Layout> => (
  <Layout
    fullWidth
    isHomepage
    title={l('MusicBrainz - The Open Music Encyclopedia')}
  >
    <div id="maincontent">
      <div className="sidebar">
        <div className="feature-column" id="blog-feed">
          <h2>{l('MetaBrainz Blog')}</h2>

          {blogEntries?.length ? (
            <>
              <p style={{margin: '1em 0 0'}}>
                <strong>{l('Latest posts:')}</strong>
              </p>
              <ul style={{margin: '0px', paddingLeft: '20px'}}>
                {blogEntries.slice(0, 6).map(item => (
                  <li key={item.url}>
                    <a href={item.url}>{he.decode(item.title)}</a>
                  </li>
                ))}
              </ul>
              <p style={{margin: '1em 0', textAlign: 'right'}}>
                <strong>
                  <a href="http://blog.metabrainz.org">
                    {l('Read more »')}
                  </a>
                </strong>
              </p>
            </>
          ) : (
            <p style={{margin: '0px', textAlign: 'center'}}>
              {l('The blog is currently unavailable.')}
            </p>
          )}
        </div>
      </div>

      <div className="sidebar">
        <div>
          <div className="feature-column" id="taggers">
            <h2 className="taggers">{l('Tag Your Music')}</h2>
            <ul>
              <li>
                <a href="//picard.musicbrainz.org">
                  {l('MusicBrainz Picard')}
                </a>
              </li>
              <li>
                <a href="/doc/AudioRanger">{l('AudioRanger')}</a>
              </li>
              <li>
                <a href="/doc/Mp3tag">{l('Mp3tag')}</a>
              </li>
              <li>
                <a href="/doc/Yate_Music_Tagger">{l('Yate Music Tagger')}</a>
              </li>
            </ul>
          </div>

          <div className="feature-column" id="quick-start">
            <h2>{l('Quick Start')}</h2>
            <ul>
              <li>
                <a href="/doc/Beginners_Guide">{l('Beginners guide')}</a>
              </li>
              <li>
                <a href="/doc/How_Editing_Works">
                  {l('Editing introduction')}
                </a>
              </li>
              <li>
                <a href="/doc/Style">{l('Style guidelines')}</a>
              </li>
              <li>
                <a href="/doc/Frequently_Asked_Questions">{l('FAQs')}</a>
              </li>
              <li>
                <a href="/doc/How_to_Add_an_Artist">
                  {l('How to add artists')}
                </a>
              </li>
              <li>
                <a href="/doc/How_to_Add_a_Release">
                  {l('How to add releases')}
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <div className="feature-column" style={{clear: 'both', paddingTop: '1%'}}>
      <h2>{l('Recent Additions')}</h2>
      <div style={{height: '160px', overflow: 'hidden'}}>
        {newestReleases.map((artwork, index) => (
          <ReleaseArtwork
            artwork={artwork}
            key={index}
          />
        ))}
      </div>
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

const ReleaseArtwork = ({
  artwork,
}: {
  +artwork: ArtworkT,
}) => {
  const release = artwork.release;
  if (!release) {
    return null;
  }
  const releaseDescription = texp.l('{entity} by {artist}', {
    artist: reduceArtistCredit(release.artistCredit),
    entity: release.name,
  });
  return (
    <div className="artwork-cont" style={{textAlign: 'center'}}>
      <div className="artwork">
        <a
          href={entityHref(release)}
          title={releaseDescription}
        >
          <ArtworkImage
            artwork={artwork}
            hover={releaseDescription}
          />
        </a>
      </div>
    </div>
  );
};

export default Homepage;
