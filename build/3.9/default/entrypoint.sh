#!/usr/bin/env bash

set -e

template_directory="/usr/share/etki/aerospike"

SERVICE_THREADS=${SERVICE_THREADS:="4"}
TRANSACTION_QUEUES=${TRANSACTION_QUEUES:="4"}
TRANSACTION_THREADS_PER_QUEUE=${TRANSACTION_THREADS_PER_QUEUE:="4"}
PAXOS_SINGLE_REPLICA_LIMIT=${PAXOS_SINGLE_REPLICA_LIMIT:="1"}
PROTO_FD_MAX=${PROTO_FD_MAX:="15000"}

FILE_LOG_ENABLED=${FILE_LOG_ENABLED:="false"}
FILE_LOG_PATH=${FILE_LOG_PATH:="/var/log/aerospike/aerospike.log"}

HEARTBEAT_MODE=${HEARTBEAT_MODE:="mesh"}
NETWORK_ACCESS_ADDRESS=${NETWORK_ACCESS_ADDRESS:=""}
HEARTBEAT_INTERFACE_ADDRESS=${HEARTBEAT_INTERFACE_ADDRESS:=""}
HEARTBEAT_INTERVAL=${HEARTBEAT_INTERVAL:="150"}
HEARTBEAT_TIMEOUT=${HEARTBEAT_TIMEOUT:="10"}
HEARTBEAT_MESH_ADDRESSES=${HEARTBEAT_MESH_ADDRESSES:=""}

NAMESPACE_ID=${NAMESPACE_ID:="default"}
NAMESPACE_REPLICATION_FACTOR=${REPLICATION_FACTOR:="2"}
NAMESPACE_MEMORY_SIZE=${MEMORY_SIZE:="1G"}
NAMESPACE_DEFAULT_TTL=${DEFAULT_TTL:="5d"}
NAMESPACE_STORAGE_TYPE=${NAMESPACE_STORAGE_TYPE:="device"}
NAMESPACE_STORAGE_SIZE=${NAMESPACE_STORAGE_SIZE:="4G"}
NAMESPACE_STORAGE_STORE_DATA_IN_MEMORY=${NAMESPACE_STORAGE_STORE_DATA_IN_MEMORY:="true"}\

file_log_stanza=""
if [ "$FILE_LOG_ENABLED" == "true" ]; then
    file_log_stanza=$(cat "${template_directory}/file-log-stanza.twig" | sed "s@{{ file_log.path }}@${FILE_LOG_PATH}@g")
fi

network_address_stanza=""
if [ "$NETWORK_ACCESS_ADDRESS" != "" ]; then
    network_address_stanza=$(
        echo "${template_directory}/network.address-stanza.twig" \
        | sed "s@{{ network.access_address }}@${NETWORK_ACCESS_ADDRESS}@g"
    )
fi

heartbeat_interface_address_stanza=""
if [ "$HEARTBEAT_INTERFACE_ADDRESS" != "" ]; then
    heartbeat_interface_address_stanza=$(
        echo "${template_directory}/heartbeat.interface-address-stanza.twig" \
        | sed "s@{{ heartbeat.address }}@${HEARTBEAT_INTERFACE_ADDRESS}@g"
    )
fi

heartbeat_mesh_addresses_stanza=""
if [ "$HEARTBEAT_MESH_ADDRESSES" != "" ]; then
    for address in $(echo "${HEARTBEAT_MESH_ADDRESSES}" | tr "," "\n"); do
        if [ "$address" != "" ]; then
            address_line=$(
                cat "${template_directory}/heartbeat.mesh-address-stanza.twig" \
                | sed "s@{{ heartbeat.mesh_address }}@${address}@g"
            )
            heartbeat_mesh_addresses_stanza="${heartbeat_mesh_addresses_stanza}\n${address_line}"
        fi
    done
fi

namespace_storage_stanza_template=$(cat "${template_directory}/${NAMESPACE_STORAGE_TYPE}-storage-stanza.twig")
namespace_storage_stanza=$(
    echo "$namespace_storage_stanza_template" \
    | sed "s@{{ storage.size }}@${NAMESPACE_STORAGE_SIZE}@g" \
    | sed "s@{{ storage.store_data_in_memory }}@${NAMESPACE_STORAGE_STORE_DATA_IN_MEMORY}@g"
)

echo "Generating Aerospike configuration"
configuration=$(cat "${template_directory}/aerospike.conf.twig")
configuration="${configuration/'{{ service_threads }}'/$SERVICE_THREADS}"
configuration="${configuration/'{{ transaction_queues }}'/$TRANSACTION_QUEUES}"
configuration="${configuration/'{{ transaction_threads_per_queue }}'/$TRANSACTION_THREADS_PER_QUEUE}"
configuration="${configuration/'{{ paxos_single_replica_limit }}'/$PAXOS_SINGLE_REPLICA_LIMIT}"
configuration="${configuration/'{{ proto_fd_max }}'/$PROTO_FD_MAX}"

configuration="${configuration/'{{ file_log_stanza }}'/$file_log_stanza}"

configuration="${configuration/'{{ network.access_address_stanza }}'/$network_address_stanza}"

configuration="${configuration/'{{ heartbeat.mode }}'/$HEARTBEAT_MODE}"
configuration="${configuration/'{{ heartbeat.interface_address_stanza }}'/$heartbeat_interface_address_stanza}"
configuration="${configuration/'{{ heartbeat.mesh_addresses_stanza }}'/$heartbeat_mesh_addresses_stanza}"
configuration="${configuration/'{{ heartbeat.interval }}'/$HEARTBEAT_INTERVAL}"
configuration="${configuration/'{{ heartbeat.timeout }}'/$HEARTBEAT_TIMEOUT}"

configuration="${configuration/'{{ namespace.id }}'/$NAMESPACE_ID}"
configuration="${configuration/'{{ namespace.replication_factor }}'/$NAMESPACE_REPLICATION_FACTOR}"
configuration="${configuration/'{{ namespace.memory_size }}'/$NAMESPACE_MEMORY_SIZE}"
configuration="${configuration/'{{ namespace.default_ttl }}'/$NAMESPACE_DEFAULT_TTL}"
configuration="${configuration/'{{ namespace.storage_stanza }}'/$namespace_storage_stanza}"

echo "$configuration" > "/etc/aerospike/aerospike.conf"

exec /usr/bin/asd --foreground