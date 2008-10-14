package MicroForms::Form;

use Moose;

has 'bound_data' => (
    isa => 'ArrayRef[Str]',
    is  => 'r'
);

1;
