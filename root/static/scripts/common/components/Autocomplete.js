// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const $ = require('jquery');
const ko = require('knockout');
const React = require('react');
const manifest = require('../../../manifest');
const {l} = require('../../common/i18n');

require('../MB/Control/Autocomplete');
require('../entity');

class Autocomplete extends React.Component {
  componentDidMount() {
    const currentSelection = ko.observable();
    const options = _.clone(this.props);

    options.currentSelection = currentSelection;
    this._currentSelection = currentSelection;
    this._subscription = currentSelection.subscribe(this.props.onChange);

    this._autocomplete = $(this._nameInput).autocomplete(options).data('ui-autocomplete');
    currentSelection(this._autocomplete._dataToEntity(this.props.currentSelection));
  }

  componentWillUnmount() {
    this._subscription.dispose();
    this._subscription = null;
    this._currentSelection = null;
    this._autocomplete = null;
    $(this._nameInput).autocomplete('destroy');
  }

  componentDidUpdate(prevProps) {
    const nextProps = this.props;

    this._subscription.dispose();
    this._subscription = this._currentSelection.subscribe(nextProps.onChange);

    const prev = prevProps.currentSelection;
    const next = nextProps.currentSelection;
    const autocomplete = this._autocomplete;

    if (!next) {
      autocomplete.clearSelection(true);
    } else if (!prev || prev.gid !== next.gid || prev.name !== next.name) {
      autocomplete.currentSelection(autocomplete._dataToEntity(nextProps.currentSelection));
    }

    autocomplete.element.prop('disabled', !!nextProps.disabled);
    if (next && autocomplete.element.val() !== next.name) {
      autocomplete.element.val(next.name);
    }

    if (nextProps.hasOwnProperty('isLookupPerformed')) {
      autocomplete.element.toggleClass('lookup-performed', !!nextProps.isLookupPerformed);
    }
  }

  render() {
    const {disabled, entity, inputID, isLookupPerformed} = this.props;
    let className = 'name';
    if (isLookupPerformed) {
      className += ' lookup-performed';
    }
    return (
      <span className={entity + ' autocomplete'}>
        <img className="search" src={manifest.pathTo('/images/icons/search.png')} alt={l('Search')} />
        <input
          className={className}
          disabled={disabled}
          id={inputID}
          ref={input => this._nameInput = input}
          type="text" />
      </span>
    );
  }
}

module.exports = Autocomplete;
