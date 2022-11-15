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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
