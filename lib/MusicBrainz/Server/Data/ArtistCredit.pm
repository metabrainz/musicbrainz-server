package MusicBrainz::Server::Data::ArtistCredit;
use Moose;
use namespace::autoclean;

use Data::Compare;
use Carp qw( cluck );

use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Data::Utils qw( placeholders load_subobjects type_to_model sanitize );
use MusicBrainz::Server::Constants qw( entities_with );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => {
    table => 'artist_credit',
};

sub _type { 'artist_credit' }

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $artist_columns = $self->c->model('Artist')->_columns;
    my $query = "SELECT artist, artist_credit_name.name AS ac_name, join_phrase, artist_credit,
                $artist_columns, ac.edits_pending AS ac_edits_pending
                FROM artist_credit_name
                JOIN artist ON artist.id=artist_credit_name.artist
                JOIN artist_credit ac ON ac.id = artist_credit_name.artist_credit
                WHERE artist_credit IN (" . placeholders(@ids) . ')
                ORDER BY artist_credit, position';

    my %result;
    my %counts;
    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        my $id = $row->{artist_credit};
        $counts{$id} //= 0;
        $result{$id} //= MusicBrainz::Server::Entity::ArtistCredit->new(
            id => $id,
            edits_pending => $row->{ac_edits_pending},
        );

        my $acn = MusicBrainz::Server::Entity::ArtistCreditName->new(
                      artist_id => $row->{artist},
                      artist => $self->c->model('Artist')->_new_from_row($row),
                      name => $row->{ac_name},
                      join_phrase => $row->{join_phrase} // '',
                  );
        $result{$id}->add_name($acn);
        $counts{$id} += 1;
    }
    foreach my $id (@ids) {
        if (!defined $counts{$id}) {
            # It's unclear how this could happen, but it seems to be the
            # cause of MBS-8806. Perhaps we'll find out with the call trace
            # provided by cluck.
            cluck "Attempted to load non-existent AC $id, please investigate";
            next;
        }
        $result{$id}->artist_count($counts{$id});
    }
    return \%result;
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'artist_credit', @objs);
}

sub find_by_ids
{
    my ($self, $ids) = @_;

    my @artist_credits = sort { $a->name cmp $b->name }
                         values %{ $self->get_by_ids(@$ids) };
    return \@artist_credits;
}

sub find_by_artist_id
{
    my ($self, $artist_id) = @_;

    my $query = 'SELECT artist_credit FROM artist_credit_name WHERE artist = ?';
    my $ids = $self->sql->select_single_column_array($query, $artist_id);
    return $self->find_by_ids($ids);
}

sub uncache_for_artist_ids
{
    my ($self, @artist_ids) = @_;
    my $query = 'SELECT DISTINCT artist_credit FROM artist_credit_name WHERE artist = any(?)';
    my $artist_credit_ids = $self->sql->select_single_column_array($query, \@artist_ids);
    $self->_delete_from_cache(@$artist_credit_ids) if scalar @$artist_credit_ids;
}

sub _find
{
    my ($self, $artist_credit) = @_;

    my @names = @{ $artist_credit->{names} };

    # remove unused trailing artistcredit slots.
    while (!defined $names[$#names]->{artist}->{id} &&
           (!defined $names[$#names]->{name} || $names[$#names]->{name} eq ''))
    {
        pop @names;
    }

    my @positions = (0..$#names);
    my @artists = map { $_->{artist}->{id} } @names;
    my @credits = map { $_->{name} } @names;
    my @join_phrases = map { $_->{join_phrase} } @names;

    my $name = '';
    my (@joins, @conditions, @args);
    for my $i (@positions) {
        my $ac_name = $names[$i];
        my $join = "JOIN artist_credit_name acn_$i ON acn_$i.artist_credit = ac.id";
        my $condition = "acn_$i.position = ? AND ".
                        "acn_$i.artist = ? AND ".
                        "acn_$i.name = ?";
        push @args, ($i, $artists[$i], $credits[$i]);
        if (defined $ac_name->{join_phrase} && $ac_name->{join_phrase} ne '')
        {
            $condition .= " AND acn_$i.join_phrase = ?";
            push @args, $join_phrases[$i];
        }
        else
        {
            $condition .= " AND acn_$i.join_phrase = ''"
        }
        push @joins, $join;
        push @conditions, $condition;
        $name .= $ac_name->{name};
        $name .= $ac_name->{join_phrase} if $ac_name->{join_phrase};
    }

    my $query = 'SELECT ac.id FROM artist_credit ac ' .
                join(' ', @joins) .
                ' WHERE ' . join(' AND ', @conditions) . ' AND ac.artist_count = ?';

    my $id = $self->sql->select_single_value($query, @args, scalar @credits);

    return ($id, $name, \@positions, \@credits, \@artists, \@join_phrases);
}

sub find
{
    my ($self, @artist_joinphrase) = @_;

    my ($id) =
        $self->_find(@artist_joinphrase);

    return $id;
}

sub find_or_insert
{
    my ($self, $artist_credit) = @_;

    for my $name (@{ $artist_credit->{names} }) {
        $name->{join_phrase} = sanitize($name->{join_phrase});
    }

    my ($id, $name, $positions, $credits, $artists, $join_phrases) =
        $self->_find($artist_credit);

    if (!defined $id)
    {
        $id = $self->sql->insert_row('artist_credit', {
            name => $name,
            artist_count => scalar @$credits,
        }, 'id');
        for my $i (@$positions)
        {
            $self->sql->insert_row('artist_credit_name', {
                    artist_credit => $id,
                    position => $i,
                    artist => $artists->[$i],
                    name => $credits->[$i],
                    join_phrase => $join_phrases->[$i],
                });
        }
    }

    return $id;
}

sub find_for_artist {
    my ($self, $artist) = @_;
    return MusicBrainz::Server::Entity::ArtistCredit->new(
        names => [
            MusicBrainz::Server::Entity::ArtistCreditName->new(
                name        => $artist->name,
                artist_id   => $artist->id,
                artist      => $artist
            )
        ]
    );
}

sub merge_artists
{
    my ($self, $new_id, $old_ids, %opts) = @_;

    my @queries;
    if ($opts{rename}) {
        # When renaming, first replace ACs with versions using the new name,
        # wherever credits match the original artist name.
        push @queries, [
            'SELECT
               artist_credit,
               array_agg(artist ORDER BY position ASC),
               array_agg(CASE
                 WHEN artist_credit_name.artist = any(?) THEN new_artist.name
                 ELSE artist_credit_name.name
               END ORDER BY position ASC),
               array_agg(join_phrase ORDER BY position ASC)
             FROM (
               SELECT artist.id, artist.name
               FROM artist
               WHERE artist.id = ?
             ) new_artist,
             (
               SELECT artist_credit, artist, name, join_phrase, position
                 FROM artist_credit_name
                WHERE artist_credit IN (
                 SELECT acn.artist_credit
                   FROM artist_credit_name acn
                   JOIN artist a ON a.id = acn.artist
                  WHERE a.id = any(?) AND a.name = acn.name
               )
             ) artist_credit_name
             GROUP BY artist_credit',
            $old_ids, $new_id, $old_ids
        ]
    }

    # Now that any renaming is done (if applicable), replace ACs with versions with the new artist ID
    # MBS-7482 is why this is done with a swap rather than a simple UPDATE
    push @queries, [
        'SELECT artist_credit,
                array_agg(CASE WHEN artist = any(?) THEN ? ELSE artist END ORDER BY position ASC),
                array_agg(artist_credit_name.name ORDER BY position ASC),
                array_agg(join_phrase ORDER BY position ASC)
           FROM artist_credit_name WHERE artist_credit IN (
                SELECT artist_credit FROM artist_credit_name WHERE artist = any(?)
           )
         GROUP BY artist_credit',
        $old_ids, $new_id, $old_ids
    ];

    # Now do the actual swapping. Queries are run serially so if applicable some ACs are replaced twice.
    for my $query (@queries) {
        my $new_artist_credits = $self->sql->select_list_of_lists(@$query);
        for my $new_artist_credit (@$new_artist_credits) {
            my ($old_credit_id, $artists, $names, $join_phrases) =
                @$new_artist_credit;

            my $n = scalar(@$artists);
            my $new_credit_id = $self->find_or_insert({
                names => [
                    map +{
                        artist => {
                            id => $artists->[$_],
                        },
                        name => $names->[$_],
                        join_phrase => $join_phrases->[$_]
                    }, (0 .. $n - 1)
                ]
            });

            $self->_swap_artist_credits($old_credit_id, $new_credit_id);
        }
    }
}

sub replace {
    my ($self, $old_ac, $new_ac) = @_;

    return if Compare($old_ac, $new_ac);

    my $old_credit_id = $self->find($old_ac) or return;
    my $new_credit_id = $self->find_or_insert($new_ac);

    $self->_swap_artist_credits($old_credit_id, $new_credit_id);
}

sub _swap_artist_credits {
    my ($self, $old_credit_id, $new_credit_id) = @_;

    return if $old_credit_id == $new_credit_id;

    for my $table (entities_with('artist_credits')) {
        my $ids = $self->c->sql->select_single_column_array(
            "UPDATE $table SET artist_credit = ?
             WHERE artist_credit = ? RETURNING id",
            $new_credit_id, $old_credit_id
        );
        $self->c->model(type_to_model($table))->_delete_from_cache(@$ids) if $table ne 'track';
    }

    $self->c->sql->do(
        'DELETE FROM artist_credit_name
         WHERE artist_credit = ?',
        $old_credit_id
    );

    $self->c->sql->do(
        'DELETE FROM artist_credit
         WHERE id = ?',
        $old_credit_id
    );

    $self->_delete_from_cache($old_credit_id);
}

sub in_use {
    my ($self, $ac) = @_;
    my $ac_id = $self->find($ac) or return 0;

    for my $t (entities_with('artist_credits')) {
        return 1 if $self->c->sql->select_single_value(
            "SELECT TRUE FROM $t WHERE artist_credit = ? LIMIT 1",
            $ac_id
        );
    }

    return 0;
}

sub related_entities {
    my ($self, $ac) = @_;

    my $related = {};
    my $ac_id = $self->find($ac) or return $related;

    for my $t (entities_with([['artist_credits'], ['mbid', 'relatable']])) {
        my $uses = $self->c->sql->select_single_column_array(
            "SELECT DISTINCT id FROM $t WHERE artist_credit = ?", $ac_id
        );
        push @{ $related->{$t} }, @$uses;
    }

    my $track_ac_releases = $self->c->sql->select_single_column_array(
        'SELECT DISTINCT medium.release FROM track JOIN medium ON track.medium = medium.id WHERE track.artist_credit = ?',
        $ac_id
    );

    push @{ $related->{release} }, @{ $track_ac_releases };

    return $related;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
