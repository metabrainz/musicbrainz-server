// @flow
// Copyright (C) 2015 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const Immutable = require('immutable');
const $ = require('jquery');
const _ = require('lodash');
const React = require('react');
const ReactDOM = require('react-dom');

const {l, lp} = require('../i18n');
const MB = require('../MB');
const request = require('../utility/request');
const TagLink = require('./TagLink');

const newTag: RecordFactory<UserTagT> = Immutable.Record({
  tag: '',
  count: 0,
  vote: 0,
});

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
  return tags.sortBy(t => t.tag).sortBy(t => -t.count);
}

function getTagsPath(entity) {
  var type = entity.entityType.replace('_', '-');
  return `/${type}/${entity.gid}/tags`;
}

function isAlwaysVisible(tag) {
  return tag.vote > 0 || (tag.vote === 0 && tag.count > 0);
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
      <li key={tag} className={(index + 1) % 2 ? 'odd' : 'even'}>
        <TagLink tag={tag} />
        <VoteButtons {...this.props} />
      </li>
    );
  }
}

type TagEditorProps = {
  entity: CoreEntityT,
};

type TagEditorState = {
  positiveTagsOnly: bool,
  tags: List<RecordOf<UserTagT>>,
};

type PendingVoteT = {
  fail: () => void,
  tag: string,
  vote: VoteT,
};

class TagEditor extends React.Component<TagEditorProps, TagEditorState> {
  _tagsInput: HTMLInputElement | HTMLTextAreaElement | null;
  debouncePendingVotes: () => void;
  pendingVotes: {[string]: PendingVoteT};

  constructor(props) {
    super(props);
    this.state = _.assign({positiveTagsOnly: true}, props.initialState);

    _.bindAll(this, 'flushPendingVotes', 'onBeforeUnload', 'addTags');

    this.pendingVotes = {};
    this.debouncePendingVotes = _.debounce(this.flushPendingVotes, VOTE_DELAY);
  }

  flushPendingVotes(asap) {
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

  componentWillMount() {
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
        accum.push(
          <TagRow key={t.tag}
                  tag={t.tag}
                  count={t.count}
                  index={index}
                  currentVote={t.vote}
                  callback={callback} />
        );
      }

      return accum;
    }, []);
  }

  getNewCount(index, vote) {
    var current = this.state.tags.get(index);

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

  addTags(event) {
    event.preventDefault();

    const input = this._tagsInput;
    if (!input) {
      return;
    }

    var tags = input.value;

    this.updateTags(
      _(tags.split(','))
        .map(name => {
          name = _.trim(name).toLowerCase();
          if (name) {
            var index = this.state.tags.findIndex(t => t.tag === name);
            if (index >= 0) {
              return {tag: name, count: this.getNewCount(index, 1), vote: 1};
            } else {
              return {tag: name, count: 1, vote: 1};
            }
          }
        })
        .compact()
        .value()
    );

    var tagsPath = getTagsPath(this.props.entity);
    $.get(`${tagsPath}/upvote?tags=${encodeURIComponent(tags)}`, data => {
      this.updateTags(JSON.parse(data).updates);
    });

    input.value = '';
  }

  updateVote(index, vote) {
    var newCount = this.getNewCount(index, vote);
    this.setState({
      tags: this.state.tags.mergeIn([index], {count: newCount, vote: vote})
    });
  }

  updateTags(updatedUserTags) {
    var newTags = this.state.tags;

    updatedUserTags.forEach(t => {
      var index = newTags.findIndex(ct => ct.tag === t.tag);

      if (t.deleted) {
        newTags = newTags.delete(index);
      } else {
        var tag = newTag(({
          count: t.count,
          tag: t.tag,
          vote: t.vote,
        }: UserTagT));

        if (index >= 0) {
          newTags = newTags.set(index, tag);
        } else {
          newTags = newTags.push(tag);
        }
      }
    });

    this.setState({tags: sortedTags(newTags)});
  }

  addPendingVote(tag, vote, index) {
    this.pendingVotes[tag] = {
      tag: tag,
      vote: vote,
      fail: () => this.updateVote(index, vote),
    };
    this.debouncePendingVotes();
  }
}

class MainTagEditor extends TagEditor {
  showAllTags(event) {
    event.preventDefault();
    this.setState({positiveTagsOnly: false});
  }

  render() {
    var {tags, positiveTagsOnly} = this.state;
    var tagRows = this.createTagRows();

    return (
      <div>
        {tags.size === 0 && <p>{l('Nobody has tagged this yet.')}</p>}

        {tagRows.length > 0 &&
          <ul className="tag-list">
            {tagRows}
          </ul>}

        {(positiveTagsOnly && tags.some(t => !isAlwaysVisible(t))) && [
          <p key={1}>
            {l('Tags with a score of zero or below, and tags that you’ve downvoted are hidden.')}
          </p>,
          <p key={2}>
            <a href="#" onClick={this.showAllTags.bind(this)}>{l('Show all tags.')}</a>
          </p>
        ]}

        <h2>{l('Add Tags')}</h2>
        <p dangerouslySetInnerHTML={{__html:
          l('You can add your own {tagdocs|tags} below. Use commas to separate multiple tags.',
            {tagdocs: '/doc/Folksonomy_Tagging'})}}></p>
        <form id="tag-form" onSubmit={this.addTags}>
          <p>
            <textarea row="5" cols="50" ref={input => this._tagsInput = input}></textarea>
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
    return (
      <div>
        <ul className="tag-list">
          {this.createTagRows()}
          {this.props.more
            // createTagRows uses tags as keys; \0 is simply used here to
            // guarantee that there isn't any conflict.
            ? <li key="\0:more">
                <a href={getTagsPath(this.props.entity)}>{l('more...')}</a>
              </li>
            : null}
        </ul>
        {!this.state.tags.size && <p>{lp('(none)', 'tag')}</p>}
        <form id="tag-form" onSubmit={this.addTags}>
          <div style={{display: 'flex'}}>
            <input
              className="tag-input"
              name="tags"
              ref={input => this._tagsInput = input}
              style={{flexGrow: 2}}
              type="text"
            />
            <button type="submit" className="styled-button">
              {l('Tag', 'verb')}
            </button>
          </div>
        </form>
      </div>
    );
  }
}

function init_tag_editor(Component, mountPoint) {
  return function (entity, aggregatedTags, userTags, more) {
    userTags = _.keyBy(userTags, t => t.tag);

    var combined = _.map(aggregatedTags, function (t) {
      var userTag = userTags[t.tag];

      if (userTag) {
        t.vote = userTag.vote;
        userTag.used = true;
      }

      return newTag(t);
    });

    // Always show upvoted user tags (affects sidebar)
    _.each(userTags, function (t) {
      if (t.vote > 0 && !t.used) {
        combined.push(newTag(t));
      }
    });

    ReactDOM.render(
      <Component entity={entity} more={more}
                 initialState={{tags: sortedTags(Immutable.List(combined))}} />,
      (document.getElementById(mountPoint): any)
    );
  };
}

MB.init_main_tag_editor = init_tag_editor(MainTagEditor, 'all-tags');
MB.init_sidebar_tag_editor = init_tag_editor(SidebarTagEditor, 'sidebar-tags');
