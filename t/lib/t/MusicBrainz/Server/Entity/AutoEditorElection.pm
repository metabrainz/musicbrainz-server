package t::MusicBrainz::Server::Entity::AutoEditorElection;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

BEGIN {
    use MusicBrainz::Server::Entity::AutoEditorElection;
    use MusicBrainz::Server::Entity::AutoEditorElectionVote;
}

use MusicBrainz::Server::Constants qw( :election_status :vote );
use MusicBrainz::Server::Entity::Editor;

test all => sub {

my $election = MusicBrainz::Server::Entity::AutoEditorElection->new;
ok(defined $election, 'constructor');
isa_ok($election, 'MusicBrainz::Server::Entity::AutoEditorElection', 'isa');
can_ok($election, qw( id candidate proposer seconder_1 seconder_2 status
                      yes_votes no_votes propose_time close_time open_time ));

};

1;
