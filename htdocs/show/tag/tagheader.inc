<%args>
	$tag
	$show => undef
</%args>

[ Show:
  <a href="/show/tag/all.html">all tags</a> |
  <a href="/show/tag/related.html?tag=<% uri_escape($tag) %>">related tags</a> |
  items tagged with “<% $tag %>”:
% if ($show ne 'all') {
    <a href="/show/tag/?tag=<% uri_escape($tag) %>&amp;show=all">all</a> |
% }
% if ($show eq 'artist') {
    artists |
% } else {
    <a href="/show/tag/?tag=<% uri_escape($tag) %>&amp;show=artist">artists</a> |
% }
% if ($show eq 'label') {
    labels |
% } else {
    <a href="/show/tag/?tag=<% uri_escape($tag) %>&amp;show=label">labels</a> |
% }
% if ($show eq 'release') {
    releases |
% } else {
    <a href="/show/tag/?tag=<% uri_escape($tag) %>&amp;show=release">releases</a> |
% }
% if ($show eq 'track') {
    tracks ]
% } else {
    <a href="/show/tag/?tag=<% uri_escape($tag) %>&amp;show=track">tracks</a> ]
% }
