/*
 * @flow strict-local
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Artwork} from '../components/Artwork.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import EventLayout from './EventLayout.js';

type Props = {
  +artwork: EventArtT,
  +event: EventT,
  +form: ConfirmFormT,
};

const RemoveEventArt = ({
  artwork,
  event,
  form,
}: Props): React$Element<typeof EventLayout> => {
  const title = lp('Remove event art', 'singular, header');

  return (
    <EventLayout entity={event} fullWidth title={title}>
      <h2>{title}</h2>
      <p>
        {exp.l(
          `Are you sure you wish to remove the art below from {event}?`,
          {
            event: <EntityLink entity={event} />,
          },
        )}
      </p>
      <p className="artwork">
        <Artwork artwork={artwork} />
      </p>
      <form method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </EventLayout>
  );
};

export default RemoveEventArt;
