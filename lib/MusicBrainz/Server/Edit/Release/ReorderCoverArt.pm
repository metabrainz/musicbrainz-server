package MusicBrainz::Server::Edit::Release::ReorderCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REORDER_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use List::UtilsBy 'nsort_by';
use Data::Compare;

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Artwork';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Reorder cover art') }
sub edit_kind { 'other' }
sub edit_type { $EDIT_RELEASE_REORDER_COVER_ART }
sub release_ids { shift->data->{entity}{id} }
sub edit_template_react { 'ReorderCoverArt' }

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

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        if Compare( [ nsort_by { $_->{position} } @{$opts{old}} ],
                    [ nsort_by { $_->{position} } @{$opts{new}} ] );

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

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );

    my $current = $self->c->model('Artwork')->find_by_release($release);

    my @current_ids = sort(map { $_->id } @$current);
    my @edit_ids = sort(map { $_->{id} } @{ $self->data->{old} });

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
        $self->c->model('CoverArtType')->load_for(@$artwork);
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

    $data{old} = [ map { to_json_object($artwork_by_id{$_->{id}}) } @old ];
    $data{new} = [ map { to_json_object($artwork_by_id{$_->{id}}) } @new ];

    $data{release} = to_json_object($data{release});

    return \%data;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
