package MusicBrainz::Server::Form::Moderation::Vote;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use Carp;
use MusicBrainz::Server::Vote;

sub profile
{
    return {
        required => {
            choice => {
                type             => 'Select',
                auto_widget_size => 5,
            }
        },
    };
}

sub options_choice
{
    [ ModDefs::VOTE_YES, 'Yes',
      ModDefs::VOTE_NO,  'No',
      ModDefs::VOTE_ABS, 'Abstain',
      'nv',  'No Vote',
    ];
}

sub vote
{
    my ($self) = @_;

    my $moderation = $self->item;
    my $user       = $self->context->user;

    my $should_vote = $self->value('choice') ne 'nv';

    return unless $should_vote;

    my $sql  = new Sql($self->context->mb->{DBH});
    my $vote = new MusicBrainz::Server::Vote($self->context->mb->{DBH});
    
    eval
    {
        $sql->Begin;
        $vote->InsertVotes(
            {
                $moderation->id => $self->value('choice')
            },
            $user->id,
        );
        $sql->Commit;
    };

    if ($@)
    {
        my $err = $@;
        $sql->Rollback;

        croak "Could not enter vote: $err";
    }
}

1;
