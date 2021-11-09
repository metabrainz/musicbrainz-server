/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as ReactDOMServer from 'react-dom/server';

import {QUALITY_UNKNOWN} from '../../../constants';
import {CatalystContext} from '../../../context';
import * as manifest from '../../../static/manifest';
import EntityLink from '../../../static/scripts/common/components/EntityLink';
import ReleaseEvents
  from '../../../static/scripts/common/components/ReleaseEvents';
import linkedEntities from '../../../static/scripts/common/linkedEntities';
import entityHref from '../../../static/scripts/common/utility/entityHref';
import formatBarcode
  from '../../../static/scripts/common/utility/formatBarcode';
import formatTrackLength
  from '../../../static/scripts/common/utility/formatTrackLength';
import releaseLabelKey
  from '../../../static/scripts/common/utility/releaseLabelKey';
import {Artwork} from '../../../components/Artwork';
import CritiqueBrainzLinks from '../../../components/CritiqueBrainzLinks';
import LinkSearchableLanguage
  from '../../../components/LinkSearchableLanguage';
import LinkSearchableProperty
  from '../../../components/LinkSearchableProperty';
import coverArtUrl from '../../../utility/coverArtUrl';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import RemoveLink from './RemoveLink';
import SidebarDataQuality from './SidebarDataQuality';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarRating from './SidebarRating';
import SidebarTags from './SidebarTags';

type Props = {
  +release: ReleaseT,
};

const ReleaseSidebar = ({release}: Props): React.Element<'div'> | null => {
  const $c = React.useContext(CatalystContext);

  const releaseGroup = release.releaseGroup;
  if (!releaseGroup) {
    return null;
  }

  const {
    combined_format_name: combinedFormatName,
    events: releaseEvents,
    labels: releaseLabels,
    packagingID: packagingId,
    scriptID: scriptId,
    statusID: statusId,
  } = release;

  const releaseArtwork = $c.stash.release_artwork;
  const releaseCoverUrl = nonEmpty(release.cover_art_url)
    ? coverArtUrl($c, release.cover_art_url)
    : '';
  const releaseCoverHost = releaseCoverUrl
    ? new URL(releaseCoverUrl).host
    : null;
  const releaseLength = release.length;
  const barcode = formatBarcode(release.barcode);
  const typeName = releaseGroup.l_type_name;
  const language = release.languageID == null
    ? null
    : linkedEntities.language[release.languageID];
  const script = scriptId == null
    ? null
    : linkedEntities.script[scriptId];

  return (
    <div id="sidebar">
      <div className="cover-art">
        {release.cover_art_presence === 'present' && releaseArtwork ? (
          <Artwork
            artwork={releaseArtwork}
            fallback={releaseCoverUrl}
            message={ReactDOMServer.renderToStaticMarkup(exp.l(
              'Front cover image failed to load correctly.' +
              '<br/>{all|View all artwork}.',
              {all: entityHref(release, 'cover-art')},
            ))}
          />
        ) : release.cover_art_presence === 'darkened' ? (
          l(`Cover art for this release has been hidden
             by the Internet Archive because of a takedown request.`)
        ) : releaseCoverUrl
          /* flow-include && releaseCoverHost === true */ ? (
            <>
              <img src={releaseCoverUrl} />
              <span className="cover-art-note">
                {/(?:ssl-)?images-amazon\.com/.test(releaseCoverHost) ? (
                  exp.l('Cover art from {cover|Amazon}', {
                    cover: releaseCoverUrl,
                  })
                ) : (
                  exp.l('Cover art from {cover|{host}}', {
                    cover: releaseCoverUrl,
                    host: releaseCoverHost,
                  })
                )}
              </span>
            </>
          ) : (
            <p className="cover-art-note" style={{textAlign: 'left'}}>
              {release.cover_art_presence === 'present' ? (
                <>
                  {l('No front cover image available.')}
                  <br />
                  <a href={entityHref(release, 'cover-art')}>
                    {l('View all artwork')}
                  </a>
                </>
              ) : l('No cover art available.')}
            </p>
          )
        }
      </div>

      <h2 className="release-information">
        {l('Release information')}
      </h2>

      <SidebarProperties>
        {barcode ? (
          <SidebarProperty className="barcode" label={l('Barcode:')}>
            {barcode}
          </SidebarProperty>
        ) : null}

        {nonEmpty(combinedFormatName) ? (
          <SidebarProperty className="format" label={l('Format:')}>
            {combinedFormatName}
          </SidebarProperty>
        ) : null}

        {releaseLength == null ? null : (
          <SidebarProperty className="length" label={l('Length:')}>
            {formatTrackLength(releaseLength)}
          </SidebarProperty>
        )}
      </SidebarProperties>

      <h2 className="additional-details">
        {l('Additional details')}
      </h2>

      <SidebarProperties>
        {nonEmpty(typeName) ? (
          <SidebarProperty className="type" label={l('Type:')}>
            {typeName}
          </SidebarProperty>
        ) : null}

        {packagingId == null ? null : (
          <SidebarProperty className="packaging" label={l('Packaging:')}>
            {lp_attributes(
              linkedEntities.release_packaging[packagingId].name,
              'release_packaging',
            )}
          </SidebarProperty>
        )}

        {statusId == null ? null : (
          <SidebarProperty
            className="status"
            label={lp('Status:', 'release status')}
          >
            {lp_attributes(
              linkedEntities.release_status[statusId].name,
              'release_status',
            )}
          </SidebarProperty>
        )}

        {language ? (
          <SidebarProperty className="language" label={l('Language:')}>
            <LinkSearchableLanguage
              entityType="release"
              language={language}
            />
          </SidebarProperty>
        ) : null}

        {script ? (
          <SidebarProperty className="script" label={l('Script:')}>
            <LinkSearchableProperty
              entityType="release"
              searchField="script"
              searchValue={script.iso_code || ''}
              text={l_scripts(script.name)}
            />
          </SidebarProperty>
        ) : null}

        {release.quality === QUALITY_UNKNOWN ? null : (
          <SidebarDataQuality quality={release.quality} />
        )}
      </SidebarProperties>

      {releaseLabels?.length ? (
        <>
          <h2 className="labels">{l('Labels')}</h2>
          <ul className="links">
            {releaseLabels.map(releaseLabel => (
              <li key={releaseLabelKey(releaseLabel)}>
                {releaseLabel.label ? (
                  <>
                    <EntityLink
                      entity={releaseLabel.label}
                      showDisambiguation={false}
                    />
                    <br />
                  </>
                ) : null}
                {nonEmpty(releaseLabel.catalogNumber) ? (
                  <span className="catalog-number">
                    {releaseLabel.catalogNumber}
                  </span>
                ) : null}
              </li>
            ))}
          </ul>
        </>
      ) : null}

      {releaseEvents?.length ? (
        <>
          <h2 className="release-events">{l('Release events')}</h2>
          <ReleaseEvents abbreviated={false} events={releaseEvents} />
          {manifest.js(
            'common/components/ReleaseEvents',
            {async: 'async'},
          )}
        </>
      ) : null}

      <SidebarRating
        entity={releaseGroup}
        heading={l('Release group rating')}
      />

      {releaseGroup.review_count == null ? null : (
        <>
          <h2 className="reviews">
            {l('Release group reviews')}
          </h2>
          <p>
            <CritiqueBrainzLinks releaseGroup={releaseGroup} />
          </p>
        </>
      )}

      <SidebarTags entity={release} />

      <ExternalLinks empty entity={release} />

      <ExternalLinks
        empty={false}
        entity={releaseGroup}
        heading={l('Release group external links')}
      />

      <EditLinks entity={release}>
        <li>
          <a href={entityHref(release, 'edit-relationships')}>
            {l('Edit relationships')}
          </a>
        </li>

        <li>
          <a href={entityHref(release, 'change-quality')}>
            {l('Change data quality')}
          </a>
        </li>

        <AnnotationLinks entity={release} />

        <MergeLink entity={release} />

        <RemoveLink entity={release} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks entity={release} />

      <SidebarLicenses entity={release} />

      <LastUpdated entity={release} />
    </div>
  );
};

export default ReleaseSidebar;
