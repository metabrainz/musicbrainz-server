package MusicBrainz::Server::Controller::Account::Subscriptions::Label;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::Controller::Account::SubscriptionsRole';

__PACKAGE__->config( model => 'Label' );

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
