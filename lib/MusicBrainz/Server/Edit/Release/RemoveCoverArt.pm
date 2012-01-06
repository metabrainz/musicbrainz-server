package MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use Moose;

use List::MoreUtils qw( any );
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REMOVE_COVER_ART );
use MusicBrainz::Server::Edit::Exceptions;
use Net::CoverArtArchive;

use aliased 'Net::Amazon::S3::Request::DeleteObject';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

sub edit_name { 'Remove cover art' }
sub edit_type { $EDIT_RELEASE_REMOVE_COVER_ART }
sub release_ids { shift->data->{entity}{id} }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        cover_art_type  => Str,
        cover_art_page  => Int
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
        cover_art_type => $opts{cover_art_type},
        cover_art_page => $opts{cover_art_page},
    });
}

sub accept {
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_id($self->data->{entity}{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This release no longer exists'
        );

    $self->lwp->request(
        DeleteObject->new(
            s3     => $self->s3,
            bucket => $self->bucket_name,
            key    => join(
                '-',
                'mbid',
                $release->gid,
                $self->data->{cover_art_type},
                $self->data->{cover_art_page},
            ) . '.jpg'
        )->http_request
    );

    # Check if the release has other cover art, and if not - remove it
    unless (
        any { $_->type ne 'pending' }
            $self->c->model('CoverArtArchive')->find_available_artwork($release->gid)
    ) {
        $self->c->model('CoverArtArchive')->update_cover_art_presence(
            $release->id, 0
        );
    }
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
        artwork => Net::CoverArtArchive->new->find_artwork(
            $self->data->{entity}{mbid},
            $self->data->{cover_art_type},
            $self->data->{cover_art_page}
        )
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
