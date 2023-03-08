/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';

type Props = {
  +label: LabelT,
  +page: string,
};

const LabelHeader = ({
  label,
  page,
}: Props): React$Element<typeof EntityHeader> => (
  <EntityHeader
    entity={label}
    headerClass="labelheader"
    page={page}
    subHeading={l('Label')}
  />
);

export default LabelHeader;
