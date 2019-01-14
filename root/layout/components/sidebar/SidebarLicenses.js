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
  ArtLibre: /artlibre\.org\/licence\/lal/,
  CC0: /creativecommons\.org\/publicdomain\/zero\//,
  CCBY: /creativecommons\.org\/licenses\/by\//,
  CCBYNC: /creativecommons\.org\/licenses\/by-nc\//,
  CCBYNCND: /creativecommons\.org\/licenses\/by-nc-nd\//,
  CCBYNCSA: /creativecommons\.org\/licenses\/by-nc-sa\//,
  CCBYND: /creativecommons\.org\/licenses\/by-nd\//,
  CCBYSA: /creativecommons\.org\/licenses\/by-sa\//,
  CCNCSamplingPlus: /creativecommons\.org\/licenses\/nc-sampling\+\//,
  CCPD: /creativecommons\.org\/licenses\/publicdomain\//,
  CCSampling: /creativecommons\.org\/licenses\/sampling\//,
  CCSamplingPlus: /creativecommons\.org\/licenses\/sampling\+\//,
};

function licenseClass(url: UrlT): string {
  for (const className in LICENSE_CLASSES) {
    if (LICENSE_CLASSES[className].test(url.name)) {
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
        <img src={manifest.pathTo(`/images/licenses/${className}.png`)} />
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
