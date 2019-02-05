package MusicBrainz::Server::Entity::URL::ASIN;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

use DBDefs;

sub pretty_name
{
    my $self = shift;

    if ($self->url =~ m{^(?:https?:)?//(?:www.)?(.*?\.)([a-z]+)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i) {
        my $country = $2;
        $country = 'US' if $country eq 'com';
        $country =~ tr/a-z/A-Z/;

        return "$country: $3";
    }

    return $self->url->as_string;
}

sub sidebar_name { shift->pretty_name }

override affiliate_url => sub {
    my $self = shift;

    my $url = super();
    if ($url =~ m{^(?:https?:)?//(?:.*?\.)(amazon\.([a-z\.]+))(?:\:[0-9]+)?/[^?]+$}i) {
        my $ass_id = DBDefs->AWS_ASSOCIATE_ID($1);
        return $url unless $ass_id;

        $url = $url->clone;
        $url->query_form(tag => $ass_id);
        return $url;
    }
    return $url;
};

sub url_is_scheme_independent { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
