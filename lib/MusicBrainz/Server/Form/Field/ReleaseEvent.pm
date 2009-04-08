package MusicBrainz::Server::Form::Field::ReleaseEvent;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Field::Compound';

use MusicBrainz::Server::ReleaseEvent;

sub profile
{
    return {
        optional => {
            date    => {
                type  => '+MusicBrainz::Server::Form::Field::Date',
                order => 1,
            },
            country => {
                type  => 'Select',
                order => 2,
            },
            label   => {
                type  => 'Text',
                order => 3,
            },
            catalog => {
                type  => 'Text',
                order => 4,
            },
            barcode => {
                type  => '+MusicBrainz::Server::Form::Field::Barcode',
                order => 5,
            },
            format  => {
                type  => 'Select',
                order => 6
            },
            remove => 'Checkbox',
            confirmed => 'Checkbox',
        }
    }
}

sub options_country
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $c = MusicBrainz::Server::Country->new($mb->{dbh});

    return map { $_->id => $_->name } $c->All;
}

sub options_format
{
    MusicBrainz::Server::ReleaseEvent::release_formats;
}

sub field_value
{
    my ($self, $field_name, $event) = @_;

    use Switch;
    switch ($field_name)
    {
        case (/date/) { return $event->sort_date; }
        case ('format') { return $event->format; }
        case ('barcode') { return $event->barcode; }
        case ('label') { return $event->label->name || ''; }
        case ('country') { return $event->country; }
        case ('catalog') { return $event->cat_no; }
    }
}

=head2 extra_validation

Check that the given catalog number does not look like an ASIN, and if it does
that the user has confirmed that they know what they are doing

=cut

sub extra_validation
{
    my $self = shift;
    my $form = $self->sub_form;

    my $cat_no = $form->value('catalog');
    if ($cat_no =~ /^B00[0-9A-Z]{7}$/)
    {
        $form->field('confirmed')->required(1);
        $form->field('confirmed')->validate_field or return;
    }

    return 1;
}

1;
