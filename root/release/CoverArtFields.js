/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtFields, {
  type CommonProps as Props,
} from '../components/ArtFields.js';

component CoverArtFields(...{
  form,
  typeIdOptions,
}: Props) {
  return (
    <ArtFields
      archiveName="cover"
      chooseMessage={l('Choose one or more cover art types for this image')}
      documentationMessage={exp.l(
        `Select all types that apply. See the {doc|Cover Art Types}
         documentation for their descriptions.`,
        {doc: {href: '/doc/Cover_Art/Types', target: '_blank'}},
      )}
      form={form}
      typeIdOptions={typeIdOptions}
    />
  );
}

export default CoverArtFields;
