// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const ko = require('knockout');
const _ = require('lodash');
const React = require('react');
const ReactDOM = require('react-dom');

const Frag = require('../../../components/Frag');
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

const ChangeMatchingArtists = ({artistText, checked, onChange}) => (
    <div>
        <label>
            <input
                checked={checked}
                id="change-matching-artists"
                onChange={onChange}
                type="checkbox"
            />
            {l('Change all artists on this release that match “{name}”', {name: artistText})}
        </label>
    </div>
);

const TrackButtons = ({nextTrack, previousTrack}) => (
    <Frag>
        <button type="button" style={{float: 'right'}} onClick={nextTrack}>
            {l('Next')}
        </button>
        <button type="button" style={{float: 'right'}} onClick={previousTrack}>
            {l('Previous')}
        </button>
    </Frag>
);

ko.bindingHandlers.artistCreditEditor = {
    changeMatchingArtists: ko.observable(false),
    initialArtistText: ko.observable(''),

    onChangeMatchingArtists: function (event) {
        this.changeMatchingArtists(event.target.checked);
    },

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

    beforeShow: function (props, state) {
        this.initialArtistText(reduceArtistCredit(state.artistCredit));
    },

    doneCallback: function () {
        if (!this.changeMatchingArtists.peek()) {
            return;
        }

        const track = this.currentTarget();
        const matchWith = this.initialArtistText.peek();
        const artistCredit = track.artistCredit.peek();

        _(track.medium.release.mediums())
            .invokeMap("tracks").flatten().without(track).map("artistCredit")
            .each(function (ac) {
                if (matchWith === reduceArtistCredit(ac.peek())) {
                    ac(artistCredit);
                }
            });

        this.initialArtistText('');
    },

    update: function (element, valueAccessor) {
        const bindingHandler = ko.bindingHandlers.artistCreditEditor;
        const entity = valueAccessor();
        const props = {
            entity: entity,
            hiddenInputs: false,
            onChange: entity.artistCredit,
        };
        if (entity instanceof fields.Track) {
            props.beforeShow = this.beforeShow;
            props.doneCallback = this.doneCallback;
            props.extraButtons = (
                <TrackButtons
                    nextTrack={this.nextTrack}
                    previousTrack={this.previousTrack}
                />
            );
            props.extraContent = (
                <ChangeMatchingArtists
                    artistText={this.initialArtistText()}
                    checked={this.changeMatchingArtists()}
                    onChange={this.onChangeMatchingArtists}
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
    'beforeShow',
    'doneCallback',
    'nextTrack',
    'onChangeMatchingArtists',
    'previousTrack',
    'update',
);
