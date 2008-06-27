%# vi: set ts=2 sw=2 ft=mason :
<%perl>
my $cvspath = shift;
my %opts = @_;
my $show = $opts{'show'};
require File::Basename;
$show = File::Basename::basename($cvspath)
	unless defined $show;
</%perl><a href="http://cvs.musicbrainz.org/cvs/<% $cvspath %>"><% $show %></a><%perl>
return;
</%perl>
