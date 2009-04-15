package MusicBrainz::Server::AutoEditorElection;
use Moose;

extends 'TableBase';
with 'MusicBrainz::Server::Role::SendsEmail';

use Moose::Util::TypeConstraints;

use Carp;
use ModDefs ':vote';
use ModDefs ':userid';
use MusicBrainz::Server::AutoEditorElectionVote;
use MusicBrainz::Server::Editor;

use Exception::Class (
        'AlreadyAutoEditorException',
        'EditorIneligibleException',
        'ElectionAlreadyExistsException' => {
            fields => 'election_id',
        },
        'ElectionDoesNotExistException',
        'ElectionClosedException',
        'ElectionOpenException',
        'ElectionNotReadyException',
    );

use constant PROPOSAL_TIMEOUT => "1 week";
use constant VOTING_TIMEOUT   => "1 week";

our $STATUS_AWAITING_SECONDER_1	= 1;
our $STATUS_AWAITING_SECONDER_2	= 2;
our $STATUS_VOTING_OPEN			= 3;
our $STATUS_ACCEPTED			= 4;
our $STATUS_REJECTED			= 5;
our $STATUS_CANCELLED			= 6;

my %descstatus = (
	$STATUS_AWAITING_SECONDER_1	=> "awaiting 1st seconder",
	$STATUS_AWAITING_SECONDER_2	=> "awaiting 2nd seconder",
	$STATUS_VOTING_OPEN			=> "voting open",
	$STATUS_ACCEPTED			=> "accepted",
	$STATUS_REJECTED			=> "declined",
	$STATUS_CANCELLED			=> "cancelled",
);

subtype 'MusicBrainz.Editor' => as class_type('MusicBrainz::Server::Editor');
coerce 'MusicBrainz.Editor'
    => from 'Int'
        => via { MusicBrainz::Server::Editor->new(undef, id => $_) };

has [qw/candidate proposer seconder1 seconder2/] => (
    is  => 'ro',
    isa => 'MusicBrainz.Editor',
    coerce => 1,
);

has 'status' => (
    is => 'ro'
);

has 'votes_for' => (
    is => 'ro',
    init_arg => 'yesvotes',
);

has 'votes_against' => (
    is => 'ro',
    init_arg => 'novotes'
);

has 'proposed_at' => (
    is => 'ro',
    init_arg => 'proposetime',
);

has 'opened_at' => (
    is => 'ro',
    init_arg => 'opentime'
);

has 'closed_at' => (
    is => 'ro',
    init_arg => 'closetime'
);

=head2 generate_profile_link

A closure to generate a URL to a user profile

=cut

has 'generate_profile_link' => (
    is => 'ro',
    isa => 'CodeRef',
);

=head2 generate_election_link

A closure to generate a URL to an election

=cut

has 'generate_election_link' => (
    is => 'ro',
    isa => 'CodeRef',
);

=head2 seconders

Return a list of all seconders

=cut

sub seconders
{
    my $self = shift;
    return [ grep { defined } (
        $self->seconder1,
        $self->seconder2,
    ) ];
}

=head2 editor_is_support $editor

Check if an editor is supporting an election by seconding it, or originally
proposing it

=cut

sub editor_is_supporter
{
    my ($self, $editor) = @_;

    my @supporters = (
        $self->proposer,
        $self->candidate,
        @{ $self->seconders }
    );

    return scalar (grep { $_->id == $editor->id } @supporters) > 0;
}

=head2 editor_can_second $editor

Check if an editor is elligible to second an election

=cut

sub editor_can_second
{
    my ($self, $editor) = @_;

    return unless defined $editor;
    return unless $editor->is_auto_editor;
    return !$self->editor_is_supporter($editor);
}

=head2 editor_can_cancel $editor

Check if an editor can cancel an election

=cut

sub editor_can_cancel
{
    my ($self, $editor) = @_;

    return unless defined $editor;
    return $editor->id == $self->proposer->id;
}

=head2 elections ?%opts

Get a list of all auto-editor elections, order in descednding order of the
the election was proposed.

Returns an array reference of MusicBrainz::Server::AutoEditorElections.

%opts is a hash that can be used to modify the bahavior of this method. If
the C<with_candidate> key exists, candidates will be fully loaded objects. If
this key is B<not> present, only the ID will be available.

=cut

sub elections
{
    my ($self, %opts) = @_;
    my $sql = Sql->new($self->dbh);

    my $query = exists $opts{with_candidate}
              ? qq|SELECT automod_election.*,
                          moderator.name AS m_name, moderator.id AS m_id
                     FROM automod_election,moderator
                    WHERE moderator.id = automod_election.candidate
                 ORDER BY proposetime DESC|
                    
              : qq|SELECT * FROM automod_election
                 ORDER BY proposetime DESC|;

    my $rows = $sql->SelectListOfHashes($query);

    my @elections = map {
        $_->{candidate} = MusicBrainz::Server::Editor->_new_from_row($_, strip_prefix => 'm_')
            if $opts{with_candidate};
            
        MusicBrainz::Server::AutoEditorElection->new($self->dbh, $_);
    } @$rows;

    return \@elections;
}

=head2 pending_elections $user

Get a list of all elections in which $user should be reminded to participate.

=cut

sub pending_elections
{
	my ($self, $user) = @_;
	my $sql = Sql->new($self->dbh);

	my $rows = $sql->SelectListOfHashes(qq|
	    SELECT *
	      FROM automod_election
		 WHERE status IN ($STATUS_AWAITING_SECONDER_1,
		                  $STATUS_AWAITING_SECONDER_2,
		                  $STATUS_VOTING_OPEN)
	  ORDER BY proposetime DESC|);

    # Find all open elections the user has not voted in (excluded elections
    # that they have shown support for).
    my @elections;
    my $uid = $user->id;
	for (@$rows)
	{
	    my $el = MusicBrainz::Server::AutoEditorElection->new($self->dbh, $_);
	    next if $el->editor_is_supporter($user);

	    for my $vote (@{ $el->votes })
	    {
	        next if $vote->voter->id == $uid;
	    }

        push @elections, $el;
	}

	return \@elections;
}

=head2 new_from_id $id, ?%opts

Load the election with database id, C<id>.

%opts is a hash that can be used to modify the bahavior of this method. If
the C<with_editors> key exists, all assossciated editors (candidate, proposer,
seconders) will be fully loaded Editor objects. Otherwise, only the ID will be
guaranteed available.

=cut

sub new_from_id
{
    my ($self, $id, %opts) = @_;
    my $sql = Sql->new($self->dbh);

    my $query;
    if (exists $opts{with_editors})
    {
        $query = qq|SELECT election.id, election.status, election.yesvotes,
                           election.novotes, election.proposetime,
                           election.opentime, election.closetime,
                           s1.id AS s1_id, s1.name AS s1_name,
                           s2.id AS s2_id, s2.name AS s2_name,
                           c.id  AS c_id,  c.name  AS c_name,
                           p.id  AS p_id,  p.name  AS p_name
                      FROM automod_election election
                 LEFT JOIN moderator s1 ON (election.seconder_1 = s1.id)
                 LEFT JOIN moderator s2 ON (election.seconder_2 = s2.id)
                 LEFT JOIN moderator c  ON (election.candidate  = c.id)
                 LEFT JOIN moderator p  ON (election.proposer   = p.id)
                     WHERE election.id = ?|;
    }
    else
    {
        $query = qq|SELECT election.id, election.status, election.yesvotes,
                           election.novotes, election.proposetime,
                           election.opentime, election.closetime,
                           election.seconder_1 AS seconder1,
                           election.seconder_2 AS seconder2,
                           election.candidate, election.proposer
                      FROM automod_election election
                     WHERE election.id = ?|;
    }

	my $row = $sql->SelectSingleRowHash($query, $id)
	    or return;

    if (exists $opts{with_editors})
    {
        $row->{candidate} = MusicBrainz::Server::Editor->_new_from_row($row, strip_prefix => 'c_');
        $row->{proposer}  = MusicBrainz::Server::Editor->_new_from_row($row, strip_prefix => 'p_');
        
        $row->{seconder1} = MusicBrainz::Server::Editor->_new_from_row($row, strip_prefix => 's1_')
            if defined $row->{s1_id};
        
        $row->{seconder2} = MusicBrainz::Server::Editor->_new_from_row($row, strip_prefix => 's2_')
            if defined $row->{s2_id};
    }
    else
    {
        delete $row->{seconder1} unless defined $row->{seconder1};
        delete $row->{seconder2} unless defined $row->{seconder2};
    }

    if (ref $self)
    {
        $row->{template_directory} = $self->template_directory;
        $row->{generate_profile_link} = $self->generate_profile_link;
        $row->{generate_election_link} = $self->generate_election_link;
    }

    return MusicBrainz::Server::AutoEditorElection->new($self->dbh, $row);
}

sub refresh
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	my $newself = $self->new_from_id($self->id)
		or return;

	%$self = %$newself;
	return $self;
}

sub status_name
{
	my ($self, $status) = @_;

	$status = $self->status unless defined $status;
	return $descstatus{$status};
}

sub votes
{
    my ($self, %opts) = @_;
	my $sql = Sql->new($self->dbh);

	my $query;
	if (exists $opts{with_voters})
	{
	    $query = qq|SELECT automod_election_vote.*,
	                       moderator.name AS m_name, moderator.id AS m_id
	                  FROM automod_election_vote, moderator
	                 WHERE automod_election = ? AND moderator.id = voter
	              ORDER BY votetime|;
	}
	else
	{
	    $query = qq|SELECT * FROM automod_election_vote
	                 WHERE automod_election = ?
	              ORDER BY votetime|;
	}

	my $votes = $sql->SelectListOfHashes($query, $self->id);
	
	return [ map {
	    if (exists $opts{with_voters}) {
	        $_->{voter} = MusicBrainz::Server::Editor->_new_from_row($_, strip_prefix => 'm_');
	    }

	    MusicBrainz::Server::AutoEditorElectionVote->new($self->dbh, $_);
	} @$votes ];
}

=head2 close_elections

Automatically close or timeout elections.

=cut

sub close_elections
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	$sql->AutoTransaction(
		sub {
			$sql->Do("LOCK TABLE automod_election IN EXCLUSIVE MODE");
			
			my $to_timeout = $sql->SelectListOfHashes(
				"SELECT * FROM automod_election WHERE status IN ($STATUS_AWAITING_SECONDER_1,$STATUS_AWAITING_SECONDER_2)
					AND NOW() - proposetime > INTERVAL ?",
				PROPOSAL_TIMEOUT,
			);

			for my $election (@$to_timeout)
			{
			    $election = MusicBrainz::Server::AutoEditorElection->new($self->dbh, $election);
				$election->_timeout;
			}

			my $to_close = $sql->SelectListOfHashes(
				"SELECT * FROM automod_election WHERE status = $STATUS_VOTING_OPEN
					AND NOW() - opentime > INTERVAL ?",
				VOTING_TIMEOUT,
			);

			for my $election (@$to_close)
			{
			    $election = MusicBrainz::Server::AutoEditorElection->new($self->dbh, $election);
				$election->_close;
			}
		},
	);
}

sub _timeout
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	$sql->Do(
		"UPDATE automod_election SET status = $STATUS_REJECTED, closetime = NOW() WHERE id = ?",
		$self->id,
	);

	$self->{status} = $STATUS_REJECTED; # XXX: Fix me - avoiding accessors
	# NOTE closetime not set

	$self->_send_email('timeout.tt', as_reply => 1);
}

=head2 _close

Close an election, depending on the amount of yes or no votes it has received

=cut

sub _close
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

    # XXX Fix me - avoiding accessors
	$self->{status} = (($self->votes_for > $self->votes_against) ? $STATUS_ACCEPTED : $STATUS_REJECTED);
	# NOTE closetime not set

	$sql->Do(
		"UPDATE automod_election SET status = ?, closetime = NOW() WHERE id = ?",
		$self->status, $self->id,
	);

	if ($self->status == $STATUS_ACCEPTED)
	{
	    my $candidate = MusicBrainz::Server::Editor->newFromId($self->dbh, $self->candidate);
		$candidate->MakeAutoModerator;

		$self->_send_email('accepted.tt', as_reply => 1);
	}
	else
	{
	    $self->_send_email('rejected.tt', as_reply => 1);
	}
}

################################################################################
# The guts of the system: propose, second, cast vote, cancel
################################################################################

=head2 is_user_eligible $user

Make sure a editor is eligible to become an auto-editor

=cut

sub is_user_eligible
{
	my ($self, $user) = @_;
	return !$user->is_special_editor;
}

sub propose
{
	my ($self, $candidate, $proposer) = @_;
	my $sql = Sql->new($self->dbh);

	$sql->AutoTransaction(sub {
        # Do not allow auto-editors to be propsed
    	AlreadyAutoEditorException->throw
    		if $candidate->is_auto_editor($candidate->privs);

        # Make sure the editor is eligible to be an auto-editor
    	EditorIneligibleException->throw
    		unless $self->is_user_eligible($candidate);

    	$sql->Do("LOCK TABLE automod_election IN EXCLUSIVE MODE");

        # Make sure the editor isn't already being elected
    	my $id = $sql->SelectSingleValue(
    		"SELECT id FROM automod_election WHERE candidate = ?
    			AND status IN ($STATUS_AWAITING_SECONDER_1,$STATUS_AWAITING_SECONDER_2,$STATUS_VOTING_OPEN)",
    		$candidate->id,
    	);
    	ElectionAlreadyExistsException->throw(election_id => $id)
    		if $id;

        # All good, create the election
    	$sql->Do(
    		"INSERT INTO automod_election (candidate, proposer) VALUES (?, ?)",
    		$candidate->id, $proposer->id,
    	);
    });

    my $id = $sql->GetLastInsertId("automod_election");

	$self = $self->new_from_id($id);
	$self->_send_email('new_election.tt');

    return $self;
}

sub second
{
	my ($self, $seconder) = @_;
	my $sql = Sql->new($self->dbh);

    $self = $sql->AutoTransaction(sub {
    	$sql->Do("LOCK TABLE automod_election IN EXCLUSIVE MODE");
    	$self->refresh
    		or ElectionDoesNotExistException->throw;

        # Do not allow seconding elections that are already closed
    	ElectionClosedException->throw if $self->is_closed;

        # Do not allow seconding elections that are open
    	ElectionOpenException->throw if $self->is_open;

        # Do not allow seconding if the seconder has already seconded, or is the candidate
    	EditorIneligibleException->throw if $self->editor_is_supporter($seconder);

    	$sql->Do(
    		"UPDATE automod_election
    			SET seconder_1 = ?, status = $STATUS_AWAITING_SECONDER_2
    			WHERE id = ? AND status = $STATUS_AWAITING_SECONDER_1",
    		$seconder->id,
    		$self->id,
    	) and do {
    		$self->{seconder1} = $seconder;
    		$self->{status} = $STATUS_AWAITING_SECONDER_2;
    		return $self;
    	};

    	$sql->Do(
    		"UPDATE automod_election
    			SET seconder_2 = ?, status = $STATUS_VOTING_OPEN, opentime = NOW()
    			WHERE id = ? AND status = $STATUS_AWAITING_SECONDER_2",
    		$seconder->id,
    		$self->id,
    	) and do {
    		$self->{seconder2} = $seconder;
    		$self->{status} = $STATUS_VOTING_OPEN;
    		return $self;
    	};

    	return;
	});

    if ($self)
    {
        $self->_send_email('voting_open.tt', as_reply => 1);
    }
}

sub is_closed
{
    my $self = shift;
    return $self->status =~ /^($STATUS_ACCEPTED|$STATUS_REJECTED|$STATUS_CANCELLED)$/o;
}

sub is_open
{
    my $self = shift;
    return $self->status =~ /^($STATUS_VOTING_OPEN)$/o;
}

sub is_pending
{
    my $self = shift;
    return $self->status =~ /^($STATUS_AWAITING_SECONDER_1|$STATUS_AWAITING_SECONDER_2)$/o;
}

sub vote
{
	my ($self, $voter, $vote) = @_;
	my $sql = Sql->new($self->dbh);

    $sql->AutoTransaction(sub {
    	$sql->Do("LOCK TABLE automod_election, automod_election_vote IN EXCLUSIVE MODE");
    	$self->refresh or ElectionDoesNotExistException->throw;

    	ElectionClosedException->throw   if $self->is_closed;
    	ElectionNotReadyException->throw if $self->is_pending;

    	EditorIneligibleException->throw if $self->editor_is_supporter($voter);

    	my $old_vote = $sql->SelectSingleRowHash(
    		"SELECT * FROM automod_election_vote
    			WHERE automod_election = ? AND voter = ?",
    		$self->id, $voter->id,
    	);

    	return 1
    		if $old_vote and $old_vote->{vote} == $vote;

    	if ($old_vote) {
    		$sql->Do(
    			"UPDATE automod_election_vote SET vote = ?, votetime = NOW() WHERE id = ?",
    			$vote,
    			$old_vote->{id},
    		);
    	} else {
    		$sql->Do(
    			"INSERT INTO automod_election_vote (automod_election, voter, vote) VALUES (?, ?, ?)",
    			$self->id,
    			$voter->id,
    			$vote,
    		);
    	}

    	my $yesdelta = my $nodelta = 0;
    	--$yesdelta if $old_vote and $old_vote->{vote} == &ModDefs::VOTE_YES;
    	--$nodelta if $old_vote and $old_vote->{vote} == &ModDefs::VOTE_NO;
    	++$yesdelta if $vote == &ModDefs::VOTE_YES;
    	++$nodelta if $vote == &ModDefs::VOTE_NO;

    	$sql->Do(
    		"UPDATE automod_election SET yesvotes = yesvotes + ?,
    		novotes = novotes + ? WHERE id = ?",
    		$yesdelta,
    		$nodelta,
    		$self->id,
    	);
    });

	return 1;
}

sub cancel
{
	my ($self, $editor) = @_;
	my $sql = Sql->new($self->dbh);

    $sql->AutoTransaction(sub {
    	$sql->Do("LOCK TABLE automod_election IN EXCLUSIVE MODE");
    	$self->refresh or ElectionDoesNotExistException->throw;

    	EditorIneligibleException->throw
    		unless $self->proposer->id == $editor->id;

    	ElectionClosedException->throw if $self->is_closed;

    	$sql->Do(
    		"UPDATE automod_election
    			SET status = $STATUS_CANCELLED, closetime = NOW()
    			WHERE id = ? AND status IN ($STATUS_AWAITING_SECONDER_1,$STATUS_AWAITING_SECONDER_2,$STATUS_VOTING_OPEN)",
    		$self->id,
    	) or die;
	});

	$self->{status} = $STATUS_CANCELLED;
	# NOTE closetime is not set
	$self->_send_email('cancelled.tt', as_reply => 1);

	return 1;
}

sub _send_email
{
    my ($self, $template, %opts) = @_;

    my $context = {
        $self->_user_to_context('proposer',  $self->proposer),
        $self->_user_to_context('candidate', $self->candidate),
        $self->_user_to_context('seconder1', $self->seconder1),
        $self->_user_to_context('seconder2', $self->seconder2),
        election_link => $self->generate_election_link->($self),
    };

    my @extra_headers;
    if (exists $opts{as_reply})
    {
        @extra_headers = (
            'In-Reply-To'  => $self->_email_id,
            'References'   => $self->_email_id,
        );
    }
    else
    {
        @extra_headers = ('Message-Id' => $self->_email_id);
    }

    $self->send_email($template, $context, extra_headers => \@extra_headers);
}

sub _user_to_context
{
    my ($self, $key, $user) = @_;
    return unless defined $user;

    return (
        $key . "_name" => $user->name,
        $key . "_link" => $self->generate_profile_link->($user),
    );
}

sub generate_email_headers
{
    my $self = shift;

    return [
        'Subject'      => 'Autoeditor Election: ' . $self->candidate->name,
        'Sender'       => 'Webserver <webserver@musicbrainz.org>',
        'From'         => 'The Returning Officer <returning-officer@musicbrainz.org>',
        'To'           => '',
        'Content-Type' => 'text/plain',
    ];
}

sub _email_id
{
    my $self = shift;
    my $id = $self->id;
    (my $nums = $self->proposed_at) =~ tr/0-9//cd;

    return "<autoeditor-election-$id-$nums\@musicbrainz.org>"
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
