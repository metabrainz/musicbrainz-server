const $ = require('jquery');
const ko = require('knockout');

const {registerEvents} = require('./edit/URLCleanup');

$(function () {
  var $urlControl = $("#id-edit-url\\.url");

  registerEvents($urlControl);

  var vm = MB.sourceRelationshipEditor;
  var source = vm.source;
  source.name = ko.observable(source.name);

  $urlControl.on("change", function () {
    source.name(this.value);
  });
});
