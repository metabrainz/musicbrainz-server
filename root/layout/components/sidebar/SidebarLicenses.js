/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import compose from 'terable/compose';
import filter from 'terable/filter';
import map from 'terable/map';
import sortBy from 'terable/sortBy';
import toArray from 'terable/toArray';

import {withCatalystContext} from '../../../context';
import * as manifest from '../../../static/manifest';
import {l} from '../../../static/scripts/common/i18n';
import {l_relationships} from '../../../static/scripts/common/i18n/relationships';

const LICENSE_CLASSES = {
  ArtLibre: {
    icon: manifest.pathTo('/images/licenses/ArtLibre.png'),
    pattern: /artlibre\.org\/licence\/lal/,
  },
  CC0: {
    icon: manifest.pathTo('/images/licenses/CC0.png'),
    pattern: /creativecommons\.org\/publicdomain\/zero\//,
  },
  CCBY: {
    icon: manifest.pathTo('/images/licenses/CCBY.png'),
    pattern: /creativecommons\.org\/licenses\/by\//,
  },
  CCBYNC: {
    icon: manifest.pathTo('/images/licenses/CCBYNC.png'),
    pattern: /creativecommons\.org\/licenses\/by-nc\//,
  },
  CCBYNCND: {
    icon: manifest.pathTo('/images/licenses/CCBYNCND.png'),
    pattern: /creativecommons\.org\/licenses\/by-nc-nd\//,
  },
  CCBYNCSA: {
    icon: manifest.pathTo('/images/licenses/CCBYNCSA.png'),
    pattern: /creativecommons\.org\/licenses\/by-nc-sa\//,
  },
  CCBYND: {
    icon: manifest.pathTo('/images/licenses/CCBYND.png'),
    pattern: /creativecommons\.org\/licenses\/by-nd\//,
  },
  CCBYSA: {
    icon: manifest.pathTo('/images/licenses/CCBYSA.png'),
    pattern: /creativecommons\.org\/licenses\/by-sa\//,
  },
  CCNCSamplingPlus: {
    icon: manifest.pathTo('/images/licenses/CCNCSamplingPlus.png'),
    pattern: /creativecommons\.org\/licenses\/nc-sampling\+\//,
  },
  CCPD: {
    icon: manifest.pathTo('/images/licenses/CCPD.png'),
    pattern: /creativecommons\.org\/licenses\/publicdomain\//,
  },
  CCSampling: {
    icon: manifest.pathTo('/images/licenses/CCSampling.png'),
    pattern: /creativecommons\.org\/licenses\/sampling\//,
  },
  CCSamplingPlus: {
    icon: manifest.pathTo('/images/licenses/CCSamplingPlus.png'),
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

const LicenseDisplay = ({url}: {|+url: UrlT|}) => {
  const className = licenseClass(url);
  return (
    <li className={className}>
      <a href={url.href_url}>
        <img alt="" src={LICENSE_CLASSES[className].icon} />
      </a>
    </li>
  );
};

const getLicenses = filter(r => (
  r.target.entityType === 'url' &&
  r.target.show_license_in_sidebar
));

const buildLicenses = map(r => <LicenseDisplay key={r.id} url={r.target} />);

type Props = {|
  +$c: CatalystContextT,
  +entity: CoreEntityT,
|};

const SidebarLicenses = ({$c, entity}: Props) => {
  let licenses = entity.relationships;

  if (!licenses) {
    return null;
  }

  licenses = compose(
    toArray,
    buildLicenses,
    sortBy(r => (
      l_relationships($c.linked_entities.link_type[r.linkTypeID].link_phrase)
    )),
    getLicenses,
  )(licenses);

  return licenses.length ? (
    <>
      <h2 className="licenses">{l('License')}</h2>
      <ul className="licenses">{licenses}</ul>
    </>
  ) : null;
};

export default withCatalystContext(SidebarLicenses);
