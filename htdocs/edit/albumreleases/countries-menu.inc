%# vi: set ts=2 sw=2 ft=mason :
<%perl>

my $dbh = shift;
$dbh ||= do { my $mb = $m->comp("/comp/dblogin"); $mb->{DBH} };

my $countries = MusicBrainz::Server::Country->new($dbh);

my @countries_menu = map {
	[ $_->GetId, $_->GetName ]
} $countries->All;

return \@countries_menu;

</%perl>
