package MusicBrainz::Server::Form::Field::Date;

use strict;
use warnings;

use base 'Form::Processor::Field';

use MusicBrainz::Server::Validation;

=head1 NAME

MusicBrainz::Server::Form::Field::Date

=head1 DESCRIPTION

A field for entering dates in 3 separate fields.

=head1 METHODS

=head2 init_widget

This field has type 'date' - we specialise on this in the forms/input.tt template

=cut

sub init_widget { 'date' }

=head2 input_to_value

Convert the data that was input (parsed in validate_field) to a single
scalar value and store it in the fields value property.

=cut

sub input_to_value {
    my ($self, %date) = @_;
    $self->value(
        MusicBrainz::Server::Validation::MakeDBDateStr(
            $date{year},
            $date{month},
            $date{day}
        )
    );
}

=head2 validate_field

Validate that what was entered was indeed a valid date.

=cut

sub validate_field {
    my $self = shift;

    my $params = $self->form->params;
    my $name = $self->name;

    my %date;
    for my $field ( qw/ year month day / )
    {
        my $value = $params->{$name . "_" . $field};
        next unless $value;

        unless ($value =~ /^\d+$/) {
            $self->add_error('Date can only contain numeric values');
            return;
        }

        $date{$field} = $value;
    }

    if ($self->required && !($date{year}))
    {
        $self->add_error($self->required_text);
        return;
    }

    unless(MusicBrainz::Server::Validation::IsValidDateOrEmpty($date{year}, $date{month}, $date{day}))
    {
        $self->add_error('Invalid date');
        return;
    }

    $self->input_to_value(%date);

    1;
}

=head2 date

Return the components of this field, split into a hash for easy use in templates.

=cut

sub date {
    my $self = shift;
  
    my @split = map { $_ == '00' ? '' : $_} split(m/-/, $self->value || '');

    return {
        year => $split[0],
        month => $split[1],
        day => $split[2]
    };
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
