'''
Copyright 2017  Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
'''

# copy_snapshots_dest_docdb
# This lambda function will copy shared docdb snapshots that match the regex specified in the environment variable SNAPSHOT_PATTERN, into the account where it runs. If the snapshot is shared and exists in the local region, it will copy it to the region specified in the environment variable DEST_REGION. If it finds that the snapshots are shared, exist in the local and destination regions, it will delete them from the local region. Copying snapshots cross-account and cross-region need to be separate operations. This function will need to run as many times necessary for the workflow to complete.
# Set SNAPSHOT_PATTERN to a regex that matches your docdb Instance identifiers
# Set DEST_REGION to the destination AWS region
import boto3
import os
import logging
from snapshots_tool_utils import *

# Initialize everything
LOGLEVEL = os.getenv('LOG_LEVEL', 'INFO').strip()
PATTERN = os.getenv('SNAPSHOT_PATTERN', 'ALL_SNAPSHOTS')
DESTINATION_REGION = os.getenv('DEST_REGION', 'eu-west-1').strip()
RETENTION_DAYS = int(os.getenv('RETENTION_DAYS', '7'))

if os.getenv('REGION_OVERRIDE', 'NO') != 'NO':
    REGION = os.getenv('REGION_OVERRIDE').strip()
else:
    REGION = os.getenv('SOURCE_REGION', 'eu-central-1')


logger = logging.getLogger()
logger.setLevel(LOGLEVEL.upper())


def lambda_handler(event, context):
    # Describe all snapshots
    pending_copies = 0
    client = boto3.client('docdb', region_name=REGION)
    db_snapshots = paginate_api_call(client, 'describe_db_cluster_snapshots', 'DBClusterSnapshots', IncludeShared=True)

    #shared_snapshots = get_shared_snapshots(PATTERN, db_snapshots)
    source_snapshots = get_own_snapshots_dest(PATTERN, db_snapshots)

    # Get list of snapshots in DEST_REGION
    client_dest = boto3.client('rds', region_name=DESTINATION_REGION)
    db_snapshots_dest = paginate_api_call(client_dest, 'describe_db_cluster_snapshots', 'DBClusterSnapshots')
    dest_snapshots = get_own_snapshots_dest(PATTERN, db_snapshots_dest)

    for snap_identifier, snap_attributes in source_snapshots.items():

        if snap_identifier.replace(":", "-") not in dest_snapshots.keys():
            if source_snapshots[snap_identifier]['Status'] == 'available':
                try:
                    copy_remote(snap_identifier, source_snapshots[snap_identifier])

                except Exception as e:
                    pending_copies += 1
                    logger.error('Remote copy pending: %s: %s (%s)' % (
                        snap_identifier, source_snapshots[snap_identifier]['Arn'], e))
            else:
                pending_copies += 1
                logger.error('Remote copy pending: %s: %s' % (
                    snap_identifier, source_snapshots[snap_identifier]['Arn']))

    if pending_copies > 0:
        log_message = 'Copies pending: %s. Needs retrying' % pending_copies
        logger.error(log_message)
        raise SnapshotToolException(log_message)


if __name__ == '__main__':
    lambda_handler(None, None)
