/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
|-----------------------------------------------------------------------------|
| This software is provided "as is", without warranty of any kind, express or |
| implied, including  but not limited  to the warranties of  merchantability, |
| fitness for a particular purpose and noninfringement. In no event shall the |
| authors or  copyright  holders be  liable for any claim,  damages or  other |
| liability, whether  in an  action of  contract, tort  or otherwise, arising |
| from,  out of  or in  connection with  the software or  the  use  or  other |
| dealings in the software.                                                   |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt |
| Permits anyone the right to use and modify the software without limitations |
| as long as proper  credits are given  and the original  and modified source |
| code are included. Requires  that the final product, software derivate from |
| the original  source or any  software  utilizing a GPL  component, such  as |
| this, is also licensed under the GPL license.                               |
|                                                                             |
| $Id$
\----------------------------------------------------------------------------*/

// setup onDomReady for internet exploder
mb.log.scopeStart("Registering DOMContentLoaded callback...");
mb.log.enter("domloaded.js", "__init");

if (document.readyState) {
	mb.log.trace("IE » using document.readyState");
	var s = document.readyState;
	var READYSTATE_INTERACTIVE = "interactive"
	var READYSTATE_COMPLETE = "complete";
	if (s == READYSTATE_INTERACTIVE || s == READYSTATE_COMPLETE) {
		mb.onDomReady();
	} else {
		document.onreadystatechange = function() {
			if (document.readyState == READYSTATE_INTERACTIVE) {
				mb.onDomReady();
			}
		};
	}
}

// for mozilla browser, register DOM loaded event
if (document.addEventListener) {
	document.addEventListener("DOMContentLoaded", mb.onDomReady, null);
	mb.log.trace("Gecko » using document.addEventListener");
}
mb.log.exit();
