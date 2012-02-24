package MusicBrainz::Server::Edit::Release::AddCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;

use aliased 'Net::Amazon::S3::Request::CreateBucket';
use aliased 'Net::Amazon::S3::Request::DeleteObject';
use aliased 'Net::Amazon::S3::Request::PutObject';

use Net::CoverArtArchive;

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

sub edit_name { 'Add cover art' }
sub edit_type { $EDIT_RELEASE_ADD_COVER_ART }
sub release_ids { shift->data->{entity}{id} }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        cover_art_types => ArrayRef[Int],
        cover_art_position => Int,
        cover_art_url  => Str,
        cover_art_id   => Int
    ]
);

sub lwp { shift->c->lwp }
sub s3 { shift->c->model('CoverArtArchive')->s3 }

has bucket_name => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return 'mbid-' . $self->data->{entity}{mbid};
    }
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
        cover_art_url => $opts{cover_art_url},
        cover_art_types => $opts{cover_art_types},
        cover_art_position => $opts{cover_art_position},
        cover_art_id => $opts{cover_art_id}
    });
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );
}

sub insert {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_gid($self->data->{entity}{mbid});

    # Mark that we now have cover art for this release
    $self->c->model('CoverArtArchive')->insert_cover_art(
        $release->id,
        $self->id,
        $self->data->{cover_art_id},
        $self->data->{cover_art_position},
        $self->data->{cover_art_types}
    );
}

sub reject {
    my $self = shift;

    # Remove the pending stuff
    $self->lwp->request(
        DeleteObject->new(
            s3     => $self->s3,
            bucket => $self->bucket_name,
            key    => $self->data->{cover_art_url}
        )->http_request
    );
}

sub foreign_keys {
    my ($self) = @_;
    return {
        Release => {
            $self->data->{entity}{id} => [ 'ArtistCredit' ]
        }
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;
    return {
        release => $loaded->{Release}{ $self->data->{entity}{id} }
            || Release->new( name => $self->data->{entity}{name} ),
        cover_art_url =>
            &DBDefs::COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . "/release/" .
            $self->data->{entity}{mbid} . "/" . $self->data->{cover_art_url}
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
