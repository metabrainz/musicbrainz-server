// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

MB.releaseEditor = _.extend(MB.releaseEditor || {}, {

    activeTabID: ko.observable("#information"),
    activeTabIndex: ko.observable(0),
    loadError: ko.observable("")
});


MB.releaseEditor.init = function (options) {
    var self = this;

    $.extend(this, _.pick(options, "action", "returnTo", "redirectURI"));

    // Setup guess case buttons for the title field. Do this every time the
    // release changes, since the old fields get removed and the events no
    // longer exist.
    this.utils.withRelease(function (release) {
        _.defer(function () {
            MB.Control.initialize_guess_case("release");
        });
    });

    // Allow pressing enter to advance to the next tab. The listener is added
    // to the document and not #release-editor so that other events can call
    // preventDefault if necessary.

    $(document).on("keydown", "#release-editor :input:not(:button, textarea)",
        function (event) {
            if (event.which === 13 && !event.isDefaultPrevented()) {
                // The _.defer is entirely for <select> elements in Firefox,
                // which don't have their change events triggered until after
                // enter is hit. Additionally, if we switch tabs before the
                // change event is handled, it doesn't seem to even register
                // (probably because the <select> is hidden by then).
                _.defer(function () {
                    self.activeTabID() === "#edit-note" ? self.submitEdits() : self.nextTab();
                });
            }
        });

    var $pageContent = $("#release-editor").tabs({

        activate: function (event, ui) {
            var panel = ui.newPanel;

            self.activeTabID(panel.selector)
                .activeTabIndex(self.uiTabs.panels.index(panel));

            // jQuery UI's position() function doesn't work on hidden
            // elements. So if any bubble was open in the tab we just
            // switched to, we have to trigger its position to update,
            // now that it's visible.

            var $bubble = panel.find("div.bubble:visible:eq(0)");
            if ($bubble.length) $bubble[0].bubbleDoc.redraw(true /* stealFocus */);
        }
    });

    this.uiTabs = $pageContent.data("ui-tabs");
    this.tabCount = this.uiTabs.panels.length;

    if (this.action === "add") {
        $pageContent.tabs("disable", 1);

        this.findReleaseDuplicates();
    }

    // Initiate tooltip widget (current just used by the recordings tab).

    $pageContent.find(".ui-tabs-nav a").tooltip();

    // Enable or disable the recordings tab depending on whether there are
    // tracks or if the tracks have errors.

    this.utils.withRelease(function (release) {
        var addingRelease = self.action === "add";
        var tabEnabled = addingRelease ? release.hasTracks() : true;

        if (tabEnabled) {
            // If we're editing a release and the mediums aren't loaded
            // (because there are many discs), we should still allow the
            // user to edit the recordings if that's all they want to do.
            tabEnabled = release.hasTrackInfo();
        }

        var tabNumber = addingRelease ? 3 : 2;
        self.uiTabs[tabEnabled ? "enable" : "disable"](tabNumber);

        // When the tab is enabled, the tooltip is *disabled*

        var tooltipEnabled = !tabEnabled;
        var $tab = self.uiTabs.tabs.eq(tabNumber).find("a");

        // XXX Don't disable the tooltip twice.
        // http://bugs.jqueryui.com/ticket/9719

        if ($tab.tooltip("option", "disabled") === tooltipEnabled) {
            $tab.tooltip(tooltipEnabled ? "enable" : "disable");
        }
    });

    // Change the track artists to match the release artist if it was changed.

    this.utils.withRelease(function (release) {
        var tabID = self.activeTabID();
        var releaseAC = release.artistCredit;
        var releaseACChanged = !releaseAC.isEqual(releaseAC.saved);

        if (tabID === "#tracklist" && releaseACChanged) {
            if (!release.artistCredit.isVariousArtists()) {
                var names = releaseAC.toJSON();

                _.each(release.mediums(), function (medium) {
                    _.each(medium.tracks(), function (track) {
                        if (track.artistCredit.text() === releaseAC.saved.text()) {
                            track.artistCredit.setNames(names);
                        }
                    });
                });
            }
            release.artistCredit.saved = self.fields.ArtistCredit(names);
        }
    });

    // Update the document title to match the release title

    this.utils.withRelease(function (release) {
        var name = _.str.clean(release.name());

        if (self.action === "add") {
            document.title = MB.i18n.expand(
                name ? MB.i18n.l("{name} - Add Release") :
                       MB.i18n.l("Add Release"), { name: name }
            );
        } else {
            document.title = MB.i18n.expand(
                name ? MB.i18n.l("{name} - Edit Release") :
                       MB.i18n.l("Edit Release"), { name: name }
            );
        }
    });

    // Handle showing/hiding the AddDisc dialog when the user switches to/from
    // the tracklist tab.

    this.utils.withRelease(function (release) {
        self.autoOpenTheAddDiscDialog(release);
    });

    // Make sure the user actually wants to close the page/tab if they've made
    // any changes. Browsers that support onbeforeunload should have this set
    // to null, or undefined otherwise.
    if (window.onbeforeunload === null) {
        MB.releaseEditor.allEdits.subscribe(function (edits) {
            window.onbeforeunload =
                edits.length ? _.constant(MB.i18n.l("All of your changes will be lost if you leave this page.")) : null;
        });
    }

    // Intialize release data/view model.

    this.rootField = this.fields.Root();

    this.rootField.missingEditNote = function () {
        return self.action === "add" && !self.rootField.editNote();
    };

    this.seed(options.seed);

    if (this.action === "edit") {
        this.loadRelease(options.gid);
    }

    this.getEditPreviews();

    // Apply root bindings to the page.

    ko.applyBindings(this, $pageContent[0]);

    // Fancy!

    $(function () {
        $pageContent.fadeIn("fast", function () { $("#name").focus() });
    });
};


MB.releaseEditor.loadRelease = function (gid, callback) {
    var args = {
        url: "/ws/js/release/" + gid,
        data: { inc: "annotation+release-events+labels+media+rels" }
    };

    return MB.utility.request(args, this)
            .done(callback || this.releaseLoaded)
            .fail(function (jqXHR, status, error) {
                error = jqXHR.status + " (" + error + ")"

                // If there wasn't an ISE, the response should parse as JSON.
                try {
                    error += ": " + JSON.parse(jqXHR.responseText).error;
                } catch (e) {};

                this.loadError(error);
            });

};


MB.releaseEditor.releaseLoaded = function (data) {
    this.loadError("");

    var seed = this.seededReleaseData;
    delete this.seededReleaseData;

    if (seed && seed.relationships) {
        data.relationships = (data.relationships || []).concat(seed.relationships);
    }

    var release = this.fields.Release(data);

    if (seed) this.seedRelease(release, seed);

    if (!seed || !seed.mediums) release.loadMedia();

    this.rootField.release(release);
};


MB.releaseEditor.autoOpenTheAddDiscDialog = function (release) {
    var addDiscUI = $(this.addDiscDialog.element).data("ui-dialog");
    var trackParserUI = $(this.trackParserDialog.element).data("ui-dialog");

    // Show the dialog if there's no non-empty disc.
    if (this.activeTabID() === "#tracklist") {
        var dialogIsOpen = (addDiscUI && addDiscUI.isOpen()) ||
                            (trackParserUI && trackParserUI.isOpen());

        if (!dialogIsOpen && release.hasOneEmptyMedium() &&
                            !release.mediums()[0].loading()) {
            this.addDiscDialog.open();
        }
    } else if (addDiscUI) {
        addDiscUI.close();
    }
};


MB.releaseEditor.allowsSubmission = function () {
    return (
        !this.submissionInProgress() &&
        !this.validation.errorsExist() &&
        (this.action === "edit" || this.rootField.editNote()) &&
        this.allEdits().length > 0
    );
};

$(MB.confirmNavigationFallback);
