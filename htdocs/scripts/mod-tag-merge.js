function check_merge_form(f)
{
	var attributes = get_radio_value(f, "merge_attributes");
	var langscript = get_radio_value(f, "merge_langscript");

	if (attributes != null && langscript != null) return true;
	var msg = "You must choose how to handle "
		+ (
			(attributes == null && langscript == null)
			? "album attributes, language and script"
			: (attributes == null)
			? "album attributes"
			: "album language and script"
		)
		;
	alert(msg);
	return false;
}
