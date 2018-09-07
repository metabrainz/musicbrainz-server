/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import uniqBy from 'lodash/uniqBy';

import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList';

const ReleaseCatno = (label) => label.catalogNumber ? (
  <span className="catalog-number">
    {label.catalogNumber}
  </span>
) : null;

type ReleaseLabelsProps = {|
  +labels?: $ReadOnlyArray<ReleaseLabelT>,
|};

const ReleaseCatnoList = ({labels}: ReleaseLabelsProps) => (
  labels && labels.length ? (
    // $FlowFixMe
    commaOnlyList(uniqBy(labels, 'catalogNumber').map(ReleaseCatno), {react: true})
  ) : null
);

export default ReleaseCatnoList;
