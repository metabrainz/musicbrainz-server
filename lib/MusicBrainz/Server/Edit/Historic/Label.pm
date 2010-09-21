package MusicBrainz::Server::Edit::Historic::Label;
use Moose::Role;

use MusicBrainz::Server::Edit::Historic::Utils
    qw(upgrade_date upgrade_id );

with 'MusicBrainz::Server::Edit::Historic::HashUpgrade' =>
{
    value_mapping => {
        type_id    => \&upgrade_id,
        country_id => \&upgrade_id,
        begin_date => \&upgrade_date,
        end_date   => \&upgrade_date
    },
    key_mapping => {
        LabelName  => 'name',
        SortName   => 'sort_name',
        Country    => 'country_id',
        LabelCode  => 'label_code',
        Type       => 'type_id',
        Resolution => 'comment',
        BeginDate  => 'begin_date',
        EndDate    => 'end_date',
    }
};

no Moose::Role;
1;
