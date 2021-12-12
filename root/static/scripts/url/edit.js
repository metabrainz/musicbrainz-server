import $ from 'jquery';
import ko from 'knockout';

import MB from '../common/MB';
import {getUnicodeUrl} from '../edit/externalLinks';
import {registerEvents} from '../edit/URLCleanup';

$(function () {
  const $urlControl = $('#id-edit-url\\.url');

  registerEvents($urlControl);

  const vm = MB.sourceRelationshipEditor;
  const source = vm.source;
  source.name = ko.observable(source.name);

  $urlControl.on('change', function () {
    this.value = getUnicodeUrl(this.value);
    source.name(this.value);
  });
});
