package MusicBrainz::Server::Entity::Vote;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Constants qw( :vote );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json datetime_to_iso8601 );
use MusicBrainz::Server::Entity::Util::JSON qw( add_linked_entity );
use MusicBrainz::Server::Types qw( DateTime VoteOption );

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
    isa => DateTime,
    is => 'rw',
    coerce => 1,
);

has 'superseded' => (
    isa => 'Bool',
    is => 'rw',
);

has 'vote' => (
    isa => VoteOption,
    is => 'rw',
);

# Converted to JavaScript at root/static/scripts/edit/utility/getVoteName.js
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

around TO_JSON => sub {
    my ($orig, $self) = @_;

    add_linked_entity('editor', $self->editor_id, $self->editor);

    my $json = $self->$orig;
    $json->{editor_id} = $self->editor_id + 0;
    $json->{superseded} = boolean_to_json($self->superseded);
    $json->{vote} = $self->vote + 0;
    $json->{vote_time} = datetime_to_iso8601($self->vote_time);

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
