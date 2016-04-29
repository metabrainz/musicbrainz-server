// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014, 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const React = require('react');
const ReactDOM = require('react-dom');
const ReactDOMServer = require('react-dom/server');
const ReactTestUtils = require('react-addons-test-utils');
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
      ReactDOM.unmountComponentAtNode($bubble[0]);

      t.ok(!$bubble.is(':visible'), 'bubble is not visible');

      $container.find('.open-ac').click();
      t.ok($bubble.is(':visible'), 'bubble is visible after clicking button');

      $('body').click();
      t.ok(!$bubble.is(':visible'), 'bubble is hidden after clicking outside of it');

      ReactDOM.unmountComponentAtNode($container[0]);
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
      ReactDOM.unmountComponentAtNode($bubble[0]);

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

      ReactDOM.unmountComponentAtNode($container[0]);
      $container.remove();
    }
  );
});

test('removing all credits but one should clear the join phrase (MBS-8896)', function (t) {
  t.plan(2);

  const $container = $('<div>').appendTo('body');
  ReactDOM.render(
    <ArtistCreditEditor entity={{name: '', artistCredit: artistCreditFromArray([])}} />,
    $container[0],
    function () {
      const $bubble = $('#artist-credit-bubble');
      ReactDOM.unmountComponentAtNode($bubble[0]);
      $container.find('.open-ac').click();

      const $joinPhrase = $bubble.find('input[type=text]:eq(2)');

      $bubble.find('.add-item').click();
      t.equal($joinPhrase.val(), ' & ');
      $bubble.find('.remove-item:last').click();
      t.equal($joinPhrase.val(), '');

      ReactDOM.unmountComponentAtNode($container[0]);
      $container.remove();
    }
  );
});

test('updating the artist field should also update the credited name field (MBS-8911)', function (t) {
  t.plan(3);

  const $container = $('<div>').appendTo('body');
  ReactDOM.render(
    <ArtistCreditEditor entity={{name: '', artistCredit: artistCreditFromArray([])}} />,
    $container[0],
    function () {
      const $bubble = $('#artist-credit-bubble');
      ReactDOM.unmountComponentAtNode($bubble[0]);
      $container.find('.open-ac').click();

      const $artistNode = $bubble.find('input[type=text]:eq(0)');
      const $creditNode = $bubble.find('input[type=text]:eq(1)');

      $artistNode.val('hello').trigger('input');
      t.equal($creditNode.val(), 'hello');

      $artistNode.val('hello there').trigger('input');
      t.equal($creditNode.val(), 'hello there');

      $artistNode.val('').trigger('input');
      t.equal($creditNode.val(), '');

      ReactDOM.unmountComponentAtNode($container[0]);
      $container.remove();
    }
  );
});

test('can clear the credited name field until it is blurred', function (t) {
  t.plan(3);

  const $container = $('<div>').appendTo('body');
  ReactDOM.render(
    <ArtistCreditEditor entity={{name: '', artistCredit: artistCreditFromArray([])}} />,
    $container[0],
    function () {
      const $bubble = $('#artist-credit-bubble');
      ReactDOM.unmountComponentAtNode($bubble[0]);
      $container.find('.open-ac').click();

      const $artistNode = $bubble.find('input[type=text]:eq(0)');
      const $creditNode = $bubble.find('input[type=text]:eq(1)');

      $artistNode.val('hello').trigger('input');

      $creditNode.focus();
      $creditNode.val('').trigger('input');
      t.equal($creditNode.val(), '');

      // also test whether it can be cleared when it differs from the artist
      // name, which was another subtle bug.
      $creditNode.val('not hello').trigger('input');
      $creditNode.val('').trigger('input');
      t.equal($creditNode.val(), '');

      // jQuery's blur() doesn't work here for some reason.
      // (Likewise, ReactTestUtils.Simulate.input() doesn't work above.)
      ReactTestUtils.Simulate.blur($creditNode[0], {target: $creditNode[0]});
      t.equal($creditNode.val(), 'hello');

      ReactDOM.unmountComponentAtNode($container[0]);
      $container.remove();
    }
  );
});

test('MBS-8924: Changing an artist field causes infinite recursion', function (t) {
  t.plan(3);

  const $container = $('<div>').appendTo('body');
  const artistCredit = artistCreditFromArray([
    {
      artist: {
        entityType: 'artist',
        gid: '18c5587c-541d-44f1-8ab6-7b142b4e85fc',
        id: 895310,
        name: 'Timothy Corlis',
      },
      joinPhrase: '',
      name: 'Timothy Corlis',
    },
  ]);

  ReactDOM.render(
    <ArtistCreditEditor entity={{entityType: 'recording', name: '', artistCredit}} />,
    $container[0],
    function () {
      const $bubble = $('#artist-credit-bubble');
      ReactDOM.unmountComponentAtNode($bubble[0]);
      $container.find('.open-ac').click();
      $container.find('input.name').val('Silent Dawn').trigger('input');

      const $artistNode = $bubble.find('input[type=text]:eq(0)');
      const $creditNode = $bubble.find('input[type=text]:eq(1)');

      t.equal($artistNode.val(), 'Silent Dawn');
      t.equal($creditNode.val(), 'Silent Dawn');
      t.ok($artistNode.is(':not(.lookup-performed)'));

      ReactDOM.unmountComponentAtNode($container[0]);
      $container.remove();
    }
  );
});
