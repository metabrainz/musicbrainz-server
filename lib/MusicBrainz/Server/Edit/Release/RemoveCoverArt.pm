package MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Str Int ArrayRef );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REMOVE_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseArt';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release',
     'MusicBrainz::Server::Edit::Release::RelatedEntities',
     'MusicBrainz::Server::Edit::Role::Art',
     'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

sub edit_name { N_lp('Remove cover art', 'singular, edit type') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RELEASE_REMOVE_COVER_ART }
sub release_ids { shift->data->{entity}{id} }
sub cover_art_id { shift->data->{cover_art_id} }
sub edit_template { 'RemoveCoverArt' }

sub art_ids { shift->cover_art_id }
sub entity_ids { shift->release_ids }
sub art_archive_model { shift->c->model('CoverArtArchive') }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str,
        ],
        cover_art_id => Int,
        cover_art_types => ArrayRef[Int],
        cover_art_comment => Str,
        cover_art_mime_type => Optional[Str],
        cover_art_suffix => Optional[Str],
    ],
);

sub initialize {
    my ($self, %opts) = @_;
    my $release = $opts{release} or die 'Release missing';
    my $cover_art = $opts{to_delete} or die q(Required 'to_delete' object);

    my %type_map = map { $_->name => $_ }
        $self->c->model('CoverArtType')->get_by_name(@{ $cover_art->type_names });

    $self->data({
        entity => {
            id => $release->id,
            name => $release->name,
            mbid => $release->gid,
        },
        cover_art_id => $cover_art->id,
        cover_art_comment => $cover_art->comment,
        cover_art_types => [
            grep { defined } map { $type_map{$_}->id } @{ $cover_art->type_names },
        ],
        cover_art_mime_type => $cover_art->mime_type,
        cover_art_suffix => $cover_art->suffix,
    });
}

sub accept {
    my $self = shift;

    $self->c->model('Release')->get_by_id($self->data->{entity}{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists',
        );

    $self->c->model('CoverArtArchive')->delete($self->data->{cover_art_id});
}

sub foreign_keys {
    my ($self) = @_;
    return {
        Release => {
            $self->data->{entity}{id} => [ 'ArtistCredit' ],
        },
        CoverArt => {
            $self->data->{cover_art_id} => [ 'Release' ],
        },
        CoverArtType => $self->data->{cover_art_types},
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $release = $loaded->{Release}{ $self->data->{entity}{id} } ||
        Release->new( name => $self->data->{entity}{name} );

    my $artwork = $loaded->{CoverArt}{ $self->data->{cover_art_id} } ||
        ReleaseArt->new(
            release => $release,
            id => $self->data->{cover_art_id},
            comment => $self->data->{cover_art_comment},
            exists $self->data->{cover_art_mime_type} ? (mime_type => $self->data->{cover_art_mime_type}) : (),
            exists $self->data->{cover_art_suffix} ? (suffix => $self->data->{cover_art_suffix}) : (),
        );

    $artwork->types([
        map { $loaded->{CoverArtType}{$_} }
            @{ $self->data->{cover_art_types} },
    ]);

    return {
        release => to_json_object($release),
        artwork => to_json_object($artwork),
    };
}


1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
