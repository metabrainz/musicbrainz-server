// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt


// Supports loading a component template from a <script type="text/html">
ko.components.loaders.unshift({
    loadTemplate: function (componentName, templateConfig, callback) {
        callback(
            templateConfig.fromScript ? ko.utils.parseHtmlFragment(
                document.getElementById(templateConfig.fromScript).innerHTML
            ) : null
        );
    }
});


// See http://knockoutjs.com/documentation/custom-bindings-disposal.html
// We don't need external data cleaned, so this just slows things down.
ko.utils.domNodeDisposal.cleanExternalData = function () {};


// The default ko.postbox behavior converts objects to JSON and then compares
// them, but this causes it to do a strict equals comparison instead.
ko.postbox.serializer = _.identity;
