/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseCatnoList from '../../../../components/ReleaseCatnoList.js';
import ReleaseCountryList from '../../../../components/ReleaseCountryList.js';
import ReleaseDateList from '../../../../components/ReleaseDateList.js';
import ReleaseLabelList from '../../../../components/ReleaseLabelList.js';
import {type SetCoverArtFormT} from '../../../../release_group/types.js';
import ArtistCreditLink from '../../common/components/ArtistCreditLink.js';
import {Artwork} from '../../common/components/Artwork.js';
import EntityLink from '../../common/components/EntityLink.js';
import {commaListText} from '../../common/i18n/commaList.js';
import formatDate from '../../common/utility/formatDate.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FieldErrors from '../../edit/components/FieldErrors.js';
import HiddenField from '../../edit/components/HiddenField.js';

component SetCoverArtForm(
  allReleases: $ReadOnlyArray<ReleaseT>,
  artwork: {[releaseId: number]: ArtworkT},
  form: SetCoverArtFormT,
) {
  const originallySelected = form.field.release.value;
  const [selected, setSelected] = React.useState(originallySelected);

  const selectCover = (event: SyntheticMouseEvent<HTMLAnchorElement>) => {
    const clickedElement = event.target;
    if (clickedElement instanceof HTMLElement) {
      // Ensure links (enclosed in BDI elements) can still be clicked
      if (clickedElement.nodeName === 'BDI') {
        return;
      }
      // Avoid selecting by clicking on the image / opening lightbox
      if (clickedElement.nodeName === 'IMG') {
        return;
      }
    }
    event.preventDefault();
    const isSelectable = event.currentTarget.dataset.selectable === 'true';
    if (!isSelectable) {
      return;
    }
    const gid = event.currentTarget.dataset.gid;
    setSelected(gid);
  };

  return (
    <form className="set-cover-art" id="set-cover-art" method="post">
      <HiddenField field={form.field.release} value={selected} />

      <p>
        {exp.l(
          `Only releases with a front cover on the {caa|Cover Art Archive}
            can be selected.`,
          {caa: '//coverartarchive.org'},
        )}
      </p>
      <div className="row" id="set-cover-art-position-row">
        <FieldErrors field={form.field.release} />
        <div id="set-cover-art-images">
          {allReleases.map((release, index) => {
            const image = artwork[release.id];
            const hasReleaseCatnos =
              release.labels != null && release.labels.some(
                x => nonEmpty(x.catalogNumber),
              );
            const releaseCatnos = hasReleaseCatnos
              ? <ReleaseCatnoList labels={release.labels} />
              : null;
            const hasReleaseCountries =
              release.events != null && release.events.some(x => x.country);
            const releaseCountries = hasReleaseCountries
              ? <ReleaseCountryList events={release.events} />
              : null;
            const hasReleaseDates =
              release.events != null && release.events.some(
                x => nonEmpty(formatDate(x.date)),
              );
            const releaseDates = hasReleaseDates
              ? <ReleaseDateList events={release.events} />
              : null;
            const hasReleaseLabels =
              release.labels != null && release.labels.some(x => x.label);
            const releaseLabels = hasReleaseLabels
              ? <ReleaseLabelList labels={release.labels} />
              : null;
            const releaseStatus = release.status;

            return (
              <div
                className={
                  'editimage' + (release.gid === selected ? ' selected' : '')
                }
                data-gid={release.gid}
                data-selectable={image ? 'true' : 'false'}
                key={index}
                onClick={selectCover}
              >
                <div className="cover-image">
                  {image ? (
                    <Artwork artwork={image} />
                  ) : (
                    <img
                      src="/static/images/no-cover-art.png"
                      title={l('No cover art available.')}
                    />
                  )}
                </div>
                <div className="release-description">
                  <p>
                    <EntityLink entity={release} />
                    <br />
                    {addColonText(l('Artist'))}
                    {' '}
                    <ArtistCreditLink artistCredit={release.artistCredit} />
                  </p>
                  {releaseCountries || releaseDates ? (
                    <p>
                      {releaseDates ? (
                        <>
                          {addColonText(l('Date'))}
                          {' '}
                          {releaseDates}
                          <br />
                        </>
                      ) : null}
                      {releaseCountries ? (
                        <>
                          {addColonText(l('Country'))}
                          {' '}
                          {releaseCountries}
                        </>
                      ) : null}
                    </p>
                  ) : null}
                  <p>
                    {addColonText(l('Format'))}
                    {' '}
                    {release.combined_format_name}
                    <br />
                    {addColonText(l('Tracks'))}
                    {' '}
                    {release.combined_track_count}
                  </p>
                  {releaseStatus ? (
                    <p>
                      {addColonText(lp('Status', 'release'))}
                      {' '}
                      {lp_attributes(releaseStatus.name, 'release_status')}
                    </p>
                  ) : null}
                  {releaseLabels || releaseCatnos ? (
                    <p>
                      {releaseLabels ? (
                        <>
                          {addColonText(l('Label'))}
                          {' '}
                          {releaseLabels}
                          <br />
                        </>
                      ) : null}
                      {releaseCatnos ? (
                        <>
                          {addColonText(l('Catalog#'))}
                          {' '}
                          {releaseCatnos}
                        </>
                      ) : null}
                    </p>
                  ) : null}
                  {nonEmpty(release.barcode) ? (
                    <p>
                      {addColonText(l('Barcode'))}
                      {' '}
                      {release.barcode}
                    </p>
                  ) : null}
                  {image ? (
                    <div>
                      {addColonText(lp('Cover art', 'singular'))}
                      <ul>
                        <li>
                          {addColonText(lp('Types', 'cover art'))}
                          {' '}
                          {image.types.length
                            ? commaListText(image.types.map(
                              type => lp_attributes(type, 'cover_art_type'),
                            ))
                            : lp('-', 'missing data')}
                        </li>
                        {nonEmpty(image.comment) ? (
                          <li>
                            {addColonText(l('Comment'))}
                            {' '}
                            {image.comment}
                          </li>
                        ) : null}
                      </ul>
                      {release.gid === originallySelected ? (
                        <strong>
                          {l('This is the current release group image')}
                        </strong>
                      ) : null}
                    </div>
                  ) : null}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <EnterEditNote field={form.field.edit_note} />
      <EnterEdit form={form} />
    </form>
  );
}

export default (hydrate<React.PropsOf<SetCoverArtForm>>(
  'div.set-cover-art-form',
  SetCoverArtForm,
): React.AbstractComponent<React.PropsOf<SetCoverArtForm>>);
