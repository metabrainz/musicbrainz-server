%# vi: set ts=2 sw=2 ft=mason :
<%args>
$dbh => undef
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
<%def .SortUnique>
<%perl>
	my %t = map { $_=>1 } @_;
	return sort { $a <=> $b } keys %t;
</%perl>
</%def>
<%def .SetClause>
<%perl>

	# Given an expression (e.g. "m.status"), a list of selected values (e.g.
	# [1,2]) and a list of all possible values (e.g. [1,2,3,4,5,6,7,8]),
	# return a WHERE clause which efficiently filters the data.

	my ($expr, $selected_values, $all_values) = @_;

	# Find the values we /don't/ want
	my $discard_values = do {
		my %all = map { $_ => 1 } @$all_values;
		delete @all{@$selected_values};
		[ $m->comp(".SortUnique", keys %all) ];
	};

	# If all or none selected, do nothing
	return () unless @$selected_values;
	return () unless @$discard_values;
	
	# If only one selected/discarded, use "=" or "!="
	return "$expr = $selected_values->[0]"
		if @$selected_values == 1;
	return "$expr != $discard_values->[0]"
		if @$discard_values == 1;
	
	# If the selected values are all above or below some threshold, then
	# use "<" or ">"
	require List::Util;

	my $max_sel = List::Util::max(@$selected_values);
	my $min_disc = List::Util::min(@$discard_values);
	return "$expr < $min_disc"
		if $max_sel < $min_disc;

	my $min_sel = List::Util::min(@$selected_values);
	my $max_disc = List::Util::max(@$discard_values);
	return "$expr > $max_disc"
		if $min_sel > $max_disc;

	# If the selected values are within or without of some range, then use
	# BETWEEN or NOT BETWEEN.
	# TODO

	# Otherwise, use "IN" or "NOT IN", whichever gives the shorter list.
	local $" = ",";
	return(
		(@$selected_values <= @$discard_values)
			? "$expr IN (@$selected_values)"
			: "$expr NOT IN (@$discard_values)"
	);
</%perl>
</%def>
<%perl>

$dbh ||= $m->comp("/comp/dblogin")->{DBH};

################################################################################
# Parse and validate %ARGS.  Return the constructed query string, the current
# voter ID, and a sanitised form of the arguments.
################################################################################

my %filter;
my @where;
my @errors;

################################################################################
# mod_status - multi-select of STATUS_* constants
################################################################################

my %allowed_status = reverse %{ &ModDefs::status_as_hashref };
@mod_status = grep { exists $allowed_status{$_} } @mod_status;
@mod_status = $m->comp(".SortUnique", @mod_status);
$filter{"mod_status"} = \@mod_status;

push @where, $m->comp(
	".SetClause",
	"m.status",
	\@mod_status,
	[keys %allowed_status],
);

# Find out whether we're using the _open tables, the _closed ones, or _all.
my $table_suffix = "all";
my $open_opt;
if (@mod_status)
{
	my $need_open = 0;
	my $need_closed = 0;

	for (@mod_status)
	{
		$need_open = 1, next
			if $_ == &ModDefs::STATUS_OPEN
			or $_ == &ModDefs::STATUS_TOBEDELETED;
		$need_closed = 1;
	}

	$table_suffix = ($need_open
		? $need_closed ? "all" : "open"
		: "closed"
	);
	$open_opt = ($need_open
		? $need_closed ? undef : 1
		: 0
	);
}

################################################################################
# mod_type - multi-select of MOD_* constants
################################################################################

my %allowed_type = reverse %{ &ModDefs::type_as_hashref };
@mod_type = grep { exists $allowed_type{$_} } @mod_type;
@mod_type = $m->comp(".SortUnique", @mod_type);
$filter{"mod_type"} = \@mod_type;

push @where, $m->comp(
	".SetClause",
	"m.type",
	\@mod_type,
	[keys %allowed_type],
);

# Silly Vim hack:
</%perl>
<%perl>

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
	my $user = UserStuff->new($dbh);
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
@vote_cast = $m->comp(".SortUnique", @vote_cast);
$filter{"vote_cast"} = \@vote_cast;

# Filtering matrix:
# ("no vote" == VOTE_NOTVOTED; "real" votes are YES, NO, ABS)

# real | "no vote" false              "no vote" true
# none : no filter required          left join, vote is null
# some : inner join with SetClause   left join, (vote is null or SetClause)
# all  : inner join                  no filter required

if (@vote_cast > 0 and @vote_cast < keys(%allowed_votes))
{
	# We've now filtered out the two "no filter required" combinations

	my @real = grep {
		$_ == &ModDefs::VOTE_YES
		or $_ == &ModDefs::VOTE_NO
		or $_ == &ModDefs::VOTE_ABS
	} @vote_cast;

	my $all_real = (@real == 3);
	my $no_vote = grep { $_ == &ModDefs::VOTE_NOTVOTED } @vote_cast;

	# The join type depends solely on $no_vote
	my $join_type = ($no_vote ? "LEFT" : "INNER");

	# Construct the whole JOIN clause.  We may add another filter to this (see
	# below).
	$vote_join = " $join_type JOIN vote_$table_suffix v ON v.moderation = m.id"
		. " AND v.moderator = $effective_voter_id"
		. " AND NOT v.superseded";

	if (not $no_vote)
	{
		unless ($all_real)
		{
			my @where = $m->comp(
				".SetClause",
				"v.vote",
				\@real,
				[ &ModDefs::VOTE_YES, &ModDefs::VOTE_NO, &ModDefs::VOTE_ABS ],
			);
			# We're using an INNER JOIN, so this can be added to the JOIN clause
			# instead of WHERE.
			$vote_join .= " AND $_" for @where;
		}
	} else {
		my @or = "v.vote IS NULL";
		push @or, $m->comp(
			".SetClause",
			"v.vote",
			\@real,
			[ &ModDefs::VOTE_YES, &ModDefs::VOTE_NO, &ModDefs::VOTE_ABS ],
		) unless $all_real;
		# This one's a left join, so we add it to the WHERE clause not the JOIN.
		push @where, "(" . join(" OR ", @or) . ")";
	}

	$vote = ", COALESCE(v.vote, ".&ModDefs::VOTE_NOTVOTED.") AS vote";
}

# Silly Vim hack:
</%perl>
<%perl>

################################################################################
# moderator_type / moderator_id
################################################################################

$moderator_type = 0
	unless $moderator_type =~ /^[0123456]$/;

if (MusicBrainz::IsNonNegInteger($moderator_id) and $moderator_id)
{
	# Validate id and get name
	my $user = UserStuff->new($dbh);
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
	unless $artist_type =~ /^[012345]$/;

if (MusicBrainz::IsNonNegInteger($artist_id) and $artist_id)
{
	# Validate id and get name
	my $ar = Artist->new($dbh);
	$ar->SetId($artist_id);

	if ($ar->LoadFromId)
	{
		$artist_id = $ar->GetId;
		$filter{"artist_name"} = $ar->GetName;
	} else {
		$artist_type = 0
			if $artist_type == 3
			or $artist_type == 5;
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
	$subs_join = " INNER JOIN artist_relation s"
		. " ON s.artist = m.artist AND s.ref = $artist_id"
		if $artist_type == 5;
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

# Silly Vim hack:
</%perl>
<%perl>

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

for my $t (
	[ \$minid, "minid" ],
	[ \$maxid, "maxid" ],
) {
	my ($ref, $key) = @$t;

	MusicBrainz::TrimInPlace($$ref);
	if ($$ref eq "")
	{
		$filter{$key} = undef;
		next;
	}

	if (MusicBrainz::IsNonNegInteger($$ref))
	{
		$filter{$key} = $$ref;
		next;
	}

	my $time = MusicBrainz::Server::DateTime::parse_datetime(
		{ PREFER_PAST => 1 },
		$$ref,
	);

	if (not defined $time)
	{
		push @errors, "Couldn't understand the date/time '$$ref'";
		next;
	}

	my $modid = Moderation->iFindByTime($dbh, $time, 'open' => $open_opt);
	$filter{$key} = $$ref;
	$$ref = $modid;
}

($minid, $maxid, $filter{"minid"}, $filter{"maxid"})
	= ($maxid, $minid, $filter{"maxid"}, $filter{"minid"})
	if $minid ne "" and $maxid ne ""
	and $minid > $maxid;

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
	. " FROM moderation_$table_suffix m" . $vote_join . $subs_join;
$query .= " WHERE " . join(" AND ", @where) if @where;
$query .= " ORDER BY m.id ".uc($orderby);

# Is this the default result?
# If so, refuse to run - you've got to filter on /something/.
unless ($ARGS{DEFAULT_TEST})
{
	my ($defquery) = $m->comp("setquery.inc", DEFAULT_TEST=>1, dbh => $dbh);
	$query = undef if $query eq $defquery;
}

return ($query, $effective_voter_id, \%filter, \@errors);

</%perl>
