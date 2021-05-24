package MusicBrainz::Server::Form::User::Login;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l N_l );
extends 'HTML::FormHandler';

with 'MusicBrainz::Server::Form::Role::ToJSON';
with 'MusicBrainz::Server::Form::Role::CSRFToken';

has_field 'username' => (
    type => 'Text',
    required => 1,
    messages => { required => N_l('Username field is required') },
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
);

has_field 'password' => (
    type => 'Password',
    required => 1,
    min_length => 1,
    messages => { required => N_l('Password field is required') },
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
);

has_field 'remember_me' => (
    type => 'Boolean'
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
