/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import kebabCase from 'lodash/kebabCase';
import * as React from 'react';

import LinkSearchableLanguage from '../../../components/LinkSearchableLanguage';
import {withCatalystContext} from '../../../context';
import CodeLink from '../../../static/scripts/common/components/CodeLink';
import commaOnlyList from '../../../static/scripts/common/i18n/commaOnlyList';
import CommonsImage from '../../../static/scripts/common/components/CommonsImage';
import {addColon, l} from '../../../static/scripts/common/i18n';
import {lp_attributes} from '../../../static/scripts/common/i18n/attributes';
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

type Props = {|
  +$c: CatalystContextT,
  +work: WorkT,
|};

const WorkSidebar = ({$c, work}: Props) => {
  const gid = encodeURIComponent(work.gid);
  const {attributes, iswcs, languages, typeID} = work;
  const showInfo =
    attributes.length ||
    (iswcs && iswcs.length) ||
    languages.length ||
    typeID;

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
              <SidebarProperty className="lyrics-language" label={addColon(l('Lyrics Languages'))}>
                {commaOnlyList(
                  languages.map((wl, index) => (
                    <LinkSearchableLanguage
                      entityType="work"
                      key={wl.language.id}
                      language={wl.language}
                    />
                  ))
                )}
              </SidebarProperty>
            ) : null}

            {iswcs && iswcs.length ? (
              iswcs.map((iswc, index) => (
                <SidebarProperty className="iswc" key={iswc.iswc} label={l('ISWC:')}>
                  <CodeLink code={iswc} />
                </SidebarProperty>
              ))
            ) : null}

            {attributes.length ? (
              attributes.map((attr, index) => {
                const type =
                  $c.linked_entities.work_attribute_type[attr.typeID];
                return (
                  <SidebarProperty
                    className={'work-attribute work-attribute-' + kebabCase(type.name)}
                    key={attr.id}
                    label={addColon(lp_attributes(type.name, 'work_attribute_type'))}
                  >
                    {attr.value_id
                      ? lp_attributes(attr.value, 'work_attribute_type_allowed_value')
                      : attr.value}
                  </SidebarProperty>
                );
              })
            ) : null}
          </SidebarProperties>
        </>
      ) : null}

      <SidebarRating entity={work} />

      <SidebarTags
        aggregatedTags={$c.stash.top_tags}
        entity={work}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

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

export default withCatalystContext(WorkSidebar);
