// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module("autocomplete", {

    setup: function () {
        this.$input = $("<input>").attr("type", "text").appendTo("#qunit-fixture");

        ko.applyBindingsToNode(this.$input[0], { autocomplete: { entity: "artist" } });

        this.$menu = this.$input.autocomplete("widget");
    },

    teardown: function () {
        this.$input.autocomplete("destroy");
        $(".ui-widget").remove();
    }
});


$.ui.menu.prototype.delay = 0;

$.ui.autocomplete.prototype.options.delay = 0;

$.ui.autocomplete.prototype.options.source = function (request, response) {
    var data = [
        {
            name: "Foo.",
            sortname: "Foo?",
            comment: "Foo!",
            id: "123",
            gid: "ac467e15-90a4-424e-9d4b-dda9564a5b35"
        },
        {
            current: 1,
            pages: 2
        }
    ];

    this._lookupSuccess(response, data);
};


function blurAutocomplete(self) {
    if (document.activeElement === self.$input[0]) {
        self.$input.blur();
    }
}


function clickOnMenuItem(self, itemToClick, callback) {
    var $item = self.$menu.find(".ui-menu-item" + itemToClick).find("a");

    $item.mouseenter();

    var mousedown = $.Event("mousedown");
    $item.trigger(mousedown);

    if (!mousedown.isDefaultPrevented()) {
        blurAutocomplete(self);
    }

    _.defer(function () {
        $item.mouseup().click();

        _.defer(callback, self);
    });
}


function searchAndClick(self, itemToClick, callback) {
    self.$input.val("Foo").keydown();

    _.delay(function () {
        self.$input.focus();

        ok(self.$menu.is(":visible"), "menu is open after search");

        clickOnMenuItem(self, itemToClick, callback);
    }, 100);
}


asyncTest("clicking on actions should not close the menu (MBS-6912)", function () {
    expect(2);

    var itemToClick = ":contains(Show more...)";

    searchAndClick(this, itemToClick, function (self) {
        ok(self.$menu.is(":visible"), "menu is still open after clicking show more");

        start();
    });
});


asyncTest("clicking on actions should not prevent the menu from ever closing (MBS-6978)", function () {
    expect(2);

    var itemToClick = ":contains(Show more...)";

    searchAndClick(this, itemToClick, function (self) {
        blurAutocomplete(self);

        _.defer(function () {
            ok(self.$menu.is(":hidden"), "menu is hidden after blurring the autocomplete");

            start();
        });
    });
});


asyncTest("multiple searches should not prevent clicks on the menu (MBS-7080)", function () {
    expect(3);

    var itemToClick = ":eq(0)";

    searchAndClick(this, itemToClick, function (self) {
        searchAndClick(self, itemToClick, function (self) {
            ok(self.$menu.is(":hidden"), "menu is hidden after selecting item");

            start();
        });
    });
});
