%# vi: set ts=2 sw=2 ft=mason :
<%args>
# These ones are multi-select, so declare them as lists so we don't
# have to do: ref($foo) ? @$foo : $foo
@mod_status => ()
@mod_type => ()
@vote_cast => ()
# All the others are single-value, so using $ARGS{key} is OK
$voter_type => 0
$voter_id => $session{uid}
$moderator_type => 0
$moderator_id => $session{uid}
$artist_type => 0
$artist_id => 0
$object_type => 0
$object_id => 0
$automod => ""
$minid => ""
$maxid => ""
$orderby => "asc"
</%args>
<%perl>

my $mb = $m->comp("/comp/dblogin");

################################################################################
# Parse and validate %ARGS.  Return the constructed query string, the current
# voter ID, and a sanitised form of the arguments.
################################################################################

my %filter;
my @where;

my $sortuniq = sub {
	my %t = map { $_=>1 } @_;
	sort { $a <=> $b } keys %t;
};

################################################################################
# mod_status - multi-select of STATUS_* constants
################################################################################

my %allowed_status = reverse %{ &ModDefs::status_as_hashref };
@mod_status = grep { exists $allowed_status{$_} } @mod_status;
@mod_status = &$sortuniq(@mod_status);
$filter{"mod_status"} = \@mod_status;

if (@mod_status)
{
	push @where, "m.status = $mod_status[0]"
		if @mod_status == 1;
	local $" = ",";
	push @where, "m.status IN (@mod_status)"
		if @mod_status > 1;
	
	# If we are specifically querying for STATUS_OPEN only, optimise using
	# ->GetMinOpenModID.
	if (@mod_status == 1 and $mod_status[0] == &ModDefs::STATUS_OPEN)
	{
		my $mod = Moderation->new($mb->{DBH});
		push @where, "m.id >= " . $mod->GetMinOpenModID;
	}
}

################################################################################
# mod_type - multi-select of MOD_* constants
################################################################################

my %allowed_type = reverse %{ &ModDefs::type_as_hashref };
@mod_type = grep { exists $allowed_type{$_} } @mod_type;
@mod_type = &$sortuniq(@mod_type);
$filter{"mod_type"} = \@mod_type;

if (@mod_type)
{
	push @where, "m.type = $mod_type[0]"
		if @mod_type == 1;
	local $" = ",";
	push @where, "m.type IN (@mod_type)"
		if @mod_type > 1;
}

################################################################################
# voter_type / voter_id
################################################################################

my $vote = ", " . &ModDefs::VOTE_UNKNOWN . " AS vote";
my $vote_join = "";
my $subs_join = "";

$voter_type = 0
	unless $voter_type =~ /^[01]$/;

if (MusicBrainz::IsNonNegInteger($voter_id) and $voter_id)
{
	# Validate id and get name
	my $user = UserStuff->new($mb->{DBH});
	$user = $user->newFromId($voter_id);

	if ($user)
	{
		$voter_id = $user->GetId;
		$filter{"voter_name"} = $user->GetName;
	} else {
		$voter_type = 0;
	}
}

$filter{"voter_type"} = $voter_type;
$filter{"voter_id"} = $voter_id;

my $effective_voter_id = $session{uid};
$effective_voter_id = $voter_id
	if $voter_type == 1;

# Silly Vim hack:
</%perl>
<%perl>

################################################################################
# vote_cast - multi-select of VOTE_* constants (excluding VOTE_UNKNOWN)
################################################################################

my %allowed_votes = reverse %{ &ModDefs::vote_as_hashref };
delete $allowed_votes{&ModDefs::VOTE_UNKNOWN};
@vote_cast = grep { exists $allowed_votes{$_} } @vote_cast;
@vote_cast = &$sortuniq(@vote_cast);
$filter{"vote_cast"} = \@vote_cast;

if (@vote_cast)
{
	my @real = grep {
		$_ == &ModDefs::VOTE_YES
		or $_ == &ModDefs::VOTE_NO
		or $_ == &ModDefs::VOTE_ABS
	} @vote_cast;

	my @or;
	my $join_type = "INNER";

	if (grep { $_ == &ModDefs::VOTE_NOTVOTED } @vote_cast)
	{
		push @or, "v.vote IS NULL";
		$join_type = "LEFT";
	}

	if (@real)
	{
		local $" = ",";
		my %real = map { $_=>1 } @real;
		push @or, "v.vote IN (@real)"
			unless $real{&ModDefs::VOTE_YES}
			and $real{&ModDefs::VOTE_NO}
			and $real{&ModDefs::VOTE_ABS};
	}

	my $or = (@or==1 ? $or[0] : join(" OR ", @or));
	$vote_join = " $join_type JOIN votes v ON v.rowid = m.id"
		. " AND v.uid = $effective_voter_id"
		. " AND (v.superseded IS NULL OR NOT v.superseded)";
	$vote_join .= " AND $or" if $or;
	$vote = ", COALESCE(v.vote, ".&ModDefs::VOTE_NOTVOTED.") AS vote";
}

################################################################################
# moderator_type / moderator_id
################################################################################

$moderator_type = 0
	unless $moderator_type =~ /^[0123456]$/;

if (MusicBrainz::IsNonNegInteger($moderator_id) and $moderator_id)
{
	# Validate id and get name
	my $user = UserStuff->new($mb->{DBH});
	$user = $user->newFromId($moderator_id);

	if ($user)
	{
		$moderator_id = $user->GetId;
		$filter{"moderator_name"} = $user->GetName;
	} else {
		$moderator_type = 0
			if $moderator_type == 3;
	}
}

$filter{"moderator_type"} = $moderator_type;
$filter{"moderator_id"} = $moderator_id;

if ($moderator_type)
{
	push @where, "m.moderator = ".&ModDefs::FREEDB_MODERATOR
		if $moderator_type == 1;
	push @where, "m.moderator != ".&ModDefs::FREEDB_MODERATOR
		if $moderator_type == 2 or $moderator_type == 6;
	push @where, "m.moderator = $moderator_id"
		if $moderator_type == 3 and $moderator_id;
	push @where, "m.moderator = $session{uid}"
		if $moderator_type == 4;
	push @where, "m.moderator != $session{uid}"
		if $moderator_type == 5 or $moderator_type == 6;
}

# Silly Vim hack:
</%perl>
<%perl>

################################################################################
# artist_type / artist_id
################################################################################

$artist_type = 0
	unless $artist_type =~ /^[01234]$/;

if (MusicBrainz::IsNonNegInteger($artist_id) and $artist_id)
{
	# Validate id and get name
	my $ar = Artist->new($mb->{DBH});
	$ar->SetId($artist_id);

	if ($ar->LoadFromId)
	{
		$artist_id = $ar->GetId;
		$filter{"artist_name"} = $ar->GetName;
	} else {
		$artist_type = 0
			if $artist_type == 3;
	}
}

$filter{"artist_type"} = $artist_type;
$filter{"artist_id"} = $artist_id;

if ($artist_type)
{
	push @where, "m.artist = ".&ModDefs::VARTIST_ID
		if $artist_type == 1;
	push @where, "m.artist != ".&ModDefs::VARTIST_ID
		if $artist_type == 2;
	push @where, "m.artist = $artist_id"
		if $artist_type == 3 and $artist_id;
	$subs_join = " INNER JOIN moderator_subscribe_artist s"
		. " ON s.artist = m.artist AND s.moderator = $session{uid}"
		if $artist_type == 4;
}

################################################################################
# object_type / object_id
################################################################################

if ($object_type =~ /^(album|track)$/ and MusicBrainz::IsNonNegInteger($object_id) and $object_id)
{
	my $l = lc $object_type;
	my $uf = ucfirst $l;

	if ($l eq "track")
	{
		push @where, "
			(
				(m.tab IN ('$l', '$uf') AND m.rowid = $object_id)
				OR
				(m.tab IN ('albumjoin', 'AlbumJoin') AND m.rowid IN
					(SELECT id FROM albumjoin WHERE track = $object_id)
					)
			)
		";
	} else {
		push @where, "m.tab IN ('$l', '$uf')";
		push @where, "m.rowid = $object_id";
	}

	$filter{"object_type"} = $l;
	$filter{"object_id"} = $object_id;
}

################################################################################
# automod
################################################################################

$automod = "" unless $automod =~ /^[01]?$/;
$filter{"automod"} = $automod;

push @where, "m.automod = $automod"
	if $automod ne "";

################################################################################
# minid, maxid
################################################################################

$minid = "" unless MusicBrainz::IsNonNegInteger($minid);
$maxid = "" unless MusicBrainz::IsNonNegInteger($maxid);

($minid, $maxid) = ($maxid, $minid)
	if $minid ne "" and $maxid ne ""
	and $minid > $maxid;

$filter{"minid"} = $minid;
$filter{"maxid"} = $maxid;

push @where, "m.id >= $minid" if $minid ne "";
push @where, "m.id <= $maxid" if $maxid ne "";

################################################################################
# orderby
################################################################################

$orderby = "asc" unless $orderby =~ /^(asc|desc)$/;
$filter{"orderby"} = $orderby;

################################################################################
# All done.  Construct the SQL, and return.
################################################################################

my $query = "SELECT m.*, NOW()>m.expiretime AS expired"
	. $vote
	. " FROM moderation m" . $vote_join . $subs_join;
$query .= " WHERE " . join(" AND ", @where) if @where;
$query .= " ORDER BY m.id ".uc($orderby);

# Is this the default result?
# If so, refuse to run - you've got to filter on /something/.
unless ($ARGS{DEFAULT_TEST})
{
	my ($defquery) = $m->comp("setquery.inc", DEFAULT_TEST=>1);
	$query = undef if $query eq $defquery;
}

return ($query, $effective_voter_id, \%filter);

</%perl>
