package MusicBrainz::Server::Edit::Role::AlwaysAutoEdit;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( $EXPIRE_ACCEPT :quality );

around 'edit_conditions' => sub {
    my $conditions = {
        duration      => 0,
        votes         => 0,
        expire_action => $EXPIRE_ACCEPT,
        auto_edit     => 1,
    };
    return {
        $QUALITY_LOW    => $conditions,
        $QUALITY_NORMAL => $conditions,
        $QUALITY_HIGH   => $conditions,
    };
};

around 'allow_auto_edit' => sub { 1 };

1;
