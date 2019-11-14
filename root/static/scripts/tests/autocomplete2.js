/* eslint-disable import/no-commonjs */

// IE 11 support.
require('core-js/modules/es6.object.assign');
require('core-js/modules/es6.array.from');
require('core-js/modules/es6.array.iterator');
require('core-js/modules/es6.string.iterator');
require('core-js/es6/set');
require('core-js/es6/map');
require('core-js/es6/promise');
require('core-js/es6/symbol');

const $ = require('jquery');
const React = require('react');
const ReactDOM = require('react-dom');
const Autocomplete2 = require('../common/components/Autocomplete2').default;

const vocals = [
  {id: 3, name: 'vocal', level: 1},
  {id: 4, name: 'lead vocals', level: 2},
  {id: 5, name: 'alto vocals', level: 3},
  {id: 6, name: 'baritone vocals', level: 3},
  {id: 7, name: 'bass vocals', level: 3},
  {id: 8, name: 'countertenor vocals', level: 3},
  {id: 9, name: 'mezzo-soprano vocals', level: 3},
  {id: 10, name: 'soprano vocals', level: 3},
  {id: 11, name: 'tenor vocals', level: 3},
  {id: 230, name: 'contralto vocals', level: 3},
  {id: 231, name: 'bass-baritone vocals', level: 3},
  {id: 834, name: 'treble vocals', level: 3},
  {id: 1060, name: 'meane vocals', level: 3},
  {id: 12, name: 'background vocals', level: 2},
  {id: 13, name: 'choir vocals', level: 2},
  {id: 461, name: 'other vocals', level: 2},
  {id: 561, name: 'spoken vocals', level: 3},
];

$(function () {
  const container = document.createElement('div');
  document.body.insertBefore(container, document.getElementById('page'));

  function render(entityType) {
    ReactDOM.render(
      <>
        <div>
          <h2>Entity autocomplete</h2>
          <p>
            Current entity type:
            {' '}
            <select
              value={entityType}
              onChange={event => render(event.target.value)}
            >
              <option value="area">Area</option>
              <option value="artist">Artist</option>
              <option value="event">Event</option>
              <option value="instrument">Instrument</option>
              <option value="label">Label</option>
              <option value="place">Place</option>
              <option value="recording">Recording</option>
              <option value="release">Release</option>
              <option value="release_group">Release Group</option>
              <option value="series">Series</option>
              <option value="work">Work</option>
            </select>
          </p>
          <Autocomplete2
            entityType={entityType}
            id="entity-test"
            key={entityType + '-autocomplete'}
            onChange={console.info}
            onTypeChange={render}
            width="200px"
          />
        </div>
        <div>
          <h2>Vocal autocomplete</h2>
          <Autocomplete2
            entityType={entityType}
            id="vocal-test"
            items={vocals}
            onChange={console.info}
            placeholder="Choose a vocal"
            width="200px"
          />
        </div>
      </>,
      container,
    );
  }

  render('artist');
});
