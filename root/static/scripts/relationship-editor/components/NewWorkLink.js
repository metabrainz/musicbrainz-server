/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {DeletedLink} from '../../common/components/EntityLink.js';

type PropsT = {
  +work: WorkT,
};

const NewWorkLink = ({
  work,
}: PropsT): React$Element<'a'> => (
  <a href={'#new-work-' + String(work.id)}>
    <DeletedLink
      allowNew
      className="rel-add"
      name={work.name}
    />
  </a>
);

export default NewWorkLink;
