/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as React from 'react';

import '../entity.js';

import SearchIcon from './SearchIcon.js';

class Autocomplete extends React.Component {
  componentDidMount() {
    const $ = require('jquery');
    require('../MB/Control/Autocomplete');

    const currentSelection = ko.observable();
    const options = {...this.props};

    options.currentSelection = currentSelection;
    this._currentSelection = currentSelection;
    this._subscription = currentSelection.subscribe(this.props.onChange);

    this._autocomplete =
      $(this._nameInput).entitylookup(options).data('mb-entitylookup');
    currentSelection(
      this._autocomplete._dataToEntity(this.props.currentSelection),
    );
  }

  componentWillUnmount() {
    const $ = require('jquery');
    require('../MB/Control/Autocomplete');

    this._subscription.dispose();
    this._subscription = null;
    this._currentSelection = null;
    this._autocomplete = null;
    $(this._nameInput).entitylookup('destroy');
  }

  componentDidUpdate(prevProps) {
    const nextProps = this.props;

    this._subscription.dispose();

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

    this._subscription = this._currentSelection.subscribe(nextProps.onChange);

    autocomplete.element.prop('disabled', !!nextProps.disabled);
    if (next && autocomplete.element.val() !== next.name) {
      autocomplete.element.val(next.name);
    }

    if (hasOwnProp(nextProps, 'isLookupPerformed')) {
      autocomplete.element.toggleClass(
        'lookup-performed',
        !!nextProps.isLookupPerformed,
      );
    }
  }

  render() {
    const {
      children,
      disabled,
      entity,
      inputID,
      inputName,
      isLookupPerformed,
    } = this.props;
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
          name={inputName}
          ref={input => this._nameInput = input}
          type="text"
        />
        {children}
      </span>
    );
  }
}

export default Autocomplete;
