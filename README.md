# Slightly Modified Aerospike

This project spins off library Aerospike Docker image and only adds a
way to configure Aerospike via environmental variables, generating 
configuration just-in-time right before service start; everything else 
is quite the same. Following environmental variables are available:

| Variable                                 | Aerospike Configuration Option                      | Default Value                        | Notes |
|------------------------------------------|-----------------------------------------------------|--------------------------------------|-------|
| `SERVICE_THREADS`                        | `service.service_threads`                           | `"4"`                                |       |
| `TRANSACTION_QUEUES`                     | `service.transaction-queues`                        | `"4"`                                |       |
| `TRANSACTION_THREADS_PER_QUEUE`          | `service.transaction-threads-per-queue`             | `"4"`                                |       |
| `PAXOS_SINGLE_REPLICA_LIMIT`             | `service.paxos-single-replica-limit`                | `"1"`                                |       |
| `PROTO_FD_MAX`                           | `service.proto-fd-max`                              | `"15000"`                            |       |
| `FILE_LOG_ENABLED`                       | -                                                   | `"false"`                            |       |
| `FILE_LOG_PATH`                          | `service.logging.file[path]`                        | `"/var/log/aerospike/aerospike.log"` |       |
| `NETWORK_ACCESS_ADDRESS`                 | `network.access-address`                            | `""`                                 |       |
| `HEARTBEAT_MODE`                         | `network.heartbeat.mode`                            | `"mesh"`                             |       |
| `HEARTBEAT_INTERFACE_ADDRESS`            | `network.heartbeat.interface-address`               | `""`                                 |       |
| `HEARTBEAT_INTERVAL`                     | `network.heartbeat.interval`                        | `"150"`                              |       |
| `HEARTBEAT_TIMEOUT`                      | `network.heartbeat.timeout`                         | `"10"`                               |       |
| `HEARTBEAT_MESH_ADDRESSES`               | `network.heartbeat.mesh-seed-address-port`          | `""`                                 | Comma-separated values of IPs, subject to change in future releases |
| `NAMESPACE_ID`                           | `namespace[id]`                                     | `"default"`                          |       |
| `NAMESPACE_REPLICATION_FACTOR`           | `namespace[id].replication-factor`                  | `"2"`                                |       |
| `NAMESPACE_MEMORY_SIZE`                  | `namespace[id].memory-size`                         | `"1G"`                               |       |
| `NAMESPACE_DEFAULT_TTL`                  | `namespace[id].default-ttl`                         | `"5d"`                               |       |
| `NAMESPACE_STORAGE_TYPE`                 | `namespace[id].storage-engine[type]`                | `"device"`                           |       |
| `NAMESPACE_STORAGE_SIZE`                 | `namespace[id].storage-engine[type].filesize`       | `"4G"`                               |       |
| `NAMESPACE_STORAGE_STORE_DATA_IN_MEMORY` | `namespace[id].storage-engine[type].data-in-memory` | `"true"`                             |       |

Please note that this is not stable release and those variables may be 
renamed.