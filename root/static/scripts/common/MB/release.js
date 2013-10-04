MB.Release = (function (Release) {

  var ViewModel, Medium, Track;

  Release.init = function(initialMedia) {
    Release.viewModel = new ViewModel(initialMedia);

    ko.bindingHandlers.foreachKv = {
      transformObject: function (obj) {
        if (obj === undefined) return [];
        return _.map(
          _.keys(obj).sort(),
          function (k) { return { key: k, value: obj[k] } }
        );
      },
      init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var value = ko.utils.unwrapObservable(valueAccessor()),
            properties = ko.bindingHandlers.foreachKv.transformObject(value);
        ko.applyBindingsToNode(element, { foreach: properties });
        return { controlsDescendantBindings: true };
      }
    };
    ko.virtualElements.allowedBindings.foreachKv = true;

    ko.applyBindings(Release.viewModel);
  };

  function computeGroupedRelationships(relationships) {
    var result = _.foldl(
      _.map(
        relationships,
        function (relationship) {
          var o = {};

          o[relationship.target.type] = {};
          o[relationship.target.type][relationship.phrase] = [
            {
              target: MB.entity(relationship.target),
              groupedSubRelationships:
                computeGroupedRelationships(relationship.subRelationships)
            }
          ];

          return o;
        }
      ),
      mergeObjectArrays,
      {}
    );

    return result;
  }

  // Merge all values of object b into object a. The keys of b will then be a
  // proper subset of the keys a. If a already has a key that b has and that
  // value is a an array, b's value will be concatenated onto a's.
  // If a has a key and it is an object, then mergeObjectArrays will be called
  // recursively
  function mergeObjectArrays(a, b) {
    var newA = _.clone(a);

    _.each(
      _.keys(b),
      function(k) {
        if (newA.hasOwnProperty(k)) {
          if (_.isArray(b[k])) {
            newA[k] = a[k].concat(b[k]);
          }
          else {
            newA[k] = mergeObjectArrays(newA[k], b[k]);
          }
        }
        else {
          newA[k] = b[k];
        }
      }
    );

    return newA;
  }

  ViewModel = function (initialMedia) {
    var model = this;

    this.mediums = _.map(
      initialMedia, function(medium, mediumIndex) {
        var medium = new MB.entity.Medium(medium);
        _.each(
          medium.tracks,
          function (track, trackIndex) {
            var inputRecording =
              initialMedia[mediumIndex].tracks[trackIndex].recording;

            track.recording.relationships = inputRecording.relationships;

            if (track.length === '') {
              track.length = '?:??';
            }

            track.recording.extend({
              "groupedRelationships": ko.computed({
                "read": function () {
                  return computeGroupedRelationships(track.recording.relationships);
                },
                "deferEvaluation": true
              }),
              rating: inputRecording.rating,
              userRating: inputRecording.userRating,
              id: inputRecording.id
            })
          }
        );

        return medium
      }
    );

    this.showArtists = ko.computed(function () {
      var allArtistCredits = _.flatten(
        _.map(model.mediums, function(medium) {
          return _.map(medium.tracks, function (track) {
            return track.artistCredit;
          });
        })
      );

      var reference = _.head(allArtistCredits),
          subjects = _.tail(allArtistCredits);

      return subjects.length > 0 &&
        _.some(subjects, function(subject) {
          return !subject.isEqual(reference)
        });
    });

    return model;
  };

  return Release;

}(MB.Release || {}));
