// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const ko = require('knockout');
const _ = require('lodash');
const React = require('react');
const ReactDOM = require('react-dom');

const {l} = require('../common/i18n');
const {reduceArtistCredit} = require('../common/immutable-entities');
const ArtistCreditEditor = require('../edit/components/ArtistCreditEditor');
const fields = require('./fields');

ko.bindingHandlers.disableBecauseDiscIDs = {

    update: function (element, valueAccessor, allBindings, viewModel) {
        var disabled = ko.unwrap(valueAccessor()) && viewModel.medium.hasToc();

        $(element)
            .prop("disabled", disabled)
            .toggleClass("disabled-hint", disabled)
            .attr("title", disabled ? l("This medium has one or more discids which prevent this information from being changed.") : "");
    }
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

    previousTrack: function () {
        const entity = this.currentTarget();
        const prev = entity.medium.tracks()[entity.position() - 2];
        if (prev) {
            prev.artistCreditEditorInst.updateBubble(true);
        }
    },

    nextTrack: function () {
        const entity = this.currentTarget();
        const next = entity.medium.tracks()[entity.position()];
        if (next) {
            next.artistCreditEditorInst.updateBubble(true);
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
            .invokeMap("tracks").flatten().without(track).map("artistCredit")
            .each(function (ac) {
                if (initialArtistText === reduceArtistCredit(ac.peek())) {
                    ac(artistCredit);
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
    }
};

_.bindAll(
    ko.bindingHandlers.artistCreditEditor,
    'doneCallback',
    'nextTrack',
    'previousTrack',
    'update',
);
