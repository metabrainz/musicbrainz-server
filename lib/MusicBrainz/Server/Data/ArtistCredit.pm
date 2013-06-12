package MusicBrainz::Server::Data::ArtistCredit;
use Moose;
use namespace::autoclean -also => [qw( _clean )];

use Data::Compare;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Data::Artist qw( is_special_purpose );
use MusicBrainz::Server::Data::Utils qw( placeholders load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'ac' };

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $query = "SELECT artist, artist_name.name, join_phrase, artist_credit,
                        artist.id, gid, n2.name AS artist_name,
                        n3.name AS sort_name,
                        comment " .
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
        $info{join_phrase} = $row->{join_phrase} // '';
        my $obj = MusicBrainz::Server::Entity::ArtistCreditName->new(%info);
        $obj->artist(MusicBrainz::Server::Entity::Artist->new(
            id => $row->{id},
            gid => $row->{gid},
            name => $row->{artist_name},
            sort_name => $row->{sort_name},
            comment => $row->{comment}
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

    if ($opts{rename}) {
        my @artist_credit_ids = @{
            $self->sql->select_single_column_array(
                'UPDATE artist_credit_name acn SET name = artist.name
                   FROM artist
                  WHERE artist.id = ?
                    AND acn.artist IN (' . placeholders(@$old_ids) . ')
              RETURNING artist_credit',
                $new_id, @$old_ids);
        };

        if (@artist_credit_ids) {
            my $partial_names = $self->sql->select_list_of_hashes(
                'SELECT acn.artist_credit, acn.join_phrase, an.name
                   FROM artist_credit_name acn
	               JOIN artist_name an ON acn.name = an.id
                  WHERE artist_credit IN (' . placeholders(@artist_credit_ids) . ')
               ORDER BY artist_credit, position',
                @artist_credit_ids);
            my %names;
            for my $name (@$partial_names) {
                my $ac_id = $name->{artist_credit};
                $names{$ac_id} ||= '';
                $names{$ac_id} .= $name->{name};
                $names{$ac_id} .= $name->{join_phrase} if defined $name->{join_phrase};
            }

            my %names_id = $self->c->model('Artist')->find_or_insert_names(values %names);
            for my $ac_id (@artist_credit_ids) {
                $self->sql->do('UPDATE artist_credit SET name = ? WHERE id = ?',
                               $names_id{$names{$ac_id}}, $ac_id);
            }
        }
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

sub replace {
    my ($self, $old_ac, $new_ac) = @_;

    return if Compare($old_ac, $new_ac);

    my $old_credit_id = $self->find ($old_ac) or return;
    my $new_credit_id = $self->find_or_insert($new_ac);
    return if $old_credit_id == $new_credit_id;

    for my $table (qw( recording release release_group track )) {
        $self->c->sql->do(
            "UPDATE $table SET artist_credit = ?
             WHERE artist_credit = ?",
            $new_credit_id, $old_credit_id
       );
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

    for my $t (qw( recording release release_group track )) {
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

    for my $t (qw( recording release release_group )) {
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
