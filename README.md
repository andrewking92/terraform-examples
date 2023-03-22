# terraform-examples

mongosh --eval "rs.initiate()"

mongosh --eval "db.createUser({ user: '', pwd: '', roles: ['root']})" admin


mongosh --eval "rs.add('mongod02.kingan916.com')"

mongosh --eval "rs.add('mongod03.kingan916.com')"

rs.status()
