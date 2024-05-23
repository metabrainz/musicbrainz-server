/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtFields, {
  type CommonProps as Props,
} from '../components/ArtFields.js';

const EventArtFields = ({
  form,
  typeIdOptions,
}: Props): React$Element<typeof ArtFields> => {
  return (
    <ArtFields
      archiveName="event"
      chooseMessage={l('Choose one or more event art types for this image')}
      documentationMessage={exp.l(
        `Please see the {doc|Event Art Types} documentation
         for a description of these types.`,
        {doc: {href: '/doc/Event_Art/Types', target: '_blank'}},
      )}
      form={form}
      typeIdOptions={typeIdOptions}
    />
  );
};

export default EventArtFields;
