/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import {faTwitter, faFacebook, faInstagram, faLinkedin}
  from '@fortawesome/free-brands-svg-icons';

import {capitalize} from '../../static/scripts/common/utility/strings';
import {returnToCurrentPage} from '../../utility/returnUri';
import {CatalystContext} from '../../context';
import logo from '../../static/images/meb-logos/musicbrainz.svg';
import listenbrainzLogo from '../../static/images/meb-icons/ListenBrainz.svg';
import metabrainzLogo from '../../static/images/meb-icons/MetaBrainz.svg';
import critiquebrainzLogo
  from '../../static/images/meb-icons/CritiqueBrainz.svg';
import picardLogo from '../../static/images/meb-icons/Picard.svg';
import bookbrainzLogo from '../../static/images/meb-icons/BookBrainz.svg';
import caaLogo from '../../static/images/meb-icons/CoverArtArchive.svg';
import DBDefs from '../../static/scripts/common/DBDefs';

function languageName(language, selected) {
  if (!language) {
    return '';
  }

  const {
    id,
    native_language: nativeLanguage,
    native_territory: nativeTerritory,
  } = language;

  let text = `[${id}]`;

  if (nativeLanguage) {
    text = capitalize(nativeLanguage);

    if (nativeTerritory) {
      text += ' (' + capitalize(nativeTerritory) + ')';
    }
  }

  if (selected) {
    text += ' \u25be';
  }

  return text;
}

const LanguageLink = ({$c, language}) => (
  <a
    href={
      '/set-language/' + encodeURIComponent(language.name) +
            '?' + returnToCurrentPage($c)
    }
  >
    {languageName(language, false)}
  </a>
);

type LanguageMenuProps = {
  +$c: CatalystContextT,
  +currentBCP47Language: string,
  +serverLanguages: $ReadOnlyArray<ServerLanguageT>,
};

const LanguageMenu = ({
  $c,
  currentBCP47Language,
  serverLanguages,
}: LanguageMenuProps) => (
  <div className="dropdown pb-2 ms-3 dropup">
    <button
      aria-expanded="false"
      className="btn btn-outline-primary fs-5"
      data-bs-toggle="dropdown"
      id="language-dropdown"
      type="button"
    >
      {languageName(
        serverLanguages.find(x => x.name === currentBCP47Language),
        true,
      )}
    </button>
    <ul aria-labelledby="language-dropdown" className="dropdown-menu">
      {serverLanguages.map(function (language, index) {
        let inner = <LanguageLink $c={$c} language={language} />;

        if (language.name === currentBCP47Language) {
          inner = <strong>{inner}</strong>;
        }

        return (
          <li
            className="nav-item dropdown fs-5"
            key={index}
          >
            {inner}
          </li>
        );
      })}
      <li className="nav-item dropdown fs-5">
        <a href={'/set-language/unset?' + returnToCurrentPage($c)}>
          {l('(reset language)')}
        </a>
      </li>
      <li className="nav-item dropdown fs-5">
        <a href="https://www.transifex.com/musicbrainz/musicbrainz/">
          {l('Help Translate')}
        </a>
      </li>
    </ul>
  </div>
);

const Footer = (): React.Element<'section'> => {
  const $c = React.useContext(CatalystContext);
  const serverLanguages = $c.stash.server_languages;

  return (
    <section className="bs footer">
      <div className="border-top container-fluid p-4">
        <div className="row">
          <div className="col-md-4">
            <h3 className="ms-3">
              <img
                alt="MusicBrainz"
                src={logo}
                width="196"
              />
            </h3>
            <br />
            <ul className="list-unstyled ms-3">
              <li>
                <span className="fs-5">
                  {l('Development IRC:')}
                </span>
                <a
                  className="fw-bold fs-5 ms-1"
                  href="https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('#metabrainz')}
                </a>
              </li>
              <li>
                <span className="fs-5">
                  {l('Discussion IRC:')}
                </span>
                <a
                  className="fw-bold fs-5 ms-1"
                  href="https://kiwiirc.com/nextclient/irc.libera.chat/?#musicbrainz"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('#musicbrainz')}
                </a>
              </li>
              <li>
                <span className="fs-5">
                  {l('Forums:')}
                </span>
                <a
                  className="fw-bold fs-5 ms-1"
                  href="https://community.metabrainz.org"
                  rel="noreferrer"
                  target="_blank"
                >
                  {l('community.metabrainz.org')}
                </a>
              </li>
              {DBDefs.BETA_REDIRECT_HOSTNAME ? (
                <li>
                  <a
                    className="fw-bold fs-5 ms-1"
                    href={
                      '/set-beta-preference?' + returnToCurrentPage($c)
                    }
                  >
                    {DBDefs.IS_BETA
                      ? l('Stop using beta site')
                      : l('Use beta site')}
                  </a>
                </li>
              ) : null}
            </ul>
            {serverLanguages && serverLanguages.length > 1 ? (
              <LanguageMenu
                $c={$c}
                currentBCP47Language={
                  $c.stash.current_language.replace('_', '-')
                }
                serverLanguages={serverLanguages}
              />
            ) : null}
          </div>
          <div className="col-sm-12 col-md-3">
            <h3 className="fs-3 fw-bold color-black ms-3">
              {l('Join Us')}
            </h3>
            <ul className="list-style-type">
              <li>
                <a
                  className="fw-bold fs-5"
                  href="/doc/Beginners_Guide"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l(`Beginner's Guide`)}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="/doc/Style"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Style Guidelines')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="/doc/How_To"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('How Tos')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="/doc/Frequently_Asked_Questions"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('FAQs')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="/doc/MusicBrainz_Documentation"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Doc Index')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="/doc/Development"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Development')}
                </a>
              </li>
            </ul>
          </div>
          <div className="col-sm-12 col-md-3">
            <h3 className="fs-3 fw-bold color-black ms-3">
              {l('Fellow Projects')}
            </h3>
            <ul className="list-style-type">
              <li>
                <img
                  alt="ListenBrainz"
                  className="me-1"
                  height="24"
                  src={listenbrainzLogo}
                  width="24"
                />
                <a
                  className="fw-bold fs-5"
                  href="https://listenbrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('ListenBrainz')}
                </a>
              </li>
              <li>
                <img
                  alt="CritiqueBrainz"
                  className="me-1"
                  height="24"
                  src={critiquebrainzLogo}
                  width="24"
                />
                <a
                  className="fw-bold fs-5"
                  href="https://critiquebrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('CritiqueBrainz')}
                </a>
              </li>
              <li>
                <img
                  alt="Picard"
                  className="me-1"
                  height="24"
                  src={picardLogo}
                  width="24"
                />
                <a
                  className="fw-bold fs-5"
                  href="https://picard.musicbrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Picard')}
                </a>
              </li>
              <li>
                <img
                  alt="BookBrainz"
                  className="me-1"
                  height="24"
                  src={bookbrainzLogo}
                  width="24"
                />
                <a
                  className="fw-bold fs-5"
                  href="https://bookbrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('BookBrainz')}
                </a>
              </li>
              <li>
                <img
                  alt="CoverArtArchive"
                  className="me-1"
                  height="24"
                  src={caaLogo}
                  width="24"
                />
                <a
                  className="fw-bold fs-5"
                  href="https://coverartarchive.org"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Cover Art Archive')}
                </a>
              </li>
              <li>
                <img
                  alt="MetaBrainz"
                  className="me-1"
                  height="24"
                  src={metabrainzLogo}
                  width="24"
                />
                <a
                  className="fw-bold fs-5"
                  href="https://metabrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('MetaBrainz')}
                </a>
              </li>
            </ul>
          </div>
          <div className="col-sm-12 col-md-2">
            <h3 className="fs-3 fw-bold color-black ms-3">
              {l('Useful Links')}
            </h3>
            <ul className="list-style-type">
              <li>
                <a
                  className="fw-bold fs-5"
                  href="https://metabrainz.org/donate"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Donate')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="https://wiki.musicbrainz.org/Main_Page"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Wiki')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="https://blog.metabrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Blog')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="https://www.redbubble.com/people/metabrainz/shop"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Shop')}
                </a>
              </li>
              <li>
                <a
                  className="fw-bold fs-5"
                  href="https://metabrainz.org/contact"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Contact us')}
                </a>
              </li>
              <li className="mt-2">
                <a
                  aria-label="Follow us on Twitter"
                  href="https://twitter.com/MusicBrainz"
                  rel="noreferrer"
                  target="_blank"
                >
                  <FontAwesomeIcon
                    icon={faTwitter}
                    size="lg"
                  />
                </a>
                <a
                  aria-label="Follow us on Facebook"
                  className="ms-3"
                  href="https://facebook.com/MusicBrainz-12390437194"
                  rel="noreferrer"
                  target="_blank"
                >
                  <FontAwesomeIcon
                    icon={faFacebook}
                    size="lg"
                  />
                </a>
                <a
                  aria-label="Follow us on Instagram"
                  className="ms-3"
                  href="https://instagram.com/metabrainz"
                  rel="noreferrer"
                  target="_blank"
                >
                  <FontAwesomeIcon
                    icon={faInstagram}
                    size="lg"
                  />
                </a>
                <a
                  aria-label="Follow us on LinkedIn"
                  className="ms-3"
                  href="https://linkedin.com/company/metabrainz"
                  rel="noreferrer"
                  target="_blank"
                >
                  <FontAwesomeIcon
                    icon={faLinkedin}
                    size="lg"
                  />
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="row mt-4 ms-2 me-2">
          <div className="col-md-3 border-top pt-4 d-none d-md-block fs-5">
            <p>
              {l('OSS Geek?')}
              {' '}
              <a
                href="https://github.com/metabrainz/musicbrainz-server"
                rel="noopener noreferrer"
                target="_blank"
              >
                <span>
                  {l('Contribute here')}
                </span>
              </a>
            </p>
          </div>
          <div className="col-md-6 border-top pt-4 text-center fs-5">
            {
              // eslint-disable-next-line max-len
              exp.l('Brought to you by <span id="meb-logo"/> MetaBrainz Foundation')
            }
          </div>
          <div className="col-md-3 border-top pt-4 d-none d-md-block fs-5">
            <p>
              {l('Found an Issue?')}
              <a
                className="ms-1"
                href="https://tickets.metabrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                <span>
                  {l('Report it here')}
                </span>
              </a>
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Footer;
