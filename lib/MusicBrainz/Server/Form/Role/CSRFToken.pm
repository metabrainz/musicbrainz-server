package MusicBrainz::Server::Form::Role::CSRFToken;

use utf8;
use HTML::FormHandler::Moose::Role;
use MusicBrainz::Server::Data::Utils qw( generate_token );
use MusicBrainz::Server::Translation qw( l N_l );

has_field 'csrf_token' => (
    type => 'Hidden',
    required => 1,
    not_nullable => 1,
    messages => {
        required => N_l('The form you’ve submitted has expired. Please resubmit your request.'),
    },
    localize_meth => sub {
        my ($self, @message) = @_;
        return l(@message);
    },
    # There's no case where we'd ever want fif to use the input value,
    # since the CSRF token acts as a nonce. (We reset the token in
    # `validate` below.)
    fif_from_value => 1,
);

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    my $args = $class->$orig(@args);

    my $c = $args->{ctx};
    my $token;
    if ($c->req->method eq 'POST') {
        $token = $c->get_csrf_token($class);
    }
    if (!defined $token) {
        $token = $c->generate_csrf_token($class);
    }

    $args->{init_object} = {
        %{ $args->{init_object} // {} },
        csrf_token => $token,
    };

    # Some controllers pass `item` to the form constructor. In those
    # cases we still want to fall back to init_object for csrf_token.
    $args->{use_init_obj_when_no_accessor_in_item} = 1;

    return $args;
};

around validate => sub {
    my ($orig, $self, @args) = @_;

    my $field = $self->field('csrf_token');

    unless ($field->has_errors) {
        my $got_token = $field->value;
        my $expected_token = $field->init_value;

        unless (
            $got_token && $expected_token &&
            $got_token eq $expected_token
        ) {
            $field->push_errors(
                l('The form you’ve submitted has expired. ' .
                  'Please resubmit your request.'),
            );
        }
    }

    $field->value($self->ctx->generate_csrf_token(ref $self));

    return $self->$orig(@args);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
