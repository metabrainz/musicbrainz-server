## no critic (RequireFilenameMatchesPackage)
package MusicBrainz::Server::Exceptions::InvalidInput;
use Moose;
use namespace::autoclean;
extends 'Throwable::Error';

package MusicBrainz::Server::Exceptions::BadData;
use Moose;
use namespace::autoclean;
extends 'MusicBrainz::Server::Exceptions::InvalidInput';

package MusicBrainz::Server::Exceptions::Duplicate;
use Moose;
use namespace::autoclean;
extends 'MusicBrainz::Server::Exceptions::InvalidInput';

has 'duplicates' => ( is => 'ro', isa => 'ArrayRef' );

package MusicBrainz::Server::Exceptions::DuplicateViolation;
use Moose;
use namespace::autoclean;
with 'Throwable';

has 'conflict' => ( is => 'ro', required => 1 );

package MusicBrainz::Server::Exceptions::GenericTimeout;
use Moose;
use namespace::autoclean;
extends 'Throwable::Error';
with 'MusicBrainz::Server::Exceptions::Role::Timeout';

package MusicBrainz::Server::Exceptions::DatabaseError;
use Moose;
use namespace::autoclean;
extends 'Throwable::Error';

use overload q{""} => 'as_string', fallback => 1;

has sqlstate => ( is => 'ro', isa => 'Str', required => 1 );
has message => ( is => 'ro', isa => 'Str', required => 1 );

sub as_string { my $self = shift; $self->sqlstate . ' ' . $self->message }

package MusicBrainz::Server::Exceptions::DatabaseError::StatementTimedOut;
use Moose;
use namespace::autoclean;
extends 'MusicBrainz::Server::Exceptions::DatabaseError';
with 'MusicBrainz::Server::Exceptions::Role::Timeout';

1;
