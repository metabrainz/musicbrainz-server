package MusicBrainz::Server::Test::RDFa;

use Test::Builder;
use RDF::RDFa::Parser;
use HTML::HTML5::Parser;
use HTML::HTML5::Sanity qw(fix_document);
use RDF::Query;

use base 'Exporter';

our @EXPORT_OK = qw( artist_type_ok );

my $Test = Test::Builder->new();

sub _parse_html {
    my ($html) = @_;

    my $html_parser = HTML::HTML5::Parser->new;
    my $document    = $html_parser->parse_string($html);
    return fix_document($document);
}
#use Data::Dumper; 
# do we get the right artist type?
sub artist_type_ok{
    my ($content, $uri_frag) = @_;

    my $parser = RDF::RDFa::Parser->new(_parse_html($content), 
					"http://ex.com",
					RDF::RDFa::Parser::OPTS_HTML5)->consume;
    my $sparql = 
	"select ?a where {?a a <http://purl.org/ontology/mo/MusicArtist> . }";
    
    my $query = RDF::Query->new( $sparql );
    my $iter = $query->execute( $parser->graph() );
    my $cnt = 0; 
    my $uri = '';
    while(my $row = $iter->next){
	$uri = $row->{ a };
	$cnt += 1;
    }
    #foreach (@rows) {
	#$row += 1;
	#$Test->diag(sprintf "%03d %s", $row, $_);
	#$Test->( Dumper $_ );
#	my $uri = $_->{ a };
#        }
    $Test->diag(sprintf "uri:%s uri_frage:%s", $uri, $uri_frag);
    $Test->ok($cnt eq 1, "Only one artist resource in RDF model");
    $Test->ok(index($uri,$uri_frag) != -1, "should have the uri fragment");
    @rows[0];
}



=head1 COPYRIGHT

Copyright (C) 2010 Kurt Jacobson

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
1;


