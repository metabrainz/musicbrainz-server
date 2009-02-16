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
| $Id: GcModeFrench.js 8023 2006-07-02 21:26:35Z keschte $
\----------------------------------------------------------------------------*/

/**
 * Models the "FrenchMode" GuessCase mode.
 **/
function GcModeFrench(modes) {
	mb.log.enter("GcModeFrench", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcModeFrench";
	this.GID = "gc.mode_fr";
	this.setConfig(
		modes, 'French', modes.FR,
		  'First word titled, lowercase for <i>most</i> of the other '
		+ 'words. Read the [url]description[/url] for more details.',
		  '/doc/GuessCaseMode/FrenchMode');

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------


	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Overide implementation in GcMode.
	 **/
	this.runFinalChecks = function(is) {
		mb.log.enter(this.GID, "runFinalChecks");

		os = is.replace(/([!\?;:]+)/gi, " $1");
		os = os.replace(/([«]+)/gi, "$1 ");
		os = os.replace(/([»]+)/gi, " $1");

		mb.log.debug('After: $', os);
		return mb.log.exit(os);
	};


	// exit constructor
	mb.log.exit();
}

try {
	GcModeFrench.prototype = new GcMode;
} catch (e) {
	mb.log.error("GcModeFrench: Could not register GcMode prototype");
}