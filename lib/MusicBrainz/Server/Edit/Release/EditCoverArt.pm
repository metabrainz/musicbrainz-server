package MusicBrainz::Server::Edit::Release::EditCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

sub edit_name { N_l('Edit cover art') }
sub edit_type { $EDIT_RELEASE_EDIT_COVER_ART }
sub release_ids { shift->data->{entity}{id} }

sub alter_edit_pending {
    my $self = shift;

    return {
        Release => [ $self->release_ids ],
        Artwork => [ $self->data->{id} ],
    }
}

sub change_fields
{
    Dict[
        types => Optional[ArrayRef[Int]],
        comment => Optional[Str],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        id => Int,
        old => change_fields(),
        new => change_fields(),
    ]
);

sub initialize {
    my ($self, %opts) = @_;
    my $release = $opts{release} or die 'Release missing';

    my %old = (
        types => $opts{old_types},
        comment => $opts{old_comment},,
    );

    my %new = (
        types => $opts{new_types},
        comment => $opts{new_comment},
        );

    $self->data({
        entity => {
            id => $release->id,
            name => $release->name,
            mbid => $release->gid
        },
        id => $opts{artwork_id},
        $self->_change_data (\%old, %new)
    });
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );

    $self->c->model('CoverArtArchive')->exists($self->data->{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This cover art no longer exists'
        );

    $self->c->model('CoverArtArchive')->update_cover_art(
        $release->id,
        $self->data->{id},
        $self->data->{new}->{types},
        $self->data->{new}->{comment}
    );
}

sub foreign_keys {
    my ($self) = @_;

    my %fk;

    $fk{Release} = {
        $self->data->{entity}{id} => [ 'ArtistCredit' ]
    };

    $fk{CoverArtType} = [
        @{ $self->data->{new}->{types} },
        @{ $self->data->{old}->{types} }
    ] if defined $self->data->{new}->{types};

    return \%fk;
}

sub display_cover_art_types
{
    my ($loaded, $types) = @_;

    # FIXME: sort these.
    # hardcode (front, back, alphabetical) sorting in CoverArtType somehow?
    return join (", ", map { $loaded->{CoverArtType}->{$_}->l_name } @$types);
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my %data;

    $data{release} = $loaded->{Release}{ $self->data->{entity}{id} } ||
        Release->new( name => $self->data->{entity}{name} );

    # FIXME: replace this with a proper MusicBrainz::Server::Entity::Artwork object
    my $prefix = DBDefs::COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . "/release/" . $data{release}->gid . "/";
    $data{artwork} = {
        image => $prefix.$self->data->{id}.'.jpg',
        large_thumbnail => $prefix.$self->data->{id}.'-500.jpg',
        small_thumbnail => $prefix.$self->data->{id}.'-250.jpg',
    };

    if ($self->data->{old}->{types})
    {
        $data{types} = {
            old => display_cover_art_types ($loaded, $self->data->{old}->{types}),
            new => display_cover_art_types ($loaded, $self->data->{new}->{types}),
        }
    }

    if (exists $self->data->{old}->{comment})
    {
        $data{comment} = {
            old => $self->data->{old}->{comment},
            new => $self->data->{new}->{comment}
        }
    }

    return \%data;
}

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
