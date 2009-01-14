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

/**
 * Load, and write the EditSuite UI to 
 * the defined element in the DOM.
 *
 * @globals es, gc	sets the global variables (es=EditSuite, gc=GuessCase)
 **/

mb.log.scopeStart("Loading the EditSuite object");
mb.log.enter("editsuite.js", "__init");
try {
	new EditSuite();
	var obj;
	if ((obj = mb.ui.get("editsuite-noscript")) != null) {
		obj.className = "";
		obj.innerHTML = es.cfg.getConfigureLinkHtml();
	}
	if ((obj = mb.ui.get("editsuite-content")) != null) {
		es.ui.writeUI(obj, null);
	}
} catch (ex) {
	mb.log.error("Error while initalising EditSuite! ex: $", (ex.message || "?"));
	mb.log.error(mb.log.getStackTrace());
	es = null;
	gc = null;
}

// exit method.
mb.log.exit();


