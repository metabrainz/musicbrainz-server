/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import MB from '../common/MB';

MB.confirmNavigationFallback = function () {
  /*
   * Every major browser supports onbeforeunload expect Opera. (This says
   * Opera 12 supports it, but it doesn't, at least not <= 12.10.)
   * https://developer.mozilla.org/en-US/docs/DOM/window.onbeforeunload
   */
  if (window.onbeforeunload !== undefined) {
    return;
  }

  let prevented = false;

  /*
   * This catches the backspace key and asks the user whether they want to
   * navigate back.
   *
   * Opera < 12.10 fires both keydown and keypress events, but keypress
   * must return false. Opera >= 12.10 doesn't fire keypress for special
   * keys, so keydown must return false. Regular event listeners and/or
   * preventDefault don't work for this, they must be assigned directly
   * to document.onkeydown and document.onkeypress.
   */
  document.onkeydown = function (event) {
    if (event.keyCode == 8) {
      const node = event.srcElement || event.target;
      const tag = node.tagName.toLowerCase();
      const type = (node.type || '').toLowerCase();
      const prevent = !(
        (tag == 'input' && (type == 'text' || type == 'password')) ||
        tag == 'textarea'
      );

      if (prevent && !confirm(
        l('All of your changes will be lost if you leave this page.'),
      )) {
        prevented = true;
        return false;
      }
    }

    return undefined;
  };

  document.onkeypress = function () {
    if (prevented) {
      return (prevented = false);
    }

    return undefined;
  };
};
