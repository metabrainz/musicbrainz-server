package MusicBrainz::Server::Test::RDFa;

use Test::Builder;
use RDF::RDFa::Parser;
use HTML::HTML5::Parser;
use HTML::HTML5::Sanity qw(fix_document);
use RDF::Query;

use base 'Exporter';

our @EXPORT_OK = qw( foaf_mades_ok rdfa_type_ok rdfa_predicate_literal_ok rdfa_predicate_ok print_triples );

my $Test = Test::Builder->new();

sub _parse_rdfa_graph {
    my ($html) = @_;

    my $html_parser = HTML::HTML5::Parser->new;
    my $document    = $html_parser->parse_string($html);
    my $parser = RDF::RDFa::Parser->new(fix_document($document), 
					"http://example.com",
					RDF::RDFa::Parser::OPTS_HTML5)->consume;
    return $parser->graph() ;
}

sub print_triples{
    my ($content) = @_;
    my $sparql = "select ?s ?p ?o where { ?s ?p ?o }";

    my $query = RDF::Query->new( $sparql );
    my $iter = $query->execute( _parse_rdfa_graph($content) );
    while( my $row = $iter->next){
        $Test->diag(sprintf "%s", $row-> { s });
        $Test->diag(sprintf "  %s", $row-> { p });
        $Test->diag(sprintf "     %s", $row-> { o });
    }

}

sub rdfa_type_ok{
    my ($content, $uri_frag, $type) = @_;
    my $sparql = "select ?a where {?a a <$type> . }";

    my $query = RDF::Query->new( $sparql );
    my $iter = $query->execute( _parse_rdfa_graph($content) );
    my $idx = 0;
    my $uri = '';
    while( my $row = $iter->next){
        $uri = $row-> { a };
        $idx += 1;
    }
    $Test->diag(sprintf "release uri: %s uri_frag: %s", $uri, $uri_frag);
    $Test->ok($idx ge 1, "We should have at least one rdf:type predicate");
    $Test->ok(index($uri,$uri_frag) != -1, "rdf:type predicate for MBID $uri_frag seems to be missing");
}

sub rdfa_predicate_ok{
    my ($content, $uri_frag, $predicate, $object) = @_;
    my $sparql = 'select ?s ?o where { ?s <' . $predicate . '> <' . $object . '> . }';

    my $query = RDF::Query->new( $sparql );
    my $iter = $query->execute( _parse_rdfa_graph($content) );
    my $qsub = '';
    while( my $row = $iter->next){
        $qsub = $row-> { s };
    }
    $Test->ok(index($qsub,$uri_frag) != -1, "The mbid $uri_frag does not have $predicate $object");
}

sub rdfa_predicate_literal_ok{
    my ($content, $uri_frag, $predicate, $literal, $datatype) = @_;
    my $sparql = 'select ?s where {?s <' . $predicate . '> "' . $literal . '"' . $datatype . ' . } ';
    #my $sparql = 'select ?s where { ?s ?p ?o . }';

    $Test->diag(sprintf $sparql);
    
    my $query = RDF::Query->new( $sparql );
    my $graph = _parse_rdfa_graph($content);
    #$Test->diag(sprintf $graph->count_statements());
    my $iter = $query->execute( $graph );
    my $idx = 0; 
    my $uri = '';
    while(my $row = $iter->next){
	$uri = $row->{ s };
	$idx += 1;
    }
    $Test->diag(sprintf "uri found: %s idx: %s", $uri, $idx);
    $Test->ok($idx ge 1, "Should get one or more result for $predicate");
    $Test->ok(index($uri,$uri_frag) != -1, "for MBID $uri_frag, $predicate $literal is not present");
}

sub foaf_mades_ok{
    my ($content, $count) = @_;

    $count = $count || 50;

    my $sparql = 
	"select ?o where { ?s <http://xmlns.com/foaf/0.1/made> ?o . }";

    my $query = RDF::Query->new( $sparql );
    my $iter = $query->execute( _parse_rdfa_graph($content) );
    my $idx=0;
    while(my $row = $iter->next){
	$Test->diag(sprintf "%s", $row);
	$idx += 1;
    }
    $Test->ok($idx eq $count, "Expected page to have $count objects for the foaf:made predicate, got $idx ." );
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


