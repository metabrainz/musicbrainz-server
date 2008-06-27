var obj;

if ((obj = document.getElementById("suiteTable")) != null) {
	var tr = obj.firstChild.children;
	var j=0;
	for (var i=0; i<tr.length;i++) {
		if (tr[i].tagName == "TR" && tr[i].className == "")  {
			tr[i].className = (j++ % 2 == 0 ? "even" : "odd");
		}
	}
}
if ((obj = document.getElementById("testTable")) != null) {
	var tr = obj.firstChild.children;
	var j=0;
	for (var i=0; i<tr.length;i++) {
		if (tr[i].tagName == "TR"  && tr[i].className == "")  {
			tr[i].className = (j++ % 2 == 0 ? "even" : "odd");
		}
	}
}