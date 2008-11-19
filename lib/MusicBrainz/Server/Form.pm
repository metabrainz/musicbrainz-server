package MusicBrainz::Server::Form;

use strict;
use warnings;

use base 'Form::Processor';

sub profile
{
    return shift->with_mod_fields({});
}

sub context
{
    my ($self, $new) = @_;

    $self->{context} = $new
        if defined $new && ref $new;

    return $self->{context};
}

=head2 with_mod_fields [$%profile]

Adds fields for entering an edit note and acting as an auto-editor to
any form profile. $profile is a hash reference to a normal
Form::Processor profile.

C<$profile> may also be undef, in which case you will simply get back
fields for an edit note and whether to enable auto-editor
privileges. This is useful in scenarios when you are just confirming
something with the user.

=cut

sub with_mod_fields
{
    my ($self, $profile) = @_;

    return {
        required => {
            %{ $profile->{required} || {} },
        },
        optional => {
            %{ $profile->{optional} || {} },
            edit_note      => 'TextArea',
            as_auto_editor => 'Checkbox',
        }
    };
}

1;
