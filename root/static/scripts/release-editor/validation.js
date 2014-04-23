// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (releaseEditor) {

    releaseEditor.validation = releaseEditor.validation || {};
    var utils = releaseEditor.utils;


    var triggeredErrorCount = 0;
    var allComputedErrors = [];
    var errorsToShowPendingTabSwitch = [];
    var releaseField = ko.observable().subscribeTo("releaseField", true);


    releaseEditor.validation.errorField = function (initialValue) {
        var observable = ko.observable(initialValue);

        // Always notify, even if the error is the same.
        observable.equalityComparer = null;

        observable.subscribe(function (newError) {
            if (newError) triggeredErrorCount++;
        });

        return observable;
    };


    function markTabWithErrors($panel) {
        // Don't mark the edit note tab, because it's the last one and only
        // can have one error, so the user will always see it anyway.
        if ($panel.attr("id") === "edit-note") {
            return;
        }
        // Mark the previous tab red if it has errors.
        var tabs = releaseEditor.uiTabs;

        var $errors = $(".field-error", $panel).filter(function () {
            return $(this).data("visible");
        });

        tabs.tabs.eq(tabs.panels.index($panel))
            .toggleClass("error-tab", $errors.length > 0);
    }


    function showErrorHandler(handler) {
        return function (element, valueAccessor) {
            var $element = $(element).hide(),
                $panel = $element.parents(".ui-tabs-panel"),
                errorField = valueAccessor().error;

            function checkError(value) {
                handler(value, $element, $panel);
                markTabWithErrors($panel);
            }

            errorField.subscribe(checkError);
            checkError(errorField());
        };
    }


    ko.bindingHandlers.showErrorRightAway = {

        init: showErrorHandler(function (value, $element) {
            $element.text(value || "").data("visible", !!value).toggle(!!value);
        })
    };


    ko.bindingHandlers.showErrorWhenTabIsSwitched = {

        init: showErrorHandler(function (value, $element, $panel) {
            var alreadyVisible = $element.text(value || "").is(":visible");

            if (!value && alreadyVisible) {
                $element.data("visible", false).hide();
            }

            var $hidden = $panel.data("hiddenErrors") || $();

            $panel.data("hiddenErrors",
                (value && !alreadyVisible)
                    ? $hidden.add($element) : $hidden.not($element));
        })
    };


    $(function () {
        $("#release-editor").on("tabsbeforeactivate", function (event, ui) {

            // Show errors on and mark all tabs between the one we just
            // clicked on, including the one we left.
            var oldPanel = ui.oldPanel;
            var newPanel = ui.newPanel;

            var $panels = (oldPanel.index() < newPanel.index())
                ? oldPanel.nextUntil(newPanel).andSelf()
                : newPanel.nextUntil(oldPanel).andSelf();

            $panels.each(function () {
                var $panel = $(this);

                ($panel.data("hiddenErrors") || $())
                    .data("visible", true).show();

                $panel.data("hiddenErrors", $());

                markTabWithErrors($panel);
            });
        });
    });


    function computeErrors(read) {
        allComputedErrors.push(
            utils.withRelease(function (release) {
                var beforeCount = triggeredErrorCount;

                if (read(release)) triggeredErrorCount++;

                return triggeredErrorCount - beforeCount;
            }, 0)
        );
    }


    // Release title shouldn't be empty.

    computeErrors(function (release) {
        release.name.error(release.name() ? "" : MB.text.ReleaseNameRequired);
    });


    // Release group should be selected when editing.

    computeErrors(function (release) {
        release.releaseGroup.error(
            releaseEditor.action === "add" ||
                release.releaseGroup().id ? "" : MB.text.SelectAReleaseGroup
        );
    });


    // All artists in release AC should be selected.

    computeErrors(function (release) {
        var ac = release.artistCredit;
        ac.error(ac.isComplete() ? "" : MB.text.MissingArtist);
    });


    // Dates should be valid, and there should be no duplicate countries.

    function countryID(event) { return event.countryID() }

    computeErrors(function (release) {
        var events = _(release.events());

        events.each(function (event) {
            var date = event.unwrapDate();

            event.date.error(
                MB.utility.validDate(date.year, date.month, date.day) ?
                "" : MB.text.InvalidDate
            );
        });

        events.filter(countryID).groupBy(countryID)
            .each(function (events, id) {
                var dupeCountry = events.length > 1;

                _.each(events, function (event) {
                    event.countryID.error(dupeCountry ?
                        MB.text.DuplicateReleaseCountry : "");
                });
            });
    });


    // All labels should be selected (if there's text in the field).

    computeErrors(function (release) {
        _.each(release.labels(), function (releaseLabel) {
            var label = releaseLabel.label() || {};

            var mustSelectLabel = label.name &&
                !(label.id || releaseLabel.catalogNumber());

            releaseLabel.label.error(mustSelectLabel ? MB.text.SelectALabel : "");
        });
    });


    // Barcode should be a valid EAN/UPC.

    computeErrors(function (release) {
        var field = release.barcode;

        field.error("");
        field.message("");

        var barcode = field.barcode();
        if (!barcode || field.confirmed()) return;

        var text = MB.text.Barcode;

        if (barcode.length === 11) {
            field.error(
                text.NoCheckdigitUPC + " " +
                MB.i18n.expand(text.CheckDigit, { checkdigit: field.checkDigit("0" + barcode) })
            );
        }
        else if (barcode.length === 12) {
            if (field.validateCheckDigit("0" + barcode)) {
                field.message(text.ValidUPC);
            }
            else {
                field.error(
                    text.InvalidUPC + " " + text.DoubleCheck + " " +
                    MB.i18n.expand(text.CheckDigit, { checkdigit: field.checkDigit(barcode) })
                );
            }
        }
        else if (barcode.length === 13) {
            if (field.validateCheckDigit(barcode)) {
                field.message(text.ValidEAN);
            }
            else {
                field.error(text.InvalidEAN + " " + text.DoubleCheck);
            }
        }
        else {
            field.error(text.Invalid + " " + text.DoubleCheck);
        }
    });


    // There should be at least one medium with one track, and all tracks
    // should have a title and complete AC. The medium format should not
    // clash with the existence of a disc ID.

    computeErrors(function (release) {
        var mediums = release.mediums(),
            mediumRequired = mediums.length === 0;

        release.mediums.error(mediumRequired ? MB.text.MediumRequired : "");

        _.each(mediums, function (medium) {
            var tracks = _(medium.tracks());

            var tracksAreNeeded = medium.loaded() && !medium.hasTracks();
            medium.tracks.error(tracksAreNeeded ? MB.text.TracklistRequired : "");

            var missingTrackInfo = tracks.any(function (track) {
                return !(track.name() && track.artistCredit.isComplete());
            });

            if (missingTrackInfo) {
                medium.tracks.error(MB.text.TrackInfoRequired);
            }

            medium.needsRecordings(tracks.any(function (track) {
                return track.needsRecording();
            }));

            if (medium.id && medium.hasToc() && !medium.canHaveDiscID()) {
                medium.formatID.error(MB.text.MediumHasDiscID);
            }
            else {
                medium.formatID.error("");
            }
        });
    });


    // An edit note is required when adding a release.

    computeErrors(function () {
        var root = releaseEditor.rootField;
        var editNote = _.str.clean(root.editNote());
        var noteRequired = releaseEditor.action === "add" && !editNote;

        root.editNote.error(noteRequired ? MB.text.EditNoteRequired : "");
    });


    // There shouldn't be any duplicate external links.

    computeErrors(function (release) {
        var links = release.externalLinks.links();

        for (var i = 0, link; link = links[i++];) {
            if (!link.removed() && !link.isEmpty() && link.error()) {
                return true;
            }
        }
    });


    function countErrors(memo, func) { return memo + func() }

    releaseEditor.validation.errorCount = ko.computed(function () {
        return _.reduce(allComputedErrors, countErrors, 0);
    });


    releaseEditor.validation.errorsExistOtherThanAMissingEditNote = ko.computed({
        read: function () {
            var errorCount = releaseEditor.validation.errorCount();
            var editNoteError = releaseEditor.rootField.editNote.error();

            return errorCount > 0 && !(errorCount === 1 && editNoteError);
        },
        deferEvaluation: true
    });

}(MB.releaseEditor = MB.releaseEditor || {}));
