/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import ArtistCreditLink from '../../common/components/ArtistCreditLink.js';
import DescriptiveLink from '../../common/components/DescriptiveLink.js';
import {reduceArtistCredit} from '../../common/immutable-entities.js';
import clean from '../../common/utility/clean.js';

import ArtistCreditNameEditor from './ArtistCreditNameEditor.js';


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
  renderCallback,
}) => (
  <div
    className="bubble"
    onKeyDown={event => onBubbleKeyDown(done, hide, event)}
    ref={renderCallback}
    style={{display: 'block', position: 'relative'}}
  >
    <table className="table-condensed">
      <thead>
        <tr>
          <td colSpan="3" style={{paddingBottom: '1em'}}>
            {exp.l(
              `Use the following fields to enter collaborations. See the
               {ac|Artist Credit} documentation for more information.`,
              {ac: '/doc/Artist_Credits'},
            )}
          </td>
        </tr>
        {clean(reduceArtistCredit(artistCredit)) ? (
          <tr>
            <td colSpan="4" style={{paddingBottom: '1em'}}>
              {l('Preview:') + ' '}
              {entity.entityType === 'track'
                ? (
                  <DescriptiveLink
                    allowNew
                    content={entity.name() === ''
                      ? l('[missing track name]')
                      : null}
                    deletedCaption={entity.name() === ''
                      ? l('You haven’t entered a track name yet.')
                      : l('This track hasn’t been created yet.')}
                    entity={Object.assign(
                      Object.create(entity), {artistCredit: artistCredit},
                    )}
                    showDeletedArtists={false}
                    target="_blank"
                  />
                ) : (
                  <ArtistCreditLink
                    artistCredit={artistCredit}
                    showDeleted={false}
                    target="_blank"
                  />
                )}
            </td>
          </tr>
        ) : null}
        <tr className="artist-credit-header">
          <th style={{width: '40%'}}>{l('Artist in MusicBrainz:')}</th>
          <th style={{width: '40%'}}>{l('Artist as credited:')}</th>
          <th>{l('Join phrase:')}</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {artistCredit.names.map((name, index) => (
          <ArtistCreditNameEditor
            entity={entity}
            index={index}
            key={index}
            name={name}
            onChange={update => onNameChange(index, update)}
            onRemove={artistCredit.names.length > 1
              ? (event => removeName(index, event))
              : null}
          />
        ))}
        <tr>
          <td className="align-right" colSpan="4">
            <button
              className="add-item with-label"
              onClick={addName}
              type="button"
            >
              {l('Add Artist Credit')}
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    {entity.entityType === 'track' ? (
      <div>
        <label>
          <input id="change-matching-artists" type="checkbox" />
          {initialArtistText ? (
            texp.l(
              'Change all artists on this release that match “{name}”',
              {name: initialArtistText},
            )
          ) : (
            l('Change all artists on this release that are currently empty')
          )}
        </label>
      </div>
    ) : null}
    <div className="buttons">
      <button
        onClick={copyArtistCredit}
        style={{float: 'left'}}
        type="button"
      >
        {l('Copy Credits')}
      </button>
      <button
        onClick={pasteArtistCredit}
        style={{float: 'left'}}
        type="button"
      >
        {l('Paste Credits')}
      </button>
      <button
        className="positive"
        onClick={done}
        style={{float: 'right'}}
        type="button"
      >
        {l('Done')}
      </button>
      {extraButtons ? extraButtons : null}
    </div>
  </div>
);

export default ArtistCreditBubble;
