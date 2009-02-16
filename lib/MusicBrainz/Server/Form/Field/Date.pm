package MusicBrainz::Server::Form::Field::Date;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Field::Compound';

use MusicBrainz::Server::Validation;

=head1 NAME

MusicBrainz::Server::Form::Field::Date

=head1 DESCRIPTION

A field for entering dates in 3 separate fields.

=head1 METHODS

=cut

sub profile
{
    return {
        optional => {
            year => {
                type  => 'Integer',
                order => 1,
                size  => 4,
            },
            month => {
                type  => 'Integer',
                order => 2,
                size  => 2,
            },
            day  => {
                type  => 'Integer',
                order => 3,
                size  => 2,
            },
        }
    }
}

=head2 input_to_value

Convert the data that was input (parsed in validate_field) to a single
scalar value and store it in the fields value property.

=cut

sub input_to_value
{
    my $self = shift;

    $self->SUPER::input_to_value;

    my $old_value = $self->value;

    $self->value(
        MusicBrainz::Server::Validation::MakeDBDateStr(
            $old_value->{year},
            $old_value->{month},
            $old_value->{day}
        )
    );
}

=head2 validate_field

Validate that what was entered was indeed a valid date.

=cut

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate(scalar $self->form->params);

    return $self->add_error($self->required_text)
        if $self->required && !$self->sub_form->value('year');

    return $self->add_error('Invalid date')
        unless MusicBrainz::Server::Validation::IsValidDateOrEmpty(
            $self->sub_form->value('year'),
            $self->sub_form->value('month'),
            $self->sub_form->value('day'),
        );

    $self->input_to_value;

    return 1;
}

sub field_value
{
    my ($self, $field_name, $data_object) = @_;

    my @components =  map { $_ == 0 ? '' : $_ } split(m/-/, $data_object);

    use Switch;
    switch ($field_name)
    {
        case ('year')  { return $components[0]; }
        case ('month') { return $components[1]; }
        case ('day')   { return $components[2]; }
    }
}

=head1 LICENSE

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
