// @flow
// Copyright (C) 2017 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const React = require('react');
const ReactDOM = require('react-dom');

const CommonsImage = require('../../components/CommonsImage');
const props = require('./common/utility/getScriptArgs')();

if (!props.image) {
  $(function () {
    $.get(props.imageEndpoint, function (data) {
      (ReactDOM: any).hydrate(
        <CommonsImage {...data} />,
        document.getElementById('commons-image'),
      );
    });
  });
}
