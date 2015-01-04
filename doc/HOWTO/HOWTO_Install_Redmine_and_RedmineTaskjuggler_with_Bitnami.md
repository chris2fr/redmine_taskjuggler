# How to Install RedmineTaskjuggler on Windows and Mac with Bitnami

The Bitnami distributions of Redmine are available here:

https://bitnami.com/stack/redmine/installer

at the time of this writing, the installer bitnami-redmine-2.6.0-3-windows-installer.exe is about 200 Mb and took me, Christopher Mann, an hour to download.

Download the corresponding package for your environment.

Then follow the indications here:

http://www.redmine.org/projects/redmine/wiki/How_to_install_Redmine_in_Linux_Windows_and_OS_X_using_BitNami_Redmine_Stack

The standard Redmine installation doc is here, but we do not need it actually:

http://www.redmine.org/projects/redmine/wiki/RedmineInstall

Here is what happened during the setup wizard:

* There is a dialog durring my installation saying that my anti-virus will slow down my installation and that I should visit https://bitnami.com/antivirus for more info. This leads to a page here https://wiki.bitnami.com/Native_Installers_Quick_Start_Guide/Antivirus asking for opening of the following ports 800, 443, 33069 5432, 8080, 8005, 8009, 3001, 3002, 8100, 3690, and 8983. Let's move on.
* In the dialog box for installation components, I unclicked Subversion, Git, and PhpMyAdmin, leaving only DevKit and Redmine.
* In the dialog box for target directory, I choose D:\Bitnami\redmine-2.6, but that is a matter of choice.
* The admin user I choose had my real name and email, but admin:minad as a login and password.
* No email support

At the end of the setup wizard, I would have liked a recapitulative statement of my configuration but did not have one.

The installation process took about a half hour. I had to authorize the Apache server manually.

The redmine installation is then here:

`D:\Bitnami\redmine-2.6,\apps\redmine\htdocs`

Therefore, I checked out directly the origin\master here:

`D:\Bitnami\redmine-2.6,\apps\redmine\htdocs\plugins`

Note, bitnami seems to use the database "production"

The README.txt at D:\Bitnami\redmine-2.6,\README.txt is quite well done.

To open an environnment, I think one needs to simply launch D:\Bitnami\redmine-2.6,\use_redmine.bat

I then installed the plugin with the following command:

`D:\Bitnami\redmine-2.6\apps\redmine\htdocs>bundle exec rake redmine:plugins:migrate RAILS_ENV=production`

and restarted the servers with the restart interface in the Bitnami graphical manager.
