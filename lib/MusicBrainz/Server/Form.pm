package MusicBrainz::Server::Form;

use strict;
use warnings;

use base 'Form::Processor';

use Rose::Object::MakeMethods::Generic(
    array => [
        general_errors => {  },
        add_general_error => { interface => 'push', hash_key => 'general_errors' },
    ],
);

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

sub check_volatile_prefs
{
    my $self = shift;
    my $c = shift;

    return unless $c->user_exists &&
        $c->user->is_auto_editor($c->session->{orig_privs});

    my %fields = map { $_->name => 1 } @{ $self->fields };
    if ($fields{as_auto_editor})
    {
        use MusicBrainz::Server::Editor;
        my $p = 0 + $c->session->{session_privs};
        if ($self->value('as_auto_editor'))
        {
            $p |= MusicBrainz::Server::Editor::AUTOMOD_FLAG;
        }
        else
        {
            $p &= ~(MusicBrainz::Server::Editor::AUTOMOD_FLAG);
        }

        $c->session->{session_privs} = $p;
        $c->user->privs($p);
    }
}

sub has_required_fields
{
    my $self = shift;
    for my $field ($self->fields)
    {
        return 1 if $field->required;
    }

    return;
}

1;
