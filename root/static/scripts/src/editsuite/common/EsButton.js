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
 * Data model of an EditSuite button
 */
function EsButton(bid, value, tooltip, func) {
	mb.log.enter("EsButton", "__constructor");

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.bid = bid;
	this.value = value;
	this.tooltip = tooltip;
	this.func = func;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Returns the button id
	 */
	this.getID = function() {
		return this.bid;
	};

	/**
	 * Returns the button text
	 */
	this.getValue = function() {
		return this.value;
	};

	/**
	 * Returns the tooltip text
	 */
	this.getTooltip = function() {
		return this.tooltip;
	};

	/**
	 * Returns the onclick function
	 */
	this.getFunction = function() {
		return this.func;
	};

	/**
	 * Returns a string representation of this object
	 */
	this.toString = function() {
		var s = [];
		s.push("EsButton [");
		s.push("bid: '");
		s.push(this.bid);
		s.push("', value: '");
		s.push(this.value);
		s.push("', tooltip: '");
		s.push(this.tooltip);
		s.push("', func: '");
		s.push(this.func);
		s.push("']");
		return s.join("");
	}

	// exit constructor
	mb.log.exit();
}