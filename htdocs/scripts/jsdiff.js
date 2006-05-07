/*
 * Javascript Diff Algorithm
 *  By John Resig (http://ejohn.org/)
 *  Modified by Chu Alan "sprite"
 *
 * More Info:
 *  http://ejohn.org/projects/javascript-diff-algorithm/
 */

	function escape(s) {
		var n = s;
		n = n.replace(/&/g, "&amp;");
		n = n.replace(/</g, "&lt;");
		n = n.replace(/>/g, "&gt;");
		n = n.replace(/"/g, "&quot;");
		return n;
	}

	function diffString( o, n) {
		o = o.replace(/\s+$/, '');
		n = n.replace(/\s+$/, '');

		var out = diff(o == "" ? [] : o.split(/\s+/), n == "" ? [] : n.split(/\s+/) );
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
				str += '<del>' + escape(out.o[i]) + oSpace[i] + "</del>";
			}
		} else {
			if (out.n[0].text == null) {
				for (n = 0; n < out.o.length && out.o[n].text == null; n++) {
					str += '<del>' + escape(out.o[n]) + oSpace[n] + "</del>";
				}
			}
			for (i = 0; i < out.n.length; i++) {
				if (out.n[i].text == null) {
					str += '<ins>' + escape(out.n[i]) + nSpace[i] + "</ins>";
				} else {
					var pre = "";

					for (n = out.n[i].row + 1; n < out.o.length && out.o[n].text == null; n++) {
						pre += '<del>' + escape(out.o[n]) + oSpace[n] + "</del>";
					}
					str += " " + out.n[i].text + nSpace[i] + pre;
				}
			}
		}
		return str;
	}

	function randomColor() {
		var r = (Math.random() * 100);
		var g = (Math.random() * 100);
		var b = (Math.random() * 100);
		return "rgb(" + r + "%, " +
						g + "%, " +
						b + "%)";
	}

	function diffString2( o, n) {
		o = o.replace(/\s+$/, '');
		n = n.replace(/\s+$/, '');

		var out = diff(o == "" ? [] : o.split(/\s+/), n == "" ? [] : n.split(/\s+/) );

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
		return { o : os.join("") , n : ns.join("") };
	}

	function diff(o, n) {
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
		return { o: o, n: n };
	}


	mb.log.scopeStart("start diffing");

	var list = mb.ui.getByTag("td");
	var fields = [];
	var i,obj, id, name, ids = [];
	for (i=0; i<list.length; i++) {
		obj = list[i];
		id = (obj.id || "");
		if (id.match(/^(nv\::(album|release|track|edit.*|artist.*)\d+|ov\::(album|release|track|edit.*|artist.*)\d+)/i)) {
			mb.log.info(id);
			var c = id.split("::");
			var s = c[0];
			id = c[1];
			if (!fields[id]) {
				fields[id] = { ov: null, nv: null};
				ids.push(id);
			}
			eval('fields["'+id+'"].'+s+' = obj');
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
				var out = diffString2(ov, nv);

				obj.ov.innerHTML = out.o.replace(/not_set/gi, "Not set");
				obj.nv.innerHTML = out.n.replace(/not_set/gi, "Not set");
			} else {
				mb.log.warning("Obj does not define ov: $, nv: $", obj.ov || "", obj.nv || "");
			}
		} else {
			mb.log.warning("No element with id: $ found", id);
		}
	}