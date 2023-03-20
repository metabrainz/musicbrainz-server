/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import InformationIcon
  from '../../static/scripts/edit/components/InformationIcon.js';

const IntentionallyRawIcon =
  (): React$Element<typeof InformationIcon> => (
    <InformationIcon
      className="align-top"
      title={l(`This field is intentionally left as it was originally
                entered (untranslated, unformatted).`)}
    />
  );

export default IntentionallyRawIcon;
