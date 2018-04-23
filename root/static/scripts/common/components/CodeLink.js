/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const entityHref = require('../utility/entityHref');

type Props = {|
  +code: IsrcT | IswcT,
|};

const CodeLink = ({code}: Props) => {
  let link = (
    <a href={entityHref(code)}>
      <bdi>
        {/* $FlowFixMe */}
        <code>{code[code.entityType]}</code>
      </bdi>
    </a>
  );
  if (code.editsPending) {
    link = <span className="mp">{link}</span>;
  }
  return link;
};

module.exports = CodeLink;
