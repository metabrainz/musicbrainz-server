package MusicBrainz::Server::Edit::Artist::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Role::MergeSubscription';

sub edit_name { l('Merge artists') }
sub edit_type { $EDIT_ARTIST_MERGE }

sub _merge_model { 'Artist' }
sub subscription_model { shift->c->model('Artist')->subscription }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
