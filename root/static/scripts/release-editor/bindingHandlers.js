// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';
import React from 'react';
import ReactDOM from 'react-dom';

import {reduceArtistCredit} from '../common/immutable-entities';
import ArtistCreditEditor from '../edit/components/ArtistCreditEditor';

import fields from './fields';

ko.bindingHandlers.disableBecauseDiscIDs = {

    update: function (element, valueAccessor, allBindings, viewModel) {
        var disabled = ko.unwrap(valueAccessor()) && viewModel.medium.hasToc();

        $(element)
            .prop("disabled", disabled)
            .toggleClass("disabled-hint", disabled)
            .attr("title", disabled ? l("This medium has one or more discids which prevent this information from being changed.") : "");
    },
};

const TrackButtons = ({nextTrack, previousTrack}) => (
    <>
        <button type="button" style={{float: 'right'}} onClick={nextTrack}>
            {l('Next')}
        </button>
        <button type="button" style={{float: 'right'}} onClick={previousTrack}>
            {l('Previous')}
        </button>
    </>
);

ko.bindingHandlers.artistCreditEditor = {
    currentTarget: function () {
        return $('#artist-credit-bubble').data('target');
    },

    uncheckChangeMatchingArtists: function () {
        const input = document.getElementById('change-matching-artists');
        if (input) {
            input.checked = false;
        }
    },

    previousTrack: function () {
        const entity = this.currentTarget();
        const prev = entity.medium.tracks()[entity.position() - 2];
        if (prev) {
            entity.artistCreditEditorInst.runDoneCallback();
            // Defer until the setState calls in doneCallback finish,
            // since initialArtistText (which is set in updateBubble)
            // depends on the artist credit state.
            _.defer(() => {
                prev.artistCreditEditorInst.updateBubble(true, this.uncheckChangeMatchingArtists);
            });
        }
    },

    nextTrack: function () {
        const entity = this.currentTarget();
        const next = entity.medium.tracks()[entity.position()];
        if (next) {
            entity.artistCreditEditorInst.runDoneCallback();
            _.defer(() => {
                next.artistCreditEditorInst.updateBubble(true, this.uncheckChangeMatchingArtists);
            });
        }
    },

    doneCallback: function (initialArtistText) {
        const input = document.getElementById('change-matching-artists');
        if (!input || !input.checked) {
            return;
        }

        const track = this.currentTarget();
        const artistCredit = track.artistCredit.peek();

        _(track.medium.release.mediums())
            .invokeMap("tracks").flatten().without(track)
            .each(function (t) {
                if (initialArtistText === reduceArtistCredit(t.artistCredit.peek())) {
                    t.artistCredit(artistCredit);
                    t.artistCreditEditorInst.setState({artistCredit});
                }
            });
    },

    update: function (element, valueAccessor) {
        const bindingHandler = ko.bindingHandlers.artistCreditEditor;
        const entity = valueAccessor();
        // Subscribe to the artistCredit observable so that we
        // re-render the ArtistCreditEditor when it changes.
        entity.artistCredit();
        const props = {
            entity: entity,
            hiddenInputs: false,
            onChange: entity.artistCredit,
        };
        if (entity instanceof fields.Track) {
            props.doneCallback = this.doneCallback;
            props.extraButtons = (
                <TrackButtons
                    nextTrack={this.nextTrack}
                    previousTrack={this.previousTrack}
                />
            );
            props.orientation = 'left';
        }
        entity.artistCreditEditorInst =
            ReactDOM.render(<ArtistCreditEditor {...props} />, element);
    },
};

_.bindAll(
    ko.bindingHandlers.artistCreditEditor,
    'doneCallback',
    'nextTrack',
    'previousTrack',
    'uncheckChangeMatchingArtists',
    'update',
);
