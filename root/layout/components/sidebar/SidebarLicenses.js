/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import map from 'lodash/map';
import * as React from 'react';

import {compare} from '../../../static/scripts/common/i18n';
import linkedEntities from '../../../static/scripts/common/linkedEntities';

const LICENSE_CLASSES = {
  ArtLibre: {
    icon: require('../../../static/images/licenses/ArtLibre.png'),
    pattern: /artlibre\.org\/licence\/lal/,
  },
  CC0: {
    icon: require('../../../static/images/licenses/CC0.png'),
    pattern: /creativecommons\.org\/publicdomain\/zero\//,
  },
  CCBY: {
    icon: require('../../../static/images/licenses/CCBY.png'),
    pattern: /creativecommons\.org\/licenses\/by\//,
  },
  CCBYNC: {
    icon: require('../../../static/images/licenses/CCBYNC.png'),
    pattern: /creativecommons\.org\/licenses\/by-nc\//,
  },
  CCBYNCND: {
    icon: require('../../../static/images/licenses/CCBYNCND.png'),
    pattern: /creativecommons\.org\/licenses\/by-nc-nd\//,
  },
  CCBYNCSA: {
    icon: require('../../../static/images/licenses/CCBYNCSA.png'),
    pattern: /creativecommons\.org\/licenses\/by-nc-sa\//,
  },
  CCBYND: {
    icon: require('../../../static/images/licenses/CCBYND.png'),
    pattern: /creativecommons\.org\/licenses\/by-nd\//,
  },
  CCBYSA: {
    icon: require('../../../static/images/licenses/CCBYSA.png'),
    pattern: /creativecommons\.org\/licenses\/by-sa\//,
  },
  CCNCSamplingPlus: {
    icon: require('../../../static/images/licenses/CCNCSamplingPlus.png'),
    pattern: /creativecommons\.org\/licenses\/nc-sampling\+\//,
  },
  CCPD: {
    icon: require('../../../static/images/licenses/CCPD.png'),
    pattern: /creativecommons\.org\/licenses\/publicdomain\//,
  },
  CCSampling: {
    icon: require('../../../static/images/licenses/CCSampling.png'),
    pattern: /creativecommons\.org\/licenses\/sampling\//,
  },
  CCSamplingPlus: {
    icon: require('../../../static/images/licenses/CCSamplingPlus.png'),
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

const cmpLinkPhrase = (a, b) => compare(a[0], b[0]);

type Props = {
  +entity: CoreEntityT,
};

const SidebarLicenses = ({entity}: Props): React.MixedElement | null => {
  const relationships = entity.relationships;

  if (!relationships) {
    return null;
  }

  const licenses = [];
  for (const r of relationships) {
    const target = r.target;
    if (target.entityType === 'url' && target.show_license_in_sidebar) {
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
        {map(licenses, '1')}
      </ul>
    </>
  ) : null;
};

export default SidebarLicenses;
