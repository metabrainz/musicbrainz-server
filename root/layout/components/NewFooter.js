/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import musicbrainzLogo
  from '../../static/images/meb-logos/musicbrainz.svg';
import metabrainzLogo
  from '../../static/images/meb-logos/metabrainz.svg';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faAngleRight } from '@fortawesome/free-solid-svg-icons';

component NewFooter() {
  return (
    <section className="footer layout-width">
      <div className="container-fluid px-4">
        <div className="row align-items-baseline">
          <div className="col-12 col-lg-4">
            <h3>
              <img
                src={musicbrainzLogo}
                width="180"
                alt="MusicBrainz"
              />
            </h3>
            <br />
            <p>
              is an open music encyclopedia that collects music metadata and makes it available to the public.
            </p>
            <ul className="list-unstyled">
              <li className="color-a">
                <span>Development IRC: </span>{" "}
                <a
                  href="/doc/Communication/ChatBrainz"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  #metabrainz
                </a>
              </li>
              <li className="color-a">
                <span>Discussion IRC: </span>{" "}
                <a
                  href="/doc/Communication/ChatBrainz"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  #metabrainz
                </a>
              </li>
              <li className="color-a">
                <span>Email: </span>{" "}
                <a href="mailto:support@metabrainz.org">
                  support@metabrainz.org{" "}
                </a>
              </li>
            </ul>
          </div>
          <div className="col-12 col-lg-3">
            <h3 className="text-brand text-body">Useful Links</h3>
            <ul className="list-unstyled">
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://metabrainz.org/donate"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Donate
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://wiki.musicbrainz.org/Main_Page"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Wiki
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://community.metabrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Community
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://blog.metabrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Blog
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://www.redbubble.com/people/metabrainz/shop"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Shop
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://metabrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  MetaBrainz
                </a>
              </li>
              <li className="d-block d-md-none">
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://github.com/metabrainz/listenbrainz-server"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Contribute Here
                </a>
              </li>
              <li className="d-block d-md-none">
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://tickets.metabrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Bug Tracker
                </a>
              </li>
            </ul>
          </div>
          <div className="col-12 col-lg-3">
            <h3 className="text-brand text-body">Fellow Projects</h3>
            <ul className="list-unstyled">
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://listenbrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {l('ListenBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://critiquebrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {l('CritiqueBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://picard.musicbrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {l('Picard')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://bookbrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {l('BookBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://acousticbrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {l('AcousticBrainz')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://coverartarchive.org"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {l('Cover Art Archive')}
                </a>
              </li>
            </ul>
          </div>
          <div className="col-12 col-lg-2">
            <h3 className="text-brand text-body">Join Us</h3>
            <ul className="list-unstyled">
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a href="/doc/Beginners_Guide">
                  {l('Beginner\'s Guide')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a href="/doc/Style">
                  {l('Style Guidelines')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a
                  href="https://picard.musicbrainz.org/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {l('How Tos')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a href="/doc/Frequently_Asked_Questions">
                  {l('FAQs')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
                <a href="/doc/MusicBrainz_Documentation">
                  {l('Doc Index')}
                </a>
              </li>
              <li>
                <FontAwesomeIcon icon={faAngleRight} size="sm" />
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
              OSS Geek?{" "}
              <a
                href="https://github.com/metabrainz/musicbrainz-server"
                target="_blank"
                rel="noopener noreferrer"
              >
                Contribute Here {" "}
              </a>
            </p>
          </div>
          <div className="col-12 col-lg-6">
            <p className="border-light border-top pt-3 text-center">
              Brought to you by{" "}
              <img
                src={metabrainzLogo}
                width="30"
                height="30"
                alt="MetaBrainz"
              />{" "}
              <a
                href="https://metabrainz.org/"
                target="_blank"
                rel="noopener noreferrer"
              >
                MetaBrainz Foundation
              </a>
            </p>
          </div>
          <div className="col-12 col-lg-3">
            <p className="border-light border-top pt-3 text-center">
              Found an Issue?{" "}
              <a
                href="https://tickets.metabrainz.org/"
                target="_blank"
                rel="noopener noreferrer"
              >
                Report Here {" "}
              </a>
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};


export default NewFooter;