package MusicBrainz::Server::Edit::CheckForConflicts;
use Moose::Role;
use namespace::autoclean;

use Algorithm::Merge qw( merge );
use JSON::Any;
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

sub merge_changes {
    my ($self) = @_;

    my $json = JSON::Any->new( utf8 => 1 );
    my $merged = {};

    my $ancestor = $self->ancestor_data;
    my $new = $self->new_data;
    my $current = $self->current_instance;

    try {
        for my $name (keys %$new) {
            my ($json_val) = merge(
                [ $json->objToJson([ $ancestor->{$name} ]) ],
                [ $json->objToJson([ $self->_property_to_edit($current, $name) ]) ],
                [ $json->objToJson([ $new->{$name} ]) ],
                { CONFLICT => sub { die bless({}, 'Conflict') } }
            );

            ($merged->{$name}) = @{ $json->jsonToObj($json_val) };
        }
    }
    catch {
        if (eval { $_->isa('Conflict') }) {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency
                  ->throw('Data has changed since this edit was created, and now conflicts ' .
                              'with changes made in this edit.');
        }
    };

    return $merged;
}

1;
