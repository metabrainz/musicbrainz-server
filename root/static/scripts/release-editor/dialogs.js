// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const i18n = require('../common/i18n');
const formatTrackLength = require('../common/utility/formatTrackLength');
const isBlank = require('../common/utility/isBlank');
const request = require('../common/utility/request');

(function (releaseEditor) {

    var Dialog = aclass({

        open: function () {
            $(this.element).dialog({ title: this.title, width: 700 });
        },

        close: function () {
            $(this.element).dialog("close");
        }
    });


    releaseEditor.trackParserDialog = Dialog().extend({
        element: "#track-parser-dialog",
        title: i18n.l("Track Parser"),

        toBeParsed: ko.observable(""),
        result: ko.observable(null),
        error: ko.observable(""),

        before$open: function (medium) { this.setMedium(medium) },

        setMedium: function (medium) {
            this.medium = medium;
            this.toBeParsed(releaseEditor.trackParser.mediumToString(medium));
        },

        parse: function () {
            var medium = this.medium;
            var toBeParsed = this.toBeParsed();

            var newTracks = releaseEditor.trackParser.parse(toBeParsed, medium);
            var error = !isBlank(toBeParsed) && newTracks.length === 0;

            this.error(error);
            !error && medium.tracks(newTracks);
        },

        addDisc: function () {
            this.parse();
            return this.error() ? null : this.medium;
        }
    });


    var SearchResult = aclass({

        init: function (tab, data) {
            _.extend(this, data);

            this.tab = tab;
            this.loaded = ko.observable(false);
            this.loading = ko.observable(false);
            this.error = ko.observable("");
        },

        expanded: function () { return this.tab.result() === this },

        toggle: function () {
            var expand = this.tab.result() !== this;

            this.tab.result(expand ? this : null);

            if (expand && !this.loaded() && !this.loading()) {
                this.loading(true);
                this.error("");

                request({
                    url: this.tab.tracksRequestURL(this),
                    data: this.tab.tracksRequestData
                }, this)
                .done(this.requestDone)
                .fail(function (jqXHR) {
                    var response = JSON.parse(jqXHR.responseText);
                    this.error(response.error);
                })
                .always(function () { this.loading(false) });
            }

            return false;
        },

        requestDone: function (data) {
            _.each(data.tracks, this.parseTrack, this);
            _.extend(this, releaseEditor.utils.reuseExistingMediumData(data));

            this.loaded(true);
        },

        parseTrack: function (track, index) {
            track.id = null;
            track.position = track.position || (index + 1);
            track.number = track.position;
            track.formattedLength = formatTrackLength(track.length);

            if (track.artistCredit) {
                track.artist = MB.entity.ArtistCredit(track.artistCredit).text();
            }
            else {
                track.artist = track.artist || this.artist || "";
                track.artistCredit = [{ name: track.artist }];
            }
        }
    });


    var SearchTab = aclass({

        tracksRequestData: {},

        init: function () {
            this.releaseName = ko.observable("");
            this.artistName = ko.observable("");
            this.trackCount = ko.observable("");

            this.searchResults = ko.observable(null);
            this.result = ko.observable(null);
            this.searching = ko.observable(false);
            this.error = ko.observable("");

            this.currentPage = ko.observable(0);
            this.totalPages = ko.observable(0);
        },

        search: function (data, event, pageJump) {
            this.searching(true);

            var data = {
                q: this.releaseName(),
                artist: this.artistName(),
                tracks: this.trackCount(),
                page: pageJump ? this.currentPage() + pageJump : 1
            };

            this._jqXHR = request({ url: this.endpoint, data: data }, this)
                .done(this.requestDone)
                .fail(function (jqXHR, textStatus) {
                    if (textStatus !== "abort") {
                        this.error(jqXHR.responseText);
                    }
                })
                .always(function () {
                    this.searching(false);
                });
        },

        cancelSearch: function () {
            if (this._jqXHR) this._jqXHR.abort();
        },

        buttonClicked: function () {
            this.searching() ? this.cancelSearch() : this.search();
        },

        keydownEvent: function (data, event) {
            if (event.keyCode === 13) { // Enter
                this.search(data, event);
            }
            else {
                // Knockout calls preventDefault unless you return true. Allows
                // people to actually enter text.
                return true;
            }
        },

        nextPage: function () {
            if (this.currentPage() < this.totalPages()) {
                this.search(this, null, 1);
            }
            return false;
        },

        previousPage: function () {
            if (this.currentPage() > 1) {
                this.search(this, null, -1);
            }
            return false;
        },

        requestDone: function (results) {
            this.error("");

            var pager = results.pop();

            if (pager) {
                this.currentPage(parseInt(pager.current, 10));
                this.totalPages(parseInt(pager.pages, 10));
            }

            this.searchResults(_.map(results, _.partial(SearchResult, this)));
        },

        addDisc: function (inner) {
            var release = releaseEditor.rootField.release(),
                medium = releaseEditor.fields.Medium(this.result(), release);

            medium.name("");
            inner && inner(medium);

            return medium;
        }
    });


    var mediumSearchTab = releaseEditor.mediumSearchTab = SearchTab().extend({
        endpoint: "/ws/js/medium",

        tracksRequestData: { inc: "recordings" },

        tracksRequestURL: function (result) {
            return [this.endpoint, result.medium_id].join("/");
        },

        augment$addDisc: function (medium) {
            medium.loaded(true);
            medium.collapsed(false);
        }
    });


    var cdstubSearchTab = SearchTab().extend({
        endpoint: "/ws/js/cdstub",

        tracksRequestURL: function (result) {
            return [this.endpoint, result.discid].join("/");
        }
    });


    var freedbSearchTab = SearchTab().extend({
        endpoint: "/ws/js/freedb",

        tracksRequestURL: function (result) {
            return [this.endpoint, result.category, result.discid].join("/");
        }
    });


    var addDiscDialog = releaseEditor.addDiscDialog = Dialog().extend({
        element: "#add-disc-dialog",
        title: i18n.l("Add Medium"),

        trackParser: releaseEditor.trackParserDialog,
        mediumSearch: mediumSearchTab,
        cdstubSearch: cdstubSearchTab,
        freedbSearch: freedbSearchTab,
        currentTab: ko.observable(releaseEditor.trackParserDialog),

        before$open: function () {
            var release = releaseEditor.rootField.release(),
                blankMedium = releaseEditor.fields.Medium({}, release);

            this.trackParser.setMedium(blankMedium);
            this.trackParser.result(blankMedium);

            _.each([mediumSearchTab, cdstubSearchTab, freedbSearchTab],
                function (tab) {
                    if (!tab.releaseName()) tab.releaseName(release.name());

                    if (!tab.artistName()) tab.artistName(release.artistCredit.text());
                });
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
                // If there are no mediums, _.max will return -Infinity.
                var nextPosition = Math.max(
                    1, _.max(_.invoke(release.mediums(), "position")) + 1
                );
                medium.position(nextPosition);
                release.mediums.push(medium);
            }

            this.close();
        }
    });


    $(function () {
        $("#add-disc-parser").data("model", addDiscDialog.trackParser);
        $("#add-disc-medium").data("model", mediumSearchTab);
        $("#add-disc-cdstub").data("model", cdstubSearchTab);
        $("#add-disc-freedb").data("model", freedbSearchTab);

        $(addDiscDialog.element).tabs({
            activate: function (event, ui) {
                addDiscDialog.currentTab(ui.newPanel.data("model"));
            }
        });
    });

}(MB.releaseEditor = MB.releaseEditor || {}));
