/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  faBluesky,
  faDiscord,
  faMastodon,
  faReddit,
} from '@fortawesome/free-brands-svg-icons';
import {faAngleRight} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import he from 'he';
import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import NewFooter from '../layout/components/NewFooter.js';
import Layout from '../layout/index.js';
import BookBrainzLogo
  from '../static/images/meb-logos/BookBrainz_logo_mini.svg';
import ListenBrainzLogo
  from '../static/images/meb-logos/ListenBrainz_logo_mini.svg';
import MetaBrainzLogo
  from '../static/images/meb-logos/MetaBrainz_logo_mini.svg';
import MusicBrainzLogo
  from '../static/images/meb-logos/MusicBrainz_logo_mini.svg';
import PicardLogo from '../static/images/meb-logos/Picard_logo_mini.svg';
import manifest from '../static/manifest.mjs';
import {l} from '../static/scripts/common/i18n.js';
import BannerCarousel from '../static/scripts/homepage/banner-carousel.js';
import EditorTools from '../static/scripts/homepage/editor-tools.js';
import Navbar from '../static/scripts/homepage/navbar.js';
import Search from '../static/scripts/homepage/search.js';
import Stats, {type WeeklyStatsT}
  from '../static/scripts/homepage/stats.js';
import TimelineCarousel
  from '../static/scripts/homepage/timeline-carousel.js';
import UserMenu from '../static/scripts/homepage/user-menu.js';

import AuthButtons from './AuthButtons.js';

type BlogEntryT = {
  +title: string,
  +url: string,
};

type CommunityPostT = {
  +slug: string,
  +title: string,
};

component Homepage(
  blogEntries: $ReadOnlyArray<BlogEntryT> | null,
  newestEvents: $ReadOnlyArray<EventArtT>,
  freshEvents: $ReadOnlyArray<EventArtT>,
  newestReleases: $ReadOnlyArray<ReleaseArtT>,
  freshReleases: $ReadOnlyArray<ReleaseArtT>,
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
        {user ? (
          <UserMenu
            latestBlogPost={
              blogEntries && blogEntries.length > 0 ? blogEntries[0] : null
            }
          />
        ) : null}
        <Search weeklyStats={weeklyStats} />

        <div className="stats-container-wrapper">
          <Stats weeklyStats={weeklyStats} />
        </div>


        <div className="timeline-container" id="releases-container">
          <div className="timeline-container-inner layout-width">
            <TimelineCarousel
              entityType="release"
              freshReleaseArtwork={freshReleases}
              newestReleaseArtwork={newestReleases}
            />
          </div>
        </div>

        <div className="info-container" id="about">
          <div className="row g-5">
            <div className="col-12 col-sm-8" id="about-musicbrainz-container">
              <h2>{l('About MusicBrainz')}</h2>
              <p className="fw-bold">
                {l(
                  `MusicBrainz is an open music encyclopedia that collects
                   music metadata and makes it available to the public.`,
                )}
              </p>

              <ul className="list-unstyled">
                <li className="d-flex align-items-start">
                  <FontAwesomeIcon
                    className="mt-1"
                    icon={faAngleRight}
                    size="sm"
                  />
                  {l(
                    `The ultimate source of audio information, releasing data
                     under open licenses and allowing anyone to contribute.`,
                  )}
                </li>

                <li className="d-flex align-items-start">
                  <FontAwesomeIcon
                    className="mt-1"
                    icon={faAngleRight}
                    size="sm"
                  />
                  {l(
                    `The universal lingua franca for music, providing reliable
                     and unambiguous forms of music identification, enabling
                     people and machines to have meaningful conversations
                     about music.`,
                  )}
                </li>

                <li className="d-flex align-items-start">
                  <FontAwesomeIcon
                    className="mt-1"
                    icon={faAngleRight}
                    size="sm"
                  />
                  {l(
                    `Like Wikipedia, MusicBrainz is maintained by a global
                     community of users and everyone - including you -
                     can participate and contribute.`,
                  )}
                </li>

                <li className="d-flex align-items-start">
                  <FontAwesomeIcon
                    className="mt-1"
                    icon={faAngleRight}
                    size="sm"
                  />
                  {l(
                    `MusicBrainz is operated by the MetaBrainz Foundation,
                     a non-profit dedicated to keeping MusicBrainz free
                     and open source.`,
                  )}
                </li>
              </ul>

              <div className="d-flex align-items-center gap-2 flex-wrap">
                <a
                  className="social-pill"
                  href="/doc/About"
                  style={{
                    backgroundColor: '#46433A',
                    color: 'white !important',
                  }}
                >
                  {l('Read More')}
                </a>
                <a
                  className="social-pill"
                  href="/doc/Beginners_Guide"
                  style={{
                    backgroundColor: '#46433A',
                    color: 'white !important',
                  }}
                >
                  {l('Beginner’s guide')}
                </a>
              </div>
            </div>

            <div
              className="col-12 col-sm-4 d-flex flex-column gap-4"
              id="about-news-container"
            >
              <div>
                <h3>{l('Latest news')}</h3>
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
                    style={{color: 'white !important'}}
                  >
                    {l('Blog')}
                  </a>
                  <a href="https://bsky.app/profile/musicbrainz.org" title="Bluesky">
                    <FontAwesomeIcon icon={faBluesky} size="lg" />
                  </a>
                  <a href="https://mastodon.social/@musicbrainz" title="Mastodon">
                    <FontAwesomeIcon icon={faMastodon} size="lg" />
                  </a>
                  <a href="https://discord.gg/R4hBw972QA" title="Discord">
                    <FontAwesomeIcon icon={faDiscord} size="lg" />
                  </a>
                  <a href="https://www.reddit.com/r/MusicBrainz/" title="Reddit">
                    <FontAwesomeIcon icon={faReddit} size="lg" />
                  </a>
                </div>
              </div>

              <div>
                <h3>{l('Community posts')}</h3>
                {communityPosts?.length ? (
                  <ul className="list-unstyled">
                    {communityPosts.slice(0, 5).map(item => (
                      <li key={item.slug}>
                        <a href={`https://community.metabrainz.org/t/${item.slug}`}>
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
                    style={{color: 'white !important'}}
                  >
                    {l('Forums')}
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="timeline-container" id="events-container">
          <div className="timeline-container-inner layout-width">
            <TimelineCarousel
              entityType="event"
              freshEventArtwork={freshEvents}
              newestEventArtwork={newestEvents}
            />
          </div>
        </div>

        {/* Contribute */}
        <div className="info-container" id="contribute">
          <div className="row g-5">
            <div className="col-12 col-sm-6">
              <div className="info-container-inner">
                <h2>{l('Develop')}</h2>
                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="https://github.com/orgs/metabrainz">
                    {l('Datasets and Live Data Feed')}
                  </a>
                </span>

                <p className="info-text">
                  {exp.l(
                    `Access all our datasets and the MusicBrainz
                     Live Data Feed by {account_link|creating an account},
                     whether for personal or non-commercial use.`,
                     {account_link: 'https://metabrainz.org/supporters/account-type'},
                  )}
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="/doc/MusicBrainz_Database">
                    {l('Database')}
                  </a>
                </span>

                <p className="info-text">
                  {l('View and download the MusicBrainz Database.')}
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="/doc/Developer_Resources">
                    {l('Developer resources')}
                  </a>
                </span>

                <p className="info-text">
                  {l(
                    `Use our XML web service or development libraries
                     to create your own MusicBrainz-enabled applications.`,
                  )}
                </p>

                <p className="d-flex align-items-center gap-1 flex-wrap">
                  <span className="fw-bold">
                    {l('See also:')}
                  </span>
                  <a href="/doc/About/Data_License">
                    {l('Data license')}
                  </a>
                  {' '}
                  {l('|')}
                  {' '}
                  <a href="/doc/Frequently_Asked_Questions">
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
                  <a href="/doc/How_to_Contribute">
                    {l('Edit the database')}
                  </a>
                </span>
                <p className="info-text">
                  {l(
                    `Anyone can help improve our global database! Get started
                     and improve existing data or add new artists and music.`,
                  )}
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="https://tickets.metabrainz.org/secure/Dashboard.jspa">
                    {l('Bug tracker')}
                  </a>
                </span>
                <p className="info-text">
                  {l(
                    `Developers, view and pick up issues in our
                     bug tracker, and join us in the developer chat.`,
                  )}
                </p>

                <span className="d-flex align-items-center fw-bold">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="/doc/Communication/ChatBrainz">
                    {l('Join the community')}
                  </a>
                </span>
                <p className="info-text">
                  {l(
                    `Talk to other database editors and music fans
                     on our forums or our live chat via IRC,
                     Matrix and Discord.`,
                  )}
                </p>

                <p className="d-flex align-items-center gap-1 flex-wrap">
                  <span className="fw-bold">
                    {l('See also:')}
                  </span>
                  <a href="/doc/Beginners_Guide">
                  {l('Beginner’s guide')}
                  </a>
                  {' | '}
                  <a href="/doc/How_Editing_Works">
                    {l('Editing introduction')}
                  </a>
                  {' '}
                  {l('|')}
                  {' '}
                  <a href="/doc/Style">
                    {l('Style guidelines')}
                  </a>
                  {' '}
                  {l('|')}
                  {' '}
                  <a href="/doc/Frequently_Asked_Questions">
                    {l('MusicBrainz FAQs')}
                  </a>
                  {' '}
                  {l('|')}
                  {' '}
                  <a href="/doc/How_to_Add_an_Artist">
                    {l('How to add artists')}
                  </a>
                  {' '}
                  {l('|')}
                  {' '}
                  <a href="/doc/How_to_Add_a_Release">
                    {l('How to add releases')}
                  </a>
                </p>

              </div>
            </div>
          </div>
        </div>

        {/* Open source */}
        <div
          className="info-container"
          id="open-source"
          ref={openSourceContainerRef}
        >
          <div className="row g-5">
            <div className="col-12 col-sm-6 col-md-4">
              <div className="info-container-inner">
                <h2>{l('Open source')}</h2>
                <p>
                  {l(
                    `"Open source is source code that is made freely available
                     for possible modification and redistribution..."`,
                  )}
{' '}
                  {l('-')}
{' '}
                  <a href="https://en.wikipedia.org/wiki/Open_source">
                    {l('Wikipedia')}
                  </a>
                </p>
                <p>
                  {l(
                    `The MusicBrainz database is all open source.
                     This means that anyone can view the code,
                     contribute improvements and new features,
                     and copy and modify it for their own use.`,
                  )}
                </p>
                <p>
                  {l(
                    `Thousands of wonderful people contribute code
                     or data to MusicBrainz and its sister projects
                     for no monetary return and for everyone's benefit.`,
                  )}
                </p>

                <span className="d-flex align-items-center">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="https://github.com/orgs/metabrainz">
                    {l('GitHub repositories')}
                  </a>
                </span>
              </div>
            </div>

            <div className="col-12 col-sm-6 col-md-4">
              <div className="info-container-inner">
                <h2>{l('Data provider')}</h2>
                <p>
                  {l(
                    `The MetaBrainz core mission is to curate and
                    maintain public datasets that anyone can download
                    and use. Some of the world's biggest platforms,
                    such as Google and Amazon, use our data, as well as
                    small-scale developers and curious individuals.`,
                  )}
{' '}
                  {l('We ask')}
{' '}
                  <a href="https://metabrainz.org/supporters">
                    {l('commercial users')}
                  </a>
{' '}
                  {l(
                    `to support us. Personal use of our
                    datasets will always be free.`,
                  )}
                </p>
                <p>
                  {l(
                    `Our datasets include the MusicBrainz PostgreSQL and
                    JSON Data Dumps. Our datasets are AI Ready, perfect for
                    training large language models for music-based tasks.`,
                  )}
                </p>

                <span className="d-flex align-items-center">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="https://metabrainz.org/datasets">
                    {l('MetaBrainz Datasets')}
                  </a>
                </span>
              </div>
            </div>

            <div className="col-12 col-sm-6 col-md-4">
              <div className="info-container-inner">
                <h2>{l('Ethical forever')}</h2>
                <p>
                  {l(
                    `The MetaBrainz Foundation is a registered non-profit,
                    making it impossible for us to be bought or traded.`,
                  )}
                </p>
                <p>
                  {l(
                    `Our team and volunteer contributers from across the globe
                    are proud to consider MusicBrainz and it's sister sites`,
                  )}
{' '}
                  <a href="https://en.wikipedia.org/wiki/Enshittification">
                    {l('enshittification')}
                  </a>
                  {l(
                    `-proof projects, immune to the the crapifying that
                    takes place when business interests inevitably subsume
                    and monetize projects that initially focussed on
                    high-quality offerings to attract users.`,
                  )}
                </p>

                <span className="d-flex align-items-center">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" />
                  <a href="https://metabrainz.org">
                    {l('MetaBrainz Foundation')}
                  </a>
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Logo container */}
        <div className="logo-container layout-width">
          <a href="https://metabrainz.org">
            <img alt="MetaBrainz" src={MetaBrainzLogo} />
          </a>
          <a href="https://musicbrainz.org">
            <img alt="MusicBrainz" src={MusicBrainzLogo} />
          </a>
          <a href="https://picard.musicbrainz.org">
            <img alt="Picard" src={PicardLogo} />
          </a>
          <a href="https://listenbrainz.org">
            <img alt="ListenBrainz" src={ListenBrainzLogo} />
          </a>
          <a href="https://bookbrainz.org">
            <img alt="BookBrainz" src={BookBrainzLogo} />
          </a>
        </div>

        <BannerCarousel />

        <NewFooter />
      </div>

      {manifest('bootstrap', {async: true})}
      {manifest('homepage/navbar', {async: true})}
      {manifest('homepage/editor-tools', {async: true})}
      {manifest('homepage/user-menu', {async: true})}
      {manifest('homepage/search', {async: true})}
      {manifest('homepage/banner-carousel', {async: true})}
      {manifest('homepage/stats', {async: true})}
      {manifest('common/loadArtwork', {async: true})}
      {manifest('homepage/timeline-carousel', {async: true})}
    </Layout>
  );
}

export default Homepage;
