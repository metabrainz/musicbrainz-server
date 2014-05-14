package MusicBrainz::Server::Edit::Instrument::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_DELETE :expire_action :quality );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Instrument';

sub edit_name { N_l('Remove instrument') }
sub edit_type { $EDIT_INSTRUMENT_DELETE }

sub _delete_model { 'Instrument' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
