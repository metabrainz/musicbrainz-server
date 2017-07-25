// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const _ = require('lodash');

function deferFocus() {
    var selectorArguments = arguments;
    _.defer(function () { $.apply(null, selectorArguments).focus() });
}

module.exports = deferFocus;
