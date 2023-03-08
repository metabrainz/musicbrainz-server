/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {SidebarProperty}
  from '../../../../layout/components/sidebar/SidebarProperties.js';

import CodeLink from './CodeLink.js';
import CollapsibleList from './CollapsibleList.js';

const buildIswcListRow = (iswc: IswcT) => (
  <li className="iswc" key={iswc.iswc}>
    <CodeLink code={iswc} />
  </li>
);

const buildIswcSidebarRow = (iswc: IswcT) => (
  <SidebarProperty
    className="iswc"
    key={iswc.iswc}
    label={addColonText(l('ISWC'))}
  >
    <CodeLink code={iswc} />
  </SidebarProperty>
);

type IswcListProps = {|
  +isSidebar?: boolean,
  +iswcs: ?$ReadOnlyArray<IswcT>,
|};

const IswcList = ({
  iswcs,
  isSidebar = false,
}: IswcListProps) => (
  <CollapsibleList
    ContainerElement={isSidebar ? 'dl' : 'ul'}
    InnerElement={isSidebar ? 'div' : 'li'}
    ariaLabel={l('ISWCs')}
    buildRow={isSidebar ? buildIswcSidebarRow : buildIswcListRow}
    className={isSidebar ? 'properties iswcs' : 'iswcs'}
    rows={iswcs}
    showAllTitle={l('Show all ISWCs')}
    showLessTitle={l('Show less ISWCs')}
    toShowAfter={1}
    toShowBefore={2}
  />
);

export default (hydrate<IswcListProps>(
  'div.iswc-list-container',
  IswcList,
): React$AbstractComponent<IswcListProps, void>);
