package MusicBrainz::Server::Form::Label;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::IPI';
with 'MusicBrainz::Server::Form::Role::ISNI';
with 'MusicBrainz::Server::Form::Role::Relationships';

has '+name' => ( default => 'edit-label' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'label_code' => (
    type => '+MusicBrainz::Server::Form::Field::LabelCode',
    size => 5,
);

has_field 'area_id'   => ( type => 'Hidden' );
has_field 'area' => ( type => '+MusicBrainz::Server::Form::Field::Area' );

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

sub edit_field_names
{
    return qw( name comment type_id area_id period.begin_date
               period.end_date period.ended label_code ipi_codes isni_codes );
}

sub options_type_id { select_options_tree(shift->ctx, 'LabelType') }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
