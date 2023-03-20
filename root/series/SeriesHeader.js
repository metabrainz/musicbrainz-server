/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';
import localizeTypeNameForEntity
  from '../static/scripts/common/i18n/localizeTypeNameForEntity.js';

type Props = {
  page: string,
  series: SeriesT,
};

const SeriesHeader = ({
  series,
  page,
}: Props): React$Element<typeof EntityHeader> => (
  <EntityHeader
    entity={series}
    headerClass="seriesheader"
    page={page}
    subHeading={localizeTypeNameForEntity(series)}
  />
);

export default SeriesHeader;
