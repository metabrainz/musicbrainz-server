The Developer's Guide to the MusicBrainz Server
===============================================

Organization
------------

Important folders are documented here, in alphabetical order.

 * **admin/**

   Various scripts for server maintenance and administration.

 * **lib/**

   The `-Ilib` in `plackup -Ilib` sets `@INC` to here on startup.

    * **DBDefs/**

      Server configuration.

    * **MusicBrainz/Server/**

      Perl code for the actual server.

       * **Controller/**

         [Catalyst](http://search.cpan.org/perldoc?Catalyst) actions.

       * **Data/**

         Methods for fetching data from the database. The results are typically
         converted to instances of some Entity class found under
         lib/MusicBrainz/Server/Entity/.

         If you see something like `$c->model('Foo')` in the controllers,
         that's accessing an instance of `MusicBrainz::Server::Data::Foo`.

       * **Edit/**

         Contains code relating to our edit system. There's a Moose class for
         each edit type defining how to insert, apply, and reject the edit. The
         classes also contain type constraints restricting what sort of data
         can be contained in the edit (i.e. the data column in the edit table).

       * **Entity/**

         Moose classes for all of our entities.

       * **Form/**

         [HTML::FormHandler](http://search.cpan.org/dist/HTML-FormHandler/)
         classes, where most forms rendered by Template Toolkit get handled.
         The controller will create an instance of the corresponding class
         here, and pass the request data to it. (See for example
         `MusicBrainz::Server::Controller::edit_action`). The form acts to
         validate the request data and return any errors.

         We have some forms that are mostly rendered client-side and submit
         JSON directly to some controller endpoint, which then performs its own
         validation. (See `/ws/js/edit`.) Those have nothing to do with
         the code here.

 * **root/**

   Mostly [Template Toolkit](http://www.template-toolkit.org/) templates (files
   ending in .tt). The directory structure mostly corresponds to Catalyst
   action paths.

    * **static/**

      Static resources used for the website.

       * **scripts/**

         Client-side JavaScript.

          * **tests/**

            JavaScript unit tests (see below).

       * **styles/**

         CSS/[Less](http://lesscss.org/).

 * **t/**

   Where the server tests live.


Testing
-------

Most tests require a test database that has to be created once:

    $ script/create_test_db.sh

We use standard Perl tools for unit testing. Tests are located in the t/
directory. The preferred way to run them is to use the `prove` program from
Test::Harness. For example, to run all tests use:

    $ prove -l t/

The bulk of tests will run from the single tests.t file, which can take a while
to complete. If you are only interested in running a single test, you can pass
the --tests option. For example if you want to run a controller test such as
t::MusicBrainz::Server::Controller::WS::2::LookupArtist you can use:

    $ prove -l t/tests.t :: --tests WS::2::LookupArtist

The --tests argument takes a regular expression to match against the test
name. For example, to run multiple tests you can use regular expression groups:

    $ prove -l t/tests.t :: --tests '(Data::URL|Entity::URL)'

While to run all Data:: tests you can do the following:

    $ prove -l t/tests.t :: --tests 'Data::'

### Database tests (pgTAP)

For unit testing database functions we use pgtap, on a recent Ubuntu
you can install pgtap like this:

    $ sudo apt-get install pgtap

To run the tests, pgtap needs to be able to connect to the test
database.  You can use environment variables for the database
configuration, the easiest way to set these is to use the provided
database_configuration script like this:

    $ eval `perl -Ilib script/database_configuration TEST`

Now that that is set up you can run individual pgtap tests like this:

    $ prove --verbose --source pgTAP t/pgtap/unaccent.sql

Or all of them like this:

    $ prove --verbose --source pgTAP t/pgtap/* t/pgtap/unused-tags/*

### JavaScript

We have a set of JavaScript unit tests (using https://github.com/substack/tape)
which can be run in a browser. They must be compiled first:

    $ script/compile_resources.sh tests

After compilation has finished, open
http://localhost:5000/static/scripts/tests/web.html on your local development
server.

It is more fun to be able to run those tests on the command line. Provided
your system is running a (headless) Chrome instance, this can be done with
the following command:

    $ node t/web.js

### Flow

Our JavaScript uses [Flow](https://flow.org/) for static type checking.
If you're adding a new JS file, it should have a `@flow strict-local`
header at the top to enable type checking.

To ensure all types are correct after making a change, run Flow:

    $ ./node_modules/.bin/flow

Global type declarations available to all files are found in
[the root/types folder](root/types) and [root/vars.js](root/vars.js).
The latter is for functions and variables that are auto-imported by
Webpack's [ProvidePlugin](webpack/providePluginConfig.js).

We have a couple of scripts you may find useful that generate Flow object
types based on JSON data:

 * `./bin/sucrase-node script/generate_edit_data_flow_type.mjs --edit-type $EDIT_TYPE_ID`
   will generate an object type to represent the edit data of `$EDIT_TYPE_ID`.
   However, this requires having a `PROD_STANDBY` database configured in
   DBDefs.pm, as it uses production data to ensure a correct type.

 * `cat $JSON | ./script/generate_json_flow_type.js` will generate an object
   type for a stream of JSON objects (which each must be on a single line).
   Passing a single object is fine, too.

### Selenium

We have a set of browser-automated UI tests running with Selenium WebDriver.
These are a bit more involved to set up:

 * Install ChromeDriver from
   https://googlechromelabs.github.io/chrome-for-testing/
   ensuring that you choose a version compatible with your version of Chrome.

 * Install a version of Google Chrome that supports headless mode (versions 59
   and above).

 * Add a `SELENIUM` database to the `register_databases` call in
   lib/DBDefs.pm, like so:

   ```perl
   SELENIUM => {
       database    => 'musicbrainz_selenium',
       schema      => 'musicbrainz',
       username    => 'musicbrainz',
       host        => 'localhost',
       port        => 5432,
   },
   ```

   Just make sure the connection options match what you're using for the
   `TEST` database.

 * Set USE_SET_DATABASE_HEADER to 1 in lib/DBDefs.pm.

 * Run `./script/create_test_db.sh SELENIUM` and
   `env MUSICBRAINZ_RUNNING_TESTS=1 ./script/compile_resources.sh` again.

Some Selenium tests make search queries and require a working search setup.
(While not all tests require one, it helps to have one ready.)

 * Set up [mb-solr](https://github.com/metabrainz/mb-solr).
   It should be fairly easy to get running in the background with
   `docker-compose up`.
   As it listens on port 8983 by default, make sure `SEARCH_SERVER` is set to
   `127.0.0.1:8983/solr` in DBDefs.pm.

 * Set up [sir](https://github.com/metabrainz/sir) with a virtual environment
   under `./venv` (relative to the sir checkout). You don't have to start it:
   this is done by script/reset_selenium_env.sh, which is invoked by
   t/selenium.js before each test. (If you need to inspect the sir logs of
   each run, they get saved to t/selenium/.sir-reindex.log and
   t/selenium/.sir-amqp_watch.log for the reindex and amqp_watch commands
   respectively.)

   Extensions and functions should be installed to the `musicbrainz_selenium`
   database. (reset_selenium_env.sh takes care of triggers for you.) You can
   do this manually (from the sir checkout):

   ```sh
   psql -U postgres -d musicbrainz_selenium -f sql/CreateExtension.sql
   psql -U musicbrainz -d musicbrainz_selenium -f sql/CreateFunctions.sql
   ```

With the above prerequisites out of the way, the tests can be run from the
command line like so:

    $ SIR_DIR=~/code/sir ./t/selenium.js

Where `SIR_DIR` is the path to your sir checkout. (You can omit this if the
tests you're running don't require search.)

If you want to run specific tests under ./t/selenium/, you can specify the
paths to them as arguments. t/selenium.mjs also accepts some command line flags
which are useful for debugging and development; see `./t/selenium.js --help`.
For example, you might want to use `-h=false -s=true` to run non-headlessly
and leave it open when it errors, to actually see what the tests are doing and
what the site looks like at the time.

The `.html` files located under ./t/selenium/ describe the tests being run,
and were created using the Selenium IDE plugin for Firefox. You can easily
open these files in the IDE and run the tests that way if you wish; it'll play
back the actions in the browser window you have open, so doesn't require any
headless mode. However, before running a test in this way, you must make sure
the test database is clean and has t/sql/selenium.sql loaded into it.

### Schema change

Prior to a schema change, you'll want to test that [upgrade.sh](upgrade.sh)
runs without errors on the previous schema version.
Our [sample database dump](http://ftp.musicbrainz.org/pub/musicbrainz/data/sample/)
is useful for testing this on a standalone database, but it's also important
to test against a full backup of the production database.

Given its size, a full production test can be time consuming, particularly if
the upgrade fails and you have to restore the dump again. To help ensure any
failures are *data-related* and not *schema-related*, it's recommended to
dump the production schema (without data) locally, and run an upgrade against
that first.

To do this, first create an empty "musicbrainz_prod_schema" database with the
proper roles and privileges. Configure this as `PROD_SCHEMA_CHANGE_TEST`, or
some other name of your choice, in DBDefs.pm.

```sh
# You may require custom host/port connection parameters to your local DB.
psql -U postgres -d template1 -c 'CREATE DATABASE musicbrainz_prod_schema;'
# It's okay if these already exist.
psql -U postgres -d template1 -c 'CREATE ROLE musicbrainz;'
psql -U postgres -d template1 -c 'CREATE ROLE musicbrainz_ro;'
psql -U postgres -d template1 -c 'CREATE ROLE caa_redirect;'
psql -U postgres -d template1 -c 'CREATE ROLE sir;'
psql -U postgres -d template1 -c 'GRANT CREATE ON DATABASE musicbrainz_prod_schema TO musicbrainz;'
```

Next, you can dump the schema of the production standby, import it locally to
`musicbrainz_prod_schema`, and run upgrade.sh against
`PROD_SCHEMA_CHANGE_TEST`:

```sh
# Set these to the current PG standby host and container name.
prod_standby_pg_host=
prod_standby_pg_container=

ssh -C $prod_standby_pg_host docker exec $prod_standby_pg_container sudo -E -H -u postgres \
  pg_dump --schema-only musicbrainz_db \
  > musicbrainz_prod_schema.dump

psql -U postgres -d musicbrainz_prod_schema -f musicbrainz_prod_schema.dump

SKIP_EXPORT=1 REPLICATION_TYPE=1 DATABASE=PROD_SCHEMA_CHANGE_TEST ./upgrade.sh
```

While it's a good sign if the upgrade runs without errors, there's another
important aspect of testing, which is making sure the upgrade scripts do what
you expect. Will the upgraded DB's schema be identical to a *new* DB created
with InitDb.pl on the same branch? A helper script,
[CheckSchemaMigration.sh](t/script/CheckSchemaMigration.sh), exists to check
that.

Caution: do not run this script with a dirty git checkout, particularly having
any local changes under admin/. They'll be wiped out!

As a prerequisite to running this script, you must setup two new database
configurations in DBDefs.pm:

```perl
MIGRATION_TEST1 => {
    database    => 'musicbrainz_test_migration_1',
    host        => 'localhost',
    password    => '',
    port        => 5432,
    username    => 'musicbrainz',
},
MIGRATION_TEST2 => {
    database    => 'musicbrainz_test_migration_2',
    host        => 'localhost',
    password    => '',
    port        => 5432,
    username    => 'musicbrainz',
},
```

The definitions of these is as follows:

 * `MIGRATION_TEST1` - a database containing the new schema, created via
   InitDb.pl.
 * `MIGRATION_TEST2` - a database upgraded from the previous schema to the
   new one via upgrade.sh.

You should leave the database names identical to above, but may need to
adjust the host/port to point to your instance. (The host/port must also
match the `SYSTEM` database configuration.)

You may also set the following environment variables during execution of the
script:

 * `SUPERUSER` - the name of the PG superuser role to use.
   (default: postgres)
 * `REPLICATION_TYPE` - 1, 2, or 3 for master, mirror, or standalone
   respectively. You should run the script three times for all three
   replication types!
   (default: 2)
 * `PGPORT` - the port your local postgres is listening on.
   (default: 5432)
 * `KEEP_TEST_DBS` - 0 or 1, indicating whether to drop or keep the migration
   test databases at the end; if you keep them, you'll have to drop them
   manually before running the script again.
   (default: 0)
 * `PENDING_SO` - if also specifying `REPLICATION_TYPE=1` (master), this is
   the path to dbmirror's pending.so, which will be forwarded to InitDb.pl
   via the `--with-pending` flag.
   (default: /usr/lib/postgresql/16/lib/pending.so)

To check the migration scripts for a standalone setup with postgres running
on port 25432, you may for example run:

    $ PGPORT=25432 REPLICATION_TYPE=3 ./t/script/CheckSchemaMigration.sh

(Obviously, you should run this on the new schema change branch.)

If there are any differences in the schemas of `MIGRATION_TEST1` and
`MIGRATION_TEST2`, a diff will be outputted. The schemas themselves
are saved to `MIGRATION_TEST1.schema.sql` and `MIGRATION_TEST2.schema.sql`;
you may inspect these afterward or diff them using another tool if you'd
like.

Code standards
--------------

For our Perl, we use `Perl::Critic` to enforce certain code standards.
The list of policies we use can be found in [.perlcriticrc](.perlcriticrc).
If you'd like to test them yourself before submitting a pull request, invoke
`prove` as follows:

    $ prove -lv t/critic.t

For JavaScript, we use eslint. Our rules and other configuration can be found
in [eslint.config.mjs](eslint.config.mjs). To check a file or directory
against all of these rules, run:

    $ ./node_modules/.bin/eslint $file_or_directory

Replace `$file_or_directory` with the path to the file or directory you'd like
to check.

Rules that are not yet enforced across all the codebase have their own
sections in [eslint.config.mjs](eslint.config.mjs) disabling them for files
that are not fixed yet. If you want to check the rule across the codebase,
you can temporarily remove that section in the config file. If you fix all the
issues, you can permanently remove the section.

Reports
-------

[Reports](https://beta.musicbrainz.org/reports) are lists of potential problems
in MusicBrainz. These reports are generated daily by the
*[daily.sh](https://github.com/metabrainz/musicbrainz-server/blob/master/admin/cron/daily.sh)*
script.

Contents of reports are stored in separate tables in `report` schema of the
database.

### Generating reports

You can generate all reports using the *[RunReports.pl](https://github.com/metabrainz/musicbrainz-server/blob/master/admin/RunReports.pl)*
script:

    $ ./admin/RunReports.pl

To run a specific report (see https://github.com/metabrainz/musicbrainz-server/tree/master/lib/MusicBrainz/Server/Report),
specify its name in an argument:


    $ ./admin/RunReports.pl DuplicateArtists

### Adding a new report

 1. Create new module in `lib/MusicBrainz/Server/Report/`.
 2. Add created module into [ReportFactory.pm](https://github.com/metabrainz/musicbrainz-server/blob/master/lib/MusicBrainz/Server/ReportFactory.pm)
   file (add into `@all` list and import module itself there).
 3. Create a new template for your report in `root/report/`. Follow the
   existing examples, and remember if you need columns not on the default
   lists you can pass them with parameters `columnsBefore` and `columnsAfter`.
 4. Add a new `ReportsIndexEntry` in `root/report/ReportsIndex.js`.

Porting TT to React
-------------------

All the TT code resides in `root/**.tt`. Some guidelines for porting TT files
to React/JSX:

 * Ported server-side React components should reside in `root/components/`.
   This generally includes ported macros from `root/common-macros.tt` and
   components common across multiple pages.

 * Any client-side components (ones which render on the client) should reside
   in `root/static/scripts/common/components`. If a component is used both on
   the client and server, put it here instead of `root/components/`.

 * Server-side utility functions go in `root/utility`.

 * All components must be type-annotated. We use Flow for static type checking.
   You can find documentation for it [here](https://flow.org/en/docs/).

 * Global types are defined in in [the root/types folder](root/types).
   They can be used without imports.

 * Make sure your JS files conform to our enforced ESlint rules by running
   `./node_modules/.bin/eslint path/to/file.js`, and to the desired ESlint
   rules by running `./script/check_unfixed_eslint_rules path/to/file.js`.

Common instructions for porting:

 1. Convert a TT file or macro to an equivalent React component (or set of
    components). Make sure they output identical HTML where possible.

 2. There are two ways to use your React components:

     1. If your component is a page, find the appropriate Catalyst controller
        in `lib/MusicBrainz/Server/Controller` and add the following to
        `$c->stash` in the corresponding action method which loads the
        respective page:
        ```perl
        $c->stash(
            current_view => 'Node',
            component_path => 'relative/path/to/component/from/root',
            component_props => {prop_name => prop_value}
        );
        ```

     2. If you're embedding a React component inside a TT page, use:
        ```perl
        [%~ React.embed(c, 'relative/path/to/component/from/root', { prop_name => prop_val }) ~%]
        ```

 3. You can access most of the [Catalyst Context](http://search.cpan.org/~ether/Catalyst-Manual-5.9009/lib/Catalyst/Manual/Intro.pod#Context) in JavaScript
    by importing the `CatalystContext` [React context](https://reactjs.org/docs/context.html)
    from root/context.mjs and either using the `CatalystContext.Consumer` component
    or using `React.useContext(CatalystContext)` (assigned by convention to the constant `$c`).

 4. To communicate between the Perl and Node servers (the latter renders React
    components for us), you need to appropriately serialize the props passed
    to the components. This can be done by defining `TO_JSON` subroutines in
    the respective Entity modules under `lib/MusicBrainz/Server/Entity`.

    You generally want to do something like this:
    ```perl
    around TO_JSON => sub {
        my ($orig, $self) = @_;
        return {
            %{ $self->$orig },
            prop_name => covert_to_json($self->prop_name)
        };
    };
    ```
    Where `convert_to_json` is a function that converts `$self->prop_name` to
    its appropriate JSON representation.
    
    If `prop_name` is an entity that has a `TO_JSON` method defined, you can
    simply do `prop_name => $self->prop_name->TO_JSON` unless you need to
    handle undef values (in that case, see `to_json_object` below).
    For converting most other props you'll often be able to just use
    one of the already existing functions in
    [Entity::Util::JSON](/lib/MusicBrainz/Server/Entity/Util/JSON.pm).
    Before you write a custom function, make sure whether one of `to_json_array`,
    `to_json_hash` or `to_json_object` is enough.

 5. Make sure that all your components are type-annotated using Flow.

 6. We follow the `snake_case` naming convention for props passed from Perl
    code, and `lowerCamelCase` for variables referencing them in JavaScript.

 7. All components should be named following the `UpperCamelCase` convention.

React state management
----------------------

For simple components with a small amount of isolated state,
`React.useState` works great.

For complex pages (let's call these apps), where an action in one deeply-
nested part of the component tree can affect the state in a sibling or
higher-up part of the tree (e.g. in the relationship editor), it's
recommended to have one [reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer)
in the very top component and pass all state downward as props.  React calls
this concept [lifting state up](https://react.dev/learn/sharing-state-between-components)
to create a "top-down" data flow.

While having all state flow in one direction greatly simplifies reasoning
about how changes are propagated and how state is kept in sync across many
components, it also creates two issues that you need to manage:

  * The first issue is related to performance: if all state comes from the
    top component, then React has to re-render the entire page each time
    any piece of state changes.  There are steps to address this, but they
    must work together (i.e. one step on its own won't help, but will when
    combined with the rest).

    1. Make sure your components don't get too large and have a clear
       purpose. If you can identify parts of a component that can render
       (update) less often than the other parts, consider splitting those
       parts into separate components.

    2. Make sure every component only receives the props it actually needs.
       For example, consider a component that receives the number of elements
       of a list as a prop, but then only performs a boolean check on the
       number, like `numItems > x`.  In this case you should just pass the
       result of `numItems > x` as a prop.

    3. Make liberal use of
       [React.memo](https://react.dev/reference/react/memo),
       especially for components that have complicated render functions.
       Assuming you also follow the previous point (passing only the
       essential information used by the component), then `React.memo` will
       ensure that rendering can be skipped when the props don't change.
       The cost of React comparing the props for a small sub-tree will be
       much less than the cost of rendering the entire tree again.

    It's highly recommended to install the
    [React Developer Tools](https://react.dev/learn/react-developer-tools)
    browser extension to identify areas where components are updating
    unnecessarily.  With the tools pane open, click on the settings cog
    and make sure the following checkboxes are enabled:

      * "Highlight updates when components render," under "General."

      * "Record why each component rendered while profiling," under
         "Profiler."

    The first setting will highlight component updates on the page, which
    should make it obvious where unnecessary updates are occurring. (For
    example, editing a relationship shouldn't update every other relationship
    on the page.) The second setting will tell you in the profiler which
    props changed to trigger those updates.

    Once you indentify which props are triggering unnecessary updates,
    it's generally just a matter of making them more specific as per above,
    or caching them with the `useMemo` and `useCallback` hooks. Another
    situation might be where you are passing a prop which is used in a
    callback (say, an event handler), but doesn't actually affect the
    rendered output at all. Consider passing that prop as a
    [ref](https://react.dev/reference/react/useRef) instead,
    since the ref's identity will remain stable.

  * The second issue with top-down data flow is related to organization: if
    there's only one reducer function, then how do we avoid it becoming a
    mess, managing tons of actions from many different files? And how do we
    make it clear what component an action is dispatched from?

    Even though there's only one "real" reducer, we don't have to make it
    handle every single action in the app on its own. We can still define
    separate reducers for each child component, and simply call them from the
    parent reducer.

    A general outline of the types and functions you'd typically define in
    a component file are described below. These are specific to the file's
    component, and handle all the actions/state used by that component.

      * `type ActionT`: A union type that lists all the actions that the
        component can `dispatch`. Each action should be an object with a
        `type` field that names the action, e.g. `add-item`, `show-help`,
        etc., along with any additional data needed by the action.

      * `type StateT`: A read-only type that describes the state which is
        needed to display the component and dispatch actions.

      * `type PropsT`: In many cases, the only props you need are `dispatch`
        (`(ActionT) => void`) and `state` (`StateT`), though it also makes
        sense to pass static values that never change as props instead of
        including them in `state`. If you need these props in the `reducer`
        function, having them in `state` is convenient, though.

      * `function createInitialState(...)`: Builds a `StateT`. The arguments
        to this function are up to you and depend on what properties you need
        to initialize.

      * `function reducer(state: StateT, action: ActionT)`: Sets up a switch
        statement over `action.type` and returns an updated `StateT`.

        `StateT` should be deeply read-only. To make modifications, first
        make a copy:

        ```js
        const newState = {...state};
        // ... and while handling some action:
        newState.someList = [...newState.someList, newItem];
        ```

        If you need to make complex updates to deeply-nested properties,
        use the `mutate-cow` library.

        If you're managing a sorted list of hundreds of items, while also
        handling insertions and deletions to that list and maintaining its
        order, consider using the `weight-balanced-tree` module to store the
        list as a binary tree. This module has the advantage that it can make
        immutable updates to the list in an efficient manner, without copying
        the whole tree.

    Above it was mentioned that each component would receive `dispatch` as a
    prop from the parent, but this `dispatch` accepts the child's `ActionT`,
    not the parent's. Thus, the parent needs to create this `dispatch`
    function in some way. There's also a `reducer` function for the
    child, but we want a way to call this from the parent reducer without
    having to list out every child action.

    What you want to do is encapsulate all of the child actions into a single
    parent action. This makes it easy to define `dispatch` for the child
    (with `React.useCallback`) and call its reducer:

    ```js
    import {
      type ActionT as ChildActionT,
      reducer as childReducer,
    } from './Child.js';

    type ActionT =
      | {+type: 'update-child', +action: ChildActionT}
      // ...
      ;

    function reducer(state: StateT, action: ActionT): StateT {
      switch (action.type) {
        /*
         * No need to list every child action here, since they're
         * encapsulated by `update-child`.
         */
        case 'update-child': {
          const childAction = action.action;
          /*
           * You could even have another switch statement here on
           * childAction.type, in case you need to handle particular actions
           * in the parent reducer (because they affect state in the parent
           * that the child doesn't know about).
           */
          state.child = childReducer(state.child, childAction);
          break;
        }
      }
    }

    function ParentComponent(props: PropsT) {
      const [state, dispatch] = React.useReducer(
        reducer,
        props,
        createInitialState,
      );

      /*
       * Create the child's dispatch function. The child need not worry how
       * it was defined, just that it can pass its own actions to it.
       */
      const childDispatch = React.useCallback((action: ChildActionT) => {
        /*
         * If you need to identify the child in some way (perhaps its index
         * in a list), you can add extra arguments to this function.  The
         * child will of course have to adjust how it calls dispatch, e.g.
         * `dispatch(myIndex, action)`.
         */
        dispatch({type: 'update-child', action});
      }, [dispatch]);

      return <Child dispatch={childDispatch} />;
    }
    ```

    As noted in a comment in the above example, sometimes a child action may
    actually require you to modify some state in the parent. With this setup,
    you can still easily look at the child action and handle it in the parent
    reducer if necessary. You may not even need to handle the action in the
    child reducer at all: it might just happen to be dispatched from there
    but only affect state in the parent. In a case like that, you can
    optionally just pass the parent's `dispatch` function to the child.
    You can decide whichever is cleaner on a case-by-case basis.

    For a working example of the recommendations above, refer to
    /root/static/scripts/tests/examples/todo-list/. You can compile it using
    `./script/compile_resources.sh tests` and navigate to
    `/root/static/scripts/tests/examples/todo-list/index.html` on your
    local server to try it out.

  As a final note, you may be wondering whether it's appropriate to use
  `React.useState` in a much larger app that has top-down data flow.
  (This isn't about whether you'll have to import external or shared
  components that use `useState`; that is a certainty and not an issue at all
  because the state should be isolated.) In the context of the app, there's
  nothing wrong with `useState` for relatively simple components that
  have a small amount of isolated state. You shouldn't force a component to
  follow this pattern if you can accomplish your goal much more simply with
  `useState`.

Cover/Event Art Archive development
-----------------------------------

The cover and event art features in MusicBrainz are provided by
[coverartarchive.org](https://coverartarchive.org/) and
[eventartarchive.org](https://eventartarchive.org/) respectively.
Instructions for adding cover and event art support to your development
setup are available in the HACKING-IMG.md file.


Cache
-----

Keys:

The cache key for an entity is determined by its name in entities.json. For
example, you can lookup artists under "artist:ROW_ID" or "artist:MBID". Here
are the non-entity cache keys:

 * blog:entries -- The lastest entries from blog.metabrainz.org
 * stats:* -- various different statistics
 * wikidoc:TEXT-INT -- wikidocs by page title and revision
 * wikidoc-index -- wikidocs index page


Debugging
---------

### Perl

If you have CATALYST_DEBUG set to true, in DBDefs, the built in server
(script/musicbrainz_server.pl) will run in a development environment. This will
cause debug information to be generated on every page, and all HTML pages will
have debug panels available to view this information. To get to these panels,
simply click the "?" icon in the top right of each page.

### JavaScript

Using your browser's debugger can sometimes be tedious due to the amount of
helper code generated by Babel for older browsers. Although we output
source maps, stepping through the program isn't always seamless when, for
example, you hit a "for ... of" loop or an object or array spread.

In order to improve the debugging experience, you may opt to target only
modern browsers when compiling static resources by specifying the
`BROWSER_TARGET` environment variable:

```sh
env BROWSER_TARGET=modern ./script/compile_resources.sh
```

Sometimes you may want to test how a certain module or function behaves
locally, in Node.js, without setting up a whole test suite or Webpack
configuration for it. This can be difficult, because most modules you would
want to test are using Flow syntax, which can't be executed directly;
furthermore, they may rely on some auto-imported functions, like `l`, which
are injected by Webpack.

There are two utilities which can help here:

 1. ./bin/sucrase-node

    If you'd like to execute an ES module which uses *at most* Flow syntax,
    and not any magic Webpack imports, then you may do so with
    ./bin/sucrase-node (the same as you would with just `node`).

 2. ./webpack/exec

    If you'd like to execute any kind of script (ESM or CommonJS) which may
    import modules that make use of magic Webpack imports, then use
    ./webpack/exec instead. This tools works by compiling the input script to
    a temporary file, which is then executed directly and cleaned up once
    it's finished with.

    ```sh
    $ cat <<EOF > test.js
    const commaOnlyList =
      require('./root/static/scripts/common/i18n/commaOnlyList.js').default;
    console.log(commaOnlyList([1, 2, 3]));
    EOF
    $ ./webpack/exec test.js
    ```

Potential issues and fixes
--------------------------

### Images from Wikimedia Commons aren't loading

This might be caused by failed SSL verification. One way to confirm is to check
response that you get from Wikimedia Commons API in `Data::Role::MediaWikiAPI`.
If it is indeed the cause then you can install `Mozilla::CA` module:

    $ cpanm Mozilla::CA

Mac OS X
--------

After updating `gettext` or `icu4c` packages with Homebrew, you might need to
re-link them:

    $ brew link gettext --force
    $ brew link icu4c --force

If `icu4c` was updated, you'll also need to rebuild `Unicode::ICU::Collator`:

    $ cpanm --force Unicode::ICU::Collator
