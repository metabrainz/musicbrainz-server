/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';

component EditEnteredFrom(
  edit: {
    +display_data?: {
      +entered_from?: NonUrlRelatableEntityT,
      ...
    },
    ...
  },
) {
  const enteredFrom = edit.display_data?.entered_from;
  return enteredFrom ? (
      <div className="entered-from">
        {addColonText(l('Entered from'))}
        {' '}
        <DescriptiveLink entity={enteredFrom} />
      </div>
  ) : null;
}

export default EditEnteredFrom;
