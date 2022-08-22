/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SidebarProperty}
  from '../../../../layout/components/sidebar/SidebarProperties.js';

import CodeLink from './CodeLink.js';
import CollapsibleList from './CollapsibleList.js';

const buildIsrcListRow = (isrc: IsrcT) => (
  <li className="isrc" key={isrc.isrc}>
    <CodeLink code={isrc} />
  </li>
);

const buildIsrcSidebarRow = (isrc: IsrcT) => (
  <SidebarProperty
    className="isrc"
    key={isrc.isrc}
    label={addColonText(l('ISRC'))}
  >
    <CodeLink code={isrc} />
  </SidebarProperty>
);

type IsrcListProps = {|
  +isrcs: ?$ReadOnlyArray<IsrcT>,
  +isSidebar?: boolean,
|};

const IsrcList = ({
  isrcs,
  isSidebar = false,
}: IsrcListProps) => (
  <CollapsibleList
    ContainerElement={isSidebar ? 'dl' : 'ul'}
    InnerElement={isSidebar ? 'p' : 'li'}
    ariaLabel={l('ISRCs')}
    buildRow={isSidebar ? buildIsrcSidebarRow : buildIsrcListRow}
    className={isSidebar ? 'properties isrcs' : 'isrcs'}
    rows={isrcs}
    showAllTitle={l('Show all ISRCs')}
    showLessTitle={l('Show less ISRCs')}
    toShowAfter={1}
    toShowBefore={2}
  />
);

export default (hydrate<IsrcListProps>(
  'div.isrc-list-container',
  IsrcList,
): React.AbstractComponent<IsrcListProps, void>);
