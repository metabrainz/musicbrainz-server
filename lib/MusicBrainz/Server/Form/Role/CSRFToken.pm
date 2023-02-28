package MusicBrainz::Server::Form::Role::CSRFToken;
use utf8;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;
use MusicBrainz::Server::Translation qw( l N_l );

my $error_message = N_l(
    'The form you’ve submitted has expired. ' .
    'Please resubmit your request.'
);

sub localize_error {
    my ($self, @message) = @_;
    return l(@message);
}

has_field 'csrf_token' => (
    type => 'Hidden',
    required => 1,
    not_nullable => 1,
    messages => {required => $error_message},
    localize_meth => \&localize_error,
    # There's no case where we'd ever want fif to use the input value,
    # since the CSRF token acts as a nonce. (We reset the token in
    # `BUILDARGS` below.)
    fif_from_value => 1,
);

has_field 'csrf_session_key' => (
    type => 'Hidden',
    required => 1,
    not_nullable => 1,
    messages => {required => $error_message},
    localize_meth => \&localize_error,
    fif_from_value => 1,
);

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    my $args = $class->$orig(@args);

    my $c = $args->{ctx};

    my ($session_key, $token) = $c->generate_csrf_token;

    $args->{init_object} = {
        %{ $args->{init_object} // {} },
        csrf_token => $token,
        csrf_session_key => $session_key,
    };

    # Some controllers pass `item` to the form constructor. In those
    # cases we still want to fall back to init_object for csrf_token.
    $args->{use_init_obj_when_no_accessor_in_item} = 1;

    return $args;
};

around validate => sub {
    my ($orig, $self, @args) = @_;

    my $session_key_field = $self->field('csrf_session_key');
    my $token_field = $self->field('csrf_token');

    unless (
        $session_key_field->has_errors ||
        $token_field->has_errors
    ) {
        my $session_key = $session_key_field->value;
        my $expected_token = $self->ctx->get_csrf_token($session_key);
        my $got_token = $token_field->value;

        unless (
            $got_token && $expected_token &&
            $got_token eq $expected_token
        ) {
            $token_field->push_errors(
                l('The form you’ve submitted has expired. ' .
                  'Please resubmit your request.'),
            );
        }
    }

    $session_key_field->value($session_key_field->init_value);
    $token_field->value($token_field->init_value);

    return $self->$orig(@args);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
