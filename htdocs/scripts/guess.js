
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

		if (string.match(/^[\(\[]?\s*untitled(\s+track)?\s*[\)\]]?$/i))
			return "[untitled]";

		if (string.match(/^[\(\[]?\s*unknown|bonus(\s+track)?\s*[\)\]]?$/i))
			return "[unknown]";

		if (string.match(/^[\(\[]?\s*no\s+artist\s*[\)\]]?$/i))
			return "[no artist]";
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
	string = string.replace(/\s*,(?!\d)\s*/g, ", ");
	string = string.replace(/\s*\.(?!\d)\s*/g, ". ");

 	string = string.toLowerCase();
  	var words = string.split(" ");

   	for (var i=0; i<words.length; i++)
	{
	  	words[i] = words[i].substring(0,1).toUpperCase()
			+ words[i].substring(1, words[i].length);
	}

	string = words.join(" ");
	string = CapsHyphen(string);
	string = LowercaseCommonWords(string);
	string = MiscTransform(string);
	string = TrimSquash(string);

	if (inbrackets)
	{
		string = string
			// common first words of bracketed parts
			. replace(/^acoustic\b/i, "acoustic")
			. replace(/^album\b/i, "album")
			. replace(/^alternate\b/i, "alternate")
			. replace(/^bonus\b/i, "bonus")
			. replace(/^clean\b/i, "clean")
			. replace(/^club\b/i, "club")
			. replace(/^dance\b/i, "dance")
			. replace(/^dirty\b/i, "dirty")
			. replace(/^(cd|dis[ck])\b/i, "disc")
			. replace(/^extended\b/i, "extended")
			. replace(/^instrumental\b/i, "instrumental")
			. replace(/^live\b/i, "live")
			. replace(/^original\b/i, "original")
			. replace(/^radio\b/i, "radio")
			. replace(/^single\b/i, "single")
			. replace(/^take\b/i, "take")
			// common last words of bracketed parts
			. replace(/\bdemo$/i, "demo")
			. replace(/\b(cd|dis[ck])$/i, "disc")
			. replace(/\bedit$/i, "edit")
			. replace(/\bskit$/i, "skit")
			. replace(/\bmix$/i, "mix")
			. replace(/\bremix$/i, "remix")
			. replace(/\brmx$/i, "remix")
			. replace(/\btake$/i, "take")
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
		. replace(/ der /gi, " der ")
		. replace(/ und /gi, " und ")
		. replace(/ de /gi, " de ")
		. replace(/ du /gi, " du ")
		. replace(/ et /gi, " et ")
		. replace(/ la /gi, " la ")
		. replace(/ le /gi, " le ")
		. replace(/ les /gi, " les ")
		. replace(/ un /gi, " un ")
		. replace(/ une /gi, " une ")
		. replace(/ y /gi, " y ")
		. replace(/ con /gi, " con ")
		. replace(/ di /gi, " di ")
		. replace(/ da /gi, " da ")
		. replace(/ do /gi, " do ")
		. replace(/ del /gi, " del ")
		// TODO op? (opus)
		;
}

function MiscTransform(string)
{
	return string
		. replace(/ (versus|vs\.|vs) /gi, " vs. ")
		. replace(/\bfeat(\.|\b|uring\b)/i, "feat.")
		. replace(/\bft(\.|\b)/i, "feat.")
		. replace(/\bdj\b/gi, "DJ")
		. replace(/\bmc\b/gi, "MC")
		. replace(/\btv\b/gi, "TV")
		. replace(/\bmtv\b/gi, "MTV")
		. replace(/\bep\b/gi, "EP")
		. replace(/\blp\b/gi, "LP")
		. replace(/\bi\b/gi, "I") // What have the Romans ever done for us?
		. replace(/\bii\b/gi, "II")
		. replace(/\biii\b/gi, "III")
		. replace(/\biiii\b/gi, "IIII")
		. replace(/\biv\b/gi, "IV")
		. replace(/\bv\b/gi, "V")
		. replace(/\bvi\b/gi, "VI")
		. replace(/\bvii\b/gi, "VII")
		. replace(/\bviii\b/gi, "VIII")
		. replace(/\bix\b/gi, "IX")
		. replace(/\bx\b/gi, "X")
		. replace(/\bbwv\b/gi, "BWV") // Bach
		. replace(/\bymca\b/gi, "YMCA")
		. replace(/\bnyc\b/gi, "NYC")
		// TODO major/minor
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

function CapsHyphen(s)
{
	var hyphen = s.indexOf("-");
	if (hyphen != -1)
	{
		s = s.substring(0, hyphen+1)
		 + s.charAt(hyphen+1).toUpperCase()
		 + CapsHyphen(s.substring(hyphen+2, s.length));
	}
	return s;
}

// vi: set ts=4 sw=4 :
// eof
