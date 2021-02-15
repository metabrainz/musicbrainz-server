package MusicBrainz::Server::Edit::ReleaseGroup::SetCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Int Maybe Str );
use MooseX::Types::Structured qw( Dict );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_SET_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::ReleaseGroup';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Set cover art') }
sub edit_kind { 'other' }
sub edit_type { $EDIT_RELEASEGROUP_SET_COVER_ART }
sub release_group_ids { shift->data->{entity}->{id} }

sub alter_edit_pending {
    my $self = shift;

    return {
        ReleaseGroup => [ $self->data->{entity}->{id} ]
    }
}

sub change_fields
{
    return Dict[
        release_id => Maybe[Int],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        old => change_fields(),
        new => change_fields(),
    ]
);

sub initialize {
    my ($self, %opts) = @_;
    my $rg = $opts{entity} or die 'Release Group missing';
    my $release = $opts{release} or die 'Release missing';

    my %old;
    my %new = ( release_id => $opts{release}->id );

    if ($rg->cover_art && $rg->cover_art->release
        && $self->c->model('ReleaseGroup')->has_cover_art_set($rg->id))
    {
        $old{release_id} = $rg->cover_art->release->id;
    }

    $self->data({
        entity => {
            id => $rg->id,
            name => $rg->name,
            mbid => $rg->gid
        },
        $self->_change_data(\%old, %new)
    });
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_id($self->data->{new}{release_id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );

    my $rg = $self->c->model('ReleaseGroup')->get_by_id($self->data->{entity}{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release group no longer exists'
        );

    $self->c->model('ReleaseGroup')->set_cover_art($rg->id, $release->id);
}

sub foreign_keys {
    my ($self) = @_;
    return {
        ReleaseGroup => { $self->data->{entity}{id} => [ 'ArtistCredit' ] },
        Release => {
            $self->data->{old}{release_id} => [ 'ArtistCredit' ],
            $self->data->{new}{release_id} => [ 'ArtistCredit' ],
        }
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my %data;

    my @releases = values %{ $loaded->{Release} };
    my $artwork = $self->c->model('Artwork')->find_front_cover_by_release(
        @releases);
    $self->c->model('CoverArtType')->load_for(@$artwork);

    my %artwork_by_release_id;
    for my $image (@$artwork)
    {
        $artwork_by_release_id{$image->release_id} = $image;
    }

    $data{release_group} = $loaded->{ReleaseGroup}->{ $self->data->{entity}{id} } ||
        ReleaseGroup->new( name => $self->data->{entity}{name} );

    my $old_id = $self->data->{old}->{release_id};
    my $new_id = $self->data->{new}->{release_id};

    $data{artwork} = { };
    $data{artwork}->{old} = $artwork_by_release_id{$old_id} if $old_id;
    $data{artwork}->{new} = $artwork_by_release_id{$new_id} if $new_id;

    return \%data;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

