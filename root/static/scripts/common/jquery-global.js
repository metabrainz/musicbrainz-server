/*
 * This is only intended to support legacy .tt files that still reference
 * the globals `$` or `jQuery`.
 */

import $ from 'jquery';

window.$ = $;
window.jQuery = $;
