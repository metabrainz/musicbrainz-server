package MusicBrainz::Server::Form::CoverArt;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';

sub edit_field_names { qw( comment type_id position ) }

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1,
);

has_field 'type_id' => (
    type      => 'Select',
    multiple  => 1,
);

sub options_type_id { select_options_tree(shift->ctx, 'CoverArtType') }

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
