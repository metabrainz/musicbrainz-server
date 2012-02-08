package MusicBrainz::WebService::RequestParser::JSON;
use Moose;
use namespace::autoclean;

with 'Sloth::RequestParser';

use JSON::Any;

sub parse {
    my ($self, $request) = @_;
    return %{
        JSON::Any->new( utf8 => 1 )->jsonToObj(do { local $/ = undef; my $b = $request->body; <$b> })
    };
}

__PACKAGE__->meta->make_immutable;
1;
