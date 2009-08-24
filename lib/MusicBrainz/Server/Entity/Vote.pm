package MusicBrainz::Server::Entity::Vote;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( :vote );

extends 'MusicBrainz::Server::Entity::Entity';

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
        $VOTE_NO_VOTE => 'No vote',
        $VOTE_ABSTAIN => 'Abstain',
        $VOTE_NO => 'No',
        $VOTE_YES => 'Yes',
    );
    return $names{$self->vote};
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
