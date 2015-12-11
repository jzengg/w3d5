# wORM

An Object-Relational Mapping using Ruby metaprogramming. Inspired by ActiveRecord.

## Features
* SQL object - table_name, all, find, insert, update and save methods
* Searchable - execute SQL WHERE queries while avoiding SQL injection attack.
* Associations - belongs_to, has_many, has_one_through and has_many_through associations


## How to use:
* Clone or Extract ZIP file of this repo into your project
* In your code, require_relative './wORM/orm.rb'
* To load your SQLite3 Database, call 'DBConnection.open(PATH_TO_YOUR_DB_FILE)'
* Use the SQL object, Searchable and Association methods provided for manipulating and querying data.

## Todo
* Implement `Relation` class and make `where` lazy and stackable.
* Add an `includes` method that does pre-fetching.
* `joins`
* Validators

