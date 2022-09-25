/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Tooltip from './Tooltip.js';

type PropsT = {
  +content: React.Node,
};

const HelpIcon = ({
  content,
}: PropsT): React.Element<'div'> => {
  const [hover, setHover] = React.useState(false);
  return (
    <div
      style={{
        position: 'relative',
        display: 'inline-block',
        marginLeft: '10px',
      }}
    >
      <div
        className="img icon help"
        onMouseEnter={() => setHover(true)}
        onMouseLeave={() => setHover(false)}
        style={{verticalAlign: 'text-top'}}
      />
      {hover ? (
        <Tooltip
          content={content}
          hoverCallback={setHover}
        />
      ) : null}
    </div>
  );
};

export default HelpIcon;
