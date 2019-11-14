// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';
import React from 'react';
import ReactDOMServer from 'react-dom/server';

import {reduceArtistCredit} from '../common/immutable-entities';
import bracketed from '../common/utility/bracketed';
import formatTrackLength from '../common/utility/formatTrackLength';
import isBlank from '../common/utility/isBlank';
import request from '../common/utility/request';

import fields from './fields';
import trackParser from './trackParser';
import utils from './utils';
import releaseEditor from './viewModel';

class Dialog {
    open() {
        $(this.element).dialog({title: this.title, width: 700});
    }

    close() {
        $(this.element).dialog("close");
    }
}


export const trackParserDialog = releaseEditor.trackParserDialog = new Dialog();

Object.assign(trackParserDialog, {
    element: "#track-parser-dialog",
    title: l("Track Parser"),

    toBeParsed: ko.observable(""),
    result: ko.observable(null),
    error: ko.observable(""),

    open: function (medium) {
        this.setMedium(medium);
        Dialog.prototype.open.apply(this, arguments);
    },

    setMedium: function (medium) {
        this.medium = medium;
        this.toBeParsed(trackParser.mediumToString(medium));
    },

    parse: function () {
        var medium = this.medium;
        var toBeParsed = this.toBeParsed();

        var newTracks = trackParser.parse(toBeParsed, medium);
        var error = !isBlank(toBeParsed) && newTracks.length === 0;

        this.error(error);
        !error && medium.tracks(newTracks);
    },

    addDisc: function () {
        this.parse();
        return this.error() ? null : this.medium;
    },
});


class SearchResult {
    constructor(tab, data) {
        Object.assign(this, data);

        this.tab = tab;
        this.loaded = ko.observable(false);
        this.loading = ko.observable(false);
        this.error = ko.observable("");
    }

    expanded() { return this.tab.result() === this }

    toggle() {
        var expand = this.tab.result() !== this;

        this.tab.result(expand ? this : null);

        if (expand && !this.loaded() && !this.loading()) {
            this.loading(true);
            this.error("");

            request({
                url: this.tab.tracksRequestURL(this),
                data: this.tab.tracksRequestData,
            }, this)
            .done(this.requestDone)
            .fail(function (jqXHR) {
                var response = JSON.parse(jqXHR.responseText);
                this.error(response.error);
            })
            .always(function () { this.loading(false) });
        }

        return false;
    }

    requestDone(data) {
        _.each(data.tracks, (track, index) => this.parseTrack(track, index));
        Object.assign(this, utils.reuseExistingMediumData(data));

        this.loaded(true);
    }

    parseTrack(track, index) {
        track.id = null;
        track.position = track.position || (index + 1);
        track.number = track.position;
        track.formattedLength = formatTrackLength(track.length);

        if (track.artistCredit) {
            track.artist = reduceArtistCredit(track.artistCredit);
        } else {
            // If the track artist matches the release artist, reuse the AC
            const release = releaseEditor.rootField.release();
            const releaseArtistCredit = release.artistCredit();
            const releaseArtistName = reduceArtistCredit(releaseArtistCredit);
            track.artist = track.artist || this.artist || "";
            if (track.artist === releaseArtistName) {
                track.artistCredit = releaseArtistCredit;
            } else {
                track.artistCredit = {names: [{name: track.artist}]};
            }
        }
    }

    link() {
        let formatString;
        if (this.format) {
            formatString = this.format +
                (this.position ? ' ' + this.position : '');
        }

        const link = exp.l('{entity} by {artist}', {
            entity: (
                <>
                    <bdi>{this.name}</bdi>
                    {formatString ? ' ' + bracketed(formatString) : null}
                </>
            ),
            artist: <bdi>{this.artist}</bdi>,
        });

        return ReactDOMServer.renderToStaticMarkup(link);
    }
}


class SearchTab {
    constructor() {
        this.releaseName = ko.observable("");
        this.artistName = ko.observable("");
        this.trackCount = ko.observable("");

        this.searchResults = ko.observable(null);
        this.result = ko.observable(null);
        this.searching = ko.observable(false);
        this.error = ko.observable("");

        this.currentPage = ko.observable(0);
        this.totalPages = ko.observable(0);
    }

    search(data, event, pageJump) {
        this.searching(true);

        var data = {
            q: this.releaseName(),
            artist: this.artistName(),
            tracks: this.trackCount(),
            page: pageJump ? this.currentPage() + pageJump : 1,
        };

        this._jqXHR = request({url: this.endpoint, data: data}, this)
            .done(this.requestDone)
            .fail(function (jqXHR, textStatus) {
                if (textStatus !== "abort") {
                    this.error(jqXHR.responseText);
                }
            })
            .always(function () {
                this.searching(false);
            });
    }

    cancelSearch() {
        if (this._jqXHR) this._jqXHR.abort();
    }

    buttonClicked() {
        this.searching() ? this.cancelSearch() : this.search();
    }

    keydownEvent(data, event) {
        if (event.keyCode === 13) { // Enter
            this.search(data, event);
        }
        else {
            // Knockout calls preventDefault unless you return true. Allows
            // people to actually enter text.
            return true;
        }
    }

    nextPage() {
        if (this.currentPage() < this.totalPages()) {
            this.search(this, null, 1);
        }
        return false;
    }

    previousPage() {
        if (this.currentPage() > 1) {
            this.search(this, null, -1);
        }
        return false;
    }

    requestDone(results) {
        this.error("");

        var pager = results.pop();

        if (pager) {
            this.currentPage(parseInt(pager.current, 10));
            this.totalPages(parseInt(pager.pages, 10));
        }

        this.searchResults(_.map(results, x => new SearchResult(this, x)));
    }

    addDisc() {
        var release = releaseEditor.rootField.release(),
            medium = new fields.Medium(this.result(), release);

        medium.name("");

        if (this._addDisc) {
            this._addDisc(medium);
        }

        return medium;
    }

    pageText() {
        return texp.l('Page {page} of {total}', {
            page: this.currentPage(),
            total: this.totalPages(),
        });
    }
}

SearchTab.prototype.tracksRequestData = {};


export const mediumSearchTab = releaseEditor.mediumSearchTab = new SearchTab();

Object.assign(mediumSearchTab, {
    endpoint: "/ws/js/medium",

    tracksRequestData: {inc: "recordings"},

    tracksRequestURL: function (result) {
        return [this.endpoint, result.medium_id].join("/");
    },

    _addDisc(medium) {
        medium.loaded(true);
        medium.collapsed(false);
    },
});


var cdstubSearchTab = new SearchTab();

Object.assign(cdstubSearchTab, {
    endpoint: "/ws/js/cdstub",

    tracksRequestURL: function (result) {
        return [this.endpoint, result.discid].join("/");
    },
});


export const addDiscDialog = releaseEditor.addDiscDialog = new Dialog();

Object.assign(addDiscDialog, {
    element: "#add-disc-dialog",
    title: l("Add Medium"),

    trackParser: trackParserDialog,
    mediumSearch: mediumSearchTab,
    cdstubSearch: cdstubSearchTab,
    currentTab: ko.observable(trackParserDialog),

    open: function () {
        var release = releaseEditor.rootField.release(),
            blankMedium = new fields.Medium({}, release);

        this.trackParser.setMedium(blankMedium);
        this.trackParser.result(blankMedium);

        _.each([mediumSearchTab, cdstubSearchTab],
            function (tab) {
                if (!tab.releaseName()) tab.releaseName(release.name());

                if (!tab.artistName()) {
                    tab.artistName(reduceArtistCredit(release.artistCredit()));
                }
            });

        Dialog.prototype.open.apply(this, arguments);
    },

    addDisc: function () {
        var medium = this.currentTab().addDisc();
        if (!medium) return;

        var release = releaseEditor.rootField.release();

        // If there's only one empty disc, replace it.
        if (release.hasOneEmptyMedium()) {
            medium.position(1);

            // Keep the existing formatID if there's not a new one.
            if (!medium.formatID()) {
                medium.formatID(release.mediums()[0].formatID());
            }

            release.mediums([medium]);
        }
        else {
            // If there are no mediums, _.max will return undefined.
            const maxPosition = _.max(_.invokeMap(release.mediums(), 'position'));
            const nextPosition = _.isFinite(maxPosition) ? (maxPosition + 1) : 1;
            medium.position(nextPosition);
            release.mediums.push(medium);
        }

        this.close();
    },
});


$(function () {
    $("#add-disc-parser").data("model", addDiscDialog.trackParser);
    $("#add-disc-medium").data("model", mediumSearchTab);
    $("#add-disc-cdstub").data("model", cdstubSearchTab);

    $(addDiscDialog.element).tabs({
        activate: function (event, ui) {
            addDiscDialog.currentTab(ui.newPanel.data("model"));
        },
    });
});
