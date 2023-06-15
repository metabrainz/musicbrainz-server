package MusicBrainz::Server::Report::EditorReport;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

around inflate_rows => sub {
    my ($orig, $self, $rows, $c) = @_;

    my $items = $self->$orig($rows, $c);

    my $editors = $self->c->model('Editor')->get_by_ids(
        map { $_->{id} } @$items
    );

    return [
        map {
            my $item = $_;
            my $editor = $editors->{ $item->{id} };
            my $result = {
                %{$item},
                editor => (defined $editor && $c->user_exists) ? (
                    $c->user->is_account_admin
                        ? $c->unsanitized_editor_json($editor)
                        : to_json_object($editor)
                ) : undef,
            };
            $result
        } @$items
    ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
