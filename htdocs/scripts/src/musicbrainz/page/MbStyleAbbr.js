/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (g0llum)               |
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
|-----------------------------------------------------------------------------|
| 2005-11-10 | First version                                                  |
\----------------------------------------------------------------------------*/

/**
 * Resize albumart if it provides naturalHeight/Width
 *
 */
function MbStyleAbbr() {
	mb.log.enter("MbStyleAbbr", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN	= "MbStyleAbbr";
	this.GID = "mb.styleabbr";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	  * Internet Explorer for Windows does not support the <abbr> element that 
	  * should be used on web pages for proper markup of abbreviations. While 
	  * you can apply cascading style sheets (CSS) on the <acronym> in IE, you 
	  * can't do the same for <abbr>. Moreover, IE displays the title attribute of 
	  * the <acronym> element as a tool tip, but ignore the <abbr>.
	  *
	  * http://www.sovavsiti.cz/css/abbr.html
	  *
	  * @param	imgRef		the amazon image to be resized.
	 **/
	this.process = function() {
		mb.log.enter(this.GID, "process");
		
		try {
			if (document.all) {
				var el = document.getElementsByTagName("body")[0];
				
				var re = /<abbr([^>]*)>([^<]*)<\/abbr>/gi;
				var oldhtml = el.innerHTML;
				var newhtml = oldhtml.replace(re, "<abbr $1><span class=\"abbr\" $1>$2</span></abbr>");
				el.innerHTML = newhtml;
			}
		} catch (ex) {
			/* we have tried at least... */
		}
	}

	// exit constructor
	mb.log.exit();
}