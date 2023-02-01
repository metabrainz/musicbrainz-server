package MusicBrainz::Server::Form::Field::OAuthRedirectURI;
use URI;
use Moose;

extends 'HTML::FormHandler::Field::Text';

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->value;
    $url = URI->new($url)->canonical;

    $self->_set_value($url->as_string);
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
