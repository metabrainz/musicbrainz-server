/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityHeader from '../components/EntityHeader.js';
import localizeTypeNameForEntity
  from '../static/scripts/common/i18n/localizeTypeNameForEntity.js';

type Props = {
  page: string,
  work: WorkT,
};

const WorkHeader = ({
  work,
  page,
}: Props): React.Element<typeof EntityHeader> => (
  <EntityHeader
    entity={work}
    headerClass="workheader"
    page={page}
    subHeading={localizeTypeNameForEntity(work)}
  />
);

export default WorkHeader;
