/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../static/scripts/common/components/EntityLink.js';
import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList.js';
import {uniqBy} from '../static/scripts/common/utility/arrays.js';

const displayLabel = (label: LabelT) => (
  <EntityLink entity={label} />
);

type ReleaseLabelsProps = {
  +labels: ?$ReadOnlyArray<ReleaseLabelT>,
};

const getLabelGid = (x: LabelT) => x.gid;

const ReleaseLabelList = ({
  labels: releaseLabels,
}: ReleaseLabelsProps): Expand2ReactOutput | null => {
  if (!releaseLabels || !releaseLabels.length) {
    return null;
  }
  const labels = [];
  for (const releaseLabel of releaseLabels) {
    const label = releaseLabel.label;
    if (label) {
      labels.push(label);
    }
  }
  return commaOnlyList(uniqBy(labels, getLabelGid).map(displayLabel));
};

export default ReleaseLabelList;
