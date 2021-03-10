package MusicBrainz::Server::Plugin::React;

use strict;
use warnings;

use base 'Template::Plugin';
use MusicBrainz::Server::ControllerUtils::JSON;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Util::JSON;
use MusicBrainz::Server::Renderer qw( render_component );

sub embed {
    my ($self, $c, $component, $props) = @_;

    my $response = render_component($c, $component, $props);
    my $status = $response->{status};
    if (!defined $status || $status == 200) {
        return $response->{body};
    } else {
        die $response->{body};
    }
}

sub bool {
    my ($self, $bool) = @_;
    boolean_to_json($bool);
}

sub to_json_array {
    my ($self, $value) = @_;
    MusicBrainz::Server::Entity::Util::JSON::to_json_array($value);
}

sub to_json_object {
    my ($self, $value) = @_;
    MusicBrainz::Server::Entity::Util::JSON::to_json_object($value);
}

sub serialize_pager {
    my ($self, $pager) = @_;
    if (((ref $pager) // '') eq 'Data::Page') {
        return MusicBrainz::Server::ControllerUtils::JSON::serialize_pager($pager);
    }
    return undef;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
