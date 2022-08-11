import $ from 'jquery';
import ko from 'knockout';

import MB from '../common/MB.js';
import {getUnicodeUrl} from '../edit/externalLinks.js';
import {registerEvents} from '../edit/URLCleanup.js';

$(function () {
  var $urlControl = $('#id-edit-url\\.url');

  registerEvents($urlControl);

  var vm = MB.sourceRelationshipEditor;
  var source = vm.source;
  source.name = ko.observable(source.name);

  $urlControl.on('change', function () {
    this.value = getUnicodeUrl(this.value);
    source.name(this.value);
  });
});
