/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import artLibreIconUrl
  from '../../../static/images/licenses/ArtLibre.png';
import cc0IconUrl
  from '../../../static/images/licenses/CC0.png';
import ccByIconUrl
  from '../../../static/images/licenses/CCBY.png';
import ccByNcIconUrl
  from '../../../static/images/licenses/CCBYNC.png';
import ccByNcNdIconUrl
  from '../../../static/images/licenses/CCBYNCND.png';
import ccByNcSaIconUrl
  from '../../../static/images/licenses/CCBYNCSA.png';
import ccByNdIconUrl
  from '../../../static/images/licenses/CCBYND.png';
import ccBySaIconUrl
  from '../../../static/images/licenses/CCBYSA.png';
import ccNcSamplingPlusIconUrl
  from '../../../static/images/licenses/CCNCSamplingPlus.png';
import ccPdIconUrl
  from '../../../static/images/licenses/CCPD.png';
import ccSamplingIconUrl
  from '../../../static/images/licenses/CCSampling.png';
import ccSamplingPlusIconUrl
  from '../../../static/images/licenses/CCSamplingPlus.png';
import {compare} from '../../../static/scripts/common/i18n.js';
import linkedEntities
  from '../../../static/scripts/common/linkedEntities.mjs';

const LICENSE_CLASSES = {
  ArtLibre: {
    icon: artLibreIconUrl,
    pattern: /artlibre\.org\/licence\/lal/,
  },
  CC0: {
    icon: cc0IconUrl,
    pattern: /creativecommons\.org\/publicdomain\/zero\//,
  },
  CCBY: {
    icon: ccByIconUrl,
    pattern: /creativecommons\.org\/licenses\/by\//,
  },
  CCBYNC: {
    icon: ccByNcIconUrl,
    pattern: /creativecommons\.org\/licenses\/by-nc\//,
  },
  CCBYNCND: {
    icon: ccByNcNdIconUrl,
    pattern: /creativecommons\.org\/licenses\/by-nc-nd\//,
  },
  CCBYNCSA: {
    icon: ccByNcSaIconUrl,
    pattern: /creativecommons\.org\/licenses\/by-nc-sa\//,
  },
  CCBYND: {
    icon: ccByNdIconUrl,
    pattern: /creativecommons\.org\/licenses\/by-nd\//,
  },
  CCBYSA: {
    icon: ccBySaIconUrl,
    pattern: /creativecommons\.org\/licenses\/by-sa\//,
  },
  CCNCSamplingPlus: {
    icon: ccNcSamplingPlusIconUrl,
    pattern: /creativecommons\.org\/licenses\/nc-sampling\+\//,
  },
  CCPD: {
    icon: ccPdIconUrl,
    pattern: /creativecommons\.org\/licenses\/publicdomain\//,
  },
  CCSampling: {
    icon: ccSamplingIconUrl,
    pattern: /creativecommons\.org\/licenses\/sampling\//,
  },
  CCSamplingPlus: {
    icon: ccSamplingPlusIconUrl,
    pattern: /creativecommons\.org\/licenses\/sampling\+\//,
  },
};

function licenseClass(url: UrlT): string {
  for (const className in LICENSE_CLASSES) {
    if (LICENSE_CLASSES[className].pattern.test(url.name)) {
      return className;
    }
  }
  return '';
}

const LicenseDisplay = ({url}: {+url: UrlT}) => {
  const className = licenseClass(url);
  return (
    <li className={className}>
      <a href={url.href_url}>
        <img alt="" src={LICENSE_CLASSES[className].icon} />
      </a>
    </li>
  );
};

const cmpLinkPhrase = (
  a: [string, React.MixedElement],
  b: [string, React.MixedElement],
) => compare(a[0], b[0]);

type Props = {
  +entity: CoreEntityT,
};

const SidebarLicenses = ({entity}: Props): React.MixedElement | null => {
  const relationships = entity.relationships;

  if (!relationships) {
    return null;
  }

  const licenses: Array<[string, React.MixedElement]> = [];
  for (const r of relationships) {
    const target = r.target;
    if (target.entityType === 'url' &&
      target.show_license_in_sidebar /*:: === true */) {
      licenses.push([
        l_relationships(linkedEntities.link_type[r.linkTypeID].link_phrase),
        <LicenseDisplay key={r.id} url={target} />,
      ]);
    }
  }

  licenses.sort(cmpLinkPhrase);

  return licenses.length ? (
    <>
      <h2 className="licenses">{l('License')}</h2>
      <ul className="licenses">
        {licenses.map(x => x[1])}
      </ul>
    </>
  ) : null;
};

export default SidebarLicenses;
