package MusicBrainz::Server::View::Default;
use strict;
use warnings;

use base 'Catalyst::View::TT';
use DBDefs;
use MRO::Compat;
use MusicBrainz::Server::Data::Utils;
use MusicBrainz::Server::Translation;
use MusicBrainz::Server::View::Base;

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt');

sub process {
    my $self = shift;
    my $c = $_[0];

    MusicBrainz::Server::View::Base::process($self, @_) or return 0;
    $self->next::method(@_) or return 0;
    MusicBrainz::Server::View::Base::_post_process($self, @_);
}

sub boolean_to_json {
    my ($self, $c, $bool) = @_;
    MusicBrainz::Server::Data::Utils::boolean_to_json($bool);
}

sub comma_list {
    my ($self, $c, $items) = @_;

    if (ref($items) ne 'ARRAY') {
        $items = [$items];
    }

    MusicBrainz::Server::Translation::comma_list(@$items);
}

sub comma_only_list {
    my ($self, $c, $items) = @_;

    if (ref($items) ne 'ARRAY') {
        $items = [$items];
    }

    MusicBrainz::Server::Translation::comma_only_list(@$items);
}

sub form_to_json {
    my ($self, $c, $form_or_field) = @_;
    MusicBrainz::Server::Form::Role::ToJSON::TO_JSON($form_or_field);
}

1;
