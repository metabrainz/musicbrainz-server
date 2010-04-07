package MusicBrainz::Server::Data::ArtistCredit;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use List::Util qw( first );
use List::MoreUtils qw( part zip );
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Schema qw( schema );

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'ac' },
     'MusicBrainz::Server::Data::Role::Subobject' => { prefix => 'artist_credit' };

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $query = do
    {
        my $acn         = schema->table('artist_credit_name');
        my $ac          = schema->table('artist_credit');
        my $artist      = $self->c->model('Artist')->table;
        my $artist_name = schema->table('artist_name')->alias('artist_name');
        my $ac_name     = schema->table('artist_name')->alias('ac_name');

        my $name_fk = first { $_->has_column($artist->column('name')) }
            schema->foreign_keys_between_tables($artist, $artist_name);

        Fey::SQL->new_select
            ->select(
                $acn->column('artist'), $ac_name->column('name'),
                $acn->column('joinphrase'), $acn->column('artist_credit'),
                $artist->column('id'), $artist->column('gid'),
                $artist_name->column('name')->alias('artist_name')
            )
            ->from($acn)
            ->from($acn, $ac_name)
            ->from($artist, $acn)
            ->from($artist, $artist_name, $name_fk)
            ->where($acn->column('artist_credit'), 'IN', @ids)
            ->order_by($acn->column('artist_credit'), $acn->column('position'));
    };

    my %result;
    my %counts;
    foreach my $id (@ids) {
        my $obj = MusicBrainz::Server::Entity::ArtistCredit->new(id => $id);
        $result{$id} = $obj;
        $counts{$id} = 0;
    }

    $self->sql->select($query->sql($self->sql->dbh), @ids);
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my %info = (
            artist_id => $row->{artist},
            name      => $row->{name}
        );
        $info{join_phrase} = $row->{joinphrase} if defined $row->{joinphrase};
        my $obj = MusicBrainz::Server::Entity::ArtistCreditName->new(%info);
        $obj->artist(MusicBrainz::Server::Entity::Artist->new(
            id   => $row->{id},
            gid  => $row->{gid},
            name => $row->{artist_name},
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

method find_or_insert (@artist_joinphrase)
{
    my $i = 0;
    my ($credits, $join_phrases) = part { $i++ % 2 } @artist_joinphrase;
    my @positions = (0..scalar @$credits - 1);
    my @artists = map { $_->{artist} } @$credits;
    my @names = map { $_->{name} } @$credits;

    my $ac  = schema->table('artist_credit');
    my $query = Fey::SQL->new_select
        ->select($ac->column('id'))->from($ac)
        ->where($ac->column('artistcount'), '=', scalar @names);

    my $name = "";
    for my $i (@positions) {
        my $acn = schema->table('artist_credit_name')->alias("acn_$i");
        my $an  = schema->table('artist_name')->alias("an_$i");

        $query
            ->from($ac, $acn)
            ->from($acn, $an)
            ->where($acn->column('position'),   '=', $positions[$i])
            ->where($acn->column('artist'),     '=', $artists[$i])
            ->where($acn->column('joinphrase'), '=', $join_phrases->[$i])
            ->where($an->column('name'),        '=', $names[$i]);

        $name .= $names[$i];
        $name .= $join_phrases->[$i] if defined $join_phrases->[$i];
    }

    my $id = $self->sql->select_single_value(
        $query->sql($self->sql->dbh), $query->bind_params);

    if(!defined $id)
    {
        my %names_id = $self->c->model('Artist')->find_or_insert_names(@names,
                                                                       $name);

        $query = Fey::SQL::Pg->new_insert
            ->into(map { $ac->column($_) } qw( name artistcount ))
            ->returning($ac->column('id'))
            ->values(
                name        => $names_id{$name},
                artistcount => scalar @names,
            );

        $id = $self->sql->select_single_value(
            $query->sql($self->sql->dbh), $query->bind_params);

        die "NO RETURN!" unless $id;

        my $acn = schema->table('artist_credit_name');
        for my $i (@positions)
        {
            $query = Fey::SQL->new_insert
                ->into($acn)
                ->values(
                    artist_credit => $id,
                    position      => $i,
                    artist        => $artists[$i],
                    name          => $names_id{$names[$i]},
                    joinphrase    => $join_phrases->[$i],
                );
            $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
        }
    }

    return $id;
}

method merge_artists ($new_id, @old_ids)
{
    my $acn = schema->table('artist_credit_name');
    my $query = Fey::SQL->new_update
        ->update($acn)
        ->set($acn->column('artist'), $new_id)
        ->where($acn->column('artist'), 'IN', @old_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
}

__PACKAGE__->meta->make_immutable;

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
