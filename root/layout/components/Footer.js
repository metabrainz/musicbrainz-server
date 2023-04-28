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
import {faChevronRight} from '@fortawesome/free-solid-svg-icons';

import {CatalystContext} from '../../context';
import logo from '../../static/images/meb-logos/musicbrainz.svg';
import {capitalize} from '../../static/scripts/common/utility/strings';
import {returnToCurrentPage} from '../../utility/returnUri';
import DBDefs from '../../static/scripts/common/DBDefs';

import type {LinkProps, LinkAndIconProps, LinkAndImgProps, Channel}
  from './FooterData';
import {footerData} from './FooterData';


type LanguageMenuProps = {
  +$c: CatalystContextT,
  +currentBCP47Language: string,
  +serverLanguages: $ReadOnlyArray<ServerLanguageT>,
};

type FooterChannelsElementProps = {
  +$c: CatalystContextT,
};

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
    className="dropdown-item"
    href={
      '/set-language/' + encodeURIComponent(language.name) +
      '?' + returnToCurrentPage($c)
    }
  >
    {languageName(language, false)}
  </a>
);

const LanguageMenu = ({
  $c,
  currentBCP47Language,
  serverLanguages,
}: LanguageMenuProps): React.Element<'div'> => (
  <div className="dropdown dropup">
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
          <li key={index}>
            {inner}
          </li>
        );
      })}
      <li>
        <a
          className="dropdown-item"
          href={'/set-language/unset?' + returnToCurrentPage($c)}
        >
          {l('(reset language)')}
        </a>
      </li>
      <li>
        <a
          className="dropdown-item"
          href="https://www.transifex.com/musicbrainz/musicbrainz/"
        >
          {l('Help Translate')}
        </a>
      </li>
    </ul>
  </div>
  );

const ListLinkElement = (props: LinkProps): React.Element<'li'> => (
  <li>
    <FontAwesomeIcon
      className="me-3"
      icon={faChevronRight}
      size="sm"
    />
    <a
      className="ms-1"
      href={props.href}
      rel="noopener noreferrer"
      target="_blank"
    >
      {l(props.text)}
    </a>
  </li>
);

const SocialNetworkLink = ({
  icon,
  link,
}: LinkAndIconProps): React.Element<'a'> =>(
  <a
    aria-label={l(link.text)}
    className="me-3"
    href={link.href}
    rel="noreferrer"
    target="_blank"
  >
    <FontAwesomeIcon
      icon={icon}
      size="lg"
    />
  </a>
);

const UsefulLinksList = (): React.Element<'ul'> => {
  return (
    <ul className="list-unstyled mb-0">
      {footerData.usefulLinks.map((contact, i) => (
        <ListLinkElement
          key={i}
          {...contact}
        />
      ))}
      <li className="mt-2">
        {footerData.socialNetworks.map((socialNetwork, i) => (
          <SocialNetworkLink
            key={i}
            {...socialNetwork}
          />
        ))}
      </li>
    </ul>
  );
};

const FellowProjectListElement = ({
  img,
  link,
}: LinkAndImgProps): React.Element<'li'> => {
  return (
    <li>
      <FontAwesomeIcon
        className="me-3"
        icon={faChevronRight}
        size="sm"
      />
      <img
        alt={img.alt}
        className="me-1"
        height="24"
        src={img.src}
        width="24"
      />
      <a
        href={link.href}
        rel="noopener noreferrer"
        target="_blank"
      >
        {l(link.text)}
      </a>
    </li>
  );
};

const FellowProjectsList = (): React.Element<'ul'> => (
  <ul className="list-unstyled mb-0">
    {footerData.fellowProjects.map((fellowProject, i) => (
      <FellowProjectListElement
        key={i}
        {...fellowProject}
      />
    ))}
  </ul>
);

const JoinUsList = (): React.Element<'ul'> => (
  <ul className="list-unstyled mb-0">
    {footerData.joinUsLinks.map((contact, i) => (
      <ListLinkElement
        key={i}
        {...contact}
      />
    ))}
  </ul>
);

const ChannelElement = (props: Channel): React.Element<'li'> => {
  const rel = props.isNoOpener ? 'noopener noreferrer' : 'noreferrer';
  const target = '_blank';
  return (
    <li>
      <span className="color-gray">{l(props.label) + ':'}</span>
      <a
        className="ms-1"
        href={props.href}
        rel={rel}
        target={target}
      >
        {l(props.linkText)}
      </a>
    </li>
  );
};

const ChannelsList = (
  props: FooterChannelsElementProps,
): React.Element<'ul'> => (
  <ul className="list-unstyled lh-base mb-4">
    {footerData.channels.map((contact, i) => (
      <ChannelElement
        key={i}
        {...contact}
      />
    ))}
    {DBDefs.BETA_REDIRECT_HOSTNAME ? (
      <li>
        <a
          className="fw-bold"
          href={'/set-beta-preference?' + returnToCurrentPage(props.$c)}
        >
          {DBDefs.IS_BETA ? l('Stop using beta site') : l('Use beta site')}
        </a>
      </li>
    ) : null}
  </ul>
);

const Footer = (): React.Element<'section'> => {
  const $c = React.useContext(CatalystContext);
  const serverLanguages = $c.stash.server_languages;

  return (
    <section className="bs footer">
      <div
        className="container-fluid g-0 mb-theme-light"
      >
        <div className="row
          row-cols-1
          row-cols-md-2
          row-cols-lg-3
          row-cols-xl-4"
        >
          <div className="col-lg-12 col-xl-4 pb-5 border-bottom">
            <h3 className="mb-4">
              <img
                alt="MusicBrainz"
                src={logo}
                width="196"
              />
            </h3>
            <p className="color-gray">
              {l(
                `MusicBrainz is an open music encyclopedia that collects
               music metadata and makes it available to the public.`,
              )}
            </p>
            <ChannelsList $c={$c} />
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
          <div
            className="col-xl-3 mt-5 mt-md-0 mt-lg-5 mt-xl-0
            border-sm-bottom-0 border-md-bottom"
          >
            <h3 className="fw-bold color-black">
              {l('Join Us')}
            </h3>
            <JoinUsList />
          </div>
          <div
            className="col-xl-3 mt-5 mt-xl-0
            border-sm-bottom-0 border-md-bottom"
          >
            <h3 className="fw-bold color-black">
              {l('Fellow Projects')}
            </h3>
            <FellowProjectsList />
          </div>
          <div className="col-xl-2 mt-5 pb-5 mt-xl-0 border-bottom">
            <h3 className="fw-bold color-black">
              {l('Useful Links')}
            </h3>
            <UsefulLinksList />
          </div>
        </div>
        <div className="row row-cols-1 row-cols-lg-3">
          <div
            className="col-lg-3 mt-4 pb-4 ps-3 d-none d-md-block color-gray
            text-start text-md-center text-lg-start
            border-sm-bottom border-lg-bottom-0"
          >
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
          </div>
          <div
            className="col-lg-6 mt-4 pb-4 text-center color-gray
            border-sm-bottom border-lg-bottom-0"
          >
            {
              // eslint-disable-next-line max-len
              exp.l('Brought to you by <span id="meb-logo"/> MetaBrainz Foundation')
            }
          </div>
          <div
            className="col-lg-3 mt-4 pe-3 d-none d-md-block color-gray
            text-end text-md-center text-lg-end"
          >
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
