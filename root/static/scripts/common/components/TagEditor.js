/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import _ from 'lodash';
import React from 'react';

import hydrate, {minimalEntity} from '../../../../utility/hydrate';
import loopParity from '../../../../utility/loopParity';
import {GENRE_TAGS} from '../constants';
import {unwrapNl} from '../i18n';
import bracketed from '../utility/bracketed';
import isBlank from '../utility/isBlank';

import TagLink from './TagLink';

const GENRE_TAGS_ARRAY = Array.from(GENRE_TAGS.values());

const VOTE_ACTIONS = {
  '-1': 'downvote',
  '0': 'withdraw',
  '1': 'upvote',
};

/*
 * The voting endpoints accept multiple tags, so we want to batch requests
 * together where possible. A delay is enforced using _.debounce, so a
 * request will not be sent until VOTE_DELAY has passed since the last vote.
 */
const VOTE_DELAY = 1000;

const getTagName = t => t.tag;

function sortedTags(tags) {
  return _.sortBy(tags, t => -t.count, getTagName);
}

function getTagsPath(entity) {
  const type = entity.entityType.replace('_', '-');
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
  activeTitle: string | () => string,
  callback: (VoteT) => void,
  currentVote: VoteT,
  text: string,
  title: string | () => string,
  vote: VoteT,
  ...,
};

class VoteButton extends React.Component<VoteButtonProps> {
  render() {
    const {
      activeTitle,
      callback,
      currentVote,
      text,
      title,
      vote,
    } = this.props;
    const isActive = vote === currentVote;

    const buttonProps = {
      className: 'tag-vote tag-' + VOTE_ACTIONS[vote],
      disabled: isActive,
      title: isActive
        ? unwrapNl(activeTitle)
        : (currentVote === 0 ? unwrapNl(title) : l('Withdraw vote')),
      type: 'button',
    };

    if (!isActive) {
      (buttonProps: any).onClick = _.partial(
        callback,
        currentVote === 0 ? vote : 0,
      );
    }

    return <button {...buttonProps}>{text}</button>;
  }
}

class UpvoteButton extends VoteButton {
  static defaultProps = {
    activeTitle: N_l('You’ve upvoted this tag'),
    text: '+',
    title: N_l('Upvote'),
    vote: 1,
  }
}

class DownvoteButton extends VoteButton {
  static defaultProps = {
    activeTitle: N_l('You’ve downvoted this tag'),
    text: '\u2212',
    title: N_l('Downvote'),
    vote: -1,
  }
}

type VoteButtonsProps = {
  $c: CatalystContextT,
  callback: (VoteT) => void,
  count: number,
  currentVote: VoteT,
  ...,
};

class VoteButtons extends React.Component<VoteButtonsProps> {
  render() {
    const currentVote = this.props.currentVote;
    let className = '';

    if (currentVote === 1) {
      className = ' tag-upvoted';
    } else if (currentVote === -1) {
      className = ' tag-downvoted';
    }

    return (
      <span className={'tag-vote-buttons' + className}>
        {this.props.$c.user_exists ? (
          <>
            <UpvoteButton {...this.props} />
            <DownvoteButton {...this.props} />
          </>
        ) : null}
        <span className="tag-count">{this.props.count}</span>
      </span>
    );
  }
}

type TagRowProps = {
  $c: CatalystContextT,
  callback: (VoteT) => void,
  count: number,
  currentVote: VoteT,
  index: number,
  tag: string,
};

class TagRow extends React.Component<TagRowProps> {
  render() {
    const {tag, index} = this.props;

    return (
      <li className={loopParity(index)} key={tag}>
        <TagLink tag={tag} />
        <VoteButtons {...this.props} />
      </li>
    );
  }
}

type TagEditorProps = {
  +$c: CatalystContextT,
  +aggregatedTags: $ReadOnlyArray<AggregatedTagT>,
  +entity: MinimalCoreEntityT,
  +more: boolean,
  +userTags: $ReadOnlyArray<UserTagT>,
};

type TagEditorState = {
  positiveTagsOnly: boolean,
  tags: $ReadOnlyArray<UserTagT>,
};

type TagUpdateT =
  | { +count: number, +deleted?: false, +tag: string, +vote: 1 | -1 }
  | { +deleted: true, +tag: string, +vote: 0 };

type PendingVoteT = {
  fail: () => void,
  tag: string,
  vote: VoteT,
};

type TagsInputT = HTMLInputElement | HTMLTextAreaElement | null;

class TagEditor extends React.Component<TagEditorProps, TagEditorState> {
  tagsInput: TagsInputT;

  debouncePendingVotes: () => void;

  pendingVotes: {[string]: PendingVoteT, ...};

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
    this.debouncePendingVotes = _.debounce(
      this.flushPendingVotes, VOTE_DELAY,
    );
  }

  flushPendingVotes(asap?: boolean) {
    const actions = {};

    _.each(this.pendingVotes, item => {
      const action =
        `${getTagsPath(this.props.entity)}/${VOTE_ACTIONS[item.vote]}`;

      (actions[action] = actions[action] || []).push(item);
    });

    this.pendingVotes = {};

    let doRequest;
    if (asap) {
      const $ = require('jquery');
      doRequest = args => $.ajax({...args, dataType: 'json'});
    } else {
      doRequest = require('../utility/request').default;
    }

    _.each(actions, (items, action) => {
      const url = action + '?tags=' +
        encodeURIComponent(_(items).map('tag').join(','));

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
    const tags = this.state.tags;

    return tags.reduce((accum, t, index) => {
      const callback = newVote => {
        this.updateVote(index, newVote);
        this.addPendingVote(t.tag, newVote, index);
      };

      if (!this.state.positiveTagsOnly || isAlwaysVisible(t)) {
        const genre = isGenre(t);

        const tagRow = (
          <TagRow
            $c={this.props.$c}
            callback={callback}
            count={t.count}
            currentVote={t.vote}
            index={genre ? accum.genres.length : accum.tags.length}
            key={t.tag}
            tag={t.tag}
          />
        );

        if (genre) {
          accum.genres.push(tagRow);
        } else {
          accum.tags.push(tagRow);
        }
      }

      return accum;
    }, {genres: [], tags: []});
  }

  getNewCount(index: number, vote: VoteT) {
    const current = this.state.tags[index];

    if (!current) {
      return 0;
    }

    if (vote === current.vote) {
      return current.count;
    } else if (vote === 0) {
      return current.count + (current.vote * -1);
    }
    return current.count + ((current.vote === -vote ? 2 : 1) * vote);
  }

  addTags(event: SyntheticEvent<HTMLFormElement>) {
    event.preventDefault();

    const input = this.tagsInput;
    if (!input) {
      return;
    }

    const tags = input.value;

    this.updateTags(
      splitTags(tags).map(name => {
        const index = _.findIndex(this.state.tags, t => t.tag === name);
        if (index >= 0) {
          return {count: this.getNewCount(index, 1), tag: name, vote: 1};
        }
        return {count: 1, tag: name, vote: 1};
      }),
    );

    const $ = require('jquery');
    const tagsPath = getTagsPath(this.props.entity);
    $.get(`${tagsPath}/upvote?tags=${encodeURIComponent(tags)}`, data => {
      this.updateTags(JSON.parse(data).updates);
    });

    input.value = '';
  }

  updateVote(index: number, vote: VoteT) {
    const newCount = this.getNewCount(index, vote);
    const tags = this.state.tags.slice(0);
    tags[index] = {...tags[index], count: newCount, vote};
    this.setState({tags});
  }

  updateTags(updatedUserTags: $ReadOnlyArray<TagUpdateT>) {
    const newTags = this.state.tags.slice(0);

    updatedUserTags.forEach(t => {
      const index = _.findIndex(newTags, ct => ct.tag === t.tag);

      if (t.deleted) {
        newTags.splice(index, 1);
      } else {
        const tag = {
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
      fail: () => this.updateVote(index, vote),
      tag: tag,
      vote: vote,
    };
    this.debouncePendingVotes();
  }

  setTagsInput(input: TagsInputT) {
    const $ = require('jquery');

    if (!input) {
      $(this.tagsInput).autocomplete('destroy');
      this.tagsInput = null;
      return;
    }

    this.tagsInput = input;

    $(input).autocomplete({
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
          ),
        );
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

export const MainTagEditor = hydrate<TagEditorProps>(
  'div.all-tags',
  class extends TagEditor {
    hideNegativeTags(event: SyntheticEvent<HTMLAnchorElement>) {
      event.preventDefault();
      this.setState({positiveTagsOnly: true});
    }

    showAllTags(event: SyntheticEvent<HTMLAnchorElement>) {
      event.preventDefault();
      this.setState({positiveTagsOnly: false});
    }

    render() {
      const {tags, positiveTagsOnly} = this.state;
      const tagRows = this.createTagRows();

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

          {(positiveTagsOnly && !tags.every(isAlwaysVisible)) ? (
            <>
              {this.props.$c.user_exists ? (
                <p>
                  {l(
                    `Tags with a score of zero or below,
                     and tags that you’ve downvoted are hidden.`,
                  )}
                </p>
              ) : (
                <p>
                  {l('Tags with a score of zero or below are hidden.') + ' '}
                </p>
              )}
              <p>
                <a href="#" onClick={this.showAllTags.bind(this)}>
                  {l('Show all tags.')}
                </a>
              </p>
            </>
          ) : null}

          {positiveTagsOnly === false ? (
            <>
              <p>
                {l('All tags are being shown.')}
              </p>
              {this.props.$c.user_exists ? (
                <p>
                  <a href="#" onClick={this.hideNegativeTags.bind(this)}>
                    {l(
                      `Hide tags with a score of zero or below,
                       and tags that you’ve downvoted.`,
                    )}
                  </a>
                </p>
              ) : (
                <p>
                  <a href="#" onClick={this.hideNegativeTags.bind(this)}>
                    {l('Hide tags with a score of zero or below.')}
                  </a>
                </p>
              )}
            </>
          ) : null}

          {this.props.$c.user_exists ? (
            <>
              <h2>{l('Add Tags')}</h2>
              <p>
                {exp.l(
                  `You can add your own {tagdocs|tags} below.
                   Use commas to separate multiple tags.`,
                  {tagdocs: '/doc/Folksonomy_Tagging'},
                )}
              </p>
              <form id="tag-form" onSubmit={this.addTags}>
                <p>
                  <textarea cols="50" ref={this.setTagsInput} rows="5" />
                </p>
                <button className="styled-button" type="submit">
                  {l('Submit tags')}
                </button>
              </form>
            </>
          ) : null}
        </div>
      );
    }
  },
  minimalEntity,
);

export const SidebarTagEditor = hydrate<TagEditorProps>(
  'div.sidebar-tags',
  class extends TagEditor {
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
                </a>,
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
              <button className="styled-button" type="submit">
                {lp('Tag', 'verb')}
              </button>
            </div>
          </form>
        </>
      );
    }
  },
  minimalEntity,
);

function createInitialTagState(
  aggregatedTags: $ReadOnlyArray<AggregatedTagT>,
  userTags: $ReadOnlyArray<UserTagT>,
) {
  const userTagsByName = _.keyBy(userTags, getTagName);

  const used = new Set();

  const combined = aggregatedTags.map(function (t) {
    const userTag = userTagsByName[t.tag];

    used.add(t.tag);

    return {
      count: t.count,
      tag: t.tag,
      vote: userTag ? userTag.vote : 0,
    };
  });

  // Always show upvoted user tags (affects sidebar)
  for (const tagName of Object.keys(userTagsByName)) {
    const tag = userTagsByName[tagName];
    if (tag.vote > 0 && !used.has(tagName)) {
      combined.push(tag);
    }
  }

  return sortedTags(combined);
}
