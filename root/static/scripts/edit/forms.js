// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt


/* Helper binding that matches an input and label (assuming a table layout)
   together in a foreach loop, by assigning an id composed of a prefix
   concatenated with the index of the item in the loop.

   So if you have something like this in the template:

    <!-- ko foreach: items -->
    <tr>
      <td><label>Foo</label></td>
      <td><input data-bind="withLabel: 'foo'" /></td>
    <tr>
    <!-- /ko -->

   It'll result in this markup once rendered (assuming two items):

    <tr>
      <td><label for="foo-0">Foo</label></td>
      <td><input id="foo-0" data-bind="withLabel: 'foo'" /></td>
    <tr>
    <tr>
      <td><label for="foo-1">Foo</label></td>
      <td><input id="foo-1" data-bind="withLabel: 'foo'" /></td>
    <tr>
*/
ko.bindingHandlers.withLabel = {

    update: function (element, valueAccessor, allBindings,
                      viewModel, bindingContext) {

        var name = valueAccessor() + "-" + bindingContext.$index();

        $(element).attr("id", name)
            .parents("td").prev("td").find("label").attr("for", name);
    }
};
