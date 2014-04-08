// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

MB.forms = {

    buildOptionsTree: function (root, textAttr, valueAttr, callback) {
        var options = [];
        var nbsp = String.fromCharCode(160);

        function buildOptions(parent, indent) {
            var i = 0, children = parent.children, child;

            while (child = children[i++]) {
                var opt = {};

                callback && callback(child, opt);
                opt.value = child[valueAttr];
                opt.text = _.str.repeat(nbsp, indent * 2) + child[textAttr];
                options.push(opt);

                if (child.children) {
                    buildOptions(child, indent + 1);
                }
            }
        }

        buildOptions(root, 0);
        return options;
    }
};


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
