// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const debounce = require('../common/utility/debounce');
const request = require('../common/utility/request');

(function (releaseEditor) {

    var utils = releaseEditor.utils;
    var releaseGroupReleases = ko.observableArray([]);


    releaseEditor.similarReleases = ko.observableArray([]);
    releaseEditor.baseRelease = ko.observable("");


    releaseEditor.baseRelease.subscribe(function (gid) {
        var release = releaseEditor.rootField.release();

        if (!gid) {
            release.mediums([ releaseEditor.fields.Medium({}, release) ]);
            return;
        }

        releaseEditor.loadRelease(gid, function (data) {
            release.mediums(
                _.map(data.mediums, function (m) {
                    return releaseEditor.fields.Medium(
                        utils.reuseExistingMediumData(m), release
                    );
                })
            );
            release.loadMedia();
        });
    });


    releaseEditor.findReleaseDuplicates = function () {
        var loadingFromRG = false;

        utils.withRelease(function (release) {
            var releaseGroup = release.releaseGroup();
            var gid = releaseGroup.gid;

            if (!gid) return;

            var url = `/ws/2/release?release-group=${gid}&inc=labels+media&fmt=json`;

            loadingFromRG = true;
            toggleLoadingIndicator(true);

            request({ url: url })
                .always(function () {
                    loadingFromRG = false;
                    toggleLoadingIndicator(false);
                })
                .done(function (data) {
                    releaseGroupReleases(_.map(data.releases, formatReleaseData));
                });
        });

        debounce(utils.withRelease(function (release) {
            var name = release.name();

            // If a release group is selected, just show the releases from
            // there without searching.
            var rgReleases = releaseGroupReleases();

            if (rgReleases.length > 0) {
                releaseEditor.similarReleases(rgReleases);
                $("#release-editor").tabs("enable", 1);
                return;
            }

            var ac = release.artistCredit;

            if (loadingFromRG || !name || !ac.isComplete()) {
                return;
            }

            var query = utils.constructLuceneFieldConjunction({
                release: [ utils.escapeLuceneValue(name) ],

                arid: _(ac.names())
                        .invoke("artist").pluck("gid")
                        .map(utils.escapeLuceneValue).value()
            });

            toggleLoadingIndicator(true);

            utils.search("release", query, 10).done(gotResults);
        }));
    };


    function gotResults(data) {
        var releases = _.filter(data.releases, function (release) {
            return parseInt(release.score, 10) >= 65;
        });

        if (releases.length > 0) {
            releaseEditor.similarReleases(_.map(releases, formatReleaseData));

            $("#release-editor").tabs("enable", 1);
        } else {
            $("#release-editor").tabs("disable", 1);
        }

        toggleLoadingIndicator(false);
    }


    function toggleLoadingIndicator(show) {
        $("#release-editor").data("ui-tabs")
            .tabs.eq(1).toggleClass("loading-tab", show);
    }


    function pluck(chain, name) { return chain.pluck(name).compact() }


    function formatReleaseData(release) {
        var clean = MB.entity.Release(utils.cleanWebServiceData(release));

        var events = _(release["release-events"]);
        var labels = _(release["label-info"]);

        clean.formats = combinedMediumFormatName(release.media);
        clean.tracks = _.pluck(release.media, "track-count").join(" + ");

        clean.dates = pluck(events, "date").value();

        clean.countries = pluck(events, "area")
            .pluck("iso-3166-1-codes")
            .flatten().compact().uniq().value();

        clean.labels = pluck(labels, "label").map(function (info) {
            return MB.entity.Label({ gid: info.id, name: info.name });
        }).value();

        clean.catalogNumbers = pluck(labels, "catalog-number").value();

        clean.barcode = release.barcode || "";

        return clean;
    }


    function combinedMediumFormatName(mediums) {
        var formats = pluck(_(mediums), "format");
        var formatCounts = formats.countBy(_.identity);

        return formats.uniq().map(function (format) {
            var count = formatCounts[format];

            return (count > 1 ? count + "\u00D7" : "") + format;
        })
        .value().join(" + ");
    }

}(MB.releaseEditor = MB.releaseEditor || {}));
