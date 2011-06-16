package MusicBrainz::Server::Controller::WS::js::Role::AliasAutocompletion;
use Moose::Role;

use MusicBrainz::Server::Data::Search qw( alias_query );

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

around _form_indexed_query => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my $query = $self->$orig(@_);
    return alias_query ($self->type, $query);
};

1;
