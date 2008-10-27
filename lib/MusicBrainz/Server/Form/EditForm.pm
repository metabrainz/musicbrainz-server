package MusicBrainz::Server::Form::EditForm;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

=head1 NAME

MusicBrainz::Server::EditForm - base for forms that enter moderations

=head1 SYNOPSIS

    package MyForm;

    use base 'MusicBrainz::Server::Form::EditForm';

    sub mod_type { ModDefs::MOD_EDIT_ARIST }

    sub build_options
    {
        my $self = shift;
        return { artist => $self->item };
    }

    sub profile
    {
        return {
            required => { ... },
            optional => { ... },
        };
    }

    package MyController;

    sub action : Local
    {
        my ($self, $c) = @_;

        my $entity = whatever...;
        
        my $form = $c->form($entity, 'MyForm');

        return unless $c->form_posted && $form->validate($c->req->params);

        $form->insert;
    }

=head1 DESCRIPTION

EditForm provides a base for creating forms that perform logic by entering
data into the moderation queue. Subclassing this class enables you to
build forms that perform these interactions, while writing a minimal
amount of code.

=head1 REQUIRED METHODS

=head2 mod_type

Returns the type of moderation to insert. See L<ModDefs/Moderation Types>.

=cut

sub mod_type
{
    my $self = shift;

    croak (ref $self) . " does not implement mod_type";
}

=head2 build_options @args?

Build all the arguments required to insert this moderation.

Return a hash reference

=cut

sub build_options
{
    my $self = shift;

    croak (ref $self) . " does not implement build_options";
}

=head1 METHODS

=head2 insert

Insert this moderation into the queue, using data provided in the form.

=cut

sub insert
{
    my ($self, @args) = @_;

    my $user = $self->context->user;

    my %opts = (
        DBH       => $self->context->mb->{DBH},
        moderator => $user,
        type      => $self->mod_type,
    );

    my $mod_opts = $self->build_options(@args);

    for my $key (keys %$mod_opts)
    {
        $opts{$key} = $mod_opts->{$key};
    }

    my @mods = Moderation->InsertModeration(%opts);

    my @edit_fields = grep { $_->name eq 'edit_note' } @{ $self->fields };
    if (scalar @mods && scalar @edit_fields)
    {
        my $field = $edit_fields[0];

        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;

    }

    return @mods;
}

1;
