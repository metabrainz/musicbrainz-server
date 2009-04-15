package MusicBrainz::Server::AutoEditorElectionVote;
use Moose;
extends 'TableBase';

use Carp;
use ModDefs ':vote';

has 'election' => (
    is => 'ro',
    init_arg => 'automod_election',
);

has [qw/voter vote/] => (
    is => 'ro',
);

has 'voted_at' => (
    is => 'ro',
    init_arg => 'votetime',
);

my %VoteText = (
    &ModDefs::VOTE_UNKNOWN	=> "Unknown",
    &ModDefs::VOTE_NOTVOTED	=> "Not voted",
    &ModDefs::VOTE_ABS		=> "Abstain",
    &ModDefs::VOTE_YES		=> "Yes",
    &ModDefs::VOTE_NO		=> "No"
);

sub vote_name
{
	my ($self, $vote) = @_;
	$vote = $self->vote unless defined $vote;
	return $VoteText{$vote};
}

1;