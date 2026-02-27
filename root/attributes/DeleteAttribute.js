/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ConfirmLayout from '../components/ConfirmLayout.js';

import {type AttributeT} from './types.js';

component DeleteAttribute(attribute: AttributeT, form: SecureConfirmFormT) {
  return (
    <ConfirmLayout
      form={form}
      question={exp.l_admin(
        `Are you sure you wish to remove the
         <strong>{name}</strong> attribute?`,
        {name: attribute.name},
      )}
      title="Remove attribute"
    />
  );
}

export default DeleteAttribute;
