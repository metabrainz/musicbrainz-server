function smt(id)
{
	if (!document.getElementById) return true;

	var sub = document.getElementById(id+"sub");
	if (!sub) return true;
	var control = document.getElementById(id+"control");
	if (!control) return true;
	
	toggle(sub, true);
	toggle(control, false);
	
	return false;
}

function toggle(ele, fHide)
{
	var cn = ele.className;
	var l = cn.length;
	var p = cn.substr(0, l-1);
	var c = cn.substr(l-1, 1);

	// Hack: ideally this should do:
	// ele.className = (p + (c=="c" ? "o" : "c"));
	// but using the below also makes it work in Konq, so we may as well...

	if (c == "c")
	{
		ele.className = p + "o";
		if (fHide) ele.style.display = "block";
	} else {
		ele.className = p + "c";
		if (fHide) ele.style.display = "none";
	}
}

function togglechar(ele)
{
	ele = ele.firstChild;
	ele.nodeValue = (ele.nodeValue == "+" ? "-" : "+");
}
