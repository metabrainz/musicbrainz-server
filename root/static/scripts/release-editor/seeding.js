// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';

import fields from './fields';
import utils from './utils';
import releaseEditor from './viewModel';

releaseEditor.seedErrors = ko.observable(null);


releaseEditor.seed = function (data) {
    data = data || {seed: {}, errors: []};

    var seed = data.seed;
    this.seededReleaseData = seed;

    if (data.errors && data.errors.length) {
        this.seedErrors(data.errors);
    }

    if (seed.editNote) {
        this.rootField.editNote(seed.editNote);
    }

    if (seed.makeVotable !== undefined) {
        this.rootField.makeVotable(!!seed.makeVotable);
    }

    if (this.action === 'add') {
        var releaseData = {};

        if (seed.relationships) {
            releaseData.relationships = seed.relationships;
        }

        var release = new fields.Release(releaseData);
        this.seedRelease(release, seed);
        this.rootField.release(release);
    }
};


releaseEditor.seedRelease = function (release, data) {
    if (data.name !== undefined) {
        release.name(data.name);
    }

    if (data.statusID !== undefined) {
        release.statusID(data.statusID);
    }

    if (data.languageID !== undefined) {
        release.languageID(data.languageID);
    }

    if (data.scriptID !== undefined) {
        release.scriptID(data.scriptID);
    }

    if (data.packagingID !== undefined) {
        release.packagingID(data.packagingID);
    }

    if (data.comment !== undefined) {
        release.comment(data.comment);
    }

    if (data.annotation !== undefined) {
        release.annotation(data.annotation);
    }

    if (data.barcode) {
        if (data.barcode === 'none') {
            release.barcode.none(true);
        } else {
            release.barcode.value(data.barcode);
        }
    }

    if (data.artistCredit) {
        release.artistCredit(data.artistCredit);
        release.artistCredit.saved = release.artistCredit.peek();
    }

    if (data.events) {
        release.events(utils.mapChild(release, data.events, fields.ReleaseEvent));
    }

    if (data.labels) {
        release.labels(utils.mapChild(release, data.labels, fields.ReleaseLabel));
    }

    if (data.releaseGroup) {
        // Need to convert secondary type IDs into strings because
        // Knockout.js will do a strict comparison when rendering the
        // input. See MBS-7828.
        data.releaseGroup.secondaryTypeIDs = data.releaseGroup.secondaryTypeIDs.map(String);
        release.releaseGroup(new fields.ReleaseGroup(data.releaseGroup));
    }

    if (data.mediums) {
        release.mediums(utils.mapChild(release, data.mediums, fields.Medium));

        release.seededTocs = _.transform(release.mediums(),
            function (result, medium) {
                var toc = medium.toc();

                if (toc) {
                    result[medium.position()] = toc;
                }
            }, {});
    }
};
