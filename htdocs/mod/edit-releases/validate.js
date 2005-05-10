function checkEditReleasesForm(f) {
	var fDateError = 0;
	var fCountryError = 0;
	for (var i = 0; i < f.length; ++i) {
		var fieldName = f[i].name;
		if (fieldName != null) {
			var matcher = fieldName.match(/^y(-?\d+)$/);
			if (matcher) {
				var id = 1 * matcher[1];
				var del = f["releasedel" + id].checked;
				if (del) continue;
				var year = f["y" + id].value;
				var month = f["m" + id].value;
				var day = f["d" + id].value;
				var country = f["country" + id].value;
				if (year == "" && month == "" && day == "" && !country) continue;
				if (year == "" || (month == "" && day != "")) fDateError = 1;
				if (!country) fCountryError = 1;
			}
		}
	}

	if (fDateError && fCountryError) {
		alert("Each release must have a date (year, year-month, or year-month-day) and a country");
		return false;
	} else if (fDateError) {
		alert("Each release must have a date: year, year-month, or year-month-day");
		return false;
	} else if (fCountryError) {
		alert("Each release must have a country");
		return false;
	}
	return true;
}
