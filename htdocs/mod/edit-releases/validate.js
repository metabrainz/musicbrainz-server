function CheckEditReleasesForm(f)
{
	var fDateError = 0;
	var fCountryError = 0;

	for (var i=0; i<f.length; ++i)
	{
		var n = f[i].name;
		var m = n.match(/^y(-?\d+)$/);
		if (m)
		{
			var id = 1*m[1];

			var del = f["releasedel"+id].checked;
			if (del) continue;

			var y = f["y"+id].value;
			var m = f["m"+id].value;
			var d = f["d"+id].value;
			var c = f["country"+id].value;

			if (y == "" && m == "" && d == "" && !c)
				continue;

			if (y == "" || (m=="" && d != ""))
				fDateError = 1;

			if (!c) fCountryError = 1;
		}
	}

	if (fDateError && fCountryError)
	{
		alert("Each release must have a date (year, year-month, or year-month-day) and a country");
		return false;
	}

	if (fDateError)
	{
		alert("Each release must have a date: year, year-month, or year-month-day");
		return false;
	}

	if (fCountryError)
	{
		alert("Each release must have a country");
		return false;
	}

	return true;
}
