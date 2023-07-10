package MusicBrainz::Server::Edit::WithDifferences;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Data::Utils qw( remove_equal );
use Scalar::Util qw(blessed);

extends 'MusicBrainz::Server::Edit';

sub _mapping { }

sub _change_hash
{
    my ($self, $instance, @keys) = @_;
    my %old = map {
        $_ => $self->_property_to_edit($instance, $_);
    } @keys;
    return \%old;
}

sub _property_to_edit {
    my ($self, $instance, $property) = @_;

    my %mapping = $self->_mapping;

    my $mapped = exists $mapping{$property} ? $mapping{$property} : $property;
    if (ref $mapped eq 'CODE') {
        return $mapped->($instance)
    }
    elsif (blessed $instance)
    {
        my $value = $instance->$mapped;
        return defined($value) ? "$value" : undef;
    }
    else
    {
        return $instance->{$mapped};
    }
}

sub _changes {
    my ($self, $object, %opts) = @_;

    my $old = $self->_change_hash($object, keys %opts);
    my $new = \%opts;

    remove_equal($old, $new);

    return (
        old => $old,
        new => $new
    );
}

sub _change_data {
    my ($self, $object, %opts) = @_;

    my %data = $self->_changes($object, %opts);
    my ($new, $old) = @data{qw( new old )};
    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
          unless keys %$new && keys %$old;

    return %data;
};

1;
