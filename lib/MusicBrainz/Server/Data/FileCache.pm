package MusicBrainz::Server::Data::FileCache;
use Moose;
use namespace::autoclean;

use DBDefs;

with 'MusicBrainz::Server::Data::Role::Context';

sub modified {
    my ($self, $path) = @_;
    $path = DBDefs::STATIC_FILES_DIR . "/$path";
    my $cache = $self->c->cache('file-cache');
    my $key = "mtime:$path";

    my $mtime = $cache->get($key);
    unless (defined $mtime) {
        $mtime = (stat($path))[9];
        $cache->set($key, $mtime);
    }

    return $mtime;
}

__PACKAGE__->meta->make_immutable;
1;
