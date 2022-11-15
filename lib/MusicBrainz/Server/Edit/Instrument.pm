package MusicBrainz::Server::Edit::Instrument;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Instrument') }

around editor_may_edit => sub {
    my ($orig, $self) = @_;
    return $self->$orig && $self->editor->is_relationship_editor;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
