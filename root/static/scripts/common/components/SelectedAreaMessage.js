/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink from './DescriptiveLink.js';

component SelectedAreaMessage(
  area: AreaT,
) {
  return (
    <p>
    {exp.l(
      'You selected {area}.',
      {area: <DescriptiveLink entity={area} target="_blank" />},
    )}
    </p>
  );
}

export default SelectedAreaMessage;
