/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage';
import IrombookImage
  from '../../../static/scripts/common/components/IrombookImage';
import {isRelationshipEditor}
  from '../../../static/scripts/common/utility/privileges';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import RemoveLink from './RemoveLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperties} from './SidebarProperties';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {
  +instrument: InstrumentT,
};

const InstrumentSidebar = ({instrument}: Props): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={instrument}
      />

      <IrombookImage entity={instrument} />

      {instrument.typeID == null ? null : (
        <>
          <h2 className="instrument-information">
            {l('Instrument information')}
          </h2>

          <SidebarProperties>
            <SidebarType entity={instrument} typeType="instrument_type" />
          </SidebarProperties>
        </>
      )}

      <SidebarTags entity={instrument} />

      <ExternalLinks empty entity={instrument} />

      <EditLinks entity={instrument} requiresPrivileges>
        {isRelationshipEditor($c.user) ? (
          <>
            <AnnotationLinks entity={instrument} />

            <MergeLink entity={instrument} />

            <RemoveLink entity={instrument} />

            <li className="separator" role="separator" />
          </>
        ) : null}
      </EditLinks>

      <CollectionLinks entity={instrument} />

      <SidebarLicenses entity={instrument} />

      <LastUpdated entity={instrument} />
    </div>
  );
};

export default InstrumentSidebar;
