%# vi: set ts=2 sw=2 ft=mason :
<%perl>

my $mb = $m->comp("/comp/dblogin");

my $filter = $session{"moderation_filter"};
$filter ||= +{};

my @where;

my $mod_status = $filter->{"mod_status"} || [];
if (@$mod_status)
{
	push @where, "m.status = $mod_status->[0]"
		if @$mod_status == 1;
	local $" = ",";
	push @where, "m.status IN (@$mod_status)"
		if @$mod_status > 1;
	
	if (@$mod_status == 1 and $mod_status->[0] == &ModDefs::STATUS_OPEN)
	{
		my $mod = Moderation->new($mb->{DBH});
		push @where, "m.id >= " . $mod->GetMinOpenModID;
	}
}

my $mod_type = $filter->{"mod_type"} || [];
if (@$mod_type)
{
	push @where, "m.type = $mod_type->[0]"
		if @$mod_type == 1;
	local $" = ",";
	push @where, "m.type IN (@$mod_type)"
		if @$mod_type > 1;
}

my $vote = ", " . &ModDefs::VOTE_UNKNOWN . " AS vote";
my $vote_join = "";
my $subs_join = "";

my $voter_id = $session{uid};
$voter_id = $filter->{"voter_id"}
	if $filter->{"voter_type"} == 1;

my $vote_cast = $filter->{"vote_cast"} || [];
if (@$vote_cast)
{
	my @real = grep {
		$_ == &ModDefs::VOTE_YES
		or $_ == &ModDefs::VOTE_NO
		or $_ == &ModDefs::VOTE_ABS
	} @$vote_cast;

	my @or;
	my $join_type = "INNER";

	if (grep { $_ == &ModDefs::VOTE_NOTVOTED } @$vote_cast)
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
		. " AND v.uid = $voter_id"
		. " AND (v.superseded IS NULL OR NOT v.superseded)";
	$vote_join .= " AND $or" if $or;
	$vote = ", COALESCE(v.vote, ".&ModDefs::VOTE_NOTVOTED.") AS vote";
}

if (my $type = $filter->{"moderator_type"})
{
	push @where, "m.moderator = ".&ModDefs::FREEDB_MODERATOR
		if $type == 1;
	push @where, "m.moderator != ".&ModDefs::FREEDB_MODERATOR
		if $type == 2 or $type == 6;
	my $id;
	push @where, "m.moderator = $id"
		if $type == 3 and $id = $filter->{'moderator_id'};
	push @where, "m.moderator = $session{uid}"
		if $type == 4;
	push @where, "m.moderator != $session{uid}"
		if $type == 5 or $type == 6;
}

if (my $type = $filter->{"artist_type"})
{
	push @where, "m.artist = ".&ModDefs::VARTIST_ID
		if $type == 1;
	push @where, "m.artist != ".&ModDefs::VARTIST_ID
		if $type == 2;
	my $id;
	push @where, "m.artist = $id"
		if $type == 3 and $id = $filter->{'artist_id'};
	$subs_join = " INNER JOIN moderator_subscribe_artist s"
		. " ON s.artist = m.artist AND s.moderator = $session{uid}"
		if $type == 4;
}

my $am = $filter->{"automod"};
push @where, "m.automod = $am"
	if $am ne "";

push @where, "m.id >= $filter->{'minid'}"
	if $filter->{'minid'};
push @where, "m.id <= $filter->{'maxid'}"
	if $filter->{'maxid'};

my $orderby = $filter->{"orderby"} || "asc";

my $query = "SELECT m.*, NOW()>m.expiretime AS expired"
	. $vote
	. " FROM moderation m" . $vote_join . $subs_join;
$query .= " WHERE " . join(" AND ", @where) if @where;
$query .= " ORDER BY m.id ".uc($orderby);

$session{"moderation_sql"} = $query;
$session{"moderation_voter_id"} = $voter_id;

#$m->out($query);
#$m->abort;

$m->comp("/comp/redirect", "/moderate.html?type=".&ModDefs::TYPE_SEARCH);

</%perl>
