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

function ShowEdit() {
	
	// ----------------------------------------------------------------------------
	// register class/global id
	// ----------------------------------------------------------------------------
	this.CN = "ShowEdit";
	this.GID = "showedit";
	mb.log.enter(this.CN, "__constructor");
	
	// ----------------------------------------------------------------------------
	// member variables
	// ----------------------------------------------------------------------------
	this.collapseReleasesEnabled = false;
	this.diffEnabled = false;

	// ----------------------------------------------------------------------------
	// member functions
	// ----------------------------------------------------------------------------
	
	/**
	 * Returns true if the releases should be collapsed.
	 * @see collapsereleases.js
	 */
	this.isCollapseReleasesEnabled = function() {
		return this.collapseReleasesEnabled;
	};
	
	/**
	 * Returns true if the diff functionality is enabled.
	 * @see jsdiff.js
	 */
	this.isDiffEnabled = function() {
		return this.diffEnabled;
	};
	
	/**
	 * Sets the cookie to the given state of the checkbox.
	 */
	this.onSettingChanged = function(el) {
		if (el && el.checked != null) {
			var which = el.value || "";
			if (which) {
				this[which] = el.checked;
				mb.cookie.set("showedit::"+which.toLowerCase(), el.checked ? 1 : 0);
			}
		}
	};	
	
	/**
	 * Insert the javascript options into the object which has
	 * been placed somewhere on the editlist, editdetail pages.
	 *
	 */
	this.createUI = function() {
		var obj;
		if ((obj = mb.ui.get("showedit::insertjs")) != null) {
						
			var cv = mb.cookie.get("showedit::diffenabled");
			this.diffEnabled = (cv == null || cv == "1");

			cv = mb.cookie.get("showedit::collapsereleasesenabled");
			this.collapseReleasesEnabled = (cv == null || cv == "1");
						
			var s = [];
			s.push('<table class="formstyle">');
			s.push('<tr class="top">');
			s.push('<td class="label">Highlight changes:</td>');
			s.push('<td style="padding: 0px">');
			s.push('<input type="checkbox" value="diffEnabled" '+(this.diffEnabled ? 'checked="checked"' : '') +' ');
			s.push('  style="padding: 0px; margin: 0px; margin-right: 4px" ');
			s.push('  onclick="showedit.onSettingChanged(this);" ');
			s.push('/></td>');	
			s.push('<td style="padding: 0px">Use javascript to highlight changes on title edits.</td> ');
			s.push('</tr>');
			s.push('<tr class="top">');
			s.push('<td class="label" style="padding-top:0">Collapse releases:</td>');
			s.push('<td style="padding: 0px">');
			s.push('<input type="checkbox" value="collapseReleasesEnabled" '+(this.collapseReleasesEnabled ? 'checked="checked"' : '') +' ');
			s.push('  style="padding: 0px; margin: 0px; margin-right: 4px" ');
			s.push('  onclick="showedit.onSettingChanged(this);" ');
			s.push('/></td>');
			s.push('<td style="padding: 0px">Collapse release per default on <strong>add release edits</strong>');
			s.push('<br/><small>(You need to enable the "For Add Release edits, show the whole release..." <br/>option in your <a href="/prefs.html">user preferences</a> for this setting to take effect).</small></td> ');
			s.push('</tr>');
			s.push('</table>');

			obj.style.borderTop = "1px dotted #000";
			obj.style.marginTop = "5px";
			obj.style.width = "95%";
			obj.innerHTML = s.join("");
		}
	};
	
	// exit constructor
	mb.log.exit();
}


// register class...
var showedit = new ShowEdit();
mb.registerDOMReadyAction(
	new MbEventAction(showedit.GID, "createUI", "Setting up UI for edit type view enhancements")
);
