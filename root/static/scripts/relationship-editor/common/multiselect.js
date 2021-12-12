/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import linkedEntities from '../../common/linkedEntities';
import clean from '../../common/utility/clean';
import deferFocus from '../../edit/utility/deferFocus';

class Multiselect {
  constructor(params, $element) {
    this.$element = $element;
    this.$menu = $element.find('div.menu').data('multiselect', this);
    this.$items = $element.find('div.items');

    const self = this;

    this.$menu
      .on('keydown', $.proxy(this.menuKeydown, this))
      .on('click', 'a', function (event) {
        event.preventDefault();
        self.select(event.target.optionData);
      });

    this.$items.on('click', 'a', $.proxy(this.deselect, this));

    $element.find('.multiselect-input').on({
      keydown: $.proxy(this.inputKeydown, this),
      click: $.proxy(this.inputClick, this),
    });

    this.placeholder = params.placeholder || '';
    this.relationship = params.relationship;

    this.term = ko.observable('');
    this.term.subscribe(this.termChanged, this);
    this.inputHasFocus = ko.observable(false);

    this.menuVisible = ko.observable(false);
    this.menuVisible.subscribe(this.menuVisibleChanged, this);

    const options = params.options;
    const optionNodes = [];

    for (var i = 0, node, option; (option = options[i]); i++) {
      node = document.createElement('a');
      node.href = '#';
      node.style.paddingLeft = option.depth + 'em';
      node.appendChild(document.createTextNode(option.text));
      node.optionData = option;
      optionNodes.push(node);
    }

    this.selectedAttributes = ko.computed(function () {
      return params.relationship.attributes().filter(function (attribute) {
        return attribute.type.root === params.attribute;
      });
    });

    this.optionNodes = optionNodes.slice(0);
    this.$menu.empty().append(optionNodes);
    this.firstVisibleOption = ko.observable(this.optionNodes[0]);
  }

  termChanged(term) {
    term = clean(term);
    this.updateOptions(term);
    this.menuVisible(!!term);
  }

  menuVisibleChanged(visible) {
    if (visible) {
      this.$menu.css('top', this.$element.outerHeight() + 'px');
    }
  }

  updateOptions(term) {
    const selected = this.relationship.attributes.peek();
    const menu = this.$menu[0];

    const previousDisplay = menu.style.display;
    menu.style.display = 'none';

    const optionNodes = this.optionNodes.filter(function (node) {
      const option = node.optionData;
      const typeGID = option.value;

      const visible = matchIndex(option, term) >= 0 && (
        linkedEntities.link_attribute_type[typeGID].creditable ||
                    selected.findIndex(a => a.type.gid === typeGID) < 0
      );

      node.style.display = visible ? 'block' : 'none';
      return visible;
    });

    menu.style.display = previousDisplay;
    this.firstVisibleOption(optionNodes[0]);
  }

  select(option) {
    this.relationship.addAttribute(option.value);
    this.menuVisible(false);
    this.term('');
    this.inputHasFocus(true);
    this.updateOptions('');
  }

  deselect(event) {
    event.preventDefault();

    const attribute = ko.dataFor(event.target);
    const typeGID = attribute.type.gid;

    this.relationship.attributes.remove(attribute);
    this.menuVisible(false);
    this.updateOptions(this.term.peek());

    const nodes = this.optionNodes;
    let node;
    let nextIndex = nodes.findIndex(
      node => node.optionData.value === typeGID,
    );

    while ((node = nodes[++nextIndex])) {
      if (node.style.display === 'block') {
        ++nextIndex;
        break;
      }
    }
    --nextIndex;

    if (nextIndex >= 0) {
      deferFocus('a:eq(' + nextIndex + ')', this.$items);
    } else {
      this.inputHasFocus(true);
    }
  }

  inputClick(event) {
    this.menuVisible(!this.menuVisible());
    event.preventDefault();
  }

  inputKeydown(event) {
    const keyCode = event.keyCode;
    const menuVisible = this.menuVisibleWithOptions();

    switch (keyCode) {
      case 13: // enter
        if (menuVisible) {
          this.select(this.firstVisibleOption().optionData);
          event.preventDefault();
        }
        break;
      case 27: // esc
        if (menuVisible) {
          this.menuVisible(false);
          event.preventDefault();
        }
        break;
      case 40: // down arrow
        if (menuVisible) {
          this.firstVisibleOption().focus();
          event.preventDefault();
        } else if (this.firstVisibleOption()) {
          this.menuVisible(true);
          event.preventDefault();
        }
        break;
    }
  }

  menuKeydown(event) {
    const keyCode = event.keyCode;
    const activeElement = document.activeElement;
    const menuItemActive = activeElement.parentNode === this.$menu[0];

    switch (keyCode) {
      case 27: // esc
        if (this.menuVisibleWithOptions()) {
          this.menuVisible(false);
          event.preventDefault();
          event.preventDefault();
        }
        break;
      case 38: // up arrow
        if (menuItemActive) {
          let nextItem = activeElement.previousSibling;

          while (nextItem && nextItem.style.display === 'none') {
            nextItem = nextItem.previousSibling;
          }

          nextItem ? nextItem.focus() : this.inputHasFocus(true);
          event.preventDefault();
        }
        break;
      case 40: // down arrow
        if (menuItemActive) {
          let nextItem = activeElement.nextSibling;

          while (nextItem && nextItem.style.display === 'none') {
            nextItem = nextItem.nextSibling;
          }

          (nextItem || this.firstVisibleOption()).focus();
          event.preventDefault();
        }
        break;
    }
  }

  menuVisibleWithOptions() {
    return this.menuVisible() && this.firstVisibleOption();
  }
}

function matchIndex(option, term) {
  return option.text.toLowerCase().indexOf(term.toLowerCase());
}


ko.components.register('multiselect', {
  viewModel: {
    createViewModel: function (params, componentInfo) {
      return new Multiselect(params, $(componentInfo.element));
    },
  },
  template: {fromScript: 'template.multiselect'},
});
