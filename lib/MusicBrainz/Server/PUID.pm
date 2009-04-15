package MusicBrainz::Server::PUID;
use Moose;

extends 'TableBase';

use Carp;
use DBDefs;
use MusicBrainz::Server::Track;

has 'puid' => (
    is  => 'rw',
    isa => 'Str',
);

has 'lookup_count' => (
    isa => 'Int',
    is  => 'ro',
);

has 'use_count' => (
    isa => 'Int',
    is  => 'ro'
);

has 'version' => (
    isa => 'Int',
    is  => 'ro'
);

has 'join_id' => (
    isa => 'Int',
    is  => 'ro'
);

sub tracks
{
 	my ($self, %opts) = @_;
	my $sql = Sql->new($self->dbh);

	my $rows = $sql->SelectListOfHashes(qq|
	    SELECT puidjoin.track AS id, puidjoin.id AS join_id
          FROM puid, puidjoin
         WHERE puid.puid = ? AND puidjoin.puid = puid.id|,
		lc $self->puid);

    return [
        map {
            my $track = MusicBrainz::Server::Track->new($self->dbh, $_);
            $track->LoadFromId if exists $opts{load_tracks};

            $track;
        } @$rows
    ];
}

sub load
{
    my ($self, $puid) = @_;
    my $sql = Sql->new($self->dbh);

    my $row = $sql->SelectSingleRowHash(qq|
        SELECT id, puid, lookupcount AS lookup_count, version
          FROM puid WHERE puid = ?|, , lc $puid);

    return $self->_new_from_row($row);
}

sub new_from_track
{
    my ($self, $track) = @_;
    return unless defined $track;

	my $sql = Sql->new($self->dbh);

	my $rows = $sql->SelectListOfHashes(qq|
	    SELECT t.puid, j.id,
	           t.lookupcount AS lookup_count,
	           j.usecount AS use_count,
	           j.id AS join_id
          FROM puid t, puidjoin j
         WHERE j.track = ? AND j.puid = t.id
      ORDER BY t.lookupcount desc, j.usecount|,
	    $track->id);

	return [ map { $self->new($self->dbh, $_) } @$rows ];
}

sub insert
{
    my ($self, $puid, $track_id, $client_ver) = @_;

    my $sql = Sql->new($self->dbh);
    my $puid_obj = $self->load($puid);
    $self->{new_insert} = 0;

    if (!defined $puid_obj)
    {
		defined $client_ver or return;

        my $ver_id = $sql->SelectSingleValue(
			"SELECT id FROM clientversion WHERE version = ?",
			$client_ver,
		);

        if (not defined $ver_id)
        {
            $sql->Do("INSERT INTO clientversion (version) VALUES (?)",
                $client_ver)
				or die;
			$ver_id = $sql->GetLastInsertId("clientversion")
				or die;
        }

        $sql->Do("INSERT INTO puid (puid, version) VALUES (?, ?)",
            $puid, $ver_id)
			or die;
		my $id = $sql->GetLastInsertId("puid")
			or die;
		$self->{new_insert} = 1;
		return $id;
    }
    elsif (defined $puid_obj && defined $track_id)
    {
		# I have no idea why, but for some reason from time to time this query
		# says 'failed to find conversion function from "unknown" to integer'.
		# This workaround (explicit cast to integer) is working at the
		# moment...
		$sql->Do(qq|
		    INSERT INTO puidjoin (puid, track)
				SELECT * FROM (SELECT ?::integer, ?::integer) AS data
				WHERE NOT EXISTS (
				    SELECT 1 FROM puidjoin
				     WHERE puid = ?::integer AND track = ?::integer)|,
			$puid_obj->id, $track_id,
			$puid_obj->id, $track_id,
		);

        return $puid_obj->id;
    }
}

sub client_version
{
	my ($self, $puid) = @_;
	$puid = $self if not defined $puid;

	my $sql = Sql->new($self->dbh);
	return $sql->SelectSingleValue(
		"SELECT cv.version FROM puid t, clientversion cv
		WHERE t.puid = ? AND cv.id = t.version",
		$puid->puid,
	);
}

=head2 remove

Remove this PUID from the database

=cut

sub remove
{
    my ($self) = @_;
    return unless defined $self->id;

    my  $sql = Sql->new($self->dbh);
    $sql->Do("DELETE FROM puidjoin WHERE puid = ?", $self->id);
    $sql->Do("DELETE FROM puid WHERE id = ?", $self->id);
}

=head2 remove_by_track

Remove all the PUIDs from the database that are assossciated with a certain
track.

=cut

sub remove_by_track
{
    my ($self, $track) = @_;
    return unless defined $track;

    my $sql = Sql->new($self->dbh);

	my $rows = $sql->SelectListOfLists(
		"SELECT id, puid FROM puidjoin WHERE track = ?", $track->id,
	);

	for my $row (@$rows)
	{
		my ($join_id, $puid) = @$row;

   		$sql->Do("DELETE FROM puidjoin WHERE id = ?", $join_id);

		my $refcount = $sql->SelectSingleValue(
			"SELECT COUNT(*) FROM puidjoin WHERE puid = ?", $puid,
		);
		if ($refcount == 0)
		{
			$sql->Do("DELETE FROM puid WHERE id = ?", $puid);
		}
	}
}

=head2 remove_instance

Remove a specific single PUID from a given track.

=cut

sub remove_instance
{
    my ($self, $join_id) = @_;
    return unless defined $join_id;

	my $sql = Sql->new($self->dbh);

	my $puid = $sql->SelectSingleValue(
		"SELECT puid FROM puidjoin WHERE id = ?", $join_id,
	) or return;

	$sql->Do("DELETE FROM puidjoin WHERE id = ?", $join_id);

	my $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM puidjoin WHERE puid = ?", $puid,
	);

	if ($refcount == 0)
	{
		$sql->Do("DELETE FROM puid WHERE id = ?", $puid);
	}
}

=head2 increment_lookup

Increment the lookup count for a puid

=cut

sub increment_lookup
{
	my ($class, $puid) = @_;

	use MusicBrainz::Server::DeferredUpdate;
	MusicBrainz::Server::DeferredUpdate->Write(
		"PUID::IncrementLookupCount",
		$puid,
	);
}

=head2 update_lookup_count

Update the lookup count on the database

=cut

sub update_lookup_count
{
	my ($self, $puid, $times_used) = @_;
	$times_used ||= 1;
    my $sql = Sql->new($self->dbh);

	my $id = $sql->SelectSingleValue(
		"SELECT id FROM puid WHERE puid = ?", $puid,
	) or return;

	my @gmtime = gmtime;
	my $month_id = 12 * $gmtime[5] + $gmtime[4];

	$sql->Do(
		"UPDATE puid_stat SET lookupcount = lookupcount + ?
		  WHERE puid_id = ? AND month_id = ?",
		$times_used, $id, $month_id,
	) or
	$sql->Do(
		"INSERT INTO puid_stat (puid_id, month_id, lookupcount) values (?, ?, ?)",
		$id, $month_id, $times_used,
	);
}

sub increment_usage_count
{
	my ($class, $puid, $track_id) = @_;

	use MusicBrainz::Server::DeferredUpdate;
	MusicBrainz::Server::DeferredUpdate->Write(
		"PUID::IncrementUsageCount",
		$puid, $track_id,
	);
}

sub update_usage_count
{
	my ($self, $puid, $track_id, $times_used) = @_;
	$times_used ||= 1;
    my $sql = Sql->new($self->dbh);

	my $join_id = $sql->SelectSingleValue(
		"select puidjoin.id 
		   from puid, puidjoin
		  where puidjoin.track = ?
		    and puid.puid = ? 
			and puidjoin.puid = puid.id", $track_id, $puid,
	) or return;

	my @gmtime = gmtime;
	my $month_id = 12*$gmtime[5] + $gmtime[4];

	$sql->Do(
		"UPDATE puidjoin_stat SET usecount = usecount + ?
		  WHERE puidjoin_id = ? AND month_id = ?",
		$times_used, $join_id, $month_id,
	) or
	$sql->Do(
		"INSERT INTO puidjoin_stat (puidjoin_id, month_id, usecount) values (?, ?, ?)",
		$join_id, $month_id, $times_used,
	);
}

=head2 merge_tracks

Handle merging PUIDs when tracks are being merged

=cut

sub merge_tracks
{
	my ($self, $from, $to) = @_;
    my $sql = Sql->new($self->dbh);

	my $puid_joins = $sql->SelectListOfHashes(
		"SELECT * FROM puidjoin WHERE track = ?",
		$from->id,
	);

	for my $old_join (@$puid_joins)
	{
		# Ensure the new puidjoin exists
		$sql->Do(
			"INSERT INTO puidjoin (puid, track)
				SELECT * FROM (SELECT ?::integer, ?::integer) AS data
				WHERE NOT EXISTS (SELECT 1 FROM puidjoin WHERE puid = ?::integer AND track = ?::integer)",
			$old_join->{puid}, $to->id,
			$old_join->{puid}, $to->id,
		);
		my $new_join_id = $sql->SelectSingleValue(
			"SELECT id FROM puidjoin WHERE puid = ? AND track = ?",
			$old_join->{puid}, $to->id,
		);

		# Merge the stats from $oldjoin->{id} to $newjoinid
		$sql->Do(
			"SELECT month_id, SUM(usecount) AS usecount
			INTO TEMPORARY TABLE tmp_merge_puidjoin_stat
			FROM	puidjoin_stat
			WHERE	puidjoin_id IN (?, ?)
			GROUP BY month_id",
			$old_join->{id},
			$new_join_id,
		);
		$sql->Do(
			"DELETE FROM puidjoin_stat WHERE puidjoin_id IN (?, ?)",
			$old_join->{id},
			$new_join_id,
		);
		$sql->Do(
			"INSERT INTO puidjoin_stat (puidjoin_id, month_id, usecount)
			SELECT	?, month_id, usecount
			FROM	tmp_merge_puidjoin_stat",
			$new_join_id,
		);
		$sql->Do(
			"DROP TABLE tmp_merge_puidjoin_stat",
		);
	}

	# Delete the old join row
	$sql->Do(
		"DELETE FROM puidjoin WHERE track = ?",
		$from->id,
	);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
