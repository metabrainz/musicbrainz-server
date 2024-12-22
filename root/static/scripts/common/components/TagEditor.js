/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import {minimalEntity} from '../../../../utility/hydrate.js';
import loopParity from '../../../../utility/loopParity.js';
import {unwrapNl} from '../i18n.js';
import {keyBy, sortByNumber} from '../utility/arrays.js';
import bracketed, {bracketedText} from '../utility/bracketed.js';
import {compareStrings} from '../utility/compare.mjs';
import debounce from '../utility/debounce.js';
import isBlank from '../utility/isBlank.js';

import TagLink from './TagLink.js';

type MinimalTaggableEntityT = {
  +entityType: TaggableEntityT['entityType'],
  +gid: string,
};

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

const cmpTags = (a: UserTagT, b: UserTagT) => (
  (b.count - a.count) || compareStrings(a.tag.name, b.tag.name)
);

function formatGenreLabel(genre: GenreT) {
  let output: string = he.encode(genre.name);
  if (genre.comment) {
    output += (
      '<span class="small"> ' +
      he.encode(bracketedText(genre.comment)) +
      '</span>'
    );
  }
  return output;
}

function getTagsPath(entity: TaggableEntityT | MinimalTaggableEntityT) {
  const type = entity.entityType.replace('_', '-');
  return `/${type}/${entity.gid}/tags`;
}

function isAlwaysVisible(tag: UserTagT) {
  return tag.vote > 0 || (tag.vote === 0 && tag.count > 0);
}

function splitTags(tags: string) {
  return (
    tags
      .trim()
      .toLowerCase()
      .split(/\s*,\s*/)
      .filter(x => !isBlank(x))
  );
}

type VoteT = 1 | 0 | -1;

component VoteButton(
  activeTitle: string | () => string,
  callback: (VoteT) => void,
  currentVote: VoteT,
  text: string,
  title: string | () => string,
  vote: VoteT,
 ) {
  const isActive = vote === currentVote;
  const className = 'tag-vote tag-' + VOTE_ACTIONS[vote];
  const buttonTitle = isActive
    ? unwrapNl<string>(activeTitle)
    : (currentVote === 0 ? unwrapNl<string>(title) : l('Withdraw vote'));

  return (
    <button
      className={className}
      disabled={isActive}
      onClick={isActive
        ? null
        : () => callback(currentVote === 0 ? vote : 0)}
      title={buttonTitle}
      type="button"
    >
      {text}
    </button>
  );
}

component UpvoteButton(
  callback: (VoteT) => void,
  currentVote: VoteT,
) renders VoteButton {
  return (
    <VoteButton
      activeTitle={lp('You’ve upvoted this tag', 'folksonomy')}
      callback={callback}
      currentVote={currentVote}
      text="+"
      title={l('Upvote')}
      vote={1}
    />
  );
}

component DownvoteButton(
  callback: (VoteT) => void,
  currentVote: VoteT,
) renders VoteButton {
  return (
    <VoteButton
      activeTitle={lp('You’ve downvoted this tag', 'folksonomy')}
      callback={callback}
      currentVote={currentVote}
      text={'\u2212'}
      title={l('Downvote')}
      vote={-1}
    />
  );
}

component VoteButtons(
  callback: (VoteT) => void,
  count: number,
  currentVote: VoteT,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  let className = '';
  if (currentVote === 1) {
    className = ' tag-upvoted';
  } else if (currentVote === -1) {
    className = ' tag-downvoted';
  }

  return (
    <span className={'tag-vote-buttons' + className}>
      {$c.user?.has_confirmed_email_address ? (
        <>
          <UpvoteButton callback={callback} currentVote={currentVote} />
          <DownvoteButton callback={callback} currentVote={currentVote} />
        </>
      ) : null}
      <span className="tag-count">{count}</span>
    </span>
  );
}

component TagRow(
  callback: (VoteT) => void,
  count: number,
  currentVote: VoteT,
  index: number,
  tag: TagT,
) {
  return (
    <li className={loopParity(index)} key={tag.name}>
      <TagLink tag={tag.name} />
      <VoteButtons
        callback={callback}
        count={count}
        currentVote={currentVote}
      />
    </li>
  );
}

type TagEditorProps = {
  +aggregatedTags: $ReadOnlyArray<AggregatedTagT>,
  +entity: TaggableEntityT | MinimalTaggableEntityT,
  +genreMap: ?{+[genreName: string]: GenreT, ...},
  +more: boolean,
  +userTags: $ReadOnlyArray<UserTagT>,
};

type TagEditorState = {
  positiveTagsOnly: boolean,
  tags: $ReadOnlyArray<UserTagT>,
};

type TagUpdateT =
  | {+count: number, +deleted?: false, +tag: string, +vote: 1 | -1}
  | {+deleted: true, +tag: string, +vote: 0};

type PendingVoteT = {
  fail: () => void,
  tag: TagT,
  vote: VoteT,
};

type TagsInputT = HTMLInputElement | HTMLTextAreaElement | null;

class TagEditor extends React.Component<TagEditorProps, TagEditorState> {
  tagsInput: TagsInputT;

  debouncePendingVotes: () => void;

  genreMap: {+[genreName: string]: GenreT, ...};

  genreOptions: $ReadOnlyArray<{+label: string, +value: string}>;

  handleSubmitBound: (SyntheticEvent<HTMLFormElement>) => void;

  onBeforeUnloadBound: () => void;

  pendingVotes: Map<string, PendingVoteT>;

  setTagsInputBound: (TagsInputT) => void;

  constructor(props: TagEditorProps) {
    super(props);

    this.state = {
      positiveTagsOnly: true,
      tags: createInitialTagState(props.aggregatedTags, props.userTags),
    };

    this.onBeforeUnloadBound = () => this.onBeforeUnload();
    this.handleSubmitBound = (event) => this.handleSubmit(event);
    this.setTagsInputBound = (input) => this.setTagsInput(input);

    this.genreMap = props.genreMap ?? ({}: {+[genreName: string]: GenreT});
    this.genreOptions =
      Object.values(this.genreMap)
        .map(genre => {
          return {
            label: formatGenreLabel(genre),
            value: genre.name,
          };
        });

    this.pendingVotes = new Map();
    this.debouncePendingVotes = debounce(
      (asap) => this.flushPendingVotes(asap),
      VOTE_DELAY,
    );
  }

  flushPendingVotes(asap?: boolean) {
    const actions: {[action: string]: Array<PendingVoteT>} = {};

    for (const item of this.pendingVotes.values()) {
      const action =
        `${getTagsPath(this.props.entity)}/${VOTE_ACTIONS[item.vote]}`;

      (actions[action] ||= []).push(item);
    }

    this.pendingVotes.clear();

    let doRequest;
    if (asap) {
      const $ = require('jquery');
      doRequest = (
        args: {+url: string},
      ) => $.ajax({...args, dataType: 'json'});
    } else {
      doRequest = require('../utility/request.js').default;
    }

    for (const [action, items] of Object.entries(actions)) {
      const url = action + '?tags=' +
        encodeURIComponent(items.map(x => x.tag.name).join(','));

      doRequest({url})
        .done(data => this.updateTags(data.updates))
        .fail(() => items.forEach(x => {
          x.fail();
        }));
    }
  }

  onBeforeUnload() {
    this.flushPendingVotes(true);
  }

  componentDidMount() {
    require('../../../lib/jquery-ui.js');
    window.addEventListener('beforeunload', this.onBeforeUnloadBound);
  }

  componentWillUnmount() {
    window.removeEventListener('beforeunload', this.onBeforeUnloadBound);
  }

  createTagRows(): {
    +genres: $ReadOnlyArray<React.MixedElement>,
    +tags: $ReadOnlyArray<React.MixedElement>,
    } {
    const tags = this.state.tags;

    return tags.reduce((
      accum: {
        +genres: Array<React.MixedElement>,
        +tags: Array<React.MixedElement>,
      },
      t: UserTagT,
      index: number,
    ) => {
      const callback = (newVote: VoteT) => {
        this.updateVote(index, newVote);
        this.addPendingVote(t.tag, newVote, index);
      };

      if (!this.state.positiveTagsOnly || isAlwaysVisible(t)) {
        const isGenre = Object.hasOwn(this.genreMap, t.tag.name);

        const tagRow = (
          <TagRow
            callback={callback}
            count={t.count}
            currentVote={t.vote}
            index={isGenre ? accum.genres.length : accum.tags.length}
            key={t.tag.name}
            tag={t.tag}
          />
        );

        if (isGenre) {
          accum.genres.push(tagRow);
        } else {
          accum.tags.push(tagRow);
        }
      }

      return accum;
    }, {genres: [], tags: []});
  }

  getNewCount(index: number, vote: VoteT): number {
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

  handleSubmit(event: SyntheticEvent<HTMLFormElement>) {
    event.preventDefault();

    const input = this.tagsInput;
    if (!input) {
      return;
    }

    const tags = input.value;

    this.updateTags(
      splitTags(tags).map(name => {
        const index = this.state.tags.findIndex(t => t.tag.name === name);
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
      const index = newTags.findIndex(ct => ct.tag.name === t.tag);
      const genre = this.genreMap[t.tag];

      if (t.deleted) {
        newTags.splice(index, 1);
      } else {
        const tag = {
          count: t.count,
          tag: {
            entityType: 'tag',
            genre,
            id: null,
            name: t.tag,
          },
          vote: t.vote,
        };

        if (index >= 0) {
          newTags[index] = tag;
        } else {
          newTags.push(tag);
        }
      }
    });

    this.setState({tags: newTags.sort(cmpTags)});
  }

  addPendingVote(tag: TagT, vote: VoteT, index: number) {
    this.pendingVotes.set(tag.name, {
      fail: () => this.updateVote(index, vote),
      tag,
      vote,
    });
    this.debouncePendingVotes();
  }

  setTagsInput(input: TagsInputT) {
    const $ = require('jquery');
    const self = this;

    if (!input) {
      $(this.tagsInput).autocomplete('destroy');
      this.tagsInput = null;
      return;
    }

    this.tagsInput = input;

    $(input).autocomplete({
      focus() {
        return false;
      },

      select(this: HTMLInputElement, event, ui) {
        // $FlowIgnore[object-this-reference]
        const terms = splitTags(this.value);
        terms.pop();
        terms.push(ui.item.value, '');
        // $FlowIgnore[object-this-reference]
        this.value = terms.join(', ');
        return false;
      },

      source(request, response) {
        const terms = splitTags(request.term);
        const last = terms.pop();

        if (isBlank(last)) {
          response([]);
          return;
        }

        const previousTerms = new Set(terms);
        const filteredTerms: $ReadOnlyArray<string> =
          sortByNumber(
            $.ui.autocomplete.filter(
              self.genreOptions.filter(x => !previousTerms.has(x.value)),
              last,
            ).sort(),
            x => x.value.startsWith(last) ? 0 : 1,
          );

        response(filteredTerms);
      },
    }).data('ui-autocomplete')._renderItem = function (ul, item) {
      return $('<li></li>')
        .append('<a>' + item.label + '</a>')
        .appendTo(ul);
    };

    /*
     * MBS-9862: jQuery UI disables the browser's builtin autocomplete
     * history in a non-configurable way, but we want it to show here
     * if the user hasn't typed anything yet, so flip it back on.
     */
    input.setAttribute('autocomplete', 'on');
  }
}

export const MainTagEditor = (hydrate<TagEditorProps>(
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

    render(): React.MixedElement {
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

              <h2>{lp('Other tags', 'folksonomy')}</h2>

              {tagRows.tags.length ? (
                <ul className="tag-list">
                  {tagRows.tags}
                </ul>
              ) : (
                <p>{lp('There are no other tags to show.', 'folksonomy')}</p>
              )}
            </>
          ) : (
            <p>{lp('Nobody has tagged this yet.', 'folksonomy')}</p>
          )}

          <SanitizedCatalystContext.Consumer>
            {($c: SanitizedCatalystContextT) => (
              <>
                {(positiveTagsOnly && !tags.every(isAlwaysVisible)) ? (
                  <>
                    {$c.user?.has_confirmed_email_address ? (
                      <p>
                        {lp(
                          `Tags with a score of zero or below,
                           and tags that you’ve downvoted are hidden.`,
                          'folksonomy',
                        )}
                      </p>
                    ) : (
                      <p>
                        {lp(
                          'Tags with a score of zero or below are hidden.',
                          'folksonomy',
                        )}
                      </p>
                    )}
                    <p>
                      <a
                        href="#"
                        onClick={(event) => this.showAllTags(event)}
                      >
                        {lp('Show all tags.', 'folksonomy')}
                      </a>
                    </p>
                  </>
                ) : null}

                {positiveTagsOnly === false ? (
                  <>
                    <p>
                      {lp('All tags are being shown.', 'folksonomy')}
                    </p>
                    {$c.user?.has_confirmed_email_address ? (
                      <p>
                        <a
                          href="#"
                          onClick={(event) => this.hideNegativeTags(event)}
                        >
                          {lp(
                            `Hide tags with a score of zero or below,
                             and tags that you’ve downvoted.`,
                            'folksonomy',
                          )}
                        </a>
                      </p>
                    ) : (
                      <p>
                        <a
                          href="#"
                          onClick={(event) => this.hideNegativeTags(event)}
                        >
                          {lp(
                            'Hide tags with a score of zero or below.',
                            'folksonomy',
                          )}
                        </a>
                      </p>
                    )}
                  </>
                ) : null}

                {$c.user?.has_confirmed_email_address ? (
                  <>
                    <h2>{lp('Add tags', 'folksonomy')}</h2>
                    <p>
                      {exp.lp(
                        `You can add your own {tagdocs|tags} below.
                        Use commas to separate multiple tags.`,
                        'folksonomy',
                        {tagdocs: '/doc/Folksonomy_Tagging'},
                      )}
                    </p>
                    <form id="tag-form" onSubmit={this.handleSubmitBound}>
                      <p>
                        <textarea
                          cols="50"
                          ref={this.setTagsInputBound}
                          rows="5"
                        />
                      </p>
                      <button className="styled-button" type="submit">
                        {lp('Submit tags', 'folksonomy')}
                      </button>
                    </form>
                  </>
                ) : null}
              </>
            )}
          </SanitizedCatalystContext.Consumer>
        </div>
      );
    }
  },
  minimalEntity,
): React.AbstractComponent<TagEditorProps, void>);

export const SidebarTagEditor = (hydrate<TagEditorProps>(
  'div.sidebar-tags',
  class extends TagEditor {
    render(): React.MixedElement {
      const tagRows = this.createTagRows();
      return (
        <>
          <h2>{lp('Tags', 'folksonomy')}</h2>

          <h3>{l('Genres')}</h3>
          {tagRows.genres.length ? (
            <ul className="genre-list">
              {tagRows.genres}
            </ul>
          ) : (
            <p>{lp('(none)', 'genre')}</p>
          )}

          <h3>{lp('Other tags', 'folksonomy')}</h3>
          {tagRows.tags.length ? (
            <ul className="tag-list">
              {tagRows.tags}
            </ul>
          ) : (
            <p>{lp('(none)', 'folksonomy tag')}</p>
          )}

          {this.props.more ? (
            <p>
              {bracketed(
                <a href={getTagsPath(this.props.entity)} key="see-all">
                  {lp('see all tags', 'folksonomy')}
                </a>,
              )}
            </p>
          ) : null}

          <form id="tag-form" onSubmit={this.handleSubmitBound}>
            <div style={{display: 'flex'}}>
              <input
                className="tag-input"
                name="tags"
                ref={this.setTagsInputBound}
                style={{flexGrow: 2}}
                type="text"
              />
              <button className="styled-button" type="submit">
                {lp('Tag', 'verb, folksonomy')}
              </button>
            </div>
          </form>
        </>
      );
    }
  },
  minimalEntity,
): React.AbstractComponent<TagEditorProps, void>);

function createInitialTagState(
  aggregatedTags: $ReadOnlyArray<AggregatedTagT>,
  userTags: $ReadOnlyArray<UserTagT>,
): $ReadOnlyArray<UserTagT> {
  const userTagsByName = keyBy(userTags, t => t.tag.name);

  const used = new Set<string>();

  const combined: Array<UserTagT> = aggregatedTags.map(function (t) {
    const userTag = userTagsByName.get(t.tag.name);

    used.add(t.tag.name);

    return {
      count: t.count,
      tag: t.tag,
      vote: userTag ? userTag.vote : 0,
    };
  });

  // Always show upvoted user tags (affects sidebar)
  for (const [tagName, tag] of userTagsByName) {
    if (tag.vote > 0 && !used.has(tagName)) {
      combined.push(tag);
    }
  }

  return combined.sort(cmpTags);
}
