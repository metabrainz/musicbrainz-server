/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const Footer = (): React.Element<'section'> => (
  <section className="section-footer">
    <div className="container">
      <div className="row">
        <div className="col-sm-12 col-md-4">
          <h3>
            <img
              alt="MusicBrainz"
              src="../../static/images/meb-logos/musicbrainz.svg"
              width="180"
            />
          </h3>
          <br />
          <p className="color-gray">
            {l(`MusicBrainz is an open music encyclopedia that collects
              music metadata and makes it available to the public.`)}
          </p>
          <ul className="list-unstyled">
            <li className="color-a">
              <span className="color-gray">
                {l('Development IRC:')}
              </span>
              <a
                href="https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('#metabrainz')}
              </a>
            </li>
            <li className="color-a">
              <span className="color-gray">
                {l('Discussion IRC:')}
              </span>
              <a
                href="https://kiwiirc.com/nextclient/irc.libera.chat/?#musicbrainz"
                rel="noopener noreferrer"
                target="_blank"
              >
                {' #metabrainz'}
              </a>
            </li>
            <li className="color-a">
              <span className="color-gray">
                {l('Email:')}
              </span>
              <a href="mailto:support@metabrainz.org">
                {l('support@metabrainz.org')}
              </a>
            </li>
          </ul>
        </div>
        <br />
        <div className="col-sm-12 col-md-3 section-md-t3">
          <h3 className="w-title-a text-brand">
            {l('Useful Links')}
          </h3>
          <ul className="list-unstyled">
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://metabrainz.org/donate"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Donate')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://wiki.musicbrainz.org/Main_Page"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Wiki')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://community.metabrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Community')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://blog.metabrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Blog')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://www.redbubble.com/people/metabrainz/shop"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Shop')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://metabrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('MetaBrainz')}
              </a>
            </li>
          </ul>
        </div>
        <div className="col-sm-12 col-md-3 section-md-t3">
          <h3 className="w-title-a text-brand">
            {l('Fellow Projects')}
          </h3>
          <ul className="list-unstyled">
            <li className="image-container item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <div className="image">
                <img
                  alt="image"
                  height="24"
                  src="../../static/images/meb-icons/ListenBrainz.svg"
                  width="24"
                />
              </div>
              <a
                href="https://listenbrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('ListenBrainz')}
              </a>
            </li>
            <li className="image-container item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <div className="image">
                <img
                  alt="image"
                  height="24"
                  src="../../static/images/meb-icons/CritiqueBrainz.svg"
                  width="24"
                />
              </div>
              <a
                href="https://critiquebrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('CritiqueBrainz')}
              </a>
            </li>
            <li className="image-container item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <div className="image">
                <img
                  alt="image"
                  height="24"
                  src="../../static/images/meb-icons/Picard.svg"
                  width="24"
                />
              </div>
              <a
                href="https://picard.musicbrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Picard')}
              </a>
            </li>
            <li className="image-container item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <div className="image">
                <img
                  alt="image"
                  height="24"
                  src="../../static/images/meb-icons/BookBrainz.svg"
                  width="24"
                />
              </div>
              <a
                href="https://bookbrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('BookBrainz')}
              </a>
            </li>
            <li className="image-container item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <div className="image">
                <img
                  alt="image"
                  height="24"
                  src="../../static/images/meb-icons/AcousticBrainz.svg"
                  width="24"
                />
              </div>
              <a
                href="https://acousticbrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('AcousticBrainz')}
              </a>
            </li>
            <li className="image-container item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <div className="image">
                <img
                  alt="image"
                  height="24"
                  src="/../../static/images/meb-icons/CoverArtArchive.svg"
                  width="24"
                />
              </div>
              <a
                href="https://coverartarchive.org"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Cover Art Archive')}
              </a>
            </li>

          </ul>
        </div>
        <div className="col-sm-12 col-md-2 section-md-t3">
          <h3 className="w-title-a text-brand">
            {l('Join Us')}
          </h3>
          <ul className="list-unstyled">
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://musicbrainz.org/doc/Beginners_Guide"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l(`Beginner's Guide`)}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://musicbrainz.org/doc/Style"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Style Guidelines')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://musicbrainz.org/doc/How_To"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('How Tos')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://musicbrainz.org/doc/Frequently_Asked_Questions"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('FAQs')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://musicbrainz.org/doc/MusicBrainz_Documentation"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Doc Index')}
              </a>
            </li>
            <li className="item-list-a">
              <img
                height="18"
                src="../../static/images/icons/angle_double_right_icon.svg"
                width="18"
              />
              <a
                href="https://musicbrainz.org/doc/Development"
                rel="noopener noreferrer"
                target="_blank"
              >
                {l('Development')}
              </a>
            </li>

          </ul>
        </div>
      </div>
      <div className="row center-p">
        <div className="col-md-3 d-none d-md-block">
          <p className="color-gray section-line">
            {l('OSS Geek? ')}
            <a
              href="https://github.com/metabrainz/musicbrainz-server"
              rel="noopener noreferrer"
              target="_blank"
            >
              <span className="color-a">
                {l('Contribute Here')}
              </span>
            </a>
          </p>
        </div>
        <div className="col-md-6 section-line image-container copyright">
          {l('Brought to you by')}
          <div className="image">
            <img
              alt="image"
              height="24"
              src="../../static/images/meb-icons/MetaBrainz.svg"
              width="24"
            />
          </div>
          <span className="color-a">
            {l('MetaBrainz Foundation')}
          </span>
        </div>
        <div className="col-md-3 d-none d-md-block">
          <p className="color-gray section-line">
            {l('Found an Issue? ')}
            <a
              href="https://tickets.metabrainz.org/"
              rel="noopener noreferrer"
              target="_blank"
            >
              <span className="color-a">
                {l('Report Here')}
              </span>
            </a>
          </p>
        </div>
      </div>
    </div>
  </section>
  );

export default Footer;
