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
	# Artist (ax)
	#   |-- Search artist name (0|1) (on by default)
	#   |-- Search artist sortname (0|1) (on by default)
	#   \-- Search artist alias' (0|1) (off by default)
	# Release (rx)
	#	none yet
	# Track (tx)
	#	none yet

	$an => undef	# Artist Name
	$as => undef	# Artist Sortname
	$aa => undef	# Artist Alias


</%args>
<%perl>

	# make sure we got a valid type parameter
	!MusicBrainz::Server::Validation::IsSingleLineString($type) and $type
		and return $m->comp("/comp/layout/badarguments",
			text => "The argument <strong>type</strong> is missing or has a wrong format.");

	# make sure we got a valid query parameter
	!MusicBrainz::Server::Validation::IsSingleLineString($query) and $query
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
		# fill in arguments into session variables
		$session{"as_query"} = (defined $query ? $query : "");
		$session{"as_limit"} = (defined $limit ? $limit : 25);
		$session{"as_type"} = (defined $type ? $type : "");
		$session{"as_dur"} = (defined $dur ? $dur : 0);

		if ($submitvalue =~ /Reset/i)
		{
			$session{"as_an"} = 1;
			$session{"as_as"} = 1;
			$session{"as_aa"} = 0;

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
				$session{"as_an"} = (defined $an ? 1 : 0);
				$session{"as_as"} = (defined $as ? 1 : 0);
				$session{"as_aa"} = (defined $aa ? 1 : 0);
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
