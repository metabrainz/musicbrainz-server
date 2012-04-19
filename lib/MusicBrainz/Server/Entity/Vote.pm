package MusicBrainz::Server::Entity::Vote;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( :vote );

extends 'MusicBrainz::Server::Entity';

has [qw( editor_id edit_id )] => (
    isa => 'Int',
    is => 'rw',
);

has 'editor' => (
    isa => 'Editor',
    is => 'rw',
);

has 'edit' => (
    isa => 'Edit',
    is => 'rw',
    weak_ref => 1
);

has 'vote_time' => (
    isa => 'DateTime',
    is => 'rw',
    coerce => 1,
);

has 'superseded' => (
    isa => 'Bool',
    is => 'rw',
);

has 'vote' => (
    isa => 'VoteOption',
    is => 'rw',
);

sub vote_name
{
    my $self = shift;
    my %names = (
        $VOTE_ABSTAIN => 'Abstain',
        $VOTE_NO => 'No',
        $VOTE_YES => 'Yes',
        $VOTE_APPROVE => 'Approve',
    );
    return $names{$self->vote};
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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
