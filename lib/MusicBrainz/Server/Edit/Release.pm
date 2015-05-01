package MusicBrainz::Server::Edit::Release;
use Moose::Role;
use namespace::autoclean;

use List::Util qw( max );
use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Release') }

requires 'release_ids';

sub determine_quality { }
around determine_quality => sub {
    my ($orig, $self) = @_;

    return max map { $_->quality } values %{ $self->c->model('Release')->get_by_ids( $self->release_ids ) };
};

sub check_event_countries {
    my ($self, $events) = @_;

    my $countries = {};

    for (@$events) {
        if (exists $countries->{$_->{country_id}}) {
            die "Duplicate release country: " . ($_->{country_id} // 'undef');
        }
        $countries->{$_->{country_id}} = 1;
    }
}

sub throw_if_release_label_is_duplicate {
    my ($self, $release, $new_label_id, $new_catalog_number) = @_;

    $new_label_id //= 0;
    $new_catalog_number //= '';

    for ($release->all_labels) {
        my $label_id = $_->label_id // 0;
        my $catalog_number = $_->catalog_number // '';

        if ($label_id == $new_label_id && $catalog_number eq $new_catalog_number) {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
                'The label and catalog number in this edit already exist on the release.'
            );
        }
    }
}

1;
