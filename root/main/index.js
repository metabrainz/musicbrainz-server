/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import * as React from 'react';

import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import {ArtworkImage} from '../static/scripts/common/components/Artwork.js';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities.js';
import entityHref from '../static/scripts/common/utility/entityHref.js';

import Navbar from '../static/scripts/homepage/navbar.js';
import AuthButtons from './AuthButtons.js';
import EditorTools from '../static/scripts/homepage/editor-tools.js';
import UserMenu from '../static/scripts/homepage/user-menu.js';
import Search from '../static/scripts/homepage/search.js';
import Blob from '../static/scripts/homepage/blob.js';
import Stats, { type WeeklyStatsT } from '../static/scripts/homepage/stats.js';
import BannerCarousel from '../static/scripts/homepage/banner-carousel.js';
import NewFooter from '../layout/components/NewFooter.js';
import TimelineCarousel from '../static/scripts/homepage/timeline-carousel.js'

import MusicBrainzLogo from '../static/images/meb-logos/MusicBrainz_logo_mini.svg';
import MetaBrainzLogo from '../static/images/meb-logos/MetaBrainz_logo_mini.svg';
import BookBrainzLogo from '../static/images/meb-logos/BookBrainz_logo_mini.svg';
import PicardLogo from '../static/images/meb-logos/Picard_logo_mini.svg';
import ListenBrainzLogo from '../static/images/meb-logos/ListenBrainz_logo_mini.svg';

import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import {faAngleRight} from '@fortawesome/free-solid-svg-icons';
import {faBluesky, faMastodon, faDiscord, faReddit} from '@fortawesome/free-brands-svg-icons';

import {CatalystContext} from '../context.mjs';

type BlogEntryT = {
  +title: string,
  +url: string,
};

type CommunityPostT = {
  +title: string,
  +slug: string,
};

component Homepage(
  blogEntries: $ReadOnlyArray<BlogEntryT> | null,
  newestEvents: $ReadOnlyArray<EventArtT>,
  newestReleases: $ReadOnlyArray<ReleaseArtT>,
  communityPosts: $ReadOnlyArray<CommunityPostT> | null,
  weeklyStats: $ReadOnlyArray<WeeklyStatsT>,
) {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;
  
  const openSourceContainerRef = React.useRef<HTMLDivElement | null>(null);

  return (
    <Layout
      fullWidth
      isHomepage
      title={l('MusicBrainz - the open music encyclopedia')}
    >
      <Navbar />
      <div className="new-homepage">
        {user ? null : <AuthButtons />}
        {user ? <EditorTools /> : null}
        {user ? <UserMenu latestBlogPost={blogEntries && blogEntries.length > 0 ? blogEntries[0] : null} /> : null}
        <Search weeklyStats={weeklyStats} />

        <div className="timeline-container" id="releases-container">
          <div className="timeline-container-inner layout-width">
            <TimelineCarousel />
          </div>
        </div>

        <div className="info-container" id="about">
          <div className="row g-4">
            <div className="col-12 col-sm-8" id="about-musicbrainz-container">
              <h2>{l('About MusicBrainz')}</h2>
              <p className="fw-bold">{l('MusicBrainz is an open music encyclopedia that collects music metadata and makes it available to the public.')}</p>

              <ul className="list-unstyled">
                <li className="d-flex align-items-start">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" className="mt-1" /> 
                  {l('The ultimate source of audio information, releasing data under open licenses and allowing anyone to contribute.')}
                </li>

                <li className="d-flex align-items-start">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" className="mt-1" /> 
                  {l('The universal lingua franca for music, providing reliable and unambiguous forms of music identification, enabling people and machines to have meaningful conversations about music.')}
                </li>

                <li className="d-flex align-items-start">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" className="mt-1" /> 
                  {l('Like Wikipedia, MusicBrainz is maintained by a global community of users and everyone - including you - can participate and contribute.')}
                </li>

                <li className="d-flex align-items-start">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" className="mt-1" /> 
                  {l('MusicBrainz is operated by the MetaBrainz Foundation, a non-profit dedicated to keeping MusicBrainz free and open source.')}
                </li>
              </ul>

              <div className="d-flex align-items-center gap-2 flex-wrap">
                <a
                  className="social-pill"
                  href="https://blog.metabrainz.org"
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{backgroundColor: '#46433A', color: 'white !important'}}
                >
                  {l('Read More')}
                </a>
                <a
                  className="social-pill"
                  href="https://blog.metabrainz.org"
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{backgroundColor: '#46433A', color: 'white !important'}}
                >
                  {l('Beginner editor\'s guide')}
                </a>
              </div>
            </div>

            <div className="col-12 col-sm-4 d-flex flex-column gap-4" id="about-news-container">
              <div>
                <h3>{l('Latest News')}</h3>
                {blogEntries?.length ? (
                  <ul className="list-unstyled">
                    {blogEntries.slice(0, 5).map(item => (
                      <li key={item.url}>
                        <a href={item.url}>{he.decode(item.title)}</a>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p>{l('The blog is currently unavailable.')}</p>
                )}

                <div className="social-buttons">
                  <a
                    className="social-pill"
                    href="https://blog.metabrainz.org"
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{color: 'white !important'}}
                  >
                    Blog
                  </a>
                  <a href="https://bsky.app/profile/musicbrainz.org" target="_blank" rel="noopener noreferrer">
                    <FontAwesomeIcon icon={faBluesky} size="lg" />
                  </a>
                  <a href="https://mastodon.social/@musicbrainz" target="_blank" rel="noopener noreferrer">
                    <FontAwesomeIcon icon={faMastodon} size="lg" />
                  </a>
                  <a href="https://discord.gg/R4hBw972QA" target="_blank" rel="noopener noreferrer">
                    <FontAwesomeIcon icon={faDiscord} size="lg" />
                  </a>
                  <a href="https://www.reddit.com/r/MusicBrainz/" target="_blank" rel="noopener noreferrer">
                    <FontAwesomeIcon icon={faReddit} size="lg" />
                  </a>
                </div>
              </div>

              <div>
                <h3>{l('Community Posts')}</h3>
                {communityPosts?.length ? (
                  <ul className="list-unstyled">
                    {communityPosts.slice(0, 5).map(item => (
                      <li key={item.slug}>
                        <a
                          href={`https://community.metabrainz.org/t/${item.slug}`}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {he.decode(item.title)}
                        </a>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p>{l('The community posts are currently unavailable.')}</p>
                )}

                <div className="social-buttons">
                  <a
                    className="social-pill"
                    href="https://community.metabrainz.org/"
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{color: 'white !important'}}
                  >
                    {l('Forums')}
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="stats-container-wrapper">
          <Stats weeklyStats={weeklyStats} />
        </div>

        <div className="timeline-container" id="events-container">
          <div className="timeline-container-inner layout-width">
            <TimelineCarousel />
          </div>
        </div>

        {/* Contribute */}
        <div className="info-container" id="contribute">
          <div className="row g-4">
            <div className="col-12 col-sm-6">
              <div className="info-container-inner">
                <h2>{l('Develop')}</h2>
                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="https://github.com/orgs/metabrainz" target="_blank" rel="noopener noreferrer">
                    {l('Datasets and Live Data Feed')}
                  </a>
                </span>

                <p className="info-text">
                  {l('Access all our datasets and the MusicBrainz Live Data Feed by')} {" "}
                  <a href="https://metabrainz.org/supporters/account-type" target="_blank" rel="noopener noreferrer">{l('creating an account')} </a>, {l('whether for personal or non-commercial use')}.
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="/doc/MusicBrainz_Database" target="_blank" rel="noopener noreferrer">
                    {l('Database')}
                  </a>
                </span>

                <p className="info-text">
                  {l('View and download the MusicBrainz Database.')}
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="/doc/Developer_Resources" target="_blank" rel="noopener noreferrer">
                    {l('Developer resources')}
                  </a>
                </span>

                <p className="info-text">
                  {l('Use our XML web service or development libraries to create your own MusicBrainz-enabled applications.')}
                </p>

                <p className="d-flex align-items-center gap-1 flex-wrap">
                  <span className="fw-bold">
                    {l('See also:')}
                  </span>
                  <a href="/doc/About/Data_License" target="_blank" rel="noopener noreferrer">
                    {l('Data license')}
                  </a>
                  |
                  <a href="/doc/Frequently_Asked_Questions" target="_blank" rel="noopener noreferrer">
                    {l('MetaBrainz FAQ')}
                  </a>
                </p>

              </div>
            </div>
  
            <div className="col-12 col-sm-6">
              <div className="info-container-inner">
                <h2>{l('Contribute')}</h2>
                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="/doc/How_to_Contribute" target="_blank" rel="noopener noreferrer">
                    {l('Edit the database')}
                  </a>
                </span>
                <p className="info-text">
                  {l('Anyone can help improve our global database! Get started and improve existing data or add new artists and music.')}
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="https://tickets.metabrainz.org/secure/Dashboard.jspa" target="_blank" rel="noopener noreferrer">
                    {l('Bug Tracker')}
                  </a>
                </span>
                <p className="info-text">
                  {l('Developers, view and pick up issues in our bug tracker, and join us in the developer chat.')}
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="/doc/Communication/ChatBrainz" target="_blank" rel="noopener noreferrer">
                    {l('Join the community')}
                  </a>
                </span>
                <p className="info-text">
                  {l('Talk to other database editors and music fans on our forums or our live chat via IRC, Matrix and Discord.')}
                </p>

                <p className="d-flex align-items-center gap-1 flex-wrap">
                  <span className="fw-bold">
                    {l('See also:')}
                  </span>
                  <a href="/doc/Beginners_Guide" target="_blank" rel="noopener noreferrer">
                    {l('Beginners guide')}
                  </a>
                  |
                  <a href="/doc/How_Editing_Works" target="_blank" rel="noopener noreferrer">
                    {l('Editing introduction')}
                  </a>
                  |
                  <a href="/doc/Style" target="_blank" rel="noopener noreferrer">
                    {l('Style guidelines')}
                  </a>
                  |
                  <a href="/doc/Frequently_Asked_Questions" target="_blank" rel="noopener noreferrer">
                    {l('MusicBrainz FAQs')}
                  </a>
                  |
                  <a href="/doc/How_to_Add_an_Artist" target="_blank" rel="noopener noreferrer">
                    {l('How to add artists')}
                  </a>
                  |
                  <a href="/doc/How_to_Add_a_Release" target="_blank" rel="noopener noreferrer">
                    {l('How to add releases')}
                  </a>
                </p>

              </div>
            </div>
          </div>  
        </div>

        {/* Open source */}
        <div className="info-container" id="open-source" ref={openSourceContainerRef}>
          <div className="row g-4">
            <div className="col-12 col-sm-6">
              <div className="info-container-inner">
                <h2>{l('Open source')}</h2>
                <p>
                  {l('"Open source is source code that is made freely available for possible modification and redistribution..."')} - {" "}
                  <a href="https://en.wikipedia.org/wiki/Open_source" target="_blank" rel="noopener noreferrer">{l('Wikipedia')}</a>
                </p>
                <p>
                  {l('The MusicBrainz database is all open source. This means that anyone can view the code, contribute improvements and new features, and copy and modify it for their own use.')}
                </p>
                <p>
                  {l('Thousands of wonderful people contribute code or data to MusicBrainz and its sister projects for no monetary return and for everyone\'s benefit.')}
                </p>

                <span className="d-flex align-items-center">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="https://github.com/orgs/metabrainz" target="_blank" rel="noopener noreferrer">{l('GitHub repositories')}</a>
                </span>
              </div>
            </div>

            <div className="col-12 col-sm-6">
              <div className="info-container-inner">
                <h2>{l('Data provider')}</h2>
                <p>
                  {l('The MetaBrainz core mission is to curate and maintain public datasets that anyone can download and use. Some of the world\'s biggest platforms, such as Google and Amazon, use our data, as well as small-scale developers and curious individuals.')}{" "}
                  {l('We ask')} <a href='https://metabrainz.org/supporters' target="_blank" rel="noopener noreferrer">{l('commercial users')}</a> {l('to support us. Personal use of our datasets will always be free.')}
                </p>
                <p>
                  {l('Our datasets include the MusicBrainz PostgreSQL and JSON Data Dumps. Our datasets are AI Ready, perfect for training large language models for music-based tasks.')}
                </p>

                <span className="d-flex align-items-center">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="https://metabrainz.org/datasets" target="_blank" rel="noopener noreferrer">{l('MetaBrainz Datasets')}</a>
                </span>
              </div>
            </div>
          </div>

          <div className="row g-4">
            <div className="col-12 col-sm-6">
              <div className="info-container-inner">
                <h2>{l('Ethical forever')}</h2>
                <p>
                  {l('The MetaBrainz Foundation is a registered non-profit, making it impossible for us to be bought or traded.')}
                </p>
                <p>
                  {l('Our team and volunteer contributers from across the globe are proud to consider MusicBrainz and it\'s sister sites')} {" "}
                  <a href="https://en.wikipedia.org/wiki/Enshittification" target="_blank" rel="noopener noreferrer">enshittification</a>{l('-proof projects, immune to the the crapifying that takes place when business interests inevitably subsume and monetize projects that initially focussed on high-quality offerings to attract users. ')}
                </p>

                <span className="d-flex align-items-center">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" /> 
                  <a href="https://metabrainz.org" target="_blank" rel="noopener noreferrer">MetaBrainz Foundation</a>
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Logo container */}
        <div className="logo-container layout-width">
          <a
            href="https://metabrainz.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            <img src={MetaBrainzLogo} alt="MetaBrainz"/>
          </a>
          <a
            href="https://musicbrainz.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            <img src={MusicBrainzLogo} alt="MusicBrainz" />
          </a>
          <a
            href="https://picard.musicbrainz.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            <img src={PicardLogo} alt="Picard"/>
          </a>
          <a
            href="https://listenbrainz.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            <img src={ListenBrainzLogo} alt="ListenBrainz"/>
          </a>
          <a
            href="https://bookbrainz.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            <img src={BookBrainzLogo} alt="BookBrainz"/>
          </a>
        </div>

        <BannerCarousel />

        <NewFooter />
      </div>

      {manifest('homepage/navbar', {async: true})}
      {manifest('homepage/editor-tools', {async: true})}
      {manifest('homepage/user-menu', {async: true})}
      {manifest('homepage/search', {async: true})}
      {manifest('homepage/banner-carousel', {async: true})}
      {manifest('homepage/stats', {async: true})}
      {manifest('common/loadArtwork', {async: true})}
      {manifest('homepage/timeline-carousel', {async : true})}
    </Layout>
  );
}

component Artwork(
  artwork: ArtworkT,
  description: string,
  entity: EventT | ReleaseT,
) {
  return (
    <div className="artwork-cont" style={{textAlign: 'center'}}>
      <div className="artwork">
        <a
          href={entityHref(entity)}
          title={description}
        >
          <ArtworkImage
            artwork={artwork}
            hover={description}
          />
        </a>
      </div>
    </div>
  );
}

component EventArtwork(artwork: EventArtT) {
  const event = artwork.event;
  if (!event) {
    return null;
  }
  return (
    <Artwork
      artwork={artwork}
      description={event.name}
      entity={event}
    />
  );
}

component ReleaseArtwork(artwork: ReleaseArtT) {
  const release = artwork.release;
  if (!release) {
    return null;
  }
  const releaseDescription = texp.l('{entity} by {artist}', {
    artist: reduceArtistCredit(release.artistCredit),
    entity: release.name,
  });
  return (
    <Artwork
      artwork={artwork}
      description={releaseDescription}
      entity={release}
    />
  );
}

export default Homepage;
