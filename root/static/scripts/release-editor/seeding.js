// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (releaseEditor) {

    var utils = releaseEditor.utils;


    releaseEditor.seedErrors = ko.observable(null);


    releaseEditor.seed = function (data) {
        data = data || { seed: {}, errors: [] };

        var seed = data.seed;

        if (data.errors && data.errors.length) {
            this.seedErrors(data.errors);
        }

        if (seed.editNote) {
            this.rootField.editNote(seed.editNote);
        }

        if (seed.asAutoEditor !== undefined) {
            this.rootField.asAutoEditor(!!seed.asAutoEditor);
        }

        if (this.action === "add") {
            var release = this.fields.Release({});

            this.seedRelease(release, seed);

            this.rootField.release(release);
        }
        else {
            this.seededReleaseData = seed;
        }
    };


    releaseEditor.seedRelease = function (release, data) {
        var fields = releaseEditor.fields;

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
            release.barcode.value(data.barcode);
        }

        if (data.artistCredit) {
            release.artistCredit.setNames(data.artistCredit);
        }

        if (data.events) {
            release.events(utils.mapChild(release, data.events, fields.ReleaseEvent));
        }

        if (data.labels) {
            release.labels(utils.mapChild(release, data.labels, fields.ReleaseLabel));
        }

        if (data.releaseGroup) {
            release.releaseGroup(fields.ReleaseGroup(data.releaseGroup));
        }

        if (data.mediums) {
            release.mediums(utils.mapChild(release, data.mediums, fields.Medium));
        }
    };

}(MB.releaseEditor = MB.releaseEditor || {}));
