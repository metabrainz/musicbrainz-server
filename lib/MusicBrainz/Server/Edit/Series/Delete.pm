package MusicBrainz::Server::Edit::Series::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_DELETE );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Role::DeleteSubscription';
with 'MusicBrainz::Server::Edit::Series';

sub edit_type { $EDIT_SERIES_DELETE }
sub edit_name { N_l('Remove series') }
sub _delete_model { 'Series' }
sub subscription_model { shift->c->model('Series')->subscription }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
