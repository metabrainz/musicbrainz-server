// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var $ = require('jquery');
var _ = require('lodash');
var Immutable = require('immutable');
var React = require('react');
var {l, lp} = require('../i18n');

var Tag = Immutable.Record({tag: '', count: 0, vote: 0});

var VOTE_ACTIONS = {
  '0': 'withdraw',
  '1': 'upvote',
  '-1': 'downvote'
};

function sortedTags(tags) {
  return tags.sortBy(t => t.tag).sortBy(t => -t.count);
}

function getTagsPath(entity) {
  return `/${entity.entity_type}/${entity.gid}/tags`;
}

function isAlwaysVisible(tag) {
  return tag.vote > 0 || (tag.vote === 0 && tag.count > 0);
}

class TagLink extends React.Component {
  render() {
    var tag = this.props.tag;
    return <a href={`/tag/${encodeURIComponent(tag)}`}>{tag}</a>;
  }
}

class VoteButton extends React.Component {
  render() {
    var {vote, currentVote, callback} = this.props;
    var title = this.props.title;

    if (vote === currentVote) {
      title = l('Withdraw vote');
    }

    return (
      <button type="button"
              className={'tag-vote tag-' + VOTE_ACTIONS[vote]}
              title={title}
              onClick={_.partial(callback, vote === currentVote ? 0 : vote)}>
        {this.props.text}
      </button>
    );
  }
}

class UpvoteButton extends VoteButton {};
UpvoteButton.defaultProps = {text: '+', title: lp('Upvote', 'verb'), vote: 1};

class DownvoteButton extends VoteButton {};
DownvoteButton.defaultProps = {text: '\u2212', title: lp('Downvote', 'verb'), vote: -1};

class VoteButtons extends React.Component {
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

class TagRow extends React.Component {
  render() {
    var {tag, count, index} = this.props;

    return (
      <li key={tag} className={(index + 1) % 2 ? 'odd' : 'even'}>
        <TagLink tag={tag} />
        <VoteButtons {...this.props} />
      </li>
    );
  }
}

class TagEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = _.assign({positiveTagsOnly: true}, props.initialState);
  }

  createTagRows() {
    var tags = this.state.tags;

    return tags.reduce((accum, t, index) => {
      var callback = newVote => {
        this.updateVote(index, newVote);

        var tagsPath = getTagsPath(this.props.entity);
        $.get(`${tagsPath}/${VOTE_ACTIONS[newVote]}?tags=${encodeURIComponent(t.tag)}`)
          .done(data => {
            this.updateTags(JSON.parse(data).updates);
          });
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

  setTags(tags) {
    this.setState({tags: sortedTags(tags)});
  }

  getNewCount(index, vote) {
    var current = this.state.tags.get(index);

    if (vote === current.vote) {
      return current.count;
    } else if (vote === 0) {
      return current.count + (current.vote * -1);
    } else {
      return current.count + ((current.vote === -vote ? 2 : 1) * vote);
    }
  }

  addTags() {
    var input = React.findDOMNode(this.refs.tags);
    var tags = input.value;

    this.updateTags(
      _(tags.split(','))
        .map(name => {
          name = _.trim(name);
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
    this.setTags(this.state.tags.mergeIn([index], {count: newCount, vote: vote}));
  }

  updateTags(updatedUserTags) {
    var newTags = this.state.tags;

    updatedUserTags.forEach(t => {
      var index = newTags.findIndex(ct => ct.tag === t.tag);

      if (t.deleted) {
        newTags = newTags.delete(index);
      } else {
        var newTag = Tag({tag: t.tag, vote: t.vote, count: t.count});

        if (index >= 0) {
          newTags = newTags.set(index, newTag);
        } else {
          newTags = newTags.push(newTag);
        }
      }
    });

    this.setTags(newTags);
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
        <p>
          <textarea row="5" cols="50" ref="tags"></textarea>
        </p>
        <button type="button" className="styled-button" onClick={this.addTags.bind(this)}>
          {l('Submit tags')}
        </button>
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
          {this.props.more &&
            <li>
              <a href={getTagsPath(this.props.entity)}>{l('more...')}</a>
            </li>}
        </ul>
        {!this.state.tags.size && <p>{lp('(none)', 'tag')}</p>}
        <div style={{display: 'flex'}}>
          <input type="text" className="tag-input" style={{flexGrow: 2}} ref="tags" />
          <button type="button" className="styled-button" onClick={this.addTags.bind(this)}>
            {l('Tag', 'verb')}
          </button>
        </div>
      </div>
    );
  }
}

function init_tag_editor(Component, mountPoint) {
  return function (entity, aggregatedTags, userTags, more) {
    userTags = _.indexBy(userTags, t => t.tag);

    var combined = _.map(aggregatedTags, function (t) {
      var userTag = userTags[t.tag];

      if (userTag) {
        t.vote = userTag.vote;
        userTag.used = true;
      }

      return Tag(t);
    });

    // Always show upvoted user tags (affects sidebar)
    _.each(userTags, function (t, k) {
      if (t.vote > 0 && !t.used) {
        combined.push(Tag(t));
      }
    });

    React.render(
      <Component entity={entity} more={more}
                 initialState={{tags: sortedTags(Immutable.List(combined))}} />,
      document.getElementById(mountPoint)
    );
  };
}

MB.init_main_tag_editor = init_tag_editor(MainTagEditor, 'all-tags');
MB.init_sidebar_tag_editor = init_tag_editor(SidebarTagEditor, 'sidebar-tags');
