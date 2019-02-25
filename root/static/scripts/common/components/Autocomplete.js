/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import _ from 'lodash';
import $ from 'jquery';
import ko from 'knockout';
import React from 'react';

import SearchIcon from './SearchIcon';

import '../MB/Control/Autocomplete';
import '../entity';

class Autocomplete extends React.Component {
  componentDidMount() {
    const currentSelection = ko.observable();
    const options = _.clone(this.props);

    options.currentSelection = currentSelection;
    this._currentSelection = currentSelection;
    this._subscription = currentSelection.subscribe(this.props.onChange);

    this._autocomplete = $(this._nameInput).entitylookup(options).data('mb-entitylookup');
    currentSelection(
      this._autocomplete._dataToEntity(this.props.currentSelection),
    );
  }

  componentWillUnmount() {
    this._subscription.dispose();
    this._subscription = null;
    this._currentSelection = null;
    this._autocomplete = null;
    $(this._nameInput).entitylookup('destroy');
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
      autocomplete.currentSelection(
        autocomplete._dataToEntity(nextProps.currentSelection),
      );
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
        <SearchIcon />
        <input
          className={className}
          disabled={disabled}
          id={inputID}
          ref={input => this._nameInput = input}
          type="text"
        />
      </span>
    );
  }
}

export default Autocomplete;
