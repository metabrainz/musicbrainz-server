/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ConfirmLayout from '../../components/ConfirmLayout.js';

component DeleteRelationshipAttributeType(
  form: SecureConfirmFormT,
  type: LinkAttrTypeT,
) {
  return (
    <ConfirmLayout
      form={form}
      question={exp.l_admin(
        `Are you sure you wish to remove the
         <strong>{link_attr_type}</strong> relationship attribute?`,
        {link_attr_type: type.name},
      )}
      title="Remove relationship attribute"
    />
  );
}

export default DeleteRelationshipAttributeType;
