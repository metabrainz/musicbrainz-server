%# vi: set ts=2 sw=2 ft=mason :
<%perl>

return $session{countries_menu} if $session{countries_menu};

my $dbh = shift;
$dbh ||= do { my $mb = $m->comp("/comp/dblogin"); $mb->{DBH} };

# Prepare and cache the list of countries.  This isn't going to be changing in
# a hurry.
my $countries = MusicBrainz::Server::Country->new($dbh);

my @countries_menu = map {
	[ $_->GetId, $_->GetName ]
} $countries->All;

return $session{countries_menu} = \@countries_menu;

</%perl>
