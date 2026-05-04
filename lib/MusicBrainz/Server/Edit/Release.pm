package MusicBrainz::Server::Edit::Release;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Release') }

requires 'release_ids';

sub check_event_countries {
    my ($self, $events) = @_;

    my $countries = {};

    for (@$events) {
        my $country_id = $_->{country_id} // 'undef';
        if (exists $countries->{$country_id}) {
            die "Duplicate release country: $country_id";
        }
        $countries->{$country_id} = 1;
    }
}

sub throw_if_release_label_is_duplicate {
    my ($self, $release, $new_label_id, $new_catalog_number) = @_;

    my $is_duplicate = $self->c->sql->select_single_value(
        <<~'SQL',
        SELECT 1
          FROM release_label
         WHERE release = ?
           AND label IS NOT DISTINCT FROM ?
           AND catalog_number IS NOT DISTINCT FROM ?
        SQL
        $release->id,
        $new_label_id,
        $new_catalog_number,
    );

    if ($is_duplicate) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'The label and catalog number in this edit already exist on the release.',
        );
    }
}

1;
