package MusicBrainz::Server::Data::ArtistCredit;
use Moose;

use List::MoreUtils qw( part zip );
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Utils qw( placeholders load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'ac' };

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $query = "SELECT artist, artist_name.name, joinphrase, artist_credit, artist.id, gid, n2.name AS artist_name " .
                "FROM artist_credit_name " .
                "JOIN artist_name ON artist_name.id=artist_credit_name.name " .
                "JOIN artist ON artist.id=artist_credit_name.artist " .
                "JOIN artist_name n2 ON n2.id=artist.name " .
                "WHERE artist_credit IN (" . placeholders(@ids) . ") " .
                "ORDER BY artist_credit, position";
    my $sql = Sql->new($self->c->dbh);
    my %result;
    my %counts;
    foreach my $id (@ids) {
        my $obj = MusicBrainz::Server::Entity::ArtistCredit->new(id => $id);
        $result{$id} = $obj;
        $counts{$id} = 0;
    }
    $sql->select($query, @ids);
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my %info = (
            artist_id => $row->{artist},
            name => $row->{name}
        );
        $info{join_phrase} = $row->{joinphrase} if defined $row->{joinphrase};
        my $obj = MusicBrainz::Server::Entity::ArtistCreditName->new(%info);
        $obj->artist(MusicBrainz::Server::Entity::Artist->new(
            id => $row->{id},
            gid => $row->{gid},
            name => $row->{artist_name},
        ));
        my $id = $row->{artist_credit};
        $result{$id}->add_name($obj);
        $counts{$id} += 1;
    }
    $sql->finish;
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

sub find_or_insert
{
    my ($self, @artist_joinphrase) = @_;

    my $i = 0;
    my ($credits, $join_phrases) = part { $i++ % 2 } @artist_joinphrase;
    my @positions = (0..scalar @$credits - 1);
    my @artists = map { $_->{artist} } @$credits;
    my @names = map { $_->{name} } @$credits;

    my $name = "";
    my (@joins, @conditions);
    for my $i (@positions) {
        my $join = "JOIN artist_credit_name acn_$i ON acn_$i.artist_credit = ac.id " .
                   "JOIN artist_name an_$i ON an_$i.id = acn_$i.name";
        my $condition = "acn_$i.position = ? AND ".
                        "acn_$i.artist = ? AND ".
                        "an_$i.name = ?";
        $condition .= " AND acn_$i.joinphrase = ?" if defined $join_phrases->[$i];
        push @joins, $join;
        push @conditions, $condition;
        $name .= $names[$i];
        $name .= $join_phrases->[$i] if defined $join_phrases->[$i];
    }

    my $sql = Sql->new($self->c->dbh);
    my $query = "SELECT ac.id FROM artist_credit ac " .
                join(" ", @joins) .
                " WHERE " . join(" AND ", @conditions) . " AND ac.artistcount = ?";
    my @args = zip @positions, @artists, @names, @$join_phrases;
    pop @args unless defined $join_phrases->[$#names];
    my $id = $sql->select_single_value($query, @args, scalar @names);

    if(!defined $id)
    {
        my %names_id = $self->c->model('Artist')->find_or_insert_names(@names, $name);
        $id = $sql->insert_row('artist_credit', {
            name => $names_id{$name},
            artistcount => scalar @names,
        }, 'id');
        for my $i (@positions)
        {
            $sql->insert_row('artist_credit_name', {
                    artist_credit => $id,
                    position => $i,
                    artist => $artists[$i],
                    name => $names_id{$names[$i]},
                    joinphrase => $join_phrases->[$i],
                });
        }
    }

    return $id;
}

sub merge_artists
{
    my ($self, $new_id, @old_ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    $sql->do('UPDATE artist_credit_name SET artist = ?
              WHERE artist IN ('.placeholders(@old_ids).')', $new_id, @old_ids);
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
