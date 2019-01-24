/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../../../manifest';

type Props = {|
  title?: string,
|};

const InformationIcon = (props: Props) => (
  <img
    src={manifest.pathTo('/images/icons/information.png')}
    {...props}
  />
);

export default InformationIcon;
