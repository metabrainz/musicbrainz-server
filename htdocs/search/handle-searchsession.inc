<%args>

	$handlearguments => 0

	# external arguments
	$query => undef
	$limit => undef
	$type => undef
	$dur => undef
	$adv => undef

	# form action
	$submitvalue => ""
	$tport => undef

</%args>
<%perl>

    # Remove tabs, which conguse IsSingleLineString
    $query =~ tr/\t/ /;

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
    $adv = 0 if ($adv != 0 and $adv != 1);

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
		$session{"as_adv"} = (defined $adv ? $adv : 0);

		if ($submitvalue =~ /Reset/i)
		{
			$session{"as_query"} = "";
			$session{"as_limit"} = 25;
			$session{"as_type"} = "artist";
			$session{"as_type"} = undef;
			$session{"as_adv"} = 0;
		}
	}
	else
	{
		# fill in arguments into session variables
		$session{"as_query"} = (defined $query ? $query : "") if (not defined $session{"as_query"});
		$session{"as_limit"} = (defined $limit ? $limit : 25) if (not defined $session{"as_limit"});
		$session{"as_type"} = (defined $type ? $type : "") if (not defined $session{"as_type"});
		$session{"as_dur"} = (defined $dur ? $dur : 0) if (not defined $session{"as_dur"});
		$session{"as_adv"} = (defined $adv ? $adv : 0) if (not defined $session{"as_adv"});
	}

</%perl>

%# vi: set ts=4 sw=4 ft=mason :
