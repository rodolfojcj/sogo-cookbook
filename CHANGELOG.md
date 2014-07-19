sogo CHANGELOG
==============

0.3.1
-----
- Minor changes
- Removed the dependency with a custom Chef cookbook used to force the updating of APT packages data; instead the inclusion of the `apt` recipe is now placed after the configuration of the SOGo APT repository so such updating is done later

0.3.0
-----
- Added the option to set SSL parameters on Apache virtual host configuration

0.2.2
-----
- Change and fix in the generation of the /etc/sogo/sogo.conf file
- Forced the updating of APT files

0.1.1
-----
- Fix in the inclusion of the deep_merge gem with a hack (the previous approach with chef_gem actually did not work)

0.1.0
-----
- Working version

0.1.0
-----
- First attempt
