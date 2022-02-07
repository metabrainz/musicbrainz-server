/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import * as React from 'react';

import {ArtworkImage} from '../components/Artwork';
import Layout from '../layout';
import {CONTACT_URL} from '../static/scripts/common/constants';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities';
import entityHref from '../static/scripts/common/utility/entityHref';
import AppDownload from '../components/home/AppDownload';
import About from '../components/home/About';
import Facts from '../components/home/Facts';

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
    <div id="maincontent">
      <div id="content">
        <h1>{l('Welcome to MusicBrainz!')}</h1>

        <p>
          {l(
            `MusicBrainz is an open music encyclopedia that collects
             music metadata and makes it available to the public.`,
          )}
        </p>

        <p>
          {l('MusicBrainz aims to be:')}
        </p>

        <ol>
          <li>
            {exp.l(
              `<strong>The ultimate source of music information</strong>
               by allowing anyone to contribute and releasing the {doc|data}
               under {doc2|open licenses}.`,
              {
                doc: '/doc/MusicBrainz_Database',
                doc2: '/doc/About/Data_License',
              },
            )}
          </li>
          <li>
            {exp.l(
              `<strong>The universal lingua franca for music</strong>
               by providing a reliable and unambiguous form of
               {doc|music identification}, enabling both people and machines
               to have meaningful conversations about music.`,
              {
                doc: '/doc/MusicBrainz_Identifier',
              },
            )}
          </li>
        </ol>

        <p>
          {exp.l(
            `Like Wikipedia, MusicBrainz is maintained by a global community
             of users and we want everyone &#x2014; including you &#x2014;
             to {doc|participate and contribute}.`,
            {
              doc: '/doc/How_to_Contribute',
            },
          )}
        </p>

        <div className="linkbar">
          {exp.l(
            `{about|More Information} &#x2014; {faq|FAQs} &#x2014;
             {contact|Contact Us}`,
            {
              about: '/doc/About',
              contact: CONTACT_URL,
              faq: '/doc/Frequently_Asked_Questions',
            },
          )}
        </div>

        <p>
          {exp.l(
            `MusicBrainz is operated by the {uri|MetaBrainz Foundation},
             a California based 501(c)(3) tax-exempt non-profit corporation
             dedicated to keeping MusicBrainz {free|free and open source}.`,
            {
              free: '/doc/About/Data_License',
              uri: 'https://metabrainz.org',
            },
          )}
        </p>
      </div>

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

    <div id="triple">
      <div className="feature-column" id="community">
        <h2 className="community">{l('Community')}</h2>
        <ul>
          <li>
            <a href="/doc/How_to_Contribute">{l('How to Contribute')}</a>
          </li>
          <li>
            <a href="https://tickets.metabrainz.org/">{l('Bug Tracker')}</a>
          </li>
          <li>
            <a href="https://community.metabrainz.org/">{l('Forums')}</a>
          </li>
        </ul>
      </div>

      <div className="feature-column" id="products">
        <h2 className="products">{l('MusicBrainz Database')}</h2>
        <p>
          <a href="/doc/MusicBrainz_Database">
            {exp.l(
              `The majority of the data in the
               <strong>MusicBrainz Database</strong> is released into
               the <strong>Public Domain</strong> and can be
               downloaded and used <strong>for free</strong>.`,
            )}
          </a>
        </p>
      </div>

      <div className="feature-column" id="developers">
        <h2 className="developers">{l('Developers')}</h2>
        <p>
          <a href="/doc/Developer_Resources">
            {exp.l(
              `Use our <strong>XML web service</strong> or
               <strong>development libraries</strong> to create
               your own MusicBrainz-enabled applications.`,
            )}
          </a>
        </p>
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
            fallback={release.cover_art_url || ''}
            hover={releaseDescription}
          />
        </a>
      </div>
    </div>
  );
};

export default Homepage;
