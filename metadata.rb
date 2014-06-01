name             'sogo'
maintainer       'OpenSinergia RL'
maintainer_email 'rodolfojcj@yahoo.com'
license          'Apache v2.0'
description      'Installs and configures SOGo groupware server solution'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends "apt"
depends "apache2"
depends "database"
depends "postgres"