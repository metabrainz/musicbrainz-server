package MusicBrainz::Server::Data::ArtistCredit;
use Moose;
use namespace::autoclean -also => [qw( _clean )];

use Data::Compare;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Data::Artist qw( is_special_purpose );
use MusicBrainz::Server::Data::Utils qw( placeholders load_subobjects type_to_model );
use MusicBrainz::Server::Constants qw( entities_with );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';

sub _type { 'artist_credit' }

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $artist_columns = $self->c->model('Artist')->_columns;
    my $query = "SELECT artist, artist_credit_name.name AS ac_name, join_phrase, artist_credit, " .
                $artist_columns . " " .
                "FROM artist_credit_name " .
                "JOIN artist ON artist.id=artist_credit_name.artist " .
                "WHERE artist_credit IN (" . placeholders(@ids) . ") " .
                "ORDER BY artist_credit, position";
    my %result;
    my %counts;
    foreach my $id (@ids) {
        my $obj = MusicBrainz::Server::Entity::ArtistCredit->new(id => $id);
        $result{$id} = $obj;
        $counts{$id} = 0;
    }
    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        my %info = (
            artist_id => $row->{artist},
            name => $row->{ac_name}
        );
        $info{join_phrase} = $row->{join_phrase} // '';
        my $obj = MusicBrainz::Server::Entity::ArtistCreditName->new(%info);
        $obj->artist($self->c->model('Artist')->_new_from_row($row));
        my $id = $row->{artist_credit};
        $result{$id}->add_name($obj);
        $counts{$id} += 1;
    }
    foreach my $id (@ids) {
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

    my $name = "";
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

    my $query = "SELECT ac.id FROM artist_credit ac " .
                join(" ", @joins) .
                " WHERE " . join(" AND ", @conditions) . " AND ac.artist_count = ?";

    my $id = $self->sql->select_single_value($query, @args, scalar @credits);

    return ($id, $name, \@positions, \@credits, \@artists, \@join_phrases);
}

sub find
{
    my ($self, @artist_joinphrase) = @_;

    my ($id, $name, $positions, $names, $artists, $join_phrases) =
        $self->_find(@artist_joinphrase);

    return $id;
}

sub find_or_insert
{
    my ($self, $artist_credit) = @_;

    for my $name (@{ $artist_credit->{names} }) {
        $name->{join_phrase} = _clean($name->{join_phrase});
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

sub _clean {
    my $text = shift;
    return '' unless defined($text);
    $text =~ s/[^[:print:]]//g;
    $text =~ s/\s+/ /g;
    return $text;
}

sub merge_artists
{
    my ($self, $new_id, $old_ids, %opts) = @_;

    my @queries;
    if ($opts{rename}) {
        # When renaming, first replace ACs with versions using the new name
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
               SELECT artist_credit, artist, artist_credit_name.name, join_phrase, position
               FROM artist_credit_name
               WHERE artist_credit_name.artist_credit IN (
                 SELECT artist_credit
                 FROM artist_credit_name
                 WHERE artist = any(?)
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
        "SELECT DISTINCT medium.release FROM track JOIN medium ON track.medium = medium.id WHERE track.artist_credit = ?",
        $ac_id
    );

    push @{ $related->{release} }, @{ $track_ac_releases };

    return $related;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
