/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import StatusPage from '../components/StatusPage.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type Props = {
  +cdToc: string,
};

const CDStubAddWhileLoggedIn = ({
  cdToc,
}: Props): React$Element<typeof StatusPage> => (
  <StatusPage title={l('Cannot Add CD Stub')}>
    <p>
      {l(`You cannot add a CD stub while logged in to MusicBrainz.
          Please add a new release instead.`)}
    </p>
    <form action="/release/add" method="post">
      <input name="mediums.0.toc" type="hidden" value={cdToc} />
      <FormSubmit label={l('Add release')} />
    </form>
  </StatusPage>
);

export default CDStubAddWhileLoggedIn;
