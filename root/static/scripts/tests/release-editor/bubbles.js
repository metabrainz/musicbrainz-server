// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

releaseEditor.test.module("release editor bubbles", releaseEditor.test.setupReleaseEdit);


function setupTrackACBubble(self) {
    var ac = self.release.mediums()[0].tracks()[0].artistCredit;
    self.bubble = releaseEditor.trackArtistBubble;

    self.$bubble = $("<div>").addClass("bubble").append("<input>");
    self.$button = $("<button>");

    $("#qunit-fixture").append(self.$bubble, self.$button);

    ko.applyBindingsToNode(self.$bubble[0], { bubble: self.bubble }, ac);
    ko.applyBindingsToNode(self.$button[0], { controlsBubble: self.bubble }, ac);
}


test("clicking outside of a track AC bubble closes it", function () {
    setupTrackACBubble(this);

    ok(!this.bubble.visible(), "bubble is not visible");

    this.$button.click();
    ok(this.bubble.visible(), "bubble is visible after clicking button");

    $("body").click();
    ok(!this.bubble.visible(), "bubble is hidden after clicking outside of it");
});


test("creating a new artist from the track AC bubble should not close it (MBS-7251)", function () {
    setupTrackACBubble(this);

    // Open the track AC bubble.
    this.$button.click();

    // Simulate an add-entity dialog opening.
    var $dialog = $("<div>").appendTo("#qunit-fixture").dialog();
    ok(this.bubble.visible(), "bubble is visible after dialog opens above it");

    $dialog.parent().find("button.ui-dialog-titlebar-close").click();
    ok(this.bubble.visible(), "bubble is visible after dialog is closed");

    this.$button.click();
    ok(!this.bubble.visible(), "bubble is hidden after clicking the button again");
});
