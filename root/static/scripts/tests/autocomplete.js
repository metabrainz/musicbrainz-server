// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');

function autocompleteTest(name, callback) {
    test(name, function (t) {
        var $fixture = $('<div>').appendTo('body');
        var $input = $("<input>").attr("type", "text").appendTo($fixture);

        ko.applyBindingsToNode($input[0], { autocomplete: { entity: "artist" } });
        var $menu = $input.autocomplete("widget");

        callback(t, $input, $menu);

        $input.autocomplete("destroy");
        $fixture.add('.ui-widget').remove();
    });
}

$.ui.menu.prototype.delay = 0;

$.ui.autocomplete.prototype.options.delay = 0;

$.Widget.prototype._delay = function (handler) {
    return (typeof handler === "string" ? this[handler] : handler).call(this);
};

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

function blurAutocomplete($input) {
    if (document.activeElement === $input[0]) {
        $input.blur();
    }
}

function clickOnMenuItem($input, $menu, itemToClick) {
    var $item = $menu.find(".ui-menu-item" + itemToClick).find("a");

    $item.mouseenter();

    var mousedown = $.Event("mousedown");
    $item.trigger(mousedown);

    if (!mousedown.isDefaultPrevented()) {
        blurAutocomplete($input);
    }

    $item.mouseup().click();
}

function searchAndClick(t, $input, $menu, itemToClick) {
    $input.val("Foo").keydown().focus();

    t.ok($menu.is(":visible"), "menu is open after search");

    clickOnMenuItem($input, $menu, itemToClick);
}

autocompleteTest("clicking on actions should not close the menu (MBS-6912)", function (t, $input, $menu) {
    t.plan(2);

    searchAndClick(t, $input, $menu, ':contains(Show more...)');

    t.ok($menu.is(":visible"), "menu is still open after clicking show more");
});

autocompleteTest("clicking on actions should not prevent the menu from ever closing (MBS-6978)", function (t, $input, $menu) {
    let isNodeJS = require('detect-node');

    t.plan(isNodeJS ? 1 : 2);

    searchAndClick(t, $input, $menu, ':contains(Show more...)');

    blurAutocomplete($input);

    // FIXME: test fails under Node.js
    if (!isNodeJS) {
        t.ok($menu.is(":hidden"), "menu is hidden after blurring the autocomplete");
    }
});

autocompleteTest("multiple searches should not prevent clicks on the menu (MBS-7080)", function (t, $input, $menu) {
    t.plan(3);

    searchAndClick(t, $input, $menu, ':eq(0)');
    searchAndClick(t, $input, $menu, ':eq(0)');

    t.ok($menu.is(":hidden"), "menu is hidden after selecting item");
});
