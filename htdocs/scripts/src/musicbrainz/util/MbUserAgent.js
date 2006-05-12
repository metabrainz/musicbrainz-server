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
 * Parse and retrieve basic user agent facts
 *
 **/
function MbUserAgent() {
	mb.log.enter("MbUserAgent", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MbUserAgent";
	this.GID = "mb.ua";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

    var id = navigator.userAgent.toLowerCase();
    this.major = mb.utils.getInt(navigator.appVersion);
    this.minor = parseFloat(navigator.appVersion);
    this.nav = ((id.indexOf('mozilla') != -1) &&
      			 ((id.indexOf('spoofer')==-1) &&
      			  (id.indexOf('compatible') == -1)));

    this.nav2 = (this.nav && (this.major == 2));
    this.nav3 = (this.nav && (this.major == 3));
    this.nav4 = (this.nav && (this.major == 4));
	this.nav5 =	(this.nav && (this.major == 5));
	this.nav6 = (this.nav && (this.major == 5));
	this.gecko = (this.nav && (this.major >= 5));
    this.ie = (id.indexOf("msie") != -1);
    this.ie3 = (this.ie && (this.major == 2));
    this.ie4 = (this.ie && (this.major == 3));
    this.ie5 = (this.ie && (this.major == 4));
    this.opera = (id.indexOf("opera") != -1);
    this.nav4up = this.nav && (this.major >= 4);
    this.ie4up = this.ie  && (this.major >= 4);

	/* code from WebFX (http://webfx.eae.net/)
	   IE55 has a serious DOM1 bug... Patch it!
	this.ie55 = (/msie 5\.[56789]/i).test(navigator.userAgent);
	this.hasSupport = (typeof document.implementation != "undefined" &&
					   document.implementation.hasFeature("html", "1.0") || ie55);
	if (this.ie55) {
		document._getElementsByTagName = document.getElementsByTagName;
		document.getElementsByTagName = function (tn) {
			if (tn == "*") {
				return document.all;
			} else {
				return document._getElementsByTagName(tn);
			}
		};
	}
	*/

	// exit constructor
	mb.log.exit();
}