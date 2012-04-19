package MusicBrainz::Server::Report::DuplicateArtists;
use Moose;

extends 'MusicBrainz::Server::Report';

sub _add_artist {
    my ($store, $name, $gid, $row) = @_;

    $name =~ s/[\p{Punctuation}]//g;
    $name =~ s/\bAND\b/&/g;

    my @words = sort $name =~ /(\w+)/g;
    my $key = "@words";

    return if exists $store->{$key}{$gid};
    $store->{$key}{$gid} = $row;
}

sub gather_data
{
    my ($self, $writer) = @_;

    my %artists;
    my $sql = $self->c->sql;

    my $artists = $sql->select_list_of_hashes(
        'SELECT artist.gid, name.name AS name, sort_name.name AS sort_name,
                musicbrainz_unaccent(name.name) AS name_unac,
                musicbrainz_unaccent(sort_name.name) AS sort_name_unac,
                artist.comment, artist.type, artist.id,
                (artist.comment IS NOT NULL) AS has_comment
         FROM artist
         JOIN artist_name name ON name.id = artist.name
         JOIN artist_name sort_name ON sort_name.id = artist.sort_name'
    );

    for my $r (@$artists) {
        _add_artist(\%artists, $r->{name_unac}, $r->{gid}, $r);
        _add_artist(\%artists, $r->{sort_name_unac}, $r->{gid}, $r);
    }

    my $aliases = $sql->select_list_of_hashes(
        "SELECT artist.gid, artist.id, name.name AS name, sort_name.name AS sort_name,
                musicbrainz_unaccent(alias_name.name) AS alias,
                CASE
                  WHEN artist.comment IS NULL THEN 'alias: ' || musicbrainz_unaccent(alias_name.name)
                  ELSE artist.comment || ') (alias: ' || musicbrainz_unaccent(alias_name.name)
                END AS comment,
                (artist.comment IS NOT NULL) AS has_comment,
                artist.type
         FROM artist
         JOIN artist_name name ON name.id = artist.name
         JOIN artist_alias alias ON alias.artist = artist.id
         JOIN artist_name alias_name ON alias_name.id = alias.name
         JOIN artist_name sort_name ON sort_name.id = artist.sort_name"
    );

    for my $r (@$aliases) {
        _add_artist(\%artists, $r->{alias}, $r->{gid}, $r);
    }

    while (my ($k, $v) = each %artists) {
		next unless keys(%$v) >= 2;
        my @dupes =values %$v;

        # Skip if all artists have comments
        next if (grep { $_->{has_comment} } @dupes) == @dupes;

		my $dupelist = [ values %$v ];

		$writer->Print($dupelist);
	}
}

sub post_load
{
    my ($self, $dupe_sets) = @_;
    my @artists;
    for my $dupes (@$dupe_sets) {
        for my $dupe (@$dupes) {
            $dupe->{artist} = $self->c->model('Artist')->get_by_gid($dupe->{gid});
            push @artists, $dupe->{artist};
        }
    }

    $self->c->model('ArtistType')->load(@artists);
}

sub template
{
    return 'report/duplicate_artists.tt';
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
