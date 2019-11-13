// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';

// Supports loading a component template from a <script type="text/html">
ko.components.loaders.unshift({
    loadTemplate: function (componentName, templateConfig, callback) {
        callback(
            templateConfig.fromScript ? ko.utils.parseHtmlFragment(
                document.getElementById(templateConfig.fromScript).innerHTML,
            ) : null,
        );
    },
});


// See http://knockoutjs.com/documentation/custom-bindings-disposal.html
// We don't need external data cleaned, so this just slows things down.
ko.utils.domNodeDisposal.cleanExternalData = function () {};


// By default, knockout limits the number of items it'll loop through before
// giving up finding any moves in an arrayChange sequence, presumably to
// limit its polynomial time complexity in the case of really large arrays.
// But the loop bindingHandler which we use depends on moves always being
// detected, so we must disable this limit by passing a falsy value as the
// third argument.
ko.utils.__findMovesInArrayComparison = ko.utils.findMovesInArrayComparison;

ko.utils.findMovesInArrayComparison = function (left, right) {
    ko.utils.__findMovesInArrayComparison(left, right, false);
};
