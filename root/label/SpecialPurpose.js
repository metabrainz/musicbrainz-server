/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import LabelLayout from './LabelLayout.js';

type Props = {
  +label: LabelT,
};

const SpecialPurpose = ({
  label,
}: Props): React$Element<typeof LabelLayout> => (
  <LabelLayout
    entity={label}
    fullWidth
    page="special_purpose"
    title={l('Cannot edit')}
  >
    <h2>{l('You may not edit special purpose labels')}</h2>
    <p>
      {l(`The label you are trying to edit is a special purpose label,
          and you may not make direct changes to this data.`)}
    </p>
  </LabelLayout>
);

export default SpecialPurpose;
