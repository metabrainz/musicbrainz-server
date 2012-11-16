package MusicBrainz::Server::Edit::CheckForConflicts;
use 5.10.0;
use Moose::Role;
use namespace::autoclean;

use Algorithm::Merge qw( merge );
use JSON::Any;
use MusicBrainz::Server::Edit::Utils qw( merge_value );
use Try::Tiny;

=head1 NAME

MusicBrainz::Server::Edit::CheckForConflicts - add conflict checking to edit
types

=head1 DESCRIPTION

This role can be applied to edit types in order to add conflict checking and
merging of properties. Merges are 3 way, combining data from the source data
when the edit was created, the data as it is currently in the database, and the
new data stored in this edit type. Each property is merged together, and if
there is a conflict a L<MusicBrainz::Server::Edit::Exceptions::FailedDependency>
exception is raised causing the edit to be rejected, and ModBot to leave a
message.

To use this class, you need to consume it and provide the C<current_instance>
method.

=cut

requires 'current_instance';

=method new_data

Returns the 'new' data in the edit type. By default this refers to the 'new'
element in the 'data' section of the edit.

=cut

sub new_data {
    my $self = shift;
    return $self->data->{new};
}

=method ancestor_data

Returns the 'ancestor' data - the data as it was when the edit was created.
By default, this returns the 'old' element in the 'data' section of the edit.

=cut

sub ancestor_data {
    my $self = shift;
    return $self->data->{old};
}

=method extract_property

    $self->extract_property($property, $ancestor, $current, $new)

Extracts a single property (named C<$property>), and returns it along with a
corresponding hash of the value. The default implementation of this treats
C<$ancestor> and C<$new> as hash-references, and access them with C<$property>
as a key. It treats C<$current> as an object, and assumes C<$property> is the
name of a method.

The merge algorithm works on strings, so it's important to return a unique hash
for the value. By default, the hash is simply the value encoded to a JSON
string. It can be useful to override this however, if you need to do more
complicated hashing. For example, see
L<MusicBrainz::Server::Edit::Utils/merge_artist_credit>.

The return value should be a tuple in the following format:

    (
      [ AncestorValueHashed, AncestorValue ],
      [ CurrentValueHashed,  CurrentValue ],
      [ NewValueHashed, NewValue ]
    )

=cut

sub extract_property {
    my ($self, $property, $ancestor, $current, $new) = @_;
    return (
        merge_value($ancestor->{$property}),
        merge_value($current->$property),
        merge_value($new->{$property})
    );
}

=method merge_changes

Attempts to merge all the data together into a single hash-reference, in the
same structure as that in C<new_data>. Each property in C<new_data> is merged
against the C<ancestor_data> and C<old_data> (using L<extract_property> to
determine exactly what the property value is).

If any properties cannot be merged, a FailedDependency exception will be raised,
and the edit will be rejected.

If all merges are successful, a new hash-reference will be returned, which can
be used to update the database.

=cut

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
