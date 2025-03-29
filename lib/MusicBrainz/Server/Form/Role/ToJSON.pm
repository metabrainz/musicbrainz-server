package MusicBrainz::Server::Form::Role::ToJSON;

use JSON;
use Moose::Role;
use MusicBrainz::Server::Form::Utils qw( form_or_field_to_json );

sub TO_JSON { form_or_field_to_json(shift) }

sub to_encoded_json {
    JSON->new->utf8(0)->encode(shift->TO_JSON);
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt
