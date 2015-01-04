## Overview

Here are some thoughts about where I would like to push my plugins :

* Taskjuggler
* Workload
* PMO

## Workload

Workload should :
* Transform the paradigm to days and not hours.  It is a small but significant change that would make my life much more enjoyable.  This would imply putting hour information in the task attributes, timesheet, time log entry. Basically, there would by an export filter on tasks that would export the time in days (even by units of 0,125 representing one hour).  I would see this as a box that has 1, 1/2, 1/4, 1/8, 3/4, 3/8, 5/8, 7/8 values.
* Allow people to input their time from a daily time-table.  Columns are days.  Lines are tasks.  The time per each day in a cell can be cliqued-on and changed.  The maximum time input value is one day per day.  It would be fun to even have ajax calls here to show the dropdown in the cell, call the server, update the info on the server, refresh the value in the cell.
* Export the data into a HTML document with a .xls extension.
* Export the data into a CSV file with columns : project.id, project.name, category.name, issue.id, issue.name, user.login, effort done, effort todo, date debut, date fin, priority
* Import massive updates with regards to start date, due date, effort still needed, priority, person

## PMO

PMO should :
* Present a summary table by project, by project category, by resource
* Milestone should be a red-line to the right (red-line on right of cell of milestone date)
* Massively change priorities on whole project/project-category/developper
* Re-affect developpers to project/project-category/developper triplets
* Always take into account all projects
* Allocat time to recurrent activities

## Task Juggler

TaskJuggler should :
* Import a file uploaded from the browser (temporary solution)
* Export a file by a link to the browser without formating (low priority)
* Have appropriate HTML and CSV format exports
  * Specifiy those appropriate formats
* Separate todo and done workloads with separate tasks
* Input ressource information : Weekly schedule, Vacation days, 
* Allocate each resource to each task with future effort, done effort

Taskjuggler will probably, for planning reasons, separate tasks in 2 per allocated resource.  If Tom and John are working on #450 TaskOne with done and todo worklads, we would see this :
* Task450
  * John : 4 days, of which 2 booked
  * Tom : 3 days of which 1 booked

Taskjuggler is a tough on, because of the syncronisation aspect.  Lets consider 4 kinds of tasks :
* Not started
* Started
* Finished

Finished tasks will work as follows :
* DoneWork == Estimated work in Redmine
* Progress == 100% in redmine
* Status == "Closed"
* Start and End are calculated by bookings
* Taskjuggler flag "scheduled" is assigned
* Export from Redmine to Taskjuggler will be one task for all (nothing to juggle)

Not started tasks will work as follows :
* Done Work == 0
* Progress == 0
* Status == "1_New" or the initial status
* Start and end are empty or in the future (but not important)
* Force start (ASAP) or force end (ALAP) dates can be checked
* Sub-tasks are created per allocated developper

Started tasks are managed as follows :
* One sub-task per developper with allocation information
* Start date is calculated from first booking entry per developper
* Progress is calculated upon spent versus estimated workload
* Estimated time is at least booked time

Task juggler mode is "projection"

## Underview