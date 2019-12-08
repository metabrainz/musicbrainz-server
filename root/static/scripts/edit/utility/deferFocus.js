/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import _ from 'lodash';

function deferFocus() {
    var selectorArguments = arguments;
    _.defer(function () {
 $.apply(null, selectorArguments).focus() 
});
}

export default deferFocus;
