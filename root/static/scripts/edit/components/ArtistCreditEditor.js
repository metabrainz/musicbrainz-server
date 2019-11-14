// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';
import React from 'react';
import ReactDOM from 'react-dom';
import mutate from 'mutate-cow';

import Autocomplete from '../../common/components/Autocomplete';
import {
  artistCreditsAreEqual,
  hasArtist,
  hasVariousArtists,
  isCompleteArtistCredit,
  isComplexArtistCredit,
  reduceArtistCredit,
} from '../../common/immutable-entities';
import MB from '../../common/MB';
import nonEmpty from '../../common/utility/nonEmpty';
import {localStorage} from '../../common/utility/storage';

import ArtistCreditBubble from './ArtistCreditBubble';

function setAutoJoinPhrases(ac) {
  const names = ac.names;
  const size = names.length;
  const auto = /^(| & |, )$/;

  if (size > 0) {
    const name0 = names[size - 1];
    if (name0 && name0.automaticJoinPhrase !== false) {
      names[size - 1] = {...name0, joinPhrase: ''};
    }
  }

  if (size > 1) {
    const name1 = names[size - 2];
    if (name1 && name1.automaticJoinPhrase !== false &&
        auto.test(name1.joinPhrase)) {
      names[size - 2] = {...name1, joinPhrase: ' & '};
    }
  }

  if (size > 2) {
    const name2 = names[size - 3];
    if (name2 && name2.automaticJoinPhrase !== false &&
        auto.test(name2.joinPhrase)) {
      names[size - 3] = {...name2, joinPhrase: ', '};
    }
  }

  return ac;
}

const makeHiddenInput = (data) => (
  <input
    key={data.name}
    name={data.name}
    type="hidden"
    value={nonEmpty(data.value) ? data.value : ''}
  />
);

class ArtistCreditEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      artistCredit: ko.unwrap(this.props.entity.artistCredit),
    };

    this.initialArtistText = '';
    this.addName = this.addName.bind(this);
    this.copyArtistCredit = this.copyArtistCredit.bind(this);
    this.done = this.done.bind(this);
    this.hide = this.hide.bind(this);
    this.onNameChange = this.onNameChange.bind(this);
    this.pasteArtistCredit = this.pasteArtistCredit.bind(this);
    this.removeName = this.removeName.bind(this);
    this.toggleBubble = this.toggleBubble.bind(this);
  }

  addName() {
    const ac = setAutoJoinPhrases({
      names: this.state.artistCredit.names.concat({
        artist: null,
        joinPhrase: '',
        name: '',
      }),
    });
    this.setState({artistCredit: ac}, () => this.positionBubble());
  }

  removeName(i, event) {
    // Prevent track artist bubbles from closing.
    event.stopPropagation();

    const ac = this.state.artistCredit;
    const newState = mutate(this.state, newState => {
      newState.artistCredit.names.splice(i, 1);
    });
    setAutoJoinPhrases(newState.artistCredit);

    this.setState(newState, () => {
      this.positionBubble();
      if (i > 0 && i === ac.names.length - 1) {
        $('#artist-credit-bubble').find('.remove-item').eq(i - 1).focus();
      }
    });
  }

  onNameChange(i, update) {
    this.setState(state => mutate(state, newState => {
      newState.artistCredit.names[i] =
        {...state.artistCredit.names[i], ...update};
    }));
  }

  copyArtistCredit() {
    let names = this.state.artistCredit.names;

    if (!names.length) {
      names = [{artist: null, joinPhrase: '', name: ''}];
    }

    localStorage('copiedArtistCredit', JSON.stringify(names));
  }

  pasteArtistCredit() {
    const names = JSON.parse(localStorage('copiedArtistCredit') || '[{}]');
    this.setState({artistCredit: {names}});
  }

  toggleBubble() {
    const $bubble = $('#artist-credit-bubble');
    if ($bubble.is(':visible')) {
      const inst = $bubble.data('componentInst');

      if (inst.props.doneCallback) {
        inst.props.doneCallback();
      }

      if ($bubble.data('target') === this.props.entity) {
        this.hide();
        return;
      }
    }
    this.updateBubble(true);
  }

  positionBubble() {
    const $bubble = $('#artist-credit-bubble');
    if (!$bubble.length) {
      return;
    }

    const $button = $(this._editButton);
    let position = {of: $button[0], collision: 'fit none', within: $('body')};
    let maxWidth;
    let tailClass;

    if (this.props.orientation === 'left') {
      position.my = 'right center';
      position.at = 'left-15 center';
      maxWidth = $button.position().left - 64;
      tailClass = 'right-tail';
    } else {
      position.my = 'left center';
      position.at = 'right+15 center';
      maxWidth = $('body').innerWidth() - ($button.position().left +
        $button.outerWidth() + 64);
      tailClass = 'left-tail';
    }

    $bubble
      .css('max-width', maxWidth)
      .find('.bubble')
        .removeClass('left-tail right-tail')
        .addClass(tailClass)
        .end()
      .show()
      .position(position)
      // For some reason this needs to be called twice...
      // Steps to reproduce: open the release AC bubble, switch to the
      // tracklist tab, open a track AC bubble.
      .position(position);
  }

  updateBubble(show = false, callback = null) {
    this.createBubble();

    const $bubble = $('#artist-credit-bubble');
    const bubbleWasVisible = $bubble.is(':visible');

    /*
     * `show` implies the bubble should be made visible with a new entity.
     * If show = false and the bubble isn't visible,
     * there's no point in updating it.
     */
    if (!show && !bubbleWasVisible) {
      return;
    }

    // Don't hijack the bubble unless show = true or this is for the
    // currently-open entity.
    if (!show && $bubble.data('target') !== this.props.entity) {
      return;
    }

    if (show) {
      this.initialArtistText = reduceArtistCredit(this.state.artistCredit);
    }

    $bubble
      .data('target', this.props.entity)
      .data('componentInst', this);

    ReactDOM.render(
      <ArtistCreditBubble
        addName={this.addName}
        artistCredit={this.state.artistCredit}
        copyArtistCredit={this.copyArtistCredit}
        done={this.done}
        hide={this.hide}
        initialArtistText={this.initialArtistText}
        onNameChange={this.onNameChange}
        pasteArtistCredit={this.pasteArtistCredit}
        removeName={this.removeName}
        {...this.props}
      />,
      $bubble[0],
      show ? (() => {
        this.positionBubble();

        if (!bubbleWasVisible) {
          $bubble.find(':input:eq(0)').focus();
          $('#change-matching-artists').prop('checked', false);
        }

        if (callback) {
          callback();
        }
      }) : null,
    );
  }

  hide(stealFocus = true) {
    const $bubble = $('#artist-credit-bubble').hide();
    if (stealFocus) {
      this._editButton.focus();
    }
    // Defer until after the doneCallback() executes (if done() called us).
    _.defer(function () {
      $bubble.data('target', null).data('componentInst', null);
    });
  }

  runDoneCallback() {
    if (this.props.doneCallback) {
      this.props.doneCallback(this.initialArtistText);
      this.initialArtistText = '';
    }
  }

  done(stealFocus = true, nextTrack = false) {
    this.runDoneCallback();

    // XXX The release editor still uses knockout.
    if (nextTrack) {
      const entity = this.props.entity;
      if (entity.entityType === 'track') {
        const next = entity.medium.tracks()[entity.position()];
        if (next) {
          ko.bindingHandlers.artistCreditEditor.nextTrack();
          return;
        }
      }
    }

    this.hide(stealFocus);
  }

  createBubble() {
    if (!document.getElementById('artist-credit-bubble')) {
      const $bubble = $('<div id="artist-credit-bubble"></div>')
        .hide()
        .appendTo('body');

      $('body').on('click.artist-credit-editor', event => {
        const $target = $(event.target);
        if (!event.isDefaultPrevented() &&
            $bubble.is(':visible') &&
            $target.is(':not(.open-ac)') &&
            !$bubble.has($target).length &&
            // Close unless focus was moved to a dialog above this one, e.g.
            // when adding a new entity.
            !$target.parents('.ui-dialog').length) {
          $bubble.data('componentInst').done(false);
        }
      });
    }
  }

  componentWillUnmount() {
    $('body').off('click.artist-credit-editor');
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.props.onChange &&
        !artistCreditsAreEqual(
          prevState.artistCredit, this.state.artistCredit,
        )) {
      this.props.onChange(this.state.artistCredit);
    }

    this.updateBubble();

    $('div.various-artists.warning')
      .toggle(hasVariousArtists(this.state.artistCredit));
  }

  getHiddenInputs() {
    let prefix = 'artist_credit.names.';

    if (this.props.form) {
      prefix = this.props.form.name + '.' + prefix;
    }

    return _.flatten(_.map(this.state.artistCredit.names, function (name, i) {
      const curPrefix = prefix + i + '.';

      return [
        {name: curPrefix + 'name', value: name.name},
        {name: curPrefix + 'join_phrase', value: name.joinPhrase},
        {
          name: curPrefix + 'artist.name',
          value: name.artist ? name.artist.name : '',
        },
        {
          name: curPrefix + 'artist.id',
          value: name.artist ? name.artist.id : '',
        },
      ];
    }));
  }

  render() {
    const ac = this.state.artistCredit;
    let entity = _.clone(this.props.entity);
    entity.artistCredit = {names: _.filter(ac.names, n => hasArtist(n))};

    // The single-artist lookup changes the credit boxes in the doc bubble,
    // and the credit boxes change the single-artist lookup.
    const complex = isComplexArtistCredit(ac);
    let singleArtistSelection = {name: ''};
    let singleArtistIsEditable = true;

    if (complex || ac.names.length > 1) {
      singleArtistSelection.name = reduceArtistCredit(ac);
      singleArtistIsEditable = false;
    } else {
      const firstName = ac.names[0];
      if (firstName) {
        if (hasArtist(firstName)) {
          singleArtistSelection = firstName.artist;
        } else {
          singleArtistSelection.name = firstName.name;
        }
      }
    }

    return (
      <>
        <table
          className="artist-credit-editor"
          key="artist-credit-editor"
          ref={node => {
            if (node) {
              $(node).data('componentInst', this);
            }
          }}
        >
          <tbody>
            <tr>
              <td>
                <Autocomplete
                  currentSelection={singleArtistSelection}
                  disabled={!singleArtistIsEditable}
                  entity="artist"
                  inputID={this.props.forLabel}
                  isLookupPerformed={isCompleteArtistCredit(ac)}
                  onChange={artist => {
                    if (singleArtistIsEditable) {
                      this.setState({
                        artistCredit: {
                          names: [{
                            artist,
                            name: artist.name,
                            joinPhrase: '',
                          }],
                        },
                      });
                    }
                  }}
                  showStatus={false}
                />
              </td>
              <td className="open-ac-cell">
                <button
                  className="open-ac"
                  onClick={this.toggleBubble}
                  ref={button => this._editButton = button}
                  type="button"
                >
                  {l('Edit')}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        {this.props.hiddenInputs
          ? this.getHiddenInputs().map(makeHiddenInput)
          : null}
      </>
    );
  }
}

export default ArtistCreditEditor;
