// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const $ = require('jquery');
const ko = require('knockout');
const React = require('react');
const {l} = require('../../common/i18n');

require('../entity');

class Autocomplete extends React.Component {
  componentDidMount() {
    const currentSelection = ko.observable();
    const options = _.clone(this.props);

    options.currentSelection = currentSelection;
    this._currentSelection = currentSelection;
    this._subscription = currentSelection.subscribe(this.props.onChange);

    this._autocomplete = $(this.refs.name).autocomplete(options).data('ui-autocomplete');
    currentSelection(this._autocomplete._dataToEntity(this.props.currentSelection));
  }

  componentWillUnmount() {
    this._subscription.dispose();
    this._subscription = null;
    this._currentSelection = null;
    this._autocomplete = null;
    $(this.refs.name).autocomplete('destroy');
  }

  componentWillReceiveProps(nextProps) {
    this._subscription.dispose();
    this._subscription = this._currentSelection.subscribe(nextProps.onChange);

    const prev = this.props.currentSelection;
    const next = nextProps.currentSelection;
    const autocomplete = this._autocomplete;

    if (!next) {
      autocomplete.clearSelection(true);
    } else if (!prev || prev.gid !== next.gid || prev.name !== next.name) {
      autocomplete.currentSelection(autocomplete._dataToEntity(nextProps.currentSelection));
    }

    autocomplete.element.prop('disabled', !!nextProps.disabled);
  }

  render() {
    const {disabled, entity, inputID} = this.props;
    return (
      <span className={entity + ' autocomplete'}>
        <img className="search" src="/static/images/icons/search.png" alt={l('Search')} />
        <input id={inputID} className="name" disabled={disabled} type="text" ref="name" />
      </span>
    );
  }
}

module.exports = Autocomplete;
