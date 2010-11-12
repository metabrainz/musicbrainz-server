package MusicBrainz::Server::Edit::WithDifferences;
use Moose;
use MooseX::ABC;

use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Data::Utils qw( remove_equal );

extends 'MusicBrainz::Server::Edit';

sub _mapping { }

sub _change_hash
{
    my ($self, $instance, @keys) = @_;
    my %mapping = $self->_mapping;
    my %old = map {
        my $mapped = exists $mapping{$_} ? $mapping{$_} : $_;
        $_ => ref $mapped eq 'CODE' ? $mapped->($instance) : '' . $instance->$mapped;
    } @keys;
    return \%old;
}

sub _change_data {
    my ($self, $object, %opts) = @_;
    local $Storable::canonical = 1;

    my $old = $self->_change_hash($object, keys %opts);
    my $new = \%opts;

    remove_equal($old, $new);

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw unless keys %$new && keys %$old;

    return (
        old => $old,
        new => $new
    );
};

1;
