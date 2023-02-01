package MusicBrainz::Server::Edit::Work::Delete;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_DELETE );
use MusicBrainz::Server::Translation qw( N_l );

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
