/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import {l_admin} from '../static/scripts/common/i18n/admin.js';

export function modelToTitle(model: string): string {
  switch (model) {
    case 'AreaType':
      return l('Area types');
    case 'ArtistType':
      return l('Artist types');
    case 'CollectionType':
      return l('Collection types');
    case 'CoverArtType':
      return l('Cover art types');
    case 'EventType':
      return l('Event types');
    case 'Gender':
      return l('Genders');
    case 'InstrumentType':
      return l('Instrument types');
    case 'LabelType':
      return l('Label types');
    case 'Language':
      return l('Languages');
    case 'MediumFormat':
      return l('Medium formats');
    case 'PlaceType':
      return l('Place types');
    case 'ReleaseGroupSecondaryType':
      return l('Release group secondary types');
    case 'ReleaseGroupType':
      return l('Release group primary types');
    case 'ReleasePackaging':
      return l('Release packagings');
    case 'ReleaseStatus':
      return l('Release statuses');
    case 'Script':
      return l('Scripts');
    case 'SeriesType':
      return l('Series types');
    case 'WorkAttributeType':
      return l('Work attribute types');
    case 'WorkType':
      return l('Work types');
    default:
      return model;
  }
}

component AttributeLayout(
  children: React.Node,
  model: string,
  showEditSections: boolean,
 ) {
  return (
    <Layout fullWidth title={modelToTitle(model)}>
      <h1>
        <a href="/attributes">{l('Attributes')}</a>
        {' / ' + modelToTitle(model)}
      </h1>

      {children}

      {showEditSections ? (
        <p>
          <span className="buttons">
            <a href={`/attributes/${model}/create`}>
              {l_admin('Add new attribute')}
            </a>
          </span>
        </p>
      ) : null}
    </Layout>
  );
}

export default AttributeLayout;
