function MoveFocus(formname, fieldname, fieldindex)
{
	var f = document.forms[formname];
	if (!f) return;

	f = f[fieldname];
	if (!f) return;

	if (fieldindex != null)
	{
		f = f[fieldindex];
		if (!f) return;
	}

	if (f.focus) f.focus();

	var t = f.type;

	if (t != null)
	{
		t = t.toLowerCase();

		if (t == 'text' || t == 'file')
		{
			if (f.select) f.select();
		}
	}
}
