/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import entityHref from '../utility/entityHref.js';

type Props = {
  +code: IsrcT | IswcT,
};

const CodeLink = ({code}: Props): React.MixedElement=> {
  let link: React.MixedElement = (
    <a href={entityHref(code)}>
      <bdi>
        {/* $FlowIssue[prop-missing] */}
        <code>{code[code.entityType]}</code>
      </bdi>
    </a>
  );
  if (code.editsPending) {
    link = <span className="mp">{link}</span>;
  }
  return link;
};

export default CodeLink;
