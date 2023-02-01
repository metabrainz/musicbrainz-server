package MusicBrainz::Server::Edit::Series::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_ADD_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Series',
    edit_name => N_l('Add series alias'),
    edit_type => $EDIT_SERIES_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
