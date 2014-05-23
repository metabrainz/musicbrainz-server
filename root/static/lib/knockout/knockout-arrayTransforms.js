// knockout-arrayTransforms 0.5.0 (https://github.com/mwiencek/knockout-arrayTransforms)
// Released under the MIT (X11) License; see the LICENSE file in the official code repository.

(function (factory) {
    if (typeof module !== "undefined" && typeof module.exports !== "undefined") {
        factory(module.exports = require("knockout"));
    } else if (typeof define === "function" && define.amd) {
        define(["knockout"], factory);
    } else {
        factory(window.ko);
    }
})(function (ko) {

    var transformClasses = emptyObject(),
        arrayChangeEvent = "arrayChange",
        compareArrays = ko.utils.compareArrays;

    function applyChanges(changes) {
        var mappedItems = this.mappedItems,
            moves = emptyObject(),
            minIndex = 0,
            offset = 0;

        for (var i = 0, change; change = changes[i]; i++) {
            var status = change.status;

            if (status === "retained") {
                continue;
            }

            var index = change.index,
                moved = change.moved,
                value = change.value,
                isMove = moved !== undefined,
                item = null;

            minIndex = Math.min(minIndex, index);

            if (status === "added") {
                var from = moved + offset;

                if (isMove) {
                    item = moves[index];

                    if (!item) {
                        item = moves[index] = mappedItems[from];
                        mappedItems[from] = null;
                    }
                } else {
                    item = emptyObject();
                    item.index = ko.observable(index);
                    item.index.isDifferent = isDifferent;
                    item.value = value;
                    mapValue(this, item);
                }

                mappedItems.splice(index, 0, item);
                this.valueAdded(value, index, item.mappedValue, item);
                offset++;

            } else if (status === "deleted") {
                var from = index + offset;

                if (isMove) {
                    item = moves[moved] || (moves[moved] = mappedItems[from]);
                } else {
                    item = mappedItems[from];
                    if (item.computed) {
                        item.computed.dispose();
                    }
                }

                mappedItems.splice(from, 1);
                this.valueDeleted(value, from, item.mappedValue, item);
                offset--;
            }
        }

        for (var i = minIndex, len = mappedItems.length, item; i < len; i++) {
            mappedItems[i].index(i);
        }

        notifyChanges(this);
    };

    function notifyChanges(state) {
        var array = state.transformedArray;

        if (array) {
            var changes = compareArrays(state.previousArray, array, { sparse: true });
            if (changes.length) {
                state.previousArray = array.concat();

                var original = state.original,
                    notifySubscribers = original.notifySubscribers,
                    previousOriginalArray = original.peek().concat(),
                    pendingArrayChange = false;

                original.notifySubscribers = function (valueToNotify, event) {
                    if (event === "arrayChange") {
                        pendingArrayChange = true;
                    } else {
                        notifySubscribers.apply(original, arguments);
                    }
                };

                state.transform.notifySubscribers(array);
                state.transform.notifySubscribers(changes, arrayChangeEvent);

                original.notifySubscribers = notifySubscribers;
                if (pendingArrayChange) {
                    changes = compareArrays(previousOriginalArray, original.peek(), { sparse: true });
                    if (changes.length) {
                        original.notifySubscribers(changes, "arrayChange");
                    }
                }
            }
        }
    }

    function emptyObject() {
        return Object.create ? Object.create(null) : {};
    }

    function exactlyEqual(a, b) { return a === b }

    function isDifferent(a, b) { return a !== b }

    function indexOf(array, item) {
        for (var i = 0, len = array.length; i < len; i++) {
            if (array[i] === item) return i;
        }
        return -1;
    }

    function mapValue(state, item) {
        var callback = state.callback;

        if (callback === undefined) {
            item.mappedValue = item.value;
            return;
        }

        var owner = state, method = "callback";

        if (typeof callback !== "function") {
            owner = item.value;
            method = callback;
            callback = owner[method];

            if (typeof callback !== "function") {
                item.mappedValue = callback;
                return;

            } else if (ko.isObservable(callback)) {
                watchItem(state, item, callback);
                return;
            }
        }

        var computedValue = ko.computed(function () {
            return owner[method](item.value, item.index);
        });

        if (computedValue.isActive()) {
            computedValue.equalityComparer = exactlyEqual;
            watchItem(state, item, computedValue);
            item.computed = computedValue;
            return computedValue;
        } else {
            item.mappedValue = computedValue.peek();
        }
    }

    function watchItem(self, item, observable) {
        item.mappedValue = observable.peek();

        observable.subscribe(function (newValue) {
            self.valueMutated(item.value, newValue, item.mappedValue, item);

            // Must be updated after valueMutated because sortBy/filter/etc.
            // expect/need the old mapped value
            item.mappedValue = newValue;

            notifyChanges(self);
        });
    }

    function delegateApplyChanges(changes) {
        this.applyChanges(changes);
    }

    function initTransformState(state, original, callback, options) {
        state.original = original;
        state.mappedItems = [];
        state.callback = callback;

        var transform = state.init(options);
        state.transform = transform;

        if (ko.isObservable(transform) && transform.cacheDiffForKnownOperation) {
            // Disallow knockout to call trackChanges() on this array
            // Writing to it normally isn't support anyway
            transform.subscribe = ko.observableArray.fn.subscribe;
            state.transformedArray = transform.peek();
            state.previousArray = state.transformedArray.concat();
        }
    }

    function makeTransform(proto) {
        function TransformState(original, callback, options) {
            initTransformState(this, original, callback, options);
        }
        TransformState.prototype.applyChanges = applyChanges;
        ko.utils.extend(TransformState.prototype, proto);
        transformClasses[proto.name] = TransformState;

        ko.observableArray.fn[proto.name] = function (callback, options) {
            var state = new TransformState(this, callback, options),
                originalArray = this.peek(),
                initialChanges = [];

            this.subscribe(delegateApplyChanges, state, arrayChangeEvent);

            for (var i = 0, len = originalArray.length; i < len; i++) {
                initialChanges.push({ status: "added", value: originalArray[i], index: i });
            }

            state.applyChanges(initialChanges);
            return state.transform;
        };
    };

    makeTransform({
        name: "sortBy",
        init: function () {
            this.keyCounts = emptyObject();
            this.sortedItems = [];
            return ko.observableArray([]);
        },
        valueAdded: function (value, index, sortKey, item) {
            var mappedIndex = this.sortedIndexOf(sortKey, value, item),
                sortedItems = this.sortedItems;

            var keyCounts = this.keyCounts;
            sortedItems.splice(mappedIndex, 0, item);
            keyCounts[sortKey] = (keyCounts[sortKey] || 0) + 1;
            this.transformedArray.splice(mappedIndex, 0, value);
        },
        valueDeleted: function (value, index, sortKey, item) {
            var sortedItems = this.sortedItems,
                mappedIndex = indexOf(sortedItems, item);

            sortedItems.splice(mappedIndex, 1);
            this.keyCounts[sortKey]--;
            this.transformedArray.splice(mappedIndex, 1);
        },
        valueMutated: function (value, newKey, oldKey, item) {
            var oldIndex = indexOf(this.sortedItems, item),
                newIndex = this.sortedIndexOf(newKey, value, item);

            // The mappedItems array hasn't been touched yet, so adjust for that
            if (oldIndex < newIndex) {
                newIndex--;
            }

            if (oldIndex !== newIndex) {
                var array = this.transformedArray,
                    sortedItems = this.sortedItems;

                sortedItems.splice(oldIndex, 1);
                sortedItems.splice(newIndex, 0, item);

                array.splice(oldIndex, 1);
                array.splice(newIndex, 0, value);

                var keyCounts = this.keyCounts;
                keyCounts[oldKey]--;
                keyCounts[newKey] = (keyCounts[newKey] || 0) + 1;
            }
        },
        sortedIndexOf: function (key, value, item) {
            var sortedItems = this.sortedItems,
                length = sortedItems.length;

            if (!length) {
                return 0;
            }

            var start = 0, end = length - 1, index;

            while (start <= end) {
                index = (start + end) >> 1;

                if (sortedItems[index].mappedValue < key) {
                    start = index + 1;
                } else if ((end = index) === start) {
                    break;
                }
            }

            // Keep things stably sorted. Only incurs a cost if there are
            // multiple of this key.
            var count = this.keyCounts[key], offset = 0;

            if (count) {
                var mappedItems = this.mappedItems, mappedItem;

                for (var i = 0; i < length; i++) {
                    if (!(mappedItem = mappedItems[i])) {
                        continue;
                    }
                    if (mappedItem === item) {
                        break;
                    }
                    if (mappedItem.mappedValue === key) {
                        offset++;
                    }
                    if (offset === count) {
                        break;
                    }
                }
            }

            return start + offset;
        }
    });

    function filterIndexOf(state, items, prop, index) {
        var previousItem, mappedIndex = 0;
        if (index > 0) {
            previousItem = items[index - 1];
            mappedIndex = previousItem[prop] || 0
            if (state.getVisibility(previousItem.mappedValue)) {
                mappedIndex++;
            }
        }
        return mappedIndex;
    }

    var filterOrReject = {
        mappedIndexProp: "mappedIndex",
        init: function () {
            return ko.observableArray([]);
        },
        valueAdded: function (value, index, visible, item) {
            visible = this.getVisibility(visible);

            var mappedItems = this.mappedItems,
                mappedIndexProp = this.mappedIndexProp;

            if (visible) {
                for (var i = index + 1, len = mappedItems.length, tmp; i < len; i++) {
                    (tmp = mappedItems[i]) && tmp[mappedIndexProp]++;
                }
            }

            var mappedIndex = filterIndexOf(this, mappedItems, mappedIndexProp, index);
            if (visible) {
                this.transformedArray.splice(mappedIndex, 0, value);
            }
            item[mappedIndexProp] = mappedIndex;
        },
        valueDeleted: function (value, index, visible, item) {
            if (this.getVisibility(visible)) {
                var mappedItems = this.mappedItems,
                    mappedIndexProp = this.mappedIndexProp,
                    mappedIndex = filterIndexOf(this, mappedItems, mappedIndexProp, index);

                // In normal cases, this item will already be spliced out of
                // mappedItems, because it was removed from the original array.
                // But in conjunction with groupBy, which uses filter
                // underneath, all of the groups share a single mappedItems
                // and use valueDelete here to "hide" an item from a group even
                // though it still exists in the original array. In that case,
                // increment index so that we only update the mappedItems
                // beyond the hidden one.

                if (mappedItems[index] === item) {
                    index++;
                }

                for (var i = index, len = mappedItems.length, tmp; i < len; i++) {
                    (tmp = mappedItems[i]) && tmp[mappedIndexProp]--;
                }

                this.transformedArray.splice(mappedIndex, 1);
            }
        },
        valueMutated: function (value, shouldBeVisible, currentlyVisible, item) {
            var index = indexOf(this.mappedItems, item);
            this.valueAdded(value, index, shouldBeVisible, item);
            this.valueDeleted(value, index, currentlyVisible, item);
        }
    };

    function boolNot(x) { return !x }
    makeTransform(ko.utils.extend({ name: "filter", getVisibility: Boolean }, filterOrReject));
    makeTransform(ko.utils.extend({ name: "reject", getVisibility: boolNot }, filterOrReject));

    function getGroupVisibility(groupKey) {
        return String(groupKey) === this.groupKey;
    }

    makeTransform({
        name: "groupBy",
        init: function () {
            this.groups = emptyObject();
            return ko.observableArray([]);
        },
        applyChanges: function (changes) {
            var groups = this.groups;

            applyChanges.call(this, changes);

            for (key in groups) {
                notifyChanges(groups[key]);

                if (!groups[key].transformedArray.length) {
                    this.deleteGroup(key);
                }
            }
        },
        valueAdded: function (value, index, groupKey, item) {
            groupKey = String(groupKey);

            var groups = this.groups;

            if (!groups[groupKey]) {
                var group = new transformClasses.filter(this.original);
                groups[groupKey] = group;

                group.groupKey = groupKey;
                group.mappedItems = this.mappedItems;
                group.mappedIndexProp = "mappedIndex." + groupKey;
                group.getVisibility = getGroupVisibility;

                var object = emptyObject();
                object.key = groupKey;
                object.values = group.transform;

                this.transformedArray.push(object);
            }

            for (var key in groups) {
                groups[key].valueAdded(value, index, groupKey, item);
            }
        },
        valueDeleted: function (value, index, groupKey, item) {
            var groups = this.groups;

            for (var key in groups) {
                groups[key].valueDeleted(value, index, groupKey, item);
            }
        },
        valueMutated: function (value, newGroupKey, oldGroupKey, item) {
            var groups = this.groups,
                index = indexOf(this.mappedItems, item),
                group;

            this.valueDeleted(value, index, oldGroupKey, item);
            this.valueAdded(value, index, newGroupKey, item);

            for (var key in groups) {
                group = groups[key];

                notifyChanges(group);

                if (!group.transformedArray.length) {
                    this.deleteGroup(key);
                }
            }
        },
        deleteGroup: function (groupKey) {
            var transformedArray = this.transformedArray;

            delete this.groups[groupKey];

            for (var i = 0, len = transformedArray.length; i < len; i++) {
                if (transformedArray[i].key === groupKey) {
                    return transformedArray.splice(i, 1);
                }
            }
        }
    });

    makeTransform({
        name: "map",
        init: function () {
            return ko.observableArray([]);
        },
        valueAdded: function (value, index, mappedValue) {
            this.transformedArray.splice(index, 0, mappedValue);
        },
        valueDeleted: function (value, index) {
            this.transformedArray.splice(index, 1);
        },
        valueMutated: function (value, newMappedValue, oldMappedValue, item) {
            this.transformedArray[indexOf(this.mappedItems, item)] = newMappedValue;
        }
    });

    var allOrAny = {
        init: function () {
            this.truthinessCount = 0;
            return ko.observable(this.getTruthiness());
        },
        valueAdded: function (value, index, truthiness) {
            this.valueMutated(null, truthiness, false);
        },
        valueDeleted: function (value, index, truthiness) {
            this.valueMutated(null, false, truthiness);
        },
        valueMutated: function (value, newTruthiness, oldTruthiness) {
            if (newTruthiness && !oldTruthiness) {
                this.truthinessCount++;
            } else if (oldTruthiness && !newTruthiness) {
                this.truthinessCount--;
            }
            this.transform(this.getTruthiness());
        }
    };

    makeTransform(ko.utils.extend({
        name: "any",
        getTruthiness: function () {
            return this.truthinessCount > 0;
        }
    }, allOrAny));

    makeTransform(ko.utils.extend({
        name: "all",
        getTruthiness: function () {
            return this.truthinessCount === this.mappedItems.length;
        }
    }, allOrAny));

    ko.observableArray.fn.some = ko.observableArray.fn.any;
    ko.observableArray.fn.every = ko.observableArray.fn.all;

    ko.arrayTransforms = {
        makeTransform: makeTransform
    };
});
