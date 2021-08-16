package MusicBrainz::Server::Edit::Release::AddCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Artwork';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Role::CoverArt';

sub edit_name { N_l('Add cover art') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RELEASE_ADD_COVER_ART }
sub release_ids { shift->data->{entity}{id} }
sub cover_art_id { shift->data->{cover_art_id} }
sub edit_template_react { 'AddCoverArt' }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        cover_art_types => ArrayRef[Int],
        cover_art_position => Int,
        cover_art_id   => Int,
        cover_art_comment => Str,
        cover_art_mime_type => Str,
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
        cover_art_types => $opts{cover_art_types},
        cover_art_position => $opts{cover_art_position},
        cover_art_id => $opts{cover_art_id},
        cover_art_comment => $opts{cover_art_comment},
        cover_art_mime_type => $opts{cover_art_mime_type},
    });
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );
}

sub post_insert {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid});

    # Mark that we now have cover art for this release
    $self->c->model('CoverArtArchive')->insert_cover_art(
        $release->id,
        $self->id,
        $self->data->{cover_art_id},
        $self->data->{cover_art_position},
        $self->data->{cover_art_types},
        $self->data->{cover_art_comment},
        $self->data->{cover_art_mime_type}
    );
}

sub reject {
    my $self = shift;

    # Remove the pending stuff
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

    my $loaded_release = $loaded->{Release}{ $self->data->{entity}{id} };
    my $release = $loaded_release ||
        Release->new(
            id => $self->data->{entity}{id},
            name => $self->data->{entity}{name},
        );
    my $artwork_release = $loaded_release ||
        Release->new(
            gid => $self->data->{entity}{mbid},
            id => $self->data->{entity}{id},
            name => $self->data->{entity}{name},
        );

    my $suffix = $self->data->{cover_art_mime_type}
        ? $self->c->model('CoverArt')->image_type_suffix($self->data->{cover_art_mime_type})
        : 'jpg';

    my $artwork = Artwork->new(release => $artwork_release,
                               id => $self->data->{cover_art_id},
                               comment => $self->data->{cover_art_comment},
                               mime_type => $self->data->{cover_art_mime_type},
                               suffix => $suffix,
                               cover_art_types => [map {$loaded->{CoverArtType}{$_}} @{ $self->data->{cover_art_types} }]);

    return {
        release => to_json_object($release),
        artwork => to_json_object($artwork),
        position => $self->data->{cover_art_position},
    };
}

sub restore {
    my ($self, $data) = @_;

    $data->{cover_art_mime_type} = 'image/jpeg'
        unless exists $data->{cover_art_mime_type};

    $self->data($data);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012,2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
