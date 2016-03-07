package MusicBrainz::Server::Authentication::User;
use Moose;
extends 'MusicBrainz::Server::Entity::Editor';

has 'auth_realm' => (
    isa => 'Str',
    is => 'rw'
);

sub supports
{
    my ($self, @spec) = @_;
    my $supported = { session => 1 };
    for (@spec) {
        return unless exists $supported->{$_};
    }
    return 1;
}

sub get
{
    my ($self, $key) = @_;
    return $self->can($key) ? $self->$key : undef;
}

sub new_from_editor
{
    my ($class, $editor) = @_;

    return undef
        unless $editor;

    return Class::MOP::Class->initialize($class)->rebless_instance($editor);
}

sub is_authorized { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
