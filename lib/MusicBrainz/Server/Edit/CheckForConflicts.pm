package MusicBrainz::Server::Edit::CheckForConflicts;
use Moose::Role;
use namespace::autoclean;

use Algorithm::Merge qw( merge );
use JSON::Any;
use MusicBrainz::Server::Log qw( log_debug );
use Try::Tiny;

requires 'current_instance', '_property_to_edit';

sub new_data {
    my $self = shift;
    return $self->data->{new};
}

sub ancestor_data {
    my $self = shift;
    return $self->data->{old};
}

my $json = JSON::Any->new( utf8 => 1 );
sub extract_property {
    my ($self, $property, $ancestor, $current, $new) = @_;
    return (
        [$json->objToJson([ $ancestor->{$property} ]), $ancestor->{$property},],
        [$json->objToJson([ $self->_property_to_edit($current, $property) ]), $self->_property_to_edit($current, $property) ],
        [$json->objToJson([ $new->{$property} ]), $new->{$property} ],
    );
}

sub merge_changes {
    my ($self) = @_;

    my $merged = {};

    my $ancestor_data = $self->ancestor_data;
    my $new_data      = $self->new_data;
    my $current_data  = $self->current_instance;

    try {
        for my $name (keys %$new_data) {
            my ($ancestor, $current, $new) =
                $self->extract_property(
                    $name,
                    $ancestor_data,
                    $current_data,
                    $new_data
                );

            # Stores a mapping of the JSON serialization to the object value
            my %hashed = map { @$_ } ($ancestor, $current, $new);

            # Attempt to merge all JSON values together
            my ($json_val) = merge(
                (map +[ $_->[0] ], ($ancestor, $current, $new)),
                { CONFLICT => sub {
                    die bless({
                        property => $name,
                        ancestor => $ancestor,
                        current  => $current,
                        new      => $new
                    }, 'Conflict')
                } }
            );

            # Resolve that JSON value back to it's actual value
            $merged->{$name} = $hashed{$json_val};
        }
    }
    catch {
        if (eval { $_->isa('Conflict') }) {
            log_debug { "Conflict detected: $_" } $_;
            MusicBrainz::Server::Edit::Exceptions::FailedDependency
                  ->throw('Data has changed since this edit was created, and now conflicts ' .
                              'with changes made in this edit.');
        }
        else {
            die $_;
        }
    };

    return $merged;
}

1;
