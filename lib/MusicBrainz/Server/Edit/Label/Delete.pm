package MusicBrainz::Server::Edit::Label::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Role::DeleteSubscription';
with 'MusicBrainz::Server::Edit::Label';

sub edit_type { $EDIT_LABEL_DELETE }
sub edit_name { N_l('Remove label') }
sub _delete_model { 'Label' }
sub subscription_model { shift->c->model('Label')->subscription }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

