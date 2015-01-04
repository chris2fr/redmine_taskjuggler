---
layout: default
title: README
---

# Redmine_Taskjuggler plugin

This is Redmine <http://www.redmine.org> and TaskJuggler (tm) <http://www.taskjuggler.org> integration maintained on the Github project page <https://github.com/chris2fr/redmine_taskjuggler>. Like Oreos (tm) and milk, Redmine and Taskjuggler are made for each other!


Further documentation to this README can be found in the subfolder [./doc/](./doc/): HOWTOs, diagrams, notes, credits, license, and todo.

Copyright (C) 2009 - 2015 Christopher Mann <christopher@mann.fr> AGPL v.3 (see [LICENSE.md] and [CREDITS.md])


Taskjuggler is available at http://www.taskjuggler.org. It is fantastic capacity planning software!

## Features

Here is what this plugin does with you :

* Exports from Redmine a Taskjuggler project
* Imports into Redmine Dates and Efforts from a Taskjuggle_Redmine CSV file ("Redmine","Start","End","Priority","Effort","Dependencies")
* Converts time-entries in Redmine to journal entries in Taskjuggler (ordering them hour-to-hour for Task-juggler bookings) 
* New (from Workload) : Sets up time sheets for resources with Redmine TimeEntries as a datastore
* New (from Workload) : Pre-reserves slots for resources into TaskJuggler from the Redmine TimeEntries datastore

## Notes on the current version 0.1.2-beta

This is a begining beta release. It works, and we have incorporated a major new feature set from RedmineWorkload.

Reserves :
* On the project being compiled, you need to input by hand the tj_period such that the start and end dates are coherent with the project (yyyy-mm-dd - yyyy-mm-dd). In the future I can change them with containing TimeEntries.
* In some cases, and I have not yet been able to reproduce this, the TJP file will have the keywork start without a date in a task. This will cause the TJ3 program to fail to compile and you need to change it by hand by removing start or adding a date. Please tell me if you can reproduce.

## Running automated tests

  `rake redmine:plugins:test`
  I think you can add NAME="redmine_taskjuggler" or PLUGIN="redmine_taskjuggler"

## Notes on the previous version 0.1.1-alpha

This is an advanced alpha release. It works, but one should follow a few indications.

* Estimated Time is the remaining estimated time.
* Do not use the Follows and Preceeds in Redmine itself
* Activate individually the projects, issues, and users for Redmine
* The screens modify issue/update, project/settings, admin/user/form
* You will need to input the necessary data manually everywhere
* TimeEntries are not yet implemented

The basic idea is that you :

1. set up the model in Redmine first,
2. then export the TJP file,
3. then compute the TJP file on your own computer, 
4. and then upload the computed CSV file to redmine.

Here are the features under developement:

* Bookings
* TimeEntry calibration (TaskJuggler likes to know exactly when the work was done.)
* Organize features form version 0.0.2
* Tests
* Estimated Effort calibration
* Have the computation done on the server (I suppose that would need factoring of the backends)
* Integrate with Redmine Workload
* Do manual
* More fields

Here is the backlog

* Sanity check for the information in Redmine for TaskJuggler
* Bulk-edit of issues for TJ
* Dealing with the Follows and Preceeds in Redmine
* Activate or disactivate plugin
* Deal with permissions
* Disactivate unused fields
* Document mapping decisions
* Look into Feng's Django implementation to see if anything good in that
* Look into that plugin than let's you graphicly manipulate things
* Look into plugins kanban, etc.
* Native backend to Taskjuggler 

There was a demo set up here: http://redtask.configmagic.com


## Installation

Install into redmine/plugins directory. Really the redmine/plugins directory. If that directory is not there, on the top level, please create it. This is important actully.

  bundle exec rake redmine:plugins RAILS_ENV=production

or

  rake db:migrate:plugin NAME=redmine_taskjuggler
  
then restart the webserver.

To uninstall

  rake db:migrate:plugin NAME=redmine_taskjuggler VERSION=0

## Workflow

Many steps were manual in the first version. Today, the idea is to automate parts of the use of Taskjuggler from Redmine, and to update Redmine from Taskjuggler. Here is the current workflow:

1. Information is maintained in Redmine
2. Redmine Issues are tagged for Taskjuggler Tasks (all time-sheet candidate tasks and others)
3. Flaged Issues are augmented with any necessary extra info for Taskjuggler (allocate, effort)
4. The administrator creates Taskjuggler master file (with Tasks extended with a field "Red" of type "number")
5. Redmine exports a Taskjuggler Include file for computation by Taskjuggler
6. Taskjuggler computes the input file and outputs, among other reports, outputs a Redmine-Taskjuggler CSV file with the following columns (no more, no less) : "Id","Start","End","Priority","Effort","Duration","Dependencies"
7. Redmine will then update per issue the start, end, and effort fields

## Getting the plugin

A copy of the released version can be downloaded from  {GitHub}[http://github.com/chris2fr/redmine_taskjuggler]


## Installation and Setup

1. Follow the Redmine plugin installation steps at: http://www.redmine.org/wiki/redmine/Plugins Make sure the plugin is installed to +plugins/redmine_taskjuggler+
2. Restart your Redmine web servers (e.g. mongrel, thin, mod_rails)
3. Login and click the Workload in the top left menu

## Upgrade

### Zip or tar files

1. Download the latest file as described in Getting the plugin
2. Extract the file to your Redmine into vendor/plugins
3. Restart your Redmine

### Git

1. Open a shell to your Redmine's plugins/redmine_taskjuggler folder
2. Update your Git copy with `git pull`
3. Restart your Redmine

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.  

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Design Decisions

Design decisions concern mainly the way redmine_taskjuggler maps Redmine objects to TaskJuggler objects.

* Use Redmine depends and preceeds
* Use Redmine priority levels with a mapping
* Add a flag to each object to indicatue use or not in Redmine
* 

## Project help

If you need help you can contact the maintainer at his email address (See CREDITS.txt) or create an issue in the Bug Tracker.

### Bug tracker

If you would like to report a bug or request a new feature the bug tracker is located at: http://github.com/chris2fr/redmine_taskjuggler

### ToDo

In timetable! sort by project then project category.