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
 * Configuration Module
 *
 */
function EsConfigModule() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsConfigModule";
	this.GID = "es.cfg";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.cfg"; };
	this.getModName = function() { return "Configuration"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.CHECKBOX_VISIBLE = this.getModID()+".cb_visible";
	this.CHECKBOX_EXPANDED = this.getModID()+".cb_expanded";


	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.getModuleHtml = function() {
		var s = [];
		s.push(this.getModuleStartHtml({x: true}));
		s.push('<table cellspacing="0" cellpadding="0" class="moduletable">');
		s.push('<tr>');
		s.push('<td><b>Module</td>');
		s.push('<td rowspan="100">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>');
		s.push('<td><b>Visible</td>');
		s.push('<td rowspan="100">&nbsp;&nbsp;&nbsp;&nbsp;</td>');
		s.push('<td><b>Expanded</td>');
		s.push('<td rowspan="100">&nbsp;&nbsp;&nbsp;&nbsp;</td>');
		s.push('<td width="100%"><b>Reset</td>');
		s.push('</tr>');
		s.push('<tr class="editsuite-box-tr"><td colspan="7"/>');
		s.push('</tr>');

		// retrieve the modules
		var id,i,m,mods = es.getRegisteredModules();
		for (i=0; i<mods.length; i++) {
			if ((m = mods[i]) != es.ui && m != this) {
				id = m.getModID();
				var vis = m.isVisible();
				var exp = m.isExpanded();
				s.push('<tr><td nowrap>');
				s.push(m.getModName());
				s.push('</td><td>');
				s.push('<input type="checkbox" name="');
				s.push(this.CHECKBOX_VISIBLE);
				s.push('" ');
				s.push('id="');
				s.push(id);
				s.push('"');
				s.push(vis ? ' checked="checked" ' : ' ');
				s.push('onClick="');
				s.push(id);
				s.push('.onSetVisibleClicked(this.checked);">');
				s.push('</td><td>');
				s.push('<input type="checkbox" name="');
				s.push(this.CHECKBOX_EXPANDED);
				s.push('" ');
				s.push('id="');
				s.push(id);
				s.push('"');
				s.push(exp ? ' checked="checked" ' : ' ');
				s.push('onClick="');
				s.push(id);
				s.push('.onSetExpandedClicked(this.checked);">');
				s.push('</td><td>');
				s.push('<a href="javascript:; // reset" ');
				s.push('onClick="');
				s.push(id);
				s.push('.onResetModuleClicked(); return false;">');
				s.push('Reset</a>');
				s.push('</td></tr>');
				mb.log.trace("Mod: $, Visible: $, Expanded: $", id, vis, exp);

			}
		}
		s.push('</tr><tr class="editsuite-box-tr"><td colspan="7"/></tr>');
		s.push('<tr><td>All modules:</td><td nowrap>');
		var f = 'onSetAllVisibleClicked';
		var sep = " | ";
		id = this.getModID();
		s.push(this.getLinkHtml("Show", id, f, true, sep));
		s.push(this.getLinkHtml("Hide", id, f, false, ""));
		f = 'onSetAllExpandedClicked';
		s.push('</td><td nowrap>');
		s.push(this.getLinkHtml("Expand", id, f, true, sep));
		s.push(this.getLinkHtml("Collapse", id, f, false, ""));
		s.push('</td><td nowrap>');
		f = 'onResetAllClicked';
		s.push(this.getLinkHtml("Reset", id, f, true, ""));
		s.push('</td></tr></table>');
		s.push(this.getModuleEndHtml({x: true}));
		return s.join("");
	};

	/**
	 * Returns a javascript clickable link.
	 **/
	this.getLinkHtml = function(title, id, func, flag, sep) {
		var s = [];
		s.push('<a href="javascript:; // ');
		s.push(title);
		s.push(' All" ');
		s.push('onClick="return ');
		s.push(id);
		s.push('.');
		s.push(func);
		s.push("(");
		s.push(flag);
		s.push(');">');
		s.push(title);
		s.push('</a>');
		s.push(sep);
		return s.join("");
	};

	/**
	 * Returns the lowest part of the UI (the config link)
	 **/
	this.getConfigureLinkHtml = function() {
		var s = [];
		s.push('<div style="font-size: 10px; background-image: url(/images/es/configure.gif); background-position: bottom right; vertical-align: bottom; text-align: right; height: 19px; background-repeat: no-repeat">');
		s.push('<div style="padding-top: 2px"><img src="/images/edit.gif" border="0" alt="">');
		s.push('<a href="javascript: void(0); // Configure modules" onClick="es.cfg.onConfigureLinkClicked()">Configure</a> ');
		s.push('&nbsp;</div>');
		s.push('</div>');
		return s.join("");
	};

	/**
	 * Add/remove amount from size attribute on edit fields in the form.
	 **/
	this.onConfigureLinkClicked = function() {
		if (!this.isVisible() || !this.isExpanded()) {
			this.setVisible(true);
			this.setExpanded(true);
		} else {
			this.setExpanded(false);
			this.setVisible(false);
		}
	};

	/**
	 * Gets called by onSetAllVisibleClicked() of the modules
	 **/
	this.updateVisible = function(mod, flag) {
		mb.log.enter(this.GID, "updateVisible");
		mb.log.info("Setting module: $ visible: $", mod, flag);
		this.traverseAndCheck(this.CHECKBOX_VISIBLE, mod, flag);
		mb.log.exit();
	};

	/**
	 * Gets called by onSetExpandedClicked() of the modules
	 **/
	this.updateExpanded = function(mod, flag) {
		mb.log.enter(this.GID, "updateExpanded");
		mb.log.info("Setting module: $ expanded: $", mod, flag);
		this.traverseAndCheck(this.CHECKBOX_EXPANDED, mod, flag);
		mb.log.exit();
	};

	/**
	 * Loop through all the checkboxes given by name,
	 * and update the module mod to the given state.
	 **/
	this.traverseAndCheck = function(name, mod, flag) {
		var list;
		if ((list = mb.ui.getByName(name)) != null) {
			var len = list.length;
			for (var i=0; i<len; i++) {
				if (list[i].id == mod) {
					list[i].checked = flag;
					break;
				}
			}
		}
	};

	/**
	 * Set all modules visible|hidden
	 **/
	this.onSetAllVisibleClicked = function(flag) {
		mb.log.enter(this.GID, "onSetAllVisibleClicked");
		mb.log.debug("flag: $", flag);
		this.traverseAndClick(this.CHECKBOX_VISIBLE, flag);
		return mb.log.exit(false);
	};

	/**
	 * Set all modules expanded|collapsed
	 **/
	this.onSetAllExpandedClicked = function(flag) {
		mb.log.enter(this.GID, "onSetAllExpandedClicked");
		mb.log.debug("flag: $", flag);
		this.traverseAndClick(this.CHECKBOX_EXPANDED, flag);
		return mb.log.exit(false);
	};

	/**
	 * Loop through all the checkboxes given by name,
	 * and click on each of the items.
	 **/
	this.traverseAndClick = function(name, flag) {
		var list;
		if ((list = mb.ui.getByName(name)) != null) {
			var len = list.length;
			for (var i=0; i<list.length; i++) {
				list[i].checked = !flag;
				list[i].click();
			}
		}
	};

	/**
	 * Reset all modules.
	 **/
	this.onResetAllClicked = function(flag) {
		mb.log.enter(this.GID, "onResetAllClicked");

		var id,i,m,mods = es.getRegisteredModules();
		for (i=0; i<mods.length; i++) {
			if ((m = mods[i]) != es.ui && m != this) {
				m.resetModule();
			}
		}
		return mb.log.exit(false);
	};

	// exit constructor
	mb.log.exit();
}

// register prototype of module superclass
try {
	EsConfigModule.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("EsConfigModule: Could not register EsModuleBase prototype");
}