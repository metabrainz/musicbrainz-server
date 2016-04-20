// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014, 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const React = require('react');
const ReactDOM = require('react-dom');
const ReactDOMServer = require('react-dom/server');
const test = require('tape');

const {artistCreditFromArray} = require('../../../common/immutable-entities');
const ArtistCreditEditor = require('../../../edit/components/ArtistCreditEditor');

const bowie = {id: 956, gid: '5441c29d-3602-4898-b1a1-b77fa23b8e50', name: 'david bowie'};
const crosby = {id: 99, gid: '2437980f-513a-44fc-80f1-b90d9d7fcf8f', name: 'bing crosby'};

test('hidden inputs', function (t) {
  t.plan(19);

  const div = document.createElement('div');
  const commonProps = {form: {name: 'form'}, hiddenInputs: true};

  div.innerHTML = ReactDOMServer.renderToStaticMarkup(
    <ArtistCreditEditor
      {...commonProps}
      entity={{name: '', artistCredit: artistCreditFromArray([{artist: bowie, name: 'david bowie'}])}} />
  );

  t.equal($('input[type=hidden]', div).length, 4);
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.name]', div).val(), 'david bowie');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.join_phrase]', div).val(), '');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.artist\\.name]', div).val(), 'david bowie');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.artist\\.id]', div).val(), '956');

  div.innerHTML = ReactDOMServer.renderToStaticMarkup(
    <ArtistCreditEditor
      {...commonProps}
      entity={{name: '', artistCredit: artistCreditFromArray([{artist: bowie, name: 'david robert jones'}])}} />
  );

  t.equal($('input[type=hidden]', div).length, 4);
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.name]', div).val(), 'david robert jones');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.join_phrase]', div).val(), '');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.artist\\.name]', div).val(), 'david bowie');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.artist\\.id]', div).val(), '956');

  div.innerHTML = ReactDOMServer.renderToStaticMarkup(
    <ArtistCreditEditor
      {...commonProps}
      entity={{
        name: '',
        artistCredit: artistCreditFromArray([
          {artist: bowie, name: 'david bowie', joinPhrase: ' & '},
          {artist: crosby, name: 'bing crosby'},
        ])}} />
  );

  t.equal($('input[type=hidden]', div).length, 8);
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.name]', div).val(), 'david bowie');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.join_phrase]', div).val(), ' & ');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.artist\\.name]', div).val(), 'david bowie');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.0\\.artist\\.id]', div).val(), '956');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.1\\.name]', div).val(), 'bing crosby');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.1\\.join_phrase]', div).val(), '');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.1\\.artist\\.name]', div).val(), 'bing crosby');
  t.equal($('input[type=hidden][name=form\\.artist_credit\\.names\\.1\\.artist\\.id]', div).val(), '99');
});

test('clicking outside of a track AC bubble closes it', function (t) {
  t.plan(3);

  const $container = $('<div>').appendTo('body');
  ReactDOM.render(
    <ArtistCreditEditor entity={{name: '', artistCredit: artistCreditFromArray([])}} />,
    $container[0],
    function () {
      const $bubble = $('#artist-credit-bubble');
      t.ok(!$bubble.is(':visible'), 'bubble is not visible');

      $container.find('.open-ac').click();
      t.ok($bubble.is(':visible'), 'bubble is visible after clicking button');

      $('body').click();
      t.ok(!$bubble.is(':visible'), 'bubble is hidden after clicking outside of it');

      $container.remove();
    }
  );
});

test('creating a new artist from the track AC bubble should not close it (MBS-7251)', function (t) {
  t.plan(3);

  const $container = $('<div>').appendTo('body');
  ReactDOM.render(
    <ArtistCreditEditor entity={{name: '', artistCredit: artistCreditFromArray([])}} />,
    $container[0],
    function () {
      const $bubble = $('#artist-credit-bubble');
      const $button = $container.find('.open-ac');

      // Open the track AC bubble.
      $button.click();

      // Simulate an add-entity dialog opening.
      const $dialog = $('<div>').appendTo($container).dialog();
      t.ok($bubble.is(':visible'), 'bubble is visible after dialog opens above it');

      $dialog.parent().find('button.ui-dialog-titlebar-close').click();
      t.ok($bubble.is(':visible'), 'bubble is visible after dialog is closed');

      $button.click();
      t.ok(!$bubble.is(':visible'), 'bubble is hidden after clicking the button again');

      $container.remove();
    }
  );
});
