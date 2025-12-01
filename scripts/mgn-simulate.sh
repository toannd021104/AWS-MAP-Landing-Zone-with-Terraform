#!/bin/bash
# =============================================================================
# AWS MGN Migration Simulation Script
# =============================================================================
# Simulates AWS Application Migration Service workflow for demo purposes
# =============================================================================

set -e

REGION="${AWS_REGION:-ap-southeast-1}"
ACCOUNT_ID="156041411272"
PROJECT="aws-map-landing-zone"
ENV="dev"

# Source Servers (from vCenter)
declare -A SOURCE_SERVERS=(
    ["PROD-WEB-01"]="192.168.1.10|WebServer|CentOS 7|4|8|100|t3.large"
    ["PROD-WEB-02"]="192.168.1.11|WebServer|CentOS 7|4|8|100|t3.large"
    ["PROD-APP-01"]="192.168.1.20|AppServer|CentOS 7|8|16|200|m5.xlarge"
    ["PROD-APP-02"]="192.168.1.21|AppServer|CentOS 7|8|16|200|m5.xlarge"
)

print_aws_header() {
    echo ""
    echo "aws mgn $1 --region $REGION"
    echo "---"
}

generate_source_id() {
    echo "s-$(echo "$1" | md5sum | cut -c1-17)"
}

generate_instance_id() {
    echo "i-$(echo "$1$RANDOM" | md5sum | cut -c1-17)"
}

show_source_servers() {
    print_aws_header "describe-source-servers"

    echo "{"
    echo "    \"items\": ["

    local first=true
    for server in "${!SOURCE_SERVERS[@]}"; do
        IFS='|' read -r ip role os cpu mem disk instance_type <<< "${SOURCE_SERVERS[$server]}"
        local source_id=$(generate_source_id "$server")

        if [ "$first" = true ]; then
            first=false
        else
            echo "        },"
        fi

        cat << EOF
        {
            "sourceServerID": "$source_id",
            "arn": "arn:aws:mgn:$REGION:$ACCOUNT_ID:source-server/$source_id",
            "isArchived": false,
            "tags": {
                "Name": "$server",
                "SourceIP": "$ip",
                "Role": "$role",
                "Datacenter": "DC-HCM"
            },
            "sourceProperties": {
                "identificationHints": {
                    "hostname": "$server",
                    "fqdn": "$server.company.local"
                },
                "os": {
                    "fullString": "$os"
                },
                "cpus": [
                    {
                        "cores": $cpu,
                        "modelName": "Intel(R) Xeon(R) CPU E5-2680 v4"
                    }
                ],
                "ramBytes": $(($mem * 1073741824)),
                "disks": [
                    {
                        "deviceName": "/dev/sda",
                        "bytes": $(($disk * 1073741824))
                    }
                ],
                "networkInterfaces": [
                    {
                        "name": "eth0",
                        "ips": ["$ip"],
                        "macAddress": "00:50:56:$(echo $server | md5sum | cut -c1-2):$(echo $server | md5sum | cut -c3-4):$(echo $server | md5sum | cut -c5-6)"
                    }
                ]
            },
            "dataReplicationInfo": {
                "dataReplicationState": "CONTINUOUS",
                "dataReplicationInitiation": {
                    "startDateTime": "2024-02-01T08:00:00.000Z",
                    "nextAttemptDateTime": null
                },
                "lagDuration": "PT0S",
                "replicatedDisks": [
                    {
                        "deviceName": "/dev/sda",
                        "totalStorageBytes": $(($disk * 1073741824)),
                        "replicatedStorageBytes": $(($disk * 1073741824)),
                        "backloggedStorageBytes": 0
                    }
                ]
            },
            "lifeCycle": {
                "state": "READY_FOR_TEST",
                "addedToServiceDateTime": "2024-02-01T08:00:00.000Z",
                "firstByteDateTime": "2024-02-01T08:05:00.000Z",
                "elapsedReplicationDuration": "P30D"
            },
            "launchStatus": "PENDING"
EOF
    done

    echo "        }"
    echo "    ]"
    echo "}"
}

show_replication_config() {
    print_aws_header "describe-replication-configuration-templates"

    cat << EOF
{
    "items": [
        {
            "replicationConfigurationTemplateID": "rct-$(echo $PROJECT | md5sum | cut -c1-17)",
            "arn": "arn:aws:mgn:$REGION:$ACCOUNT_ID:replication-configuration-template/rct-abc123",
            "stagingAreaSubnetId": "subnet-0e0a8e11ee3ff5640",
            "associateDefaultSecurityGroup": false,
            "replicationServersSecurityGroupsIDs": [
                "sg-0533a936815bb4eff"
            ],
            "replicationServerInstanceType": "t3.small",
            "useDedicatedReplicationServer": false,
            "defaultLargeStagingDiskType": "GP3",
            "ebsEncryption": "DEFAULT",
            "ebsEncryptionKeyArn": null,
            "bandwidthThrottling": 0,
            "dataPlaneRouting": "PRIVATE_IP",
            "createPublicIP": false,
            "stagingAreaTags": {
                "Name": "$PROJECT-$ENV-mgn-staging",
                "Purpose": "MGN-Replication"
            },
            "tags": {
                "Project": "$PROJECT",
                "Environment": "$ENV"
            }
        }
    ]
}
EOF
}

simulate_test_launch() {
    local server=$1
    IFS='|' read -r ip role os cpu mem disk instance_type <<< "${SOURCE_SERVERS[$server]}"
    local source_id=$(generate_source_id "$server")
    local job_id="mgn-test-$(echo $server$RANDOM | md5sum | cut -c1-8)"

    print_aws_header "start-test --source-server-ids $source_id"

    cat << EOF
{
    "job": {
        "jobID": "$job_id",
        "arn": "arn:aws:mgn:$REGION:$ACCOUNT_ID:job/$job_id",
        "type": "LAUNCH",
        "initiatedBy": "START_TEST",
        "status": "PENDING",
        "creationDateTime": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
        "participatingServers": [
            {
                "sourceServerID": "$source_id",
                "launchStatus": "PENDING"
            }
        ]
    }
}
EOF

    echo ""
    echo "Waiting for test instance..."
    sleep 2

    local instance_id=$(generate_instance_id "$server")

    print_aws_header "describe-jobs --filters jobIDs=$job_id"

    cat << EOF
{
    "items": [
        {
            "jobID": "$job_id",
            "type": "LAUNCH",
            "initiatedBy": "START_TEST",
            "status": "COMPLETED",
            "creationDateTime": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
            "endDateTime": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
            "participatingServers": [
                {
                    "sourceServerID": "$source_id",
                    "launchStatus": "LAUNCHED",
                    "launchedEc2InstanceID": "$instance_id"
                }
            ]
        }
    ]
}
EOF

    echo ""
    echo "aws ec2 describe-instances --instance-ids $instance_id --region $REGION"
    echo "---"

    cat << EOF
{
    "Reservations": [
        {
            "Instances": [
                {
                    "InstanceId": "$instance_id",
                    "InstanceType": "$instance_type",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },
                    "PrivateIpAddress": "10.0.$(( RANDOM % 256 )).$(( RANDOM % 256 ))",
                    "SubnetId": "subnet-0e0a8e11ee3ff5640",
                    "VpcId": "vpc-0f0bc4e96e973a9f6",
                    "Tags": [
                        {"Key": "Name", "Value": "$PROJECT-$ENV-$server-test"},
                        {"Key": "MigrationSource", "Value": "vCenter"},
                        {"Key": "SourceVM", "Value": "$server"},
                        {"Key": "SourceIP", "Value": "$ip"},
                        {"Key": "aws:mgn:source-server-id", "Value": "$source_id"}
                    ],
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/sda1",
                            "Ebs": {
                                "VolumeId": "vol-$(echo $server$RANDOM | md5sum | cut -c1-17)",
                                "Status": "attached",
                                "VolumeSize": $disk,
                                "VolumeType": "gp3"
                            }
                        }
                    ]
                }
            ]
        }
    ]
}
EOF
}

simulate_cutover() {
    local server=$1
    IFS='|' read -r ip role os cpu mem disk instance_type <<< "${SOURCE_SERVERS[$server]}"
    local source_id=$(generate_source_id "$server")
    local job_id="mgn-cutover-$(echo $server$RANDOM | md5sum | cut -c1-8)"

    print_aws_header "start-cutover --source-server-ids $source_id"

    cat << EOF
{
    "job": {
        "jobID": "$job_id",
        "type": "LAUNCH",
        "initiatedBy": "START_CUTOVER",
        "status": "PENDING",
        "creationDateTime": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
        "participatingServers": [
            {
                "sourceServerID": "$source_id",
                "launchStatus": "PENDING"
            }
        ]
    }
}
EOF

    echo ""
    echo "Performing final sync and launching cutover instance..."
    sleep 3

    local instance_id=$(generate_instance_id "$server-prod")

    print_aws_header "describe-jobs --filters jobIDs=$job_id"

    cat << EOF
{
    "items": [
        {
            "jobID": "$job_id",
            "type": "LAUNCH",
            "initiatedBy": "START_CUTOVER",
            "status": "COMPLETED",
            "creationDateTime": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
            "endDateTime": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
            "participatingServers": [
                {
                    "sourceServerID": "$source_id",
                    "launchStatus": "LAUNCHED",
                    "launchedEc2InstanceID": "$instance_id"
                }
            ]
        }
    ]
}
EOF

    echo ""
    echo "Cutover completed: $server -> $instance_id"
}

show_migration_status() {
    echo ""
    echo "Migration Status Summary"
    echo "========================"
    echo ""
    printf "%-15s %-20s %-15s %-12s %s\n" "SOURCE" "SOURCE_SERVER_ID" "INSTANCE_TYPE" "STATE" "EC2_INSTANCE"
    printf "%-15s %-20s %-15s %-12s %s\n" "------" "----------------" "-------------" "-----" "-----------"

    for server in "${!SOURCE_SERVERS[@]}"; do
        IFS='|' read -r ip role os cpu mem disk instance_type <<< "${SOURCE_SERVERS[$server]}"
        local source_id=$(generate_source_id "$server")
        local instance_id=$(generate_instance_id "$server")
        printf "%-15s %-20s %-15s %-12s %s\n" "$server" "$source_id" "$instance_type" "CUTOVER" "$instance_id"
    done
    echo ""
}

main() {
    case "${1:-menu}" in
        list)
            show_source_servers
            ;;
        config)
            show_replication_config
            ;;
        test)
            if [ -n "$2" ]; then
                simulate_test_launch "$2"
            else
                for server in "${!SOURCE_SERVERS[@]}"; do
                    simulate_test_launch "$server"
                    echo ""
                done
            fi
            ;;
        cutover)
            if [ -n "$2" ]; then
                simulate_cutover "$2"
            else
                for server in "${!SOURCE_SERVERS[@]}"; do
                    simulate_cutover "$server"
                    echo ""
                done
            fi
            ;;
        status)
            show_migration_status
            ;;
        demo)
            echo "Step 1: List source servers"
            show_source_servers
            echo ""
            echo "Step 2: Show replication configuration"
            show_replication_config
            echo ""
            echo "Step 3: Launch test instances"
            for server in "${!SOURCE_SERVERS[@]}"; do
                simulate_test_launch "$server"
                echo ""
            done
            echo "Step 4: Perform cutover"
            for server in "${!SOURCE_SERVERS[@]}"; do
                simulate_cutover "$server"
                echo ""
            done
            echo "Step 5: Final status"
            show_migration_status
            ;;
        *)
            echo "Usage: $0 {list|config|test [server]|cutover [server]|status|demo}"
            echo ""
            echo "Commands:"
            echo "  list              - List source servers (aws mgn describe-source-servers)"
            echo "  config            - Show replication config"
            echo "  test [server]     - Simulate test launch"
            echo "  cutover [server]  - Simulate cutover"
            echo "  status            - Show migration status"
            echo "  demo              - Run full demo"
            ;;
    esac
}

main "$@"
