/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {l} = require('../static/scripts/common/i18n');
const EntityLink = require('../static/scripts/common/components/EntityLink');
const EntityTabs = require('./EntityTabs');
const Frag = require('./Frag');
const SubHeader = require('./SubHeader');

type Props = {|
  +editTab?: React.Node,
  +entity: CoreEntityT,
  +headerClass: string,
  +heading?: string | React.Node,
  +page: string,
  +preHeader?: React.Node,
  +hideEditTab?: boolean,
  +subHeading: string,
|};

const EntityHeader = ({
  editTab,
  entity,
  headerClass,
  heading,
  hideEditTab = false,
  page,
  // $FlowFixMe
  preHeader = null,
  subHeading,
}: Props) => (
  <Frag>
    <div className={headerClass}>
      {preHeader}
      <h1>
        {heading || <EntityLink entity={entity} />}
      </h1>
      <SubHeader subHeading={subHeading} />
    </div>
    <EntityTabs
      editTab={editTab}
      entity={entity}
      page={page}
      hideEditTab={hideEditTab}
    />
  </Frag>
);

module.exports = EntityHeader;
