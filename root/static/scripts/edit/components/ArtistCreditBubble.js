// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import {assign} from 'lodash';
import React from 'react';

import ArtistCreditLink from '../../common/components/ArtistCreditLink';
import DescriptiveLink from '../../common/components/DescriptiveLink';
import {l} from '../../common/i18n';
import {reduceArtistCredit} from '../../common/immutable-entities';
import clean from '../../common/utility/clean';

import ArtistCreditNameEditor from './ArtistCreditNameEditor';


function onBubbleKeyDown(done, hide, event) {
  if (event.isDefaultPrevented()) {
    return;
  }
  const pressedEsc = event.which === 27;
  const pressedEnter = event.which === 13;

  if (pressedEsc || (pressedEnter && $(event.target).is(':not(:button)'))) {
    event.preventDefault();
    if (pressedEsc) {
      hide();
    } else if (pressedEnter) {
      done(true /* stealFocus */, true /* nextTrack */);
    }
  }
}

const ArtistCreditBubble = ({
  addName,
  artistCredit,
  copyArtistCredit,
  done,
  entity,
  extraButtons,
  hide,
  initialArtistText,
  onNameChange,
  pasteArtistCredit,
  removeName,
}) => (
  <div className="bubble"
       onKeyDown={event => onBubbleKeyDown(done, hide, event)}
       style={{display: 'block', position: 'relative'}}>
    <table className="table-condensed">
      <thead>
        <tr>
          <td colSpan="3" style={{paddingBottom: '1em'}}>
            {l('Use the following fields to enter collaborations. See the {ac|Artist Credit} documentation for more information.',
             {ac: '/doc/Artist_Credits'})}
          </td>
        </tr>
        {clean(reduceArtistCredit(artistCredit)) ? (
          <tr>
            <td colSpan="4" style={{paddingBottom: '1em'}}>
              {l('Preview:') + ' '}
              {entity.entityType === 'track'
                ? <DescriptiveLink
                    entity={assign(Object.create(entity), {artistCredit: artistCredit})}
                    showDeletedArtists={false}
                  />
                : <ArtistCreditLink
                    artistCredit={artistCredit}
                    showDeleted={false}
                  />}
            </td>
          </tr>
        ) : null}
        <tr className="artist-credit-header">
          <th style={{width: '40%'}}>{l('Artist in MusicBrainz:')}</th>
          <th style={{width: '40%'}}>{l('Artist as credited:')}</th>
          <th>{l('Join phrase:')}</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {artistCredit.map((name, index) => (
          <ArtistCreditNameEditor
            entity={entity}
            index={index}
            key={index}
            name={name}
            onChange={update => onNameChange(index, update)}
            onRemove={artistCredit.length > 1 ? (event => removeName(index, event)) : null}
          />
        ))}
        <tr>
          <td colSpan="4" style={{textAlign: 'right'}}>
            <button type="button" className="add-item with-label" onClick={addName}>
              {l('Add Artist Credit')}
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    {(initialArtistText && entity.entityType === 'track') ? (
      <div>
        <label>
          <input id="change-matching-artists" type="checkbox" />
          {l('Change all artists on this release that match “{name}”', {
            name: initialArtistText,
          })}
        </label>
      </div>
    ) : null}
    <div className="buttons">
      <button type="button" style={{float: 'left'}} onClick={copyArtistCredit}>{l('Copy Credits')}</button>
      <button type="button" style={{float: 'left'}} onClick={pasteArtistCredit}>{l('Paste Credits')}</button>
      <button type="button" style={{float: 'right'}} className="positive" onClick={done}>{l('Done')}</button>
      {extraButtons ? extraButtons : null}
    </div>
  </div>
);

export default ArtistCreditBubble;
