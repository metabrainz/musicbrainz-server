package MusicBrainz::Server::Edit::Release::DeleteReleaseLabel;
use Moose;

use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETERELEASELABEL );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Remove release label' }
sub edit_type { $EDIT_RELEASE_DELETERELEASELABEL }

sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub related_entities { { release => [ shift->release_id ] } }
sub models { [qw( Release ReleaseLabel )] }

has '+data' => (
    isa => Dict[
        release_label_id => Int,
        release_id => Int
    ]
);

has 'release_id' => (
    isa => Int,
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_id} }
);

has 'release' => (
    isa => 'Release',
    is => 'rw',
);

has 'release_label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_label_id} }
);

has 'release_label' => (
    isa => 'ReleaseLabel',
    is => 'rw',
);

sub accept
{
    my $self = shift;
    $self->c->model('ReleaseLabel')->delete($self->release_label_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
