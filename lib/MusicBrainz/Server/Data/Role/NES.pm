package MusicBrainz::Server::Data::Role::NES;
use Moose::Role;

with 'MusicBrainz::Server::Data::Role::Context';

sub request {
    my $self = shift;
    return $self->c->nes->request(@_);
}

1;
