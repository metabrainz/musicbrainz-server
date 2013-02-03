package MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use Moose;

use MooseX::Types::Moose qw( Str Int ArrayRef );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REMOVE_COVER_ART );
use MusicBrainz::Server::Edit::Utils qw( conditions_without_autoedit );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Artwork';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::CoverArt';

sub edit_name { N_l('Remove cover art') }
sub edit_type { $EDIT_RELEASE_REMOVE_COVER_ART }
sub release_ids { shift->data->{entity}{id} }
sub cover_art_id { shift->data->{cover_art_id} }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        cover_art_id => Int,
        cover_art_types => ArrayRef[Int],
        cover_art_comment => Str,
    ]
);

around edit_conditions => sub {
    my ($orig, $self, @args) = @_;
    return conditions_without_autoedit($self->$orig(@args));
};

sub initialize {
    my ($self, %opts) = @_;
    my $release = $opts{release} or die 'Release missing';
    my $cover_art = $opts{to_delete} or die "Required 'to_delete' object";

    my %type_map = map { $_->name => $_ }
        $self->c->model ('CoverArtType')->get_by_name(@{ $cover_art->types });

    $self->data({
        entity => {
            id => $release->id,
            name => $release->name,
            mbid => $release->gid
        },
        cover_art_id => $cover_art->id,
        cover_art_comment => $cover_art->comment,
        cover_art_types => [
            grep defined, map { $type_map{$_}->id } @{ $cover_art->types }
        ]
    });
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_id($self->data->{entity}{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );

    $self->c->model('CoverArtArchive')->delete($self->data->{cover_art_id});
}

sub foreign_keys {
    my ($self) = @_;
    return {
        Release => {
            $self->data->{entity}{id} => [ 'ArtistCredit' ]
        },
        CoverArtType => $self->data->{cover_art_types}
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $release = $loaded->{Release}{ $self->data->{entity}{id} } ||
        Release->new( name => $self->data->{entity}{name} );

    my $artwork = Artwork->new(release => $release,
                               id => $self->data->{cover_art_id},
                               comment => $self->data->{cover_art_comment},
                               cover_art_types => [map {$loaded->{CoverArtType}{$_}} @{ $self->data->{cover_art_types} }]);
    return {
        release => $release,
        artwork => $artwork,
    };
}


1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation

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
