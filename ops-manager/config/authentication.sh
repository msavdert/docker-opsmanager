#!/bin/bash
# For Application Database
/usr/bin/mongo 127.0.0.1:27017/admin --eval 'db.createUser({user:"admin",pwd:"mongo",roles:[{role:"root",db:"admin"}]})'
/usr/bin/sed -i -- 's/.*security.*/security:'"\n"'  authorization: enabled/' /etc/mongod.conf

# For Backup Database
/usr/bin/mongo 127.0.0.1:27018/admin --eval 'db.createUser({user:"admin",pwd:"mongo",roles:[{role:"root",db:"admin"}]})'
/usr/bin/sed -i -- 's/.*security.*/security:'"\n"'  authorization: enabled/' /etc/mongodbackup.conf

/usr/bin/systemctl restart mongod
/usr/bin/systemctl restart mongodbackup
