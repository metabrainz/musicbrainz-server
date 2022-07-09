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
         here, and pass the request data to it. (See e.g.
         `MusicBrainz::Server::Controller::edit_action`). The form acts to
         validate the request data and return any errors.

         We have some forms that are mostly rendered client-side and submit
         JSON directly to some controller endpoint, which then performs its own
         validation. (See e.g. `/ws/js/edit`.) Those have nothing to do with
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

 * `./script/generate_edit_data_flow_type.js --edit-type $EDIT_TYPE_ID`
   will generate an object type to represent the edit data of `$EDIT_TYPE_ID`.
   However, this requires having a `PROD_STANDBY` database configured in
   DBDefs.pm, as it uses production data to ensure a correct type.

 * `cat $JSON | ./script/generate_json_flow_type.js` will generate an object
   type for a stream of JSON objects (which each must be on a single line).
   Passing a single object is fine, too.

### Selenium

We have a set of browser-automated UI tests running with Selenium WebDriver.
These are a bit more involved to set up:

 * Install ChromeDriver:
   https://github.com/SeleniumHQ/selenium/wiki/ChromeDriver

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

 * Run ./script/create_test_db.sh SELENIUM and run ./script/compile_resources.sh again.

With the above prerequisites out of the way, the tests can be run from the
command line like so:

    $ ./bin/sucrase-node t/selenium.mjs

If you want to run specific tests under ./t/selenium/, you can specify the
paths to them as arguments. t/selenium.mjs also accepts some command line flags
which are useful for debugging and development; see `./bin/sucrase-node t/selenium.mjs --help`.
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
   (default: /usr/lib/postgresql/12/lib/pending.so)

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
in [.eslintrc.yaml](.eslintrc.yaml). To check a file or directory against all
of these rules, run:

    $ ./node_modules/.bin/eslint $file_or_directory

Replace `$file_or_directory` with the path to the file or directory you'd like
to check.

If you want to check only a specific rule (say, because you'd like to fix that
particular rule across the codebase and want to ignore others while doing so),
we also have a script for that:

    $ ./script/check_eslint_rule $rule $file_or_directory

In this case, you'd replace `$rule` with a string defining the specific rule
you'd like to check, in [levn](https://github.com/gkz/levn) format. For
example, `'block-scoped-var: [warn]'`. Further documentation on how to specify
these can be found
[here](https://eslint.org/docs/user-guide/command-line-interface#--rule),
but in most cases you can copy rules as-is from .eslintrc.yaml, since the YAML
syntax is very similar.

A second YAML file, [.eslintrc.unfixed.yaml](.eslintrc.unfixed.yaml), lists rules
we want to follow but we don't yet enforce. We also have a script to check a file
or directory against all of these rules,
[script/check_unfixed_eslint_rules](script/check_unfixed_eslint_rules):

    $ ./script/check_unfixed_eslint_rules $file_or_directory

You can also check these unfixed rules one by one with `check_eslint_rule`
as indicated above.


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
    via the variable `$c`. This is passed as a prop automatically if the
    component is top-level or used from `React.embed`. If you need to access
    `$c` from a deeply-nested component, you can either pass it down from
    a parent component, or import the `CatalystContext`
    [React context](https://reactjs.org/docs/context.html) from
    root/context.js and either use the `CatalystContext.Consumer` component
    or use `React.useContext(CatalystContext)`.

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

Cover Art Archive development
-----------------------------

The Cover Art features in MusicBrainz are provided by
[coverartarchive.org](https://coverartarchive.org/). Instructions for adding
cover art support to your development setup are available in HACKING-CAA.md
file.


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


Debug information
-----------------

If you have CATALYST_DEBUG set to true, in DBDefs, the built in server
(script/musicbrainz_server.pl) will run in a development environment. This will
cause debug information to be generated on every page, and all HTML pages will
have debug panels available to view this information. To get to these panels,
simply click the "?" icon in the top right of each page.

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
