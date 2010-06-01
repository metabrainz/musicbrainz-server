package MusicBrainz::Server::Edit::Historic::Artist;
use Moose::Role;

use MusicBrainz::Server::Edit::Historic::Utils
    'upgrade_date', 'upgrade_id';

with 'MusicBrainz::Server::Edit::Historic::HashUpgrade' => {
    value_mapping => {
        type_id    => \&upgrade_id,
        begin_date => \&upgrade_date,
        end_date   => \&upgrade_date,
    },
    key_mapping => {
        ArtistName => 'name',
        SortName   => 'sort_name',
        Resolution => 'comment',
        Type       => 'type_id',
        BeginDate  => 'begin_date',
        EndDate    => 'end_date',
    }
};

no Moose::Role;
1;
