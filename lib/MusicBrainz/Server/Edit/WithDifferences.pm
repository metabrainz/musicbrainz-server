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
        if (ref $mapped eq 'CODE') {
            $_ => $mapped->($instance)
        }
        else {
            my $value = $instance->$mapped;
            $_ => defined($value) ? "$value" : undef;
        }
    } @keys;
    return \%old;
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
