package MusicBrainz::Server::Form::Label::Base;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz::Server::Validation;

sub name { 'label' }

sub profile
{
    shift->with_mod_fields({
        required => {
            name       => 'Text',
            sort_name  => 'Text',
            type       => 'Select',
        },
        optional => {
            begin_date => '+MusicBrainz::Server::Form::Field::Date',
            end_date   => '+MusicBrainz::Server::Form::Field::Date',
            label_code => '+MusicBrainz::Server::Form::Field::LabelCode',
            country    => 'Select',

            # We make this required if duplicates are found,
            # or if a resolution is present when we edit the artist.
            resolution => {
                type             => 'Text',
                required_message => 'A label with this name already exists. '.
                                    'Please enter a comment about this label for disambiguation',
            },

            # We make this required if duplicates are found
            confirmed => 'Checkbox',
        }
    });
}

sub options_country
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $c = MusicBrainz::Server::Country->new($mb->{dbh});

    return map { $_->id => $_->name } $c->All;
}

sub options_type
{
    my $types = MusicBrainz::Server::Label::GetLabelTypes;

    return map {
        $_->[0] => sprintf("%s%s", $_->[3] ? '&nbsp;&nbsp;' : '', $_->[1]),
    } @$types;
}

=head2 model_validate

If the new label name already exists, make sure that the resolution field
is required

=cut

sub model_validate
{
    my $self = shift;

    my $label  = MusicBrainz::Server::Label->new($self->context->mb->{dbh});
    my $labels = $label->find_labels_by_name($self->value('name'));

    # Filter labels that have the same name but a different id
    # if item_id is false, we are probably creating a new label - so count everything as
    # a duplicate
    my @dupes = grep { defined $self->item ? $_->id != $self->item->id : 1 } @$labels;

    if (scalar @dupes)
    {
        $self->field('confirmed')->required(1);
        $self->field('confirmed')->validate_field;

        $self->field('resolution')->required(1);
        $self->field('resolution')->validate_field;
    }
}

=head2 cross_validate

Cross validate all fields to ensure start and end date are in chronological
order.

=cut

sub cross_validate
{
    my $self = shift;

    my ($sy, $sm, $sd) = grep { $_ > 0 } split m/-/, $self->value('begin_date');
    my ($ey, $em, $ed) = grep { $_ > 0 } split m/-/, $self->value('end_date');

    my @start = ($sy, $sm, $sd);
    my @end = ($ey, $em, $ed);

    if (MusicBrainz::Server::Validation::IsDateEarlierThan(@end, @start))
    {
        $self->field('end_date')->add_error('Label end date must be after the start date');
    }
}

sub init_value
{
    my $self = shift;
    my ($field, $item) = @_;

    $item ||= $self->item;

    return unless defined $item;

    if ($field->name eq 'resolution' && $item->resolution)
    {
        $field->required(1);
    }

    $self->SUPER::init_value(@_);
}

1;
