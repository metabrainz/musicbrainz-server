package MusicBrainz::Server::Edit::Work::Delete;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_DELETE $EDITOR_MODBOT );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Work';

sub edit_name { N_l('Remove work') }
sub edit_type { $EDIT_WORK_DELETE }
sub _delete_model { 'Work' }
sub work_id { shift->entity_id }

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{Work} = {
        $self->work_id => [ ]
    };
    return $data;
};

__PACKAGE__->meta->make_immutable;
1;
