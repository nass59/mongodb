# Chapter 1 - The Mongod

## What is mongod?

Mongod is the main deamon process for mongodb.

## What is deamon?

A deamon is a process that's meant to be run and not interacted with in a direct manner. Instead, our application utulizes a driver to communicate with the mongod.

MongoDB is available on numerous 64-bit architectures.

```
mongod
```

```
MongoDB starting : pid=73 port=27017 dbpath=/data/db 64-bit host=edbc338149b9
```

```
use admin
db.shutdownServer()

mongod --port 30000 --dbpath data/first_mongod --logpath data/first_mongod/mongod.log --fork

mongo --port 30000
```

- --port: The port to listen on.
- --dbpath: The location to store database files.
- --logpath: The location of a logfile for mongod to log information to.
- --fork: A flag to tell mongod to run as a background process, rather than as an active process which blocks the shell.

### Question

When specifying the --fork argument to mongod, what must also be specified?
=> **--logpath**

---

```
mongo admin --eval '
  db.createUser({
    user: "m103-admin",
    pwd: "m103-pass",
    roles: [
      {role: "root", db: "admin"}
    ]
  })
'
```

---

## Command Line Option

- --dbpath => storage.dbPath
- --logpath => systemLog.path and systemLog.destination
- --bind_ip => net.bind_ip
- --replSet => replication.replSetName
- --keyFile => security.keyFile
- --sslPEMKey => net.ssl.sslPEMKey
- --sslCAKey => net.ssl.sslCAKey
- --sslMode => net.sslMode
- --fork => processManagement.fork

```yaml
storage:
  dbPath: "/data/db"

systemLog:
  path: "/data/log.mongod.log"
  destination: "file"

net:
  bindIp: "127.0.0.1, 192.168.0.10"
  ssl:
    mode: "requireSSL"
    PEMKeyFile: "/etc/ssl/ssl.pem"
    CAFile: "/etc/ssl/SSLCA.pem"

security:
  keyFile: "/data/keyfile"

processManagement:
  fork: true
```

```yaml
storage:
  dbPath: "/data/db"

systemLog:
  path: "/data/logs/mongod.log"
  destination: "file"

net:
  bindIp: "127.0.0.1,192.168.103.100"
  port: 27000

security:
  authorization: enabled

processManagement:
  fork: true
```

```
mongod --config "/etc/mongod.conf"
// or
mongod -f "/etc/mongod.conf"
```

## MongoDB File Structure (WiredTiger)

```
/data/db
    WiredTiger
    WiredTiger.lock
    WiredTiger.turtle
    WiredTiger.wt
    WiredTigerLAS.wt
    _mdb_catalog.wt
    diagnostic.data
    journal
    local
    mongod.lock
    sizeStorer.wt
    storage.bson
```

## Conclusion

- **diagnostic.data** and log files assist support in diagnostics
- Do not modify files or folders in the MongoDB data directory

```yaml
storage:
  dbPath: "/var/mongodb/db/"

systemLog:
  path: "/data/logs/mongod.log"
  destination: "file"

net:
  bindIp: "127.0.0.1,192.168.103.100"
  port: 27000

security:
  authorization: enabled

processManagement:
  fork: true
```

## Basic Commands

### User Management

```
db.createUser()
db.dropUser()
```

### Collection Management

```
db.<collection>.renameCollection()
db.<collection>.createIndex()
db.<collection>.drop()
```

### Database Management

```
db.dropDatabase()
db.createCollection()
```

### Database Status

```
db.serverStatus()
```

### Database Command

```
db.runCommand( { <COMMAND> })
```

```
db.runCommand(
  { "createIndexes": <collection> },
  { "indexes": [
    {
      "key": { "product": 1 }
    },
    { "name": "name_index" }
    ]
  }
)

db.<collection>.createIndex(
  { "product": 1 },
  { "name": "name_index" }
)
```

## Logging Basics

- Verbosity 1 to 5.
- -1: Inherit from parent.
- 0: Default Verbosity

```
db.getLogComponents()
db.setLogLevel(0, "index")
```

```
2020-01-01T16:47:52.642+0000 I  COMMAND  [conn1] successfully set parameter logComponentVerbosity to { index: { verbosity: 0.0 } } (was { verbosity: 0, accessControl: { verbosity: -1 }, command: { verbosity: -1 }, control: { verbosity: -1 }, executor: { verbosity: -1 }, geo: { verbosity: -1 }, index: { verbosity: -1 }, network: { verbosity: -1, asio: { verbosity: -1 }, bridge: { verbosity: -1 }, connectionPool: { verbosity: -1 } }, query: { verbosity: -1 }, replication: { verbosity: -1, election: { verbosity: -1 }, heartbeats: { verbosity: -1 }, initialSync: { verbosity: -1 }, rollback: { verbosity: -1 } }, sharding: { verbosity: -1, shardingCatalogRefresh: { verbosity: -1 } }, storage: { verbosity: -1, recovery: { verbosity: -1 }, journal: { verbosity: -1 } }, write: { verbosity: -1 }, ftdc: { verbosity: -1 }, tracking: { verbosity: -1 }, transaction: { verbosity: -1 } })
```

### Log Message Severity Level

- F: Fatal
- E: Error
- W: Warning
- I: Information (Verbosity Level 0)
- D: Debug (Verbosity Level 1-5)

## Recap

- MongoDB Process log supports multiple components for controlling granularity of events captured.
- You can retrieve the log from the mongo shell, or using command line utilities like tail.
- You can change the verbosity of any log component from the mongo shell.

## Question

The insert operation generates both a WRITE and COMMAND log event. There is no UPDATE component, and the QUERY component captures events related to query planning.

## Profiling the Database

The MongoDB Profiler:

| Level | Description                                                                            |
| ----- | -------------------------------------------------------------------------------------- |
| 0     | The profiler is off and does not collect any data. This is the default profiler level. |
| 1     | The profiler collects data for operations that take longer then the value of slowms.   |
| 2     | The profiler collects data for all operations.                                         |

```
db.runCommand({listCollections: 1})
db.getProfilingLevel()
db.setProfilingLevel(1)
db.getCollectionNames()
db.setProfilingLevel( 1, { slowms: 0 } )
db.new_collection.insert( { "a": 1 } )
db.system.profile.find().pretty()
```

### Question

What events are captured by the profiler?

- Adminitrative commands
- Cluster configuration operations
- CRUD operations

CRUD operations, Administrative commands, and Cluster configuration operations are all captured by the database profiler.

However, Network timeouts and WiredTiger storage data are not captured by the profiler - this data is stored in the logs instead.

```yaml
storage:
  dbPath: "/var/mongodb/db/"

systemLog:
  path: "/var/mongodb/db/mongod.log"
  destination: "file"
  logAppend: true

net:
  bindIp: "127.0.0.1,192.168.103.100"
  port: 27000

security:
  authorization: enabled

processManagement:
  fork: true

operationProfiling:
  slowOpThresholdMs: 50
```

## Basic Security

- **Authentication**: Verifies the **Identity** of a user.

- **Authorization**: Verifies the **Privileges** of a user.

### Authentication Mechanisms

- SCRAM: Default. Password Security. Basic Security
- X.509: X.509 Certificate
- LDAP (For MongoDB Enterprise Only)
- Kerberos (For MongoDB Enterprise Only)

Also Cluster Authentication Mecanisms

### Authorization: Role Based Access Control

- Each user has one or more **Roles**
- Each **Roles** has one or more **Privileges**
- A **Privilege** represents a group of **Actions** and the **Resources** those actions apply to.

### Localhost Exception

- Allows you to access a MongoDB server that enforces authentication but does not yet have a configured user for you to authenticate with.
- Must run Mongo shell from the same host running the mongoDB server.
- The localhost exception closes after you create your first user.
- Always create a user with administrative privileges first.

#### Connect to the mongo

```bash
mongo --host 127.0.0.1:27017
```

#### Create an user

```js
db.createUser({
  user: "root",
  pwd: "root123",
  roles: ["root"]
});
```

#### Connect as Admin

```js
mongo --username root --password root123 --authenticationDatabase admin
```

## Buit-In Roles

### Role Structure

**Role is composed of**:

- Set of privileges
  - Actions -> Resources
- Network Authentication Restrictions
  - clientSource
  - serverAddress

**Resources**:

- Database
- Collection
- Set of Collections
- Cluster
  - Replica Set
  - Shard Cluster

**Privilege**:

- Resource
- Actions allowed over a resource

A Role can also inherit of one or more roles

### Built-In Roles

- **Database User**
  - read
  - readWrite
- **Database Administration**
  - dbAdmin
  - userAdmin
  - dbOwner
- **Cluster Administration**
  - clusterAdmin
  - clusterManager
  - clusterMonitor
  - hostManager
- **Backup/Restore**
  - backup
  - restore
- **Super User**
  - root
- **All Database**

  - Database User
  - Database Administration
  - Super User

### User Admin

```js
db.createUser({
  user: "security_officer",
  pwd: "h3ll0th3r3",
  roles: [{ db: "admin", role: "userAdmin" }]
});
```

He can:

- changeCustomData
- changePassword
- createRole
- createUser
- dropRole
- dropUser
- grantRole
- revokeRole
- setAuthenticationRestriction
- viewRole
- viewUser

### dbAdmin

```js
db.createUser({
  user: "dba",
  pwd: "c1lynd3rs",
  roles: [{ db: "m103", role: "dbAdmin" }]
});
```

He can:

- collStats
- dbHash
- dbStats
- killCursors
- listIndexes
- listCollections
- bypassDocumentValidation
- collMod
- compact
- convertToCapped

```js
db.grantRolesToUser("dba", [{ db: "playground", role: "dbOwner" }]);
```

### dbOwner

The database owner can perform any administrative action on the database.

This role combines the privileges granted by the readWrite, dbAdmin and userAdmin roles.

```js
db.runCommand({
  rolesInfo: { role: "dbOwner", db: "playground" },
  showPrivileges: true
});
```

```js
db.createUser({
  user: "m103-application-user",
  pwd: "m103-application-pass",
  roles: [{ db: "applicationData", role: "readWrite" }]
});
```

## Server Tools Overview

- mongod
- mongo
- mongoexport
- mongostat
- mongofiles
- mongoimport
- mongos
- mongorestore
- mongodump
- mongotop

### List mongodb binaries

```bash
find /usr/bin/ -name "mongo*"
```

### Create new dbpath and launch mongod

```bash
mkdir -p ~/first_mongod
mongod --port 30000 --dbpath ~/first_mongod --logpath ~/first_mongod/mongodb.log --fork
```

### Use mongostat to get stats on a running mongod process

```bash
mongostat --help
mongostat --port 30000
```

### Use mongodump to get a BSON dump of a MongoDB collection

```bash
mongodump --help
mongodump --port 30000 --db applicationData --collection products
ls dump/applicationData/
cat dump/applicationData/products.metadata.json
```

### Use mongorestore to restore a MongoDB collection from a BSON dump

```bash
mongorestore --drop --port 30000 dump/
```

### Use mongoexport to export a MongoDB collection to JSON or CSV (or stdout!)

```bash
mongoexport --help
mongoexport --port 30000 --db applicationData --collection products
mongoexport --port 30000 --db applicationData --collection products -o products.json
```

### Use mongoimport to create a MongoDB collection from a JSON or CSV file

```bash
mongoimport --port 30000 products.json
```

## Questions

- Mongodump can create a data file and a metadata file, but mongoexport just creates a data file.
- By default, mongoexport sends output to standard output, but mongodump writes to a file.
- Mongodump outputs BSON, but mongoexport outputs JSON.