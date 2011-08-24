package MusicBrainz::Server::Data::ArtistCredit;
use Moose;

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
    my $query = "SELECT artist, artist_name.name, join_phrase, artist_credit,
                        artist.id, gid, n2.name AS artist_name,
                        n3.name AS sort_name " .
                "FROM artist_credit_name " .
                "JOIN artist_name ON artist_name.id=artist_credit_name.name " .
                "JOIN artist ON artist.id=artist_credit_name.artist " .
                "JOIN artist_name n2 ON n2.id=artist.name " .
                "JOIN artist_name n3 ON n3.id=artist.sort_name " .
                "WHERE artist_credit IN (" . placeholders(@ids) . ") " .
                "ORDER BY artist_credit, position";
    my %result;
    my %counts;
    foreach my $id (@ids) {
        my $obj = MusicBrainz::Server::Entity::ArtistCredit->new(id => $id);
        $result{$id} = $obj;
        $counts{$id} = 0;
    }
    $self->sql->select($query, @ids);
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my %info = (
            artist_id => $row->{artist},
            name => $row->{name}
        );
        $info{join_phrase} = $row->{join_phrase} if defined $row->{join_phrase};
        my $obj = MusicBrainz::Server::Entity::ArtistCreditName->new(%info);
        $obj->artist(MusicBrainz::Server::Entity::Artist->new(
            id => $row->{id},
            gid => $row->{gid},
            name => $row->{artist_name},
            sort_name => $row->{sort_name}
        ));
        my $id = $row->{artist_credit};
        $result{$id}->add_name($obj);
        $counts{$id} += 1;
    }
    $self->sql->finish;
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
        my $join = "JOIN artist_credit_name acn_$i ON acn_$i.artist_credit = ac.id " .
                   "JOIN artist_name an_$i ON an_$i.id = acn_$i.name";
        my $condition = "acn_$i.position = ? AND ".
                        "acn_$i.artist = ? AND ".
                        "an_$i.name = ?";
        push @args, ($i, $artists[$i], $credits[$i]);
        if (defined $ac_name->{join_phrase} && $ac_name->{join_phrase} ne '')
        {
            $condition .= " AND acn_$i.join_phrase = ?";
            push @args, $join_phrases[$i];
        }
        else
        {
            $condition .= " AND (acn_$i.join_phrase = '' OR acn_$i.join_phrase IS NULL)"
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
        $self->_find (@artist_joinphrase);

    return $id;
}

sub find_or_insert
{
    my ($self, @artist_joinphrase) = @_;

    my ($id, $name, $positions, $credits, $artists, $join_phrases) =
        $self->_find (@artist_joinphrase);

    if(!defined $id)
    {
        my %names_id = $self->c->model('Artist')->find_or_insert_names(@$credits, $name);
        $id = $self->sql->insert_row('artist_credit', {
            name => $names_id{$name},
            artist_count => scalar @$credits,
        }, 'id');
        for my $i (@$positions)
        {
            $self->sql->insert_row('artist_credit_name', {
                    artist_credit => $id,
                    position => $i,
                    artist => $artists->[$i],
                    name => $names_id{$credits->[$i]},
                    join_phrase => _clean($join_phrases->[$i]),
                });
        }
    }

    return $id;
}

sub _clean {
    my $text = shift;
    return undef unless defined($text);
    $text =~ s/[^[:print:]]//g;
    $text =~ s/\s+/ /g;
    return $text;
}

sub merge_artists
{
    my ($self, $new_id, $old_ids, %opts) = @_;
    if ($opts{rename}) {
        $self->sql->do(
            'UPDATE artist_credit_name acn SET name = artist.name
               FROM artist
              WHERE artist.id = ?
                AND acn.artist IN (' . placeholders(@$old_ids) . ')',
            $new_id, @$old_ids);
    }
    my @artist_credit_ids = @{
        $self->sql->select_single_column_array(
        'UPDATE artist_credit_name SET artist = ?
          WHERE artist IN ('.placeholders(@$old_ids).')
      RETURNING artist_credit',
        $new_id, @$old_ids)
    };

    $self->_delete_from_cache(@artist_credit_ids) if @artist_credit_ids;
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
