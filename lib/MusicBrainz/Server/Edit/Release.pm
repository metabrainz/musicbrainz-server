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

1;
