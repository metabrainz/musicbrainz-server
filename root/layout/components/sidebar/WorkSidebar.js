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
import LinkSearchableLanguage
  from '../../../components/LinkSearchableLanguage';
import * as manifest from '../../../static/manifest';
import CodeLink from '../../../static/scripts/common/components/CodeLink';
import AttributeList
  from '../../../static/scripts/common/components/AttributeList';
import commaOnlyList from '../../../static/scripts/common/i18n/commaOnlyList';
import CommonsImage from
  '../../../static/scripts/common/components/CommonsImage';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarRating from './SidebarRating';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {
  +work: WorkT,
};

const WorkSidebar = ({work}: Props): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);
  const {attributes, iswcs, languages, typeID} = work;
  const showInfo = Boolean(
    attributes.length ||
    iswcs.length ||
    languages.length ||
    typeID,
  );

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={work}
      />

      {showInfo ? (
        <>
          <h2 className="work-information">
            {l('Work information')}
          </h2>

          <SidebarProperties>
            <SidebarType entity={work} typeType="work_type" />

            {languages.length ? (
              <SidebarProperty
                className="lyrics-language"
                label={addColonText(l('Lyrics Languages'))}
              >
                {commaOnlyList(
                  languages.map((wl) => (
                    <LinkSearchableLanguage
                      entityType="work"
                      key={wl.language.id}
                      language={wl.language}
                    />
                  )),
                )}
              </SidebarProperty>
            ) : null}

            {iswcs.length ? (
              iswcs.map((iswc) => (
                <SidebarProperty
                  className="iswc"
                  key={iswc.iswc}
                  label={l('ISWC:')}
                >
                  <CodeLink code={iswc} />
                </SidebarProperty>
              ))
            ) : null}
          </SidebarProperties>

          {attributes.length ? (
            <>
              <h2 className="work-attributes">{l('Work attributes')}</h2>
              <SidebarProperties>
                <AttributeList attributes={attributes} isSidebar />
                {manifest.js(
                  'common/components/AttributeList',
                  {async: 'async'},
                )}
              </SidebarProperties>
            </>
          ) : null}
        </>
      ) : null}

      <SidebarRating entity={work} />

      <SidebarTags entity={work} />

      <ExternalLinks empty entity={work} />

      <EditLinks entity={work}>
        <AnnotationLinks entity={work} />

        <MergeLink entity={work} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks entity={work} />

      <SidebarLicenses entity={work} />

      <LastUpdated entity={work} />
    </div>
  );
};

export default WorkSidebar;
