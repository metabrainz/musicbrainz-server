/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {faTwitter, faFacebook, faInstagram, faLinkedin}
  from '@fortawesome/free-brands-svg-icons';
// eslint-disable-next-line import/no-unresolved
import type {IconLookup} from '@fortawesome/fontawesome-common-types';

import listenbrainzLogo from '../../static/images/meb-icons/ListenBrainz.svg';
import metabrainzLogo from '../../static/images/meb-icons/MetaBrainz.svg';
import critiquebrainzLogo
  from '../../static/images/meb-icons/CritiqueBrainz.svg';
import picardLogo from '../../static/images/meb-icons/Picard.svg';
import bookbrainzLogo from '../../static/images/meb-icons/BookBrainz.svg';
import caaLogo from '../../static/images/meb-icons/CoverArtArchive.svg';

export type LinkProps = {
href: string,
text: string,
};

export type ImgProps = {
    alt: string,
    src: string,
};

export type LinkAndIconProps = {
    icon: IconLookup,
    link: LinkProps,
};

export type LinkAndImgProps = {
    img: ImgProps,
    link: LinkProps,
};

export type Channel = {
    href: string,
    isNoOpener: boolean,
    label: string,
    linkText: string,
};

export type FooterData = {
    channels: Channel[],
    fellowProjects: LinkAndImgProps[],
    joinUsLinks: LinkProps[],
    socialNetworks: LinkAndIconProps[],
    usefulLinks: LinkProps[],
};

export const footerData: FooterData = {
  channels: [
    {
      label: 'Forums',
      href: 'https://community.metabrainz.org',
      isNoOpener: false,
      linkText: 'community.metabrainz.org',
    },
    {
      label: 'Development IRC',
      href: 'https://kiwiirc.com/nextclient/irc.libera.chat/?#metabrainz',
      isNoOpener: true,
      linkText: '#metabrainz',
    },
    {
      label: 'Discussion IRC',
      href: 'https://kiwiirc.com/nextclient/irc.libera.chat/?#musicbrainz',
      isNoOpener: true,
      linkText: '#musicbrainz',
    },
  ],
  fellowProjects: [
    {
      img: {
        alt: 'ListenBrainz',
        src: listenbrainzLogo,
      },
      link: {
        href: 'https://listenbrainz.org/',
        text: 'ListenBrainz',
      },
    },
    {
      img: {
        alt: 'CritiqueBrainz',
        src: critiquebrainzLogo,
      },
      link: {
        href: 'https://critiquebrainz.org/',
        text: 'CritiqueBrainz',
      },
    },
    {
      img: {
        alt: 'Picard',
        src: picardLogo,
      },
      link: {
        href: 'https://picard.musicbrainz.org/',
        text: 'Picard',
      },
    },
    {
      img: {
        alt: 'BookBrainz',
        src: bookbrainzLogo,
      },
      link: {
        href: 'https://bookbrainz.org/',
        text: 'BookBrainz',
      },
    },
    {
      img: {
        alt: 'CoverArtArchive',
        src: caaLogo,
      },
      link: {
        href: 'https://coverartarchive.org',
        text: 'Cover Art Archive',
      },
    },
    {
      img: {
        alt: 'MetaBrainz',
        src: metabrainzLogo,
      },
      link: {
        href: 'https://metabrainz.org/',
        text: 'MetaBrainz',
      },
    },
  ],
  joinUsLinks: [
    {
      href: '/doc/Beginners_Guide',
      text: `Beginner's Guide`,
    },
    {
      href: '/doc/Style',
      text: 'Style Guidelines',
    },
    {
      href: '/doc/How_To',
      text: 'How Tos',
    },
    {
      href: '/doc/Frequently_Asked_Questions',
      text: 'FAQs',
    },
    {
      href: '/doc/MusicBrainz_Documentation',
      text: 'Doc Index',
    },
    {
      href: '/doc/Development',
      text: 'Development',
    },
  ],
  socialNetworks: [
    {
      link: {
        href: 'https://twitter.com/MusicBrainz',
        text: 'Follow us on Twitter',
      },
      icon: faTwitter,
    },
    {
      link: {
        href: 'https://facebook.com/MusicBrainz-12390437194',
        text: 'Follow us on Facebook',
      },
      icon: faFacebook,
    },
    {
      link: {
        href: 'https://instagram.com/metabrainz',
        text: 'Follow us on Instagram',
      },
      icon: faInstagram,
    },
    {
      link: {
        href: 'https://linkedin.com/company/metabrainz',
        text: 'Follow us on LinkedIn',
      },
      icon: faLinkedin,
    },
  ],
  usefulLinks: [
    {
      href: 'https://metabrainz.org/donate',
      text: `Donate`,
    },
    {
      href: 'https://wiki.musicbrainz.org/Main_Page',
      text: 'Wiki',
    },
    {
      href: 'https://blog.metabrainz.org/',
      text: 'Blog',
    },
    {
      href: 'https://www.redbubble.com/people/metabrainz/shop',
      text: 'Shop',
    },
    {
      href: 'https://metabrainz.org/contact',
      text: 'Contact us',
    },
  ],
};

export default footerData;
