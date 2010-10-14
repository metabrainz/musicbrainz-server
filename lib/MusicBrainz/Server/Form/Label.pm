package MusicBrainz::Server::Form::Label;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::DatePeriod';
with 'MusicBrainz::Server::Form::Role::CheckDuplicates';

has '+name' => ( default => 'edit-label' );

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'sort_name' => (
    type => 'Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'label_code' => (
    type => 'Integer',
    size => 5,
);

has_field 'country_id' => (
    type => 'Select',
);

has_field 'comment' => (
    type      => 'Text',
    maxlength => 255
);

sub edit_field_names
{
    return qw( name sort_name comment type_id country_id
               begin_date end_date label_code );
}

sub options_type_id    { shift->_select_all('LabelType') }
sub options_country_id { shift->_select_all('Country') }

sub dupe_model { shift->ctx->model('Label') }

1;
