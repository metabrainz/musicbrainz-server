
function GuessSortname(name)
{
	name = TrimSquash(name);

	// Change "A B C" to "B C, A"
	var first_space = name.indexOf(" ");
	if (first_space != -1)
		name = name.substring(first_space+1, name.length)
			+ ", "
			+ name.substring(0,first_space);

	return name;
}

function GuessCase(s) { return GuessCase2(s, false) }

function GuessCase2(string, inbrackets)
{
	string = TrimSquash(string);

	if (inbrackets == false)
	{
		if (string.match(/^[\(\[]?\s*data(\s+track)?\s*[\)\]]?$/i))
			return "[data track]";

		if (string.match(/^[\(\[]?\s*silen(t|ce)(\s+track)?\s*[\)\]]?$/i))
			return "[silence]";
	}

	// foo (...
	var m = string.match(/^([^\(\[\"]*) ([\(\[\"].*)$/);

	if (m != null)
	{
		return GuessCase2(m[1], false) + " " + GuessCase2(m[2], false);
	}

	// (bar) ...
	m = string.match(/^([\(\[\"])([^\(\[\"]*)([\)\]\"])(.*)$/);

	if (m != null)
	{
		s = m[1] + GuessCase2(m[2], true) + m[3];
		if (m[4] != "") s += " " + GuessCase2(m[4], false);
		return s;
	}

	// stuff: more stuff
	m = string.match(/^([^:]*):\s*(.*)$/);

	if (m != null)
	{
		return GuessCase2(m[1], false) + ": " + GuessCase2(m[2], false);
	}

	// normalise some punctuation and spacing
	string = string.replace(/\s*:\s*/g, ": ");
	string = string.replace(/\s*,\s*/g, ", ");

 	string = string.toLowerCase();
  	var words = string.split(" ");

   	for (var i=0; i<words.length; i++)
	{
	  	words[i] = words[i].substring(0,1).toUpperCase()
			+ words[i].substring(1, words[i].length);
	}

	string = words.join(" ");
	string = LowercaseCommonWords(string);
	string = MiscTransform(string);
	string = TrimSquash(string);

	if (inbrackets)
	{
		string = string
			// common first words of bracketed parts
			. replace(/^clean\b/i, "clean")
			. replace(/^club\b/i, "club")
			. replace(/^dance\b/i, "dance")
			. replace(/^dirty\b/i, "dirty")
			. replace(/^dis[ck]\b/i, "disc")
			. replace(/^radio\b/i, "radio")
			// common last words of bracketed parts
			. replace(/\bedit$/i, "edit")
			. replace(/\bmix$/i, "mix")
			. replace(/\bremix$/i, "remix")
			. replace(/\brmx$/i, "remix")
			. replace(/\bversion$/i, "version")
			;
	}

	return string;
}

function LowercaseCommonWords(string)
{
	return string
		. replace(/ a /gi, " a ")
		. replace(/ and /gi, " and ")
		. replace(/ an /gi, " an ")
		. replace(/ as /gi, " as ")
		. replace(/ at /gi, " at ")
		. replace(/ but /gi, " but ")
		. replace(/ by /gi, " by ")
		. replace(/ for /gi, " for ")
		. replace(/ in /gi, " in ")
		. replace(/ 'n' /gi, " 'n' ")
		. replace(/ n\' /gi, " n' ")
		. replace(/ nor /gi, " nor ")
		. replace(/ of /gi, " of ")
		. replace(/ o\' /gi, " o' ")
		. replace(/ on /gi, " on ")
		. replace(/ or /gi, " or ")
		. replace(/ the /gi, " the ")
		. replace(/ to /gi, " to ")
		;
}

function MiscTransform(string)
{
	return string
		. replace(/ (versus|vs\.|vs) /gi, " vs. ")
		. replace(/\bfeat(\.|\b|uring\b)/i, "feat.")
		;
}

function TrimSquash(s)
{
	return s
		. replace(/^\s\s*/, "")
		. replace(/\s\s*$/, "")
		. replace(/\s\s*/g, " ")
		;
}

// vi: set ts=4 sw=4 :
// eof
