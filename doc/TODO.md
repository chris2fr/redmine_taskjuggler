# Redmine_Taskjuggler Todo

https://github.com/chris2fr/redmine_taskjuggler

The main todo is now managed in the issue management system of GitHub here :

https://github.com/chris2fr/redmine_taskjuggler/issues

Here is a wish list for later on:

* Native integration with Taskjuggler 3 (also in Ruby whereas TJ2 was in C / QT)
  However, they seem to use different versions of Ruby (1.9.3 versus 2.0)

## Thoughts on what I am doing now by Christopher Mann

Initially used for a 22-person IT department in Redmine v.0.9 and Taskjuggler v.2, today this update was for a 4-person development team in Redmine v2.X and Taskjuggler v.3.  However ...  Well I'll finish the update anyway.

The basic idea was to use Redmine as a missing GUI for Taskjuggler, at least in tracking. At the time, my own programming was quick and dirty. I was under time pressure myself. The main error, I think, was using custom variables that needed to be manually configured in Redmine. So, as I debug for the current version of Redmine, I will also incorporate a proprietary data model into this plugin.

This plugin may have different features for different uses, especially after we fuse it with Workload. Inxbil is the first to really bring about a novel way of using integration with Redmine in a way I had not foreseen.

## Specific work items that should be in the GitHub issue Tracker

This is a file of things to do in order to put some sense into redmine_taskjuggler.

I just started a website for taskjuggler.net, so I would like to publish that. I will start on taskjuggler.mann.fr
* DONE Declare domain taskjuggler.mann.fr and redtask.mann.fr to point to ovh server
The OVH Server is 92.222.4.203 and 2001:41D0:0052:0A00:0000:0000:0000:089b
This is not working. For some reason the DNS request doesn't seem to make it yet on mann.fr.
* DONE Setup a static website for taskjuggler.mann.fr on the ovh server
  * DONE Put the files generated with EMacs Org Mode in /var/www/taskjuggler
  * DONE Configure a virtual host to recognize taskjuggler.mann.fr
* DONE Point projuggler.net and redmine.mann.fr to ovh server
* DONE Setup virtual host for redmine.mann.fr and projuggler.net
See comment above about subdomaines on mann.fr.

* TODO Go through all the code in users/christopher/draft
* TODO Look into user/inxbil code
* TODO TimeEntry calibrating
* TODO Initiate doc directory (not very organized)
* TODO Add fields to issues views (which ones?)
* TODO Manage priorities
* TODO On-the-server execution
* TODO Between-servers execution

* TODO Change timeingresolution to enumeration 5, 10, 15, 30, 60min
* TODO Add fields to Views : Project, User, TimeEntry
* TODO Add fields to mass-edit dialogue
* TODO Update demo server and have demo roles, as well as demo scenarios
* TODO Cool idea : setup public compilation server for anyone to use
* TODO Re-establish categories and versions in taskjuggler reports
* TODO More accounting integration
* TODO Field for reports specifications (text, uploadable)
* TODO Nested tasks
* TODO Aribtrary groups
* TODO Look into modelisation options from Taskjuggler and those accessible by RedmineTaskjuggler and mapping the difference
* TODO Right-click edit
* TODO Create a website for this project
* TODO Close Workload

* DONE Factorize code
* DONE Migrate custom-fields to own data model
  * DONE Augment Issues, Projects, Ressources 
  * DONE Add fields to issue update
* DONE Institute test procedures
* DONE CSV import
* DONE TJP export
* DONE Take screen shots (in wiki and in doc I think)
* DONE Incoporate Workload into this plugin
