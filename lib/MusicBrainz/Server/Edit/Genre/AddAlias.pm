package MusicBrainz::Server::Edit::Genre::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_GENRE_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Alias::Add' => {
    model => 'Genre',
    edit_name => N_l('Add genre alias'),
    edit_type => $EDIT_GENRE_ADD_ALIAS,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
