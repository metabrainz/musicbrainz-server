## no critic (RequireFilenameMatchesPackage)
package MusicBrainz::Server::WebService::Exceptions::UnknownIncParameter;
use Moose;
with 'Throwable';

has parameter => ( is => 'ro', required => 1, isa => 'Str' );

sub message { sprintf 'Unknown inc parameter: %s', shift->parameter }

1;
