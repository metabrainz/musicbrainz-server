package MusicBrainz::Server::Form::Field::Date;

use strict;
use warnings;

use base 'Form::Processor::Field';

use MusicBrainz::Server::Validation;

sub init_widget { 'date' }

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

# Really don't like how I'm handling this, but I see no other way to get the data from the value to the html form.
sub date {
    my $self = shift;
  
    my @split = map { $_ == '00' ? '' : $_} split(m/-/, $self->value);

    return {
        year => $split[0],
        month => $split[1],
        day => $split[2]
    };
}

1;
