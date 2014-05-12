package MusicBrainz::Server::Edit::Artist::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE :expire_action :quality );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Role::DeleteSubscription';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { N_l('Remove artist') }
sub edit_type { $EDIT_ARTIST_DELETE }

sub _delete_model { 'Artist' }
sub subscription_model { shift->c->model('Artist')->subscription }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
