function get_input_value(f, i)
{
	// TODO
	return null;
}

function get_radio_value(formobj, inputname)
{
	var ele = formobj.elements[inputname];

	if (ele.length)
	{
		for (var j=0; j<ele.length; ++j)
		{
			if (ele[j].checked) return ele[j].value;
		}
		return null;
	} else {
		if (ele.checked) return ele.value;
		else return null;
	}
}
