%# vi: set ts=4 sw=4 ft=mason :
<%perl>
return unless $session{uid};
return unless UserStuff->IsAutoMod($session{privs});
my $mb = $m->comp("/comp/dblogin");
my $e = MusicBrainz::Server::AutomodElection->new($mb->{DBH});
my $pending = $e->GetPendingElections($session{uid});
@$pending or return;

my $url = (
	(@$pending == 1)
	? "/user/election/show.html?id=" . $pending->[0]->GetId
	: "/user/election/"
);

</%perl>
<p class="notice">
	Please participate in the <a href="<% $url %>">automoderator elections</a>.&nbsp; Thank you!
</p>
