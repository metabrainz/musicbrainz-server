package MusicBrainz::Server::Edit::Release::ReorderCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REORDER_COVER_ART $EXPIRE_ACCEPT :quality );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Translation qw ( N_l );

use List::UtilsBy 'nsort_by';

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Artwork';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

sub edit_name { N_l('Reorder cover art') }
sub edit_type { $EDIT_RELEASE_REORDER_COVER_ART }
sub release_ids { shift->data->{entity}{id} }

sub alter_edit_pending {
    return {
        Release => [ shift->release_ids ],
    }
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        old => ArrayRef[Dict[ id => Int, position => Int ]],
        new => ArrayRef[Dict[ id => Int, position => Int ]],
    ]
);

sub initialize {
    my ($self, %opts) = @_;
    my $release = $opts{release} or die 'Release missing';

    $self->data({
        entity => {
            id => $release->id,
            name => $release->name,
            mbid => $release->gid
        },
        old => $opts{old},
        new => $opts{new},
    });
}

sub edit_conditions
{
    my $conditions = {
        duration      => 0,
        votes         => 0,
        expire_action => $EXPIRE_ACCEPT,
        auto_edit     => 1,
    };
    return {
        $QUALITY_LOW    => $conditions,
        $QUALITY_NORMAL => $conditions,
        $QUALITY_HIGH   => $conditions,
    };
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );


    my $current = $self->c->model ('CoverArtArchive')->find_available_artwork ($release->gid);

    my @current_ids = sort (map { $_->id } @$current);
    my @edit_ids = sort (map { $_->{id} } @{ $self->data->{old} });

    if (join(",", @current_ids) ne join (",", @edit_ids))
    {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency
            ->throw('Cover art has been added or removed since this edit was created, which conflicts ' .
                    'with changes made in this edit.');
    }

    my %position = map { $_->{id} => $_->{position} } @{ $self->data->{new} };

    $self->c->model('CoverArtArchive')->reorder_cover_art($release->id, \%position);
}

sub foreign_keys {
    my ($self) = @_;

    my %fk;

    $fk{Release} = {
        $self->data->{entity}{id} => [ 'ArtistCredit' ]
    };

    return \%fk;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my %data;

    $data{release} = $loaded->{Release}{ $self->data->{entity}{id} };
    if (!$data{release} && ($data{release} ||= $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid}))) {
        $self->c->model('ArtistCredit')->load($data{release});
    }

    my $artwork;
    if ($data{release}) {
        $artwork = $self->c->model('Artwork')->find_by_release($data{release});
        $self->c->model ('CoverArtType')->load_for(@$artwork);
    } else {
        $data{release} = Release->new( name => $self->data->{entity}{name},
                                       id => $self->data->{entity}{id},
                                       gid => $self->data->{entity}{mbid} );
        $artwork = [];
    }
    my %artwork_by_id = map { $_->id => $_ } @$artwork;

    for my $undef_artwork (grep { !defined $artwork_by_id{$_->{id}} } @{ $self->data->{old} }) {
        my $fake_artwork = Artwork->new( release => $data{release}, id => $undef_artwork->{id});
        push @$artwork, $fake_artwork;
        $artwork_by_id{$undef_artwork->{id}} = $fake_artwork;
    }

    my @old = nsort_by { $_->{position} } @{ $self->data->{old} };
    my @new = nsort_by { $_->{position} } @{ $self->data->{new} };

    $data{old} = [ map { $artwork_by_id{$_->{id}} } @old ];
    $data{new} = [ map { $artwork_by_id{$_->{id}} } @new ];

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
