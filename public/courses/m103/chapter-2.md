# Chapter 2 - Replication.

## What is Replication

- Maintain multiple copy of your data.
- Allow Availability.
- Asynchronous Replication.

## What is a Replica Set

- In MongoDB, a group of nodes that each have copies of the same data ic alled a replica set.
- In a replica set, all data is handled by default in one of the nodes, and it's up to the remaining nodes in the set to sync up with it.

## Primary / Secondary Nodes

- The node where the data is sent is called the **primary node**. All the other nodes are **secondary nodes**.
- If the primary node goes down, one of the secondary nodes can take its place as primary in a process known as **failover**.

## Failover

- The nodes decides specifically which secondary will become the primary through an election.

## Types of replication

- Binary Replication: Simple but it require a very strict consistency across evry machine running in a replica set.
  - Less data
  - Faster
- Statement-Based Replication: Default. Idempotence
  - Not bound by operating system, or any machine level dependency

## Questions

- MongoDB uses statement-based replication, not binary replication.
- Statement-based replication is platform independent.

## Replica Set

- Protocol Version 1 (PV1)
- The oplog is a segment bases lock that keeps track of all write operations aknowledged by the replica sets.
- Indempodent operation can be applies multiple times.

A replica set member can also be configured as an arbiter.

- Holds no data
- Can vote in an election
- Cannot become primary

> We should have an odd number of nodes. Up to 50 members. 7 voting Members

> Avoid Arbiters

## Types of Node

- Primary
- Secondary
- Arbiter
- Hidden
- Delayed

## Recap

- Replica Sets are group of mongod
- High Availability and Failover
- Members can have different roles and specific purposes

## Instructions

The configuration file for the first node (node1.conf):

```yaml
storage:
  dbPath: /var/mongodb/db/node1
net:
  bindIp: 192.168.103.100,localhost
  port: 27011
security:
  authorization: enabled
  keyFile: /var/mongodb/pki/m103-keyfile
systemLog:
  destination: file
  path: /var/mongodb/db/node1/mongod.log
  logAppend: true
processManagement:
  fork: true
replication:
  replSetName: m103-example
```

### Creating the keyfile and setting permissions on it:

```bash
sudo mkdir -p /var/mongodb/pki/
sudo chown vagrant:vagrant /var/mongodb/pki/
openssl rand -base64 741 > /var/mongodb/pki/m103-keyfile
chmod 400 /var/mongodb/pki/m103-keyfile
```

### Creating the dbpath for node1:

```bash
mkdir -p /var/mongodb/db/node1
```

### Starting a mongod with node1.conf:

```bash
mongod -f node1.conf
```

### Copying node1.conf to node2.conf and node3.conf:

```bash
cp node1.conf node2.conf
cp node2.conf node3.conf
```

### Editing node2.conf using vi:

```bash
vi node2.conf
```

### node2.conf, after changing the dbpath, port, and logpath:

```yaml
storage:
  dbPath: /var/mongodb/db/node2
net:
  bindIp: 192.168.103.100,localhost
  port: 27012
security:
  keyFile: /var/mongodb/pki/m103-keyfile
systemLog:
  destination: file
  path: /var/mongodb/db/node2/mongod.log
  logAppend: true
processManagement:
  fork: true
replication:
  replSetName: m103-example
```

### node3.conf, after changing the dbpath, port, and logpath:

```yaml
storage:
  dbPath: /var/mongodb/db/node3
net:
  bindIp: 192.168.103.100,localhost
  port: 27013
security:
  keyFile: /var/mongodb/pki/m103-keyfile
systemLog:
  destination: file
  path: /var/mongodb/db/node3/mongod.log
  logAppend: true
processManagement:
  fork: true
replication:
  replSetName: m103-example
```

### Creating the data directories for node2 and node3:

```bash
mkdir /var/mongodb/db/{node2,node3}
```

### Starting mongod processes with node2.conf and node3.conf:

```bash
mongod -f node2.conf
mongod -f node3.conf
```

### Connecting to node1:

```bash
mongo --port 27011
```

### Initiating the replica set:

```bash
rs.initiate()
```

### Creating a user:

```bash
use admin
db.createUser({
  user: "m103-admin",
  pwd: "m103-pass",
  roles: [
    {role: "root", db: "admin"}
  ]
})
```

### Exiting out of the Mongo shell and connecting to the entire replica set:

```bash
exit
mongo --host "m103-example/192.168.103.100:27011" -u "m103-admin" --authenticationDatabase "admin"
```

### Getting replica set status:

```bash
rs.status()
```

### Adding other members to replica set:

```bash
rs.add("m103.mongodb.university:27012")
rs.add("m103.mongodb.university:27013")
```

### Getting an overview of the replica set topology:

```bash
rs.isMaster()
```

### Stepping down the current primary:

```bash
rs.stepDown()
```

### Checking replica set overview after election:

```bash
rs.isMaster()
```

## Questions

- Enabling internal authentication in a replica set implicitly enables client authentication.
- When connecting to a replica set, the mongo shell will redirect the connection to the primary node.

## Replication Configuration

- JSON

```js
{
  _id: <string>,    // m103-example
  version: <int>,   // 1
  members: [
    {
      _id: <int>,             // 1
      host: <string>,         // m103:27017
      arbiterOnly: <boolean>, // false
      hidden: <boolean>,      // false
      priority: <number>,     // 1
      slaveDelay: <int>,      // 0
    }
  ]
}
```

## Replication Command

- **rs.status()**

  - Reports health on replica set nodes
  - Uses data from heartbeats

- **rs.isMaster()**

  - Describes a node's in the replica set
  - Shorter output than rs.status()

- **db.serverStatus()['repl']**

  - Section of the db.serverStatus() output
  - Similar to the output of rs.isMaster()

- **rs.printReplicationInfo()**
  - Only returns oplog data relative to the current node
  - Contains timestamp for first and last oplog events

## Question

What information can be obtained from running rs.printReplicationInfo()?

- The time of the latest entry in the oplog.
- The time of the earliest entry in the oplog.

## Local DB

- **oplog.rs**:

  - Keep track to things that have to be replicated.
  - capped collection

  Display collections from the local database (this displays more collections from a replica set than from a standalone node):

```bash
use local
show collections
```

### Querying the oplog after connected to a replica set:

```bash
use local
db.oplog.rs.find()
```

Getting information about the oplog. Remember the oplog is a capped collection, meaning it can grow to a pre-configured size before it starts to overwrite the oldest entries with newer ones. The below will determine whether a collection is capped, what the size is, and what the max size is.

### Storing oplog stats as a variable called stats:

```bash
var stats = db.oplog.rs.stats()
```

Verifying that this collection is capped (it will grow to a pre-configured size before it starts to overwrite the oldest entries with newer ones):

```bash
stats.capped
```

### Getting current size of the oplog:

```bash
stats.size
```

### Getting size limit of the oplog:

```bash
stats.maxSize
```

### Getting current oplog data (including first and last event times, and configured oplog size):

```bash
rs.printReplicationInfo()
```

## Reconfigure a Running Replica Set

Lecture Instructions

**node4.conf**

```yaml
storage:
  dbPath: /var/mongodb/db/node4
net:
  bindIp: 192.168.103.100,localhost
  port: 27014
systemLog:
  destination: file
  path: /var/mongodb/db/node4/mongod.log
  logAppend: true
processManagement:
  fork: true
replication:
  replSetName: m103-example
```

**arbiter.conf**

```yaml
storage:
  dbPath: /var/mongodb/db/arbiter
net:
  bindIp: 192.168.103.100,localhost
  port: 28000
systemLog:
  destination: file
  path: /var/mongodb/db/arbiter/mongod.log
  logAppend: true
processManagement:
  fork: true
replication:
  replSetName: m103-example
```

### Starting up mongod processes for our fourth node and arbiter:

```bash
mongod -f node4.conf
mongod -f arbiter.conf
```

### From the Mongo shell of the replica set, adding the new secondary and the new arbiter:

```
rs.add("m103.mongodb.university:27014")
rs.addArb("m103.mongodb.university:28000")
```

### Checking replica set makeup after adding two new nodes:

```bash
rs.isMaster()
```

### Removing the arbiter from our replica set:

```bash
rs.remove("m103.mongodb.university:28000")
```

### Assigning the current configuration to a shell variable we can edit, in order to reconfigure the replica set:

```js
cfg = rs.conf();
```

### Editing our new variable cfg to change topology - specifically, by modifying cfg.members:

```js
cfg.members[3].votes = 0;
cfg.members[3].hidden = true;
cfg.members[3].priority = 0;
```

### Updating our replica set to use the new configuration cfg:

```bash
rs.reconfig(cfg)
rs.conf()
```

## Questions

- Hidden nodes vote in elections.
- Hidden nodes replicate data.

## Reads and Writes on a Replica Set

### Checking replica set topology:

```bash
rs.isMaster()
```

### Inserting one document into a new collection:

```bash
use newDB
db.new_collection.insert( { "student": "Matt Javaly", "grade": "A+" } )
```

### Connecting directly to a secondary node (this node may not be a secondary in your replica set!):

```bash
mongo --host "m103.mongodb.university:27012" -u "m103-admin" -p "m103-pass"
--authenticationDatabase "admin"
```

### Attempting to execute a read command on a secondary node (this should fail):

```bash
show dbs
```

### Enabling read commands on a secondary node:

```bash
rs.slaveOk()
```

### Reading from a secondary node:

```bash
use newDB
db.new_collection.find()
```

### Shutting down the server (on both secondary nodes)

```bash
use admin
db.shutdownServer()
```

## Questions

- We have to run rs.slaveOk() before we can read from secondary nodes.
- Nodes with higher priority are more likely to be elected primary.
- Nodes with priority 0 cannot be elected primary.

## Write concerns

- "0": Don't wait for acknowledgment
- "1": (Default) - Wait for acknowledgment from the primary only
- ">=2": Wait for acknowledgment from the primary and one or more secondaries
- "majorirty": Wait for acknowledgment from a majority of replica set members

**Options**:

- wtimeout: (int) - The time to wait for the requested write concern before marking the operation as failed.
- j: (true|false) - requires the node to commit the write operation to the journal before returning an acknowledgment

**Write Concern Commands**:

- insert
- update
- delete
- findAndModify

## Recap

- Write Concern is a system of aknowledgment that provides a level of durability guarantee
- The trade off of higher write concern levels is the speed at which write are committed
- MongoDB supports write concern for all cluster types: standalone, replica set, and sharded clusters

## Lab

- When a writeConcernError occurs, the document is still written to the healthy nodes.
- The unhealthy node will be receiving the inserted document when it is brought back online.

## Read Concern

**Read Concern Levels**:

- local
- available (shared clusters)
- majority
- linearizable

### Recap

- Read Concern is a way of requesting data that meets a specified level of durability
- Read Concern options: local/available, majority, and linearizable
- Use with write concern for best durability guarantees

### Questions

Which of the following read concerns only return data from write operations that have been committed to a majority of nodes?

- majority
- linearizable

## Read Preference

**Read Preference Modes**:
- primary (default)
- primaryPreferred
- secondary
- secondaryPreferred
- nearest

### Recap

- Read Preference lets you route read operations to specific replica set members
- Every read preference other than primary can return stale reads
- nearest supports geographically local reads

### Questions

Which of the following read preference options may result in stale data?

- primaryPreferred
- secondary
- secondaryPreferred
- nearest
