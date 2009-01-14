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
 * Models a Module Configuration entity.
 **/
function EsModuleConfig(id, defaultOn, desc, helpText) {
	mb.log.enter("EsModuleConfig", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsModuleConfig";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.id = id;
	this.defaultOn = defaultOn;
	this.desc = desc;
	this.helpText = helpText;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Returns the configvalue id
	 */
	this.getID = function() {
		return this.id;
	};

	/**
	 * Returns if the configuration value is default=on
	 */
	this.isDefaultOn = function() {
		return this.defaultOn;
	};

	/**
	 * Returns the description
	 */
	this.getDescription = function() {
		return this.desc;
	};

	/**
	 * Returns the help text
	 */
	this.getHelpText = function() {
		return this.helpText;
	};

	// exit constructor
	mb.log.exit();
}