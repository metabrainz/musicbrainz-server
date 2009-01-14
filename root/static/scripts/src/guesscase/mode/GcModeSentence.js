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
 * Models the "SentenceMode" GuessCase mode.
 **/
function GcModeSentence(modes) {
	mb.log.enter("GcModeSentence", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcModeSentence";
	this.GID = "gc.mode_xx";
	this.setConfig(
		modes, 'Sentence', modes.XX,
		  'First word titled, lowercase for <i>most</i> of the other '
		+ 'words. Read the [url]description[/url] for more details.',
		  '/doc/GuessCaseMode/SentenceMode');

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------


	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------


	// exit constructor
	mb.log.exit();
}

try {
	GcModeSentence.prototype = new GcMode;
} catch (e) {
	mb.log.error("GcModeSentence: Could not register GcMode prototype");
}