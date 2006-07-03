<%args>

	$handlearguments => 0

	# external arguments
	$query => undef
	$limit => undef
	$type => undef
	$dur => undef

	# form action
	$submitvalue => ""
	$tport => undef

	# advanced search parameters
	$as_on => 0			# Advanced search enabled (0|1)
						# |-- Artist
	$as_a0 => undef 	#   |-- Search artist name (0|1) (on by default)
	$as_a1 => undef 	#   |-- Search artist sortname (0|1) (on by default)
	$as_a2 => undef 	#   \-- Search artist alias' (0|1) (off by default)

</%args>
<%perl>

	# make sure we got a valid type parameter
	!MusicBrainz::IsSingleLineString($type) and $type
		and return $m->comp("/comp/layout/badarguments",
			text => "The argument <strong>type</strong> is missing or has a wrong format.");

	# make sure we got a valid query parameter
	!MusicBrainz::IsSingleLineString($query) and $query
		and return $m->comp("/comp/layout/badarguments",
			text => "The argument <strong>query</strong> is missing or has a wrong format.");

	# sanitize variables
	$type = lc $type;
	$limit = 25 if (defined $limit and ($limit < 0 or $limit > 100));

	# add tagger port to the session variable
	UserStuff::EnsureSessionOpen(), $session{"tport"} = $tport
	  if defined ($tport);

	if ($handlearguments or $submitvalue ne "")
	{
		# if the advanced search is shown, and the parameters were
		# not transmitted, override default values.
		$session{"as_on"} = ($as_on ? 1 : 0);

		# fill in arguments into session variables
		$session{"as_query"} = (defined $query ? $query : "");
		$session{"as_limit"} = (defined $limit ? $limit : 25);
		$session{"as_type"} = (defined $type ? $type : "");
		$session{"as_dur"} = (defined $dur ? $dur : 0);

		if ($submitvalue =~ /Reset/i)
		{
			$session{"as_on"} = 0;
			$session{"as_a0"} = 1;
			$session{"as_a1"} = 1;
			$session{"as_a2"} = 0;

			$session{"as_query"} = "";
			$session{"as_limit"} = 25;
			$session{"as_type"} = "artist";
			$session{"as_type"} = undef;
		}
		else
		{
			# if the value is transmitted, use this value (e.g. enabled).
			# if the advanced search is disabled, assume default value,
			# else if value is not submitted, 0 (checkbox unchecked)

			if ($session{"as_type"} eq "artist")
			{
				$session{"as_a0"} = (defined $as_a0 ? $as_a0 : ($as_on ? 0 : 1));
				$session{"as_a1"} = (defined $as_a1 ? $as_a1 : ($as_on ? 0 : 1));
				$session{"as_a2"} = (defined $as_a2 ? $as_a2 : ($as_on ? 0 : 0));
			}
		}
	}
	else
	{
		# fill in arguments into session variables
		$session{"as_query"} = (defined $query ? $query : "") if (not defined $session{"as_query"});
		$session{"as_limit"} = (defined $limit ? $limit : 25) if (not defined $session{"as_limit"});
		$session{"as_type"} = (defined $type ? $type : "") if (not defined $session{"as_type"});
		$session{"as_dur"} = (defined $dur ? $dur : 0) if (not defined $session{"as_dur"});
	}

</%perl>

%# vi: set ts=4 sw=4 ft=mason :
