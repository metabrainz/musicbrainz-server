package MusicBrainz::Server::Edit::Historic::Label;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

use MusicBrainz::Server::Edit::Historic::Utils
    qw(upgrade_date upgrade_id );

my $value_mapping = {
    type_id    => \&upgrade_id,
    country_id => \&upgrade_id,
    begin_date => \&upgrade_date,
    end_date   => \&upgrade_date
};

my $key_mapping = {
    LabelName  => 'name',
    SortName   => 'sort_name',
    Country    => 'country_id',
    LabelCode  => 'label_code',
    Type       => 'type_id',
    Resolution => 'comment',
    BeginDate  => 'begin_date',
    EndDate    => 'end_date',
};

sub upgrade_attribute {
    my ($self, $key, $value) = @_;

    my $attribute = $key_mapping->{$key} or return ();
    my $inflator  = $value_mapping->{$attribute};

    $value = defined $inflator
        ? $inflator->($value)
            : $value eq '' ? undef : $value;

    return ($attribute => $value);
};

sub upgrade_hash {
    my ($self, $hash) = @_;
    return {
        map {
            $self->upgrade_attribute($_, $hash->{$_});
        } keys %$hash
    };
};

1;
