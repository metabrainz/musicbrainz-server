/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink';
import ExpandedArtistCredit from
  '../../static/scripts/common/components/ExpandedArtistCredit';
import ReleaseEvents
  from '../../static/scripts/common/components/ReleaseEvents';
import formatBarcode from '../../static/scripts/common/utility/formatBarcode';

type AddReleaseEditT = {
  ...EditT,
  +display_data: {
    +artist_credit: ArtistCreditT,
    +barcode: string | null,
    +comment: string,
    +events?: $ReadOnlyArray<ReleaseEventT>,
    +language: LanguageT | null,
    +name: string,
    +packaging: ReleasePackagingT | null,
    +release: ReleaseT,
    +release_group: ReleaseGroupT,
    +script: ScriptT | null,
    +status: ReleaseStatusT | null,
  },
};

type Props = {
  +allowNew?: boolean,
  +edit: AddReleaseEditT,
};

const AddRelease = ({allowNew, edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const language = display.language;
  const packaging = display.packaging;
  const script = display.script;
  const status = display.status;

  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Release'))}</th>
            <td>
              <DescriptiveLink
                allowNew={allowNew}
                entity={display.release}
              />
            </td>
          </tr>
        </tbody>
      </table>

      <table className="details add-release">
        <tbody>
          <tr>
            <th>{addColonText(l('Name'))}</th>
            <td>{display.name}</td>
          </tr>

          <tr>
            <th>{addColonText(l('Artist'))}</th>
            <td>
              <ExpandedArtistCredit
                artistCredit={display.artist_credit}
              />
            </td>
          </tr>

          <tr>
            <th>{addColonText(l('Release group'))}</th>
            <td>
              {allowNew /*:: === true */ && !display.release_group.gid
                ? l('(new release group)')
                : <DescriptiveLink entity={display.release_group} />}
            </td>
          </tr>

          {display.comment ? (
            <tr>
              <th>{addColonText(l('Disambiguation'))}</th>
              <td>{display.comment}</td>
            </tr>
          ) : null}

          {status ? (
            <tr>
              <th>{lp('Status:', 'release status')}</th>
              <td>
                {lp_attributes(status.name, 'release_status')}
              </td>
            </tr>
          ) : null}

          {language ? (
            <tr>
              <th>{addColonText(l('Language'))}</th>
              <td>{l_languages(language.name)}</td>
            </tr>
          ) : null}

          {script ? (
            <tr>
              <th>{addColonText(l('Script'))}</th>
              <td>{l_scripts(script.name)}</td>
            </tr>
          ) : null}

          {packaging ? (
            <tr>
              <th>{addColonText(l('Packaging'))}</th>
              <td>{l(packaging.name)}</td>
            </tr>
          ) : null}

          {display.barcode == null ? null : (
            <tr>
              <th>{addColonText(l('Barcode'))}</th>
              <td>{formatBarcode(display.barcode)}</td>
            </tr>
          )}

          {display.events?.length ? (
            <tr>
              <th>{addColonText(l('Release events'))}</th>
              <td>
                <ReleaseEvents
                  abbreviated={false}
                  events={display.events}
                />
              </td>
            </tr>
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default AddRelease;
