/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {capitalize} from '../../static/scripts/common/utility/strings';
import {returnToCurrentPage} from '../../utility/returnUri';
import {CatalystContext} from '../../context';

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
  <div className="dropdown pb-1 mb-1 dropup">
    <button
      aria-expanded="false"
      className="btn btn-outline-primary fs-4"
      data-bs-toggle="dropdown"
      id="languageDropdown"
      type="button"
    >
      {languageName(
        serverLanguages.find(x => x.name === currentBCP47Language),
        true,
      )}
    </button>
    <ul aria-labelledby="languageDropdown" className="dropdown-menu">
      {serverLanguages.map(function (language, index) {
        let inner = <LanguageLink $c={$c} language={language} />;

        if (language.name === currentBCP47Language) {
          inner = <strong>{inner}</strong>;
        }

        return (
          <li
            className="nav-item dropdown fs-4"
            key={index}
          >
            {inner}
          </li>
        );
      })}
      <li className="nav-item dropdown fs-4">
        <a href={'/set-language/unset?' + returnToCurrentPage($c)}>
          {l('(reset language)')}
        </a>
      </li>
      <li className="nav-item dropdown fs-4">
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
    <section className="footer">
      <div className="ms-4 me-4 mb-3 ps-4 pb-3 pe-4 border-top container">
        <div className="row mb-4 mt-2 pt-2">
          <div className="col-sm-12 col-md-4">
            <h3>
              <img
                alt="MusicBrainz"
                src="../../static/images/meb-logos/musicbrainz.svg"
                width="180"
              />
            </h3>
            <br />
            <p className="fs-4">
              {l(`MusicBrainz is an open music encyclopedia that collects
              music metadata and makes it available to the public.`)}
            </p>
            <ul className="list-unstyled">
              <li>
                <span className="fs-4">
                  {l('Development IRC: ')}
                </span>
                <a
                  className="fw-bold fs-4"
                  href="https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('#metabrainz')}
                </a>
              </li>
              <li>
                <span className="fs-4">
                  {l('Email: ')}
                </span>
                <a
                  className="fw-bold fs-4"
                  href="mailto:support@metabrainz.org"
                >
                  {l('support@metabrainz.org')}
                </a>
              </li>
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
          <br />
          <div className="col-sm-12 col-md-3">
            <h3 className="fs-2 fw-bold color-black">
              {l('Useful Links')}
            </h3>
            <ul className="list-unstyled">
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://metabrainz.org/donate"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Donate')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://wiki.musicbrainz.org/Main_Page"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Wiki')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://community.metabrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Community')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://blog.metabrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Blog')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://www.redbubble.com/people/metabrainz/shop"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Shop')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
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
            <h3 className="fs-2 fw-bold color-black">
              {l('Fellow Projects')}
            </h3>
            <ul className="list-unstyled">
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <div className="image me-1">
                  <img
                    alt="ListenBrainz"
                    height="24"
                    src="../../static/images/meb-icons/ListenBrainz.svg"
                    width="24"
                  />
                </div>
                <a
                  className="fw-bold fs-4"
                  href="https://listenbrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('ListenBrainz')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <div className="image me-1">
                  <img
                    alt="CritiqueBrainz"
                    height="24"
                    src="../../static/images/meb-icons/CritiqueBrainz.svg"
                    width="24"
                  />
                </div>
                <a
                  className="fw-bold fs-4"
                  href="https://critiquebrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('CritiqueBrainz')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <div className="image me-1">
                  <img
                    alt="Picard"
                    height="24"
                    src="../../static/images/meb-icons/Picard.svg"
                    width="24"
                  />
                </div>
                <a
                  className="fw-bold fs-4"
                  href="https://picard.musicbrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Picard')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <div className="image me-1">
                  <img
                    alt="BookBrainz"
                    height="24"
                    src="../../static/images/meb-icons/BookBrainz.svg"
                    width="24"
                  />
                </div>
                <a
                  className="fw-bold fs-4"
                  href="https://bookbrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('BookBrainz')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <div className="image me-1">
                  <img
                    alt="AcousticBrainz"
                    height="24"
                    src="../../static/images/meb-icons/AcousticBrainz.svg"
                    width="24"
                  />
                </div>
                <a
                  className="fw-bold fs-4"
                  href="https://acousticbrainz.org/"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('AcousticBrainz')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <div className="image me-1">
                  <img
                    alt="CoverArtArchive"
                    height="24"
                    src="../../static/images/meb-icons/CoverArtArchive.svg"
                    width="24"
                  />
                </div>
                <a
                  className="fw-bold fs-4"
                  href="https://coverartarchive.org"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Cover Art Archive')}
                </a>
              </li>

            </ul>
          </div>
          <div className="col-sm-12 col-md-2">
            <h3 className="fs-2 fw-bold color-black">
              {l('Join Us')}
            </h3>
            <ul className="list-unstyled">
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://musicbrainz.org/doc/Beginners_Guide"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l(`Beginner's Guide`)}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://musicbrainz.org/doc/Style"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Style Guidelines')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://musicbrainz.org/doc/How_To"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('How Tos')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://musicbrainz.org/doc/Frequently_Asked_Questions"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('FAQs')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
                  href="https://musicbrainz.org/doc/MusicBrainz_Documentation"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Doc Index')}
                </a>
              </li>
              <li>
                <img
                  alt="Arrow"
                  height="24"
                  src="../../static/images/icons/angle_double_right_icon.svg"
                  width="18"
                />
                <a
                  className="fw-bold fs-4"
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
        <div className="row mt-4">
          <div className="col-md-3 border-top pt-4 d-none d-md-block fs-4">
            <p>
              {l('OSS Geek? ')}
              <a
                href="https://github.com/metabrainz/musicbrainz-server"
                rel="noopener noreferrer"
                target="_blank"
              >
                <span>
                  {l('Contribute Here')}
                </span>
              </a>
            </p>
          </div>
          <div className="col-md-6 border-top pt-4 text-center fs-4">
            {l('Brought to you by')}
            <div className="image ms-1 me-1">
              <img
                alt="MetaBrainz"
                height="24"
                src="../../static/images/meb-icons/MetaBrainz.svg"
                width="24"
              />
            </div>
            <span>
              {l('MetaBrainz Foundation')}
            </span>
          </div>
          <div className="col-md-3 border-top pt-4 d-none d-md-block fs-4">
            <p>
              {l('Found an Issue? ')}
              <a
                href="https://tickets.metabrainz.org/"
                rel="noopener noreferrer"
                target="_blank"
              >
                <span>
                  {l('Report Here')}
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
