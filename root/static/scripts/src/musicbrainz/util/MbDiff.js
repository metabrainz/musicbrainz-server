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
 * Adapted from: Javascript Diff Algorithm - by John Resig (http://ejohn.org/)
 * http://ejohn.org/projects/javascript-diff-algorithm/
 *
 **/
function MbDiff() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ----------------------------------------------------------------------------
	this.CN = "MbDiff";
	this.GID = "mb.diff";
	mb.log.enter(this.CN, "__constructor");

	/**
	 * Escape html.
 	 */
	this.escape = function(s) {
		mb.log.enter(this.GID, "escape");
		var n = (s || "");
		n = n.replace(/&/g, "&amp;");
		n = n.replace(/</g, "&lt;");
		n = n.replace(/>/g, "&gt;");
		n = n.replace(/"/g, "&quot;");
		mb.log.exit();
		return n;
	};

	/**
	 * Diff where changes are shown inline (e.g. in the same string)
	 */
	this.diffStringInline = function(o, n) {
		mb.log.enter(this.GID, "diffStringInline");
		o = o.replace(/\s+$/, '');
		n = n.replace(/\s+$/, '');

		var out = this.diff(o == "" ? [] : o.split(/\s+/), n == "" ? [] : n.split(/\s+/) );
		var str = "";
		var oSpace = o.match(/\s+/g);
		if (oSpace == null) {
			oSpace = ["\n"];
		} else {
			oSpace.push("\n");
		}
		var nSpace = n.match(/\s+/g);
		if (nSpace == null) {
			nSpace = ["\n"];
		} else {
			nSpace.push("\n");
		}
		var i;
		if (out.n.length == 0) {
			for (i = 0; i < out.o.length; i++) {
				str += '<del>' + this.escape(out.o[i]) + oSpace[i] + "</del>";
			}
		} else {
			if (out.n[0].text == null) {
				for (n = 0; n < out.o.length && out.o[n].text == null; n++) {
					str += '<del>' + this.escape(out.o[n]) + oSpace[n] + "</del>";
				}
			}
			for (i = 0; i < out.n.length; i++) {
				if (out.n[i].text == null) {
					str += '<ins>' + this.escape(out.n[i]) + nSpace[i] + "</ins>";
				} else {
					var pre = "";

					for (n = out.n[i].row + 1; n < out.o.length && out.o[n].text == null; n++) {
						pre += '<del>' + this.escape(out.o[n]) + oSpace[n] + "</del>";
					}
					str += " " + out.n[i].text + nSpace[i] + pre;
				}
			}
		}
		mb.log.exit();
		return str;
	};

	/**
	 * Diff where changes are returned as an array of
	 * original, new string
	 */
	this.diffStringSeparate = function(o, n) {
		mb.log.enter(this.GID, "diffStringSeparate");
		o = o.replace(/\s+$/, '');
		n = n.replace(/\s+$/, '');
		var out = this.diff(o == "" ? [] : o.split(/\s+/), n == "" ? [] : n.split(/\s+/) );
		var oSpace = o.match(/\s+/g);
		if (oSpace == null) {
			oSpace = ["\n"];
		} else {
			oSpace.push("\n");
		}
		var nSpace = n.match(/\s+/g);
		if (nSpace == null) {
			nSpace = ["\n"];
		} else {
			nSpace.push("\n");
		}
		var os = [];
		var i;
		for (i = 0; i < out.o.length; i++) {
			if (out.o[i].text != null) {
				os.push('<span class="text">');
				os.push(out.o[i].text);
				os.push('</span>');
				os.push(oSpace[i]);
			} else {
				os.push('<span class="del">');
				os.push(out.o[i]);
				os.push("</span>");
				os.push(oSpace[i]);
			}
		}
		var ns = [];
		for (i = 0; i < out.n.length; i++) {
			if (out.n[i].text != null) {
				ns.push('<span class="text">');
				ns.push(out.n[i].text);
				ns.push('</span>');
				ns.push(nSpace[i]);
			} else {
				ns.push('<span class="ins">');
				ns.push(out.n[i]);
				ns.push("</span>");
				ns.push(nSpace[i]);
			}
		}
		mb.log.exit();
		return { o : os.join("") , n : ns.join("") };
	};

	/**
	 * Perform the diffing
	 */
	this.diff = function(o, n) {
		mb.log.enter(this.GID, "diff");
		var ns = new Object();
		var os = new Object();
		var i;
		for (i = 0; i < n.length; i++) {
			if (ns[n[i]] == null) {
				ns[n[i]] = { rows: new Array(), o: null };
			}
			ns[n[i]].rows.push(i);
		}
		for (i = 0; i < o.length; i++) {
			if (os[o[i]] == null) {
				os[o[i]] = { rows: new Array(), n: null };
			}
			os[o[i]].rows.push(i);
		}
		for (i in ns) {
			if (ns[i].rows.length == 1 && typeof(os[i]) != "undefined" && os[i].rows.length == 1) {
				n[ns[i].rows[0]] = { text: n[ns[i].rows[0]], row: os[i].rows[0] };
				o[os[i].rows[0]] = { text: o[os[i].rows[0]], row: ns[i].rows[0] };
			}
		}
		for (i = 0; i < n.length - 1; i++) {
			if ((n[i].text != null) &&
				(n[i+1].text == null) &&
				(n[i].row + 1 < o.length) &&
				(o[n[i].row + 1].text == null) &&
				(n[i+1] == o[n[i].row + 1])) {
				n[i+1] = { text: n[i+1], row: n[i].row + 1 };
				o[n[i].row+1] = { text: o[n[i].row+1], row: i + 1 };
			}
		}
		for (i = n.length - 1; i > 0; i--) {
			if ((n[i].text != null) &&
				(n[i-1].text == null) &&
				(n[i].row > 0) &&
				(o[n[i].row - 1].text == null) &&
				(n[i-1] == o[n[i].row - 1])) {
				n[i-1] = { text: n[i-1], row: n[i].row - 1 };
				o[n[i].row-1] = { text: o[n[i].row-1], row: i - 1 };
			}
		}
		mb.log.exit();
		return { o: o, n: n };
	};

	/**
	 * Search for <td> in the page that satisfy the
	 * prerequisites for diffing, see if there is an
	 * old+new value and perform the diff. replaces
	 * the original text in the respective <td>.
	 *
	 **/
	this.runDiff = function() {
		mb.log.enter(this.GID, "runDiff");

		// diff is enabled per default, turn it off
		// if showedit config says so.
		var enabled = true;
		if (window.showedit != undefined && !showedit.isDiffEnabled()) {
			enabled = false;
		}
		if (enabled) {
			var list = mb.ui.getByTag("td");
			var fields = [];
			var i,obj, id, name, ids = [];
			for (i=0; i<list.length; i++) {
				obj = list[i];
				id = (obj.id || "");
				if (id.match(/^(nv\::(album|release|track|edit.*|artist.*|label.*)\d+|ov\::(album|release|track|edit.*|artist.*|label.*)\d+)/i)) {
					var c = id.split("::");
					if (c.length == 2) {
						mb.log.info("Found diffable element: $", id);
						var which = c[0];
						var name = c[1];
						if (!fields[name]) {
							fields[name] = { ov: null, nv: null};
							ids.push(name);
						}
						fields[name][which] = obj;
					} else {
						mb.log.error(c);
					}
				}
			}
			mb.log.info("ids: $", ids);
			for (i=0; i<ids.length; i++) {
				id = ids[i];
				if ((obj = fields[id]) != null) {
					if (obj.ov && obj.nv) {
						mb.log.info("id: $, ov: $, nv: $", id, obj.ov, obj.nv);
						var ov = (obj.ov.innerHTML || "").replace("&nbsp;", " ");
						var nv = (obj.nv.innerHTML || "").replace("&nbsp;", " ");
						var out = this.diffStringSeparate(ov, nv);

						obj.ov.innerHTML = out.o.replace(/not_set/gi, "Not set");
						obj.nv.innerHTML = out.n.replace(/not_set/gi, "Not set");
					} else {
						mb.log.warning("Obj does not define ov: $, nv: $", obj.ov || "", obj.nv || "");
					}
				} else {
					mb.log.warning("No element with id: $ found", id);
				}
			}
		}
		mb.log.exit();
	};

	// exit constructor
	mb.log.exit();
}

