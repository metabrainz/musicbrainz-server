/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {faAngleRight} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import * as React from 'react';

import metabrainzLogo
  from '../../static/images/meb-logos/metabrainz.svg';
import musicbrainzLogo
  from '../../static/images/meb-logos/musicbrainz.svg';
import {l} from '../../static/scripts/common/i18n.js';

component NewFooter() {
  return (
    <section className="footer layout-width">
      <div className="container-fluid px-4">
        <div className="row align-items-baseline pb-3">
          <div className="col-12 col-lg-4">
            <h3>
              <img
                alt="MusicBrainz"
                src={musicbrainzLogo}
                width="180"
              />
            </h3>
            <br />
            <p>
              {l(
                `is an open music encyclopedia that collects music metadata
                and makes it available to the public.`,
              )}
            </p>
            <ul className="list-unstyled">
              <li className="color-a">
                <span>{l('Development IRC:')} </span>
{' '}
                <a href="/doc/Communication/ChatBrainz">
                  {'#metabrainz'}
                </a>
              </li>
              <li className="color-a">
                <span>{l('Discussion IRC:')} </span>
{' '}
                <a href="/doc/Communication/ChatBrainz">
                  {'#metabrainz'}
                </a>
              </li>
              <li className="color-a">
                <span>{l('Email:')} </span>
{' '}
                <a href="mailto:support@metabrainz.org">
                  {'support@metabrainz.org'}{' '}
                </a>
              </li>
            </ul>
          </div>
          <div className="col-12 col-md-4 col-lg-3">
            <h3 className="text-brand text-body">{l('Useful links')}</h3>
            <ul className="list-unstyled">
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://metabrainz.org/donate">
                  {l('Donate')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://wiki.musicbrainz.org/Main_Page">
                  {l('Wiki')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://community.metabrainz.org/">
                  {l('Community')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://blog.metabrainz.org/">
                  {l('Blog')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://www.redbubble.com/people/metabrainz/shop">
                  {l('Shop')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://metabrainz.org/">
                  {l('MetaBrainz')}
                </a>
              </li>
              <li className="d-block d-md-none">
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://github.com/metabrainz/listenbrainz-server">
                  {l('Contribute Here')}
                </a>
              </li>
              <li className="d-block d-md-none">
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://tickets.metabrainz.org/">
                  {l('Bug Tracker')}
                </a>
              </li>
            </ul>
          </div>
          <div className="col-12 col-md-4 col-lg-3">
            <h3 className="text-brand text-body">{l('Fellow projects')}</h3>
            <ul className="list-unstyled">
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://listenbrainz.org/">
                  {l('ListenBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://critiquebrainz.org/">
                  {l('CritiqueBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://picard.musicbrainz.org/">
                  {l('Picard')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://bookbrainz.org/">
                  {l('BookBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://acousticbrainz.org/">
                  {l('AcousticBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://coverartarchive.org">
                  {l('Cover Art Archive')}
                </a>
              </li>
            </ul>
          </div>
          <div className="col-12 col-md-4 col-lg-2">
            <h3 className="text-brand text-body">{l('Join Us')}</h3>
            <ul className="list-unstyled">
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="/doc/Beginners_Guide">
                  {l('Beginner\'s Guide')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="/doc/Style">
                  {l('Style guidelines')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="https://picard.musicbrainz.org/">
                  {l('How tos')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="/doc/Frequently_Asked_Questions">
                  {l('FAQs')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="/doc/MusicBrainz_Documentation">
                  {l('Documentation index')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="lg" />
                <a href="/doc/Development">
                  {l('Development')}
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="row center-p">
          <div className="col-12 col-lg-3">
            <p className="border-light border-top pt-3 text-center">
              {l('OSS Geek?')}
{' '}
              <a href="https://github.com/metabrainz/musicbrainz-server">
                {l('Contribute here')} {' '}
              </a>
            </p>
          </div>
          <div className="col-12 col-lg-6">
            <p className="border-light border-top pt-3 text-center">
              {l('Brought to you by')}
{' '}
              <img
                alt="MetaBrainz"
                height="30"
                src={metabrainzLogo}
                width="30"
              />
{' '}
              <a href="https://metabrainz.org/">
                {l('MetaBrainz Foundation')}
              </a>
            </p>
          </div>
          <div className="col-12 col-lg-3">
            <p className="border-light border-top pt-3 text-center">
              {l('Found an issue?')}
{' '}
              <a href="https://tickets.metabrainz.org/">
                {l('Report it here')} {' '}
              </a>
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}

export default NewFooter;
