/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';

import {isCompleteArtistCredit} from '../common/immutable-entities';
import MB from '../common/MB';
import debounce from '../common/utility/debounce';
import request from '../common/utility/request';

import releaseEditor from './viewModel';
import utils from './utils';


var releaseGroupReleases = ko.observableArray([]);


releaseEditor.similarReleases = ko.observableArray([]);
releaseEditor.baseRelease = ko.observable("");


releaseEditor.baseRelease.subscribe(function (gid) {
    var release = releaseEditor.rootField.release();

    if (!gid) {
        release.mediums([new releaseEditor.fields.Medium({}, release)]);
        return;
    }

    releaseEditor.loadRelease(gid, function (data) {
        release.mediums(
            _.map(data.mediums, function (m) {
                return new releaseEditor.fields.Medium(
                    utils.reuseExistingMediumData(m), release,
                );
            }),
        );
        release.loadMedia();
    });
});


releaseEditor.findReleaseDuplicates = function () {
    var loadingFromRG = false;

    utils.withRelease(function (release) {
        var releaseGroup = release.releaseGroup();
        var gid = releaseGroup.gid;

        if (!gid) {
            return;
        }

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

        /*
         * If a release group is selected, just show the releases from
         * there without searching.
         */
        var rgReleases = releaseGroupReleases();

        if (rgReleases.length > 0) {
            releaseEditor.similarReleases(rgReleases);
            $("#release-editor").tabs("enable", 1);
            return;
        }

        var ac = release.artistCredit();

        if (loadingFromRG || !name || !isCompleteArtistCredit(ac)) {
            return;
        }

        var query = utils.constructLuceneFieldConjunction({
            release: [utils.escapeLuceneValue(name)],

            arid: ac.names.map(
                x => utils.escapeLuceneValue(x.artist.gid),
            ),
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


function formatReleaseData(release) {
    var clean = new MB.entity.Release(utils.cleanWebServiceData(release));

    var events = release["release-events"];
    var labels = release["label-info"];

    clean.formats = combinedMediumFormatName(release.media) || l('[missing media]');
    clean.tracks = _.map(release.media, "track-count").join(" + ") ||
        lp('-', 'missing data');

    clean.dates = events
        ? events.map(x => x.date).filter(Boolean)
        : [];

    clean.countries = events ? [...new Set(events.flatMap(
        x => (x.area?.['iso-3166-1-codes']) ?? [],
    ))] : [];

    clean.labels = labels ? labels.map(function (info) {
        const label = info.label;
        if (label) {
            return new MB.entity.Label({ gid: label.id, name: label.name });
        }
        return null;
    }).filter(Boolean) : [];

    clean.catalogNumbers = labels
        ? labels.map(x => x['catalog-number']).filter(Boolean)
        : [];

    clean.barcode = release.barcode || "";

    return clean;
}


function combinedMediumFormatName(mediums) {
    const getFormat = medium => medium.format || '';
    const formats = _.uniq(mediums.map(getFormat));
    const formatCounts = _.countBy(mediums, getFormat);

    return formats
        .map(function (format) {
            const count = formatCounts[format];

            return (count > 1 ? count + "\u00D7" : "") +
                (format
                    ? lp_attributes(format, 'medium_format')
                    : lp('(unknown)', 'medium format'));
        })
        .join(" + ");
}
