/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Tooltip from './Tooltip.js';

type PropsT = {
  +content: React$Node,
};

const ICON_STYLE = {
  display: 'inline-block',
  marginLeft: '10px',
  verticalAlign: 'text-top',
};

const HelpIcon = ({
  content,
}: PropsT): React$MixedElement => (
  <Tooltip
    content={content}
    target={
      <span
        className="img icon help"
        style={ICON_STYLE}
      />
    }
  />
);

export default HelpIcon;
