// @flow
// Copyright (C) 2015 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const _ = require('lodash');
const React = require('react');
const ReactDOM = require('react-dom');
import keyBy from 'terable/keyBy';

import hydrate, {minimalEntity} from '../../../../utility/hydrate';
import loopParity from '../../../../utility/loopParity';
import {GENRE_TAGS} from '../constants';
const {l, lp} = require('../i18n');
const MB = require('../MB');
import bracketed from '../utility/bracketed';
import isBlank from '../utility/isBlank';
const request = require('../utility/request');
const TagLink = require('./TagLink');

const GENRE_TAGS_ARRAY = Array.from(GENRE_TAGS.values());

var VOTE_ACTIONS = {
  '0': 'withdraw',
  '1': 'upvote',
  '-1': 'downvote',
};

// The voting endpoints accept multiple tags, so we want to batch requests
// together where possible. A delay is enforced using _.debounce, so a
// request will not be sent until VOTE_DELAY has passed since the last vote.
var VOTE_DELAY = 1000;

function sortedTags(tags) {
  return _.sortBy(tags, t => t.tag, t => -t.count);
}

function getTagsPath(entity) {
  var type = entity.entityType.replace('_', '-');
  return `/${type}/${entity.gid}/tags`;
}

function isAlwaysVisible(tag) {
  return tag.vote > 0 || (tag.vote === 0 && tag.count > 0);
}

function isGenre(tag) {
  return GENRE_TAGS.has(tag.tag);
}

function splitTags(tags) {
  return (
    tags
      .trim()
      .toLowerCase()
      .split(/\s*,\s*/)
      .filter(x => !isBlank(x))
  );
}

type VoteT = 1 | 0 | -1;

type VoteButtonProps = {
  activeTitle: string,
  callback: (VoteT) => void,
  currentVote: VoteT,
  text: string,
  title: string,
  vote: VoteT,
};

class VoteButton extends React.Component<VoteButtonProps> {
  render() {
    var {
      activeTitle,
      callback,
      currentVote,
      text,
      title,
      vote,
    } = this.props;
    var isActive = vote === currentVote;

    var buttonProps = {
      type: 'button',
      title: isActive ? activeTitle : (currentVote === 0 ? title : l('Withdraw vote')),
      disabled: isActive,
      className: 'tag-vote tag-' + VOTE_ACTIONS[vote],
    };

    if (!isActive) {
      (buttonProps: any).onClick = _.partial(callback, currentVote === 0 ? vote : 0);
    }

    return <button {...buttonProps}>{text}</button>;
  }
}

class UpvoteButton extends VoteButton {
  static defaultProps = {
    text: '+',
    title: l('Upvote'),
    activeTitle: l('You’ve upvoted this tag'),
    vote: 1,
  }
}

class DownvoteButton extends VoteButton {
  static defaultProps = {
    text: '\u2212',
    title: l('Downvote'),
    activeTitle: l('You’ve downvoted this tag'),
    vote: -1,
  }
}

type VoteButtonsProps = {
  callback: (VoteT) => void,
  count: number,
  currentVote: VoteT,
};

class VoteButtons extends React.Component<VoteButtonsProps> {
  render() {
    var currentVote = this.props.currentVote;
    var className = '';

    if (currentVote === 1) {
      className = ' tag-upvoted';
    } else if (currentVote === -1) {
      className = ' tag-downvoted';
    }

    return (
      <span className={'tag-vote-buttons' + className}>
        <UpvoteButton {...this.props} />
        <DownvoteButton {...this.props} />
        <span className="tag-count">{this.props.count}</span>
      </span>
    );
  }
}

type TagRowProps = {
  callback: (VoteT) => void,
  count: number,
  currentVote: VoteT,
  index: number,
  tag: string,
};

class TagRow extends React.Component<TagRowProps> {
  render() {
    var {tag, index} = this.props;

    return (
      <li key={tag} className={loopParity(index)}>
        <TagLink tag={tag} />
        <VoteButtons {...this.props} />
      </li>
    );
  }
}

type TagEditorProps = {|
  +aggregatedTags: $ReadOnlyArray<AggregatedTagT>,
  +entity: CoreEntityT,
  +more: boolean,
  +userTags: $ReadOnlyArray<UserTagT>,
|};

type TagEditorState = {
  positiveTagsOnly: bool,
  tags: $ReadOnlyArray<UserTagT>,
};

type TagUpdateT =
  | {| +count: number, +deleted?: false, +tag: string, +vote: 1 | -1 |}
  | {| +deleted: true, +tag: string, +vote: 0 |};

type PendingVoteT = {
  fail: () => void,
  tag: string,
  vote: VoteT,
};

type TagsInputT = HTMLInputElement | HTMLTextAreaElement | null;

class TagEditor extends React.Component<TagEditorProps, TagEditorState> {
  tagsInput: TagsInputT;
  debouncePendingVotes: () => void;
  pendingVotes: {[string]: PendingVoteT};
  setTagsInput: (TagsInputT) => void;

  constructor(props: TagEditorProps) {
    super(props);

    this.state = {
      positiveTagsOnly: true,
      tags: createInitialTagState(props.aggregatedTags, props.userTags),
    };

    _.bindAll(
      this,
      'flushPendingVotes',
      'onBeforeUnload',
      'addTags',
      'setTagsInput',
    );

    this.pendingVotes = {};
    this.debouncePendingVotes = _.debounce(this.flushPendingVotes, VOTE_DELAY);
  }

  flushPendingVotes(asap?: boolean) {
    var actions = {};

    _.each(this.pendingVotes, item => {
      var action = `${getTagsPath(this.props.entity)}/${VOTE_ACTIONS[item.vote]}`;

      (actions[action] = actions[action] || []).push(item);
    });

    this.pendingVotes = {};

    var doRequest = request;
    if (asap) {
      doRequest = args => $.ajax(_.assign({dataType: 'json'}, args));
    }

    _.each(actions, (items, action) => {
      var url = action + '?tags=' + encodeURIComponent(_(items).map('tag').join(','));

      doRequest({url: url})
        .done(data => this.updateTags(data.updates))
        .fail(() => items.forEach(x => x.fail()));
    });
  }

  onBeforeUnload() {
    this.flushPendingVotes(true);
  }

  componentDidMount() {
    require('../../../lib/jquery-ui');
    window.addEventListener('beforeunload', this.onBeforeUnload);
  }

  componentWillUnmount() {
    window.removeEventListener('beforeunload', this.onBeforeUnload);
  }

  createTagRows() {
    var tags = this.state.tags;

    return tags.reduce((accum, t, index) => {
      var callback = newVote => {
        this.updateVote(index, newVote);
        this.addPendingVote(t.tag, newVote, index);
      };

      if (!this.state.positiveTagsOnly || isAlwaysVisible(t)) {
        const genre = isGenre(t);

        const tagRow = (
          <TagRow key={t.tag}
                  tag={t.tag}
                  count={t.count}
                  index={genre ? accum.genres.length : accum.tags.length}
                  currentVote={t.vote}
                  callback={callback}
          />
        );

        if (genre) {
          accum.genres.push(tagRow);
        } else {
          accum.tags.push(tagRow);
        }
      }

      return accum;
    }, {tags: [], genres: []});
  }

  getNewCount(index: number, vote: VoteT) {
    var current = this.state.tags[index];

    if (!current) {
      return 0;
    }

    if (vote === current.vote) {
      return current.count;
    } else if (vote === 0) {
      return current.count + (current.vote * -1);
    } else {
      return current.count + ((current.vote === -vote ? 2 : 1) * vote);
    }
  }

  addTags(event: SyntheticEvent<HTMLFormElement>) {
    event.preventDefault();

    const input = this.tagsInput;
    if (!input) {
      return;
    }

    var tags = input.value;

    this.updateTags(
      splitTags(tags).map(name => {
        var index = _.findIndex(this.state.tags, t => t.tag === name);
        if (index >= 0) {
          return {tag: name, count: this.getNewCount(index, 1), vote: 1};
        } else {
          return {tag: name, count: 1, vote: 1};
        }
      })
    );

    var tagsPath = getTagsPath(this.props.entity);
    $.get(`${tagsPath}/upvote?tags=${encodeURIComponent(tags)}`, data => {
      this.updateTags(JSON.parse(data).updates);
    });

    input.value = '';
  }

  updateVote(index: number, vote: VoteT) {
    var newCount = this.getNewCount(index, vote);
    const tags = this.state.tags.slice(0);
    tags[index] = _.assign({}, tags[index], {count: newCount, vote: vote});
    this.setState({tags});
  }

  updateTags(updatedUserTags: $ReadOnlyArray<TagUpdateT>) {
    var newTags = this.state.tags.slice(0);

    updatedUserTags.forEach(t => {
      var index = _.findIndex(newTags, ct => ct.tag === t.tag);

      if (t.deleted) {
        newTags.splice(index, 1);
      } else {
        var tag = {
          count: t.count,
          tag: t.tag,
          vote: t.vote,
        };

        if (index >= 0) {
          newTags[index] = tag;
        } else {
          newTags.push(tag);
        }
      }
    });

    this.setState({tags: sortedTags(newTags)});
  }

  addPendingVote(tag: string, vote: VoteT, index: number) {
    this.pendingVotes[tag] = {
      tag: tag,
      vote: vote,
      fail: () => this.updateVote(index, vote),
    };
    this.debouncePendingVotes();
  }

  setTagsInput(input: TagsInputT) {
    if (!input) {
      $(this.tagsInput).autocomplete('destroy');
      this.tagsInput = null;
      return;
    }

    this.tagsInput = input;

    $(input).autocomplete({
      source: function (request, response) {
        const terms = splitTags(request.term);
        const last = terms.pop();
        if (isBlank(last)) {
          response([]);
          return;
        }
        response(
          _.sortBy(
            ($.ui.autocomplete.filter(
              _.without(GENRE_TAGS_ARRAY, ...terms),
              last,
            ): $ReadOnlyArray<string>),
            [x => x.startsWith(last) ? 0 : 1, _.identity],
          )
        );
      },

      focus: function () {
        return false;
      },

      select: function (event, ui) {
        const terms = splitTags(this.value);
        terms.pop();
        terms.push(ui.item.value, '');
        this.value = terms.join(', ');
        return false;
      },
    });

    /*
     * MBS-9862: jQuery UI disables the browser's builtin autocomplete
     * history in a non-configurable way, but we want it to show here
     * if the user hasn't typed anything yet, so flip it back on.
     */
    input.setAttribute('autocomplete', 'on');
  }
}

class MainTagEditor extends TagEditor {
  showAllTags(event: SyntheticEvent<HTMLAnchorElement>) {
    event.preventDefault();
    this.setState({positiveTagsOnly: false});
  }

  render() {
    var {tags, positiveTagsOnly} = this.state;
    var tagRows = this.createTagRows();

    return (
      <div>
        {tags.length ? (
          <>
            <h2>{l('Genres')}</h2>

            {tagRows.genres.length ? (
              <ul className="genre-list">
                {tagRows.genres}
              </ul>
            ) : (
              <p>{l('There are no genres to show.')}</p>
            )}

            <h2>{l('Other tags')}</h2>

            {tagRows.tags.length ? (
              <ul className="tag-list">
                {tagRows.tags}
              </ul>
            ) : (
              <p>{l('There are no other tags to show.')}</p>
            )}
          </>
        ) : (
          <p>{l('Nobody has tagged this yet.')}</p>
        )}

        {(positiveTagsOnly && !tags.every(isAlwaysVisible)) && [
          <p key={1}>
            {l('Tags with a score of zero or below, and tags that you’ve downvoted are hidden.')}
          </p>,
          <p key={2}>
            <a href="#" onClick={this.showAllTags.bind(this)}>{l('Show all tags.')}</a>
          </p>
        ]}

        <h2>{l('Add Tags')}</h2>
        <p>
          {l('You can add your own {tagdocs|tags} below. Use commas to separate multiple tags.',
            {tagdocs: '/doc/Folksonomy_Tagging'})}
        </p>
        <form id="tag-form" onSubmit={this.addTags}>
          <p>
            <textarea row="5" cols="50" ref={this.setTagsInput}></textarea>
          </p>
          <button type="submit" className="styled-button">
            {l('Submit tags')}
          </button>
        </form>
      </div>
    );
  }
}

class SidebarTagEditor extends TagEditor {
  render() {
    const tagRows = this.createTagRows();
    return (
      <>
        <h2>{l('Genres')}</h2>

        {tagRows.genres.length ? (
          <ul className="genre-list">
            {tagRows.genres}
          </ul>
        ) : (
          <p>{lp('(none)', 'genre')}</p>
        )}

        <h2>{l('Other tags')}</h2>

        {tagRows.tags.length ? (
          <ul className="tag-list">
            {tagRows.tags}
          </ul>
        ) : (
          <p>{lp('(none)', 'tag')}</p>
        )}

        {this.props.more ? (
          <p>
            {bracketed(
              <a href={getTagsPath(this.props.entity)} key="see-all">
                {l('see all tags')}
              </a>
            )}
          </p>
        ) : null}

        <form id="tag-form" onSubmit={this.addTags}>
          <div style={{display: 'flex'}}>
            <input
              className="tag-input"
              name="tags"
              ref={this.setTagsInput}
              style={{flexGrow: 2}}
              type="text"
            />
            <button type="submit" className="styled-button">
              {l('Tag', 'verb')}
            </button>
          </div>
        </form>
      </>
    );
  }
}

const keyByTag = keyBy(t => t.tag);

function createInitialTagState(
  aggregatedTags: $ReadOnlyArray<AggregatedTagT>,
  userTags: $ReadOnlyArray<UserTagT>,
) {
  const userTagsByName = keyByTag(userTags);

  const used = new Set();

  const combined = aggregatedTags.map(function (t) {
    var userTag = userTagsByName.get(t.tag);

    used.add(t.tag);

    return {
      tag: t.tag,
      count: t.count,
      vote: userTag ? userTag.vote : 0,
    };
  });

  // Always show upvoted user tags (affects sidebar)
  for (const t of userTagsByName.values()) {
    if (t.vote > 0 && !used.has(t.tag)) {
      combined.push(t);
    }
  }

  return sortedTags(combined);
}

function init_tag_editor(Component, mountPoint) {
  return function (entity, aggregatedTags, userTags, more) {
    ReactDOM.render(
      <Component
        aggregatedTags={aggregatedTags}
        entity={entity}
        more={more}
        userTags={userTags}
      />,
      (document.getElementById(mountPoint): any)
    );
  };
}

exports.MainTagEditor = MainTagEditor;

exports.SidebarTagEditor = hydrate<TagEditorProps>('sidebar-tags', SidebarTagEditor, minimalEntity);

MB.init_main_tag_editor = init_tag_editor(MainTagEditor, 'all-tags');
