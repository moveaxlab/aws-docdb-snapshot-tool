'''
Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
'''

# take_snapshots_docdb
# This Lambda function will take snapshots that match the regex set in the PATTERN environment variable. It will also look for a matching timestamp in the following format: YYYY-MM-DD-HH-mm
# Set PATTERN to a regex that matches your docdb Instance identifiersimport boto3
import os
import logging
from snapshots_tool_utils import *

# Init
LOGLEVEL = os.getenv('LOG_LEVEL', 'ERROR').strip()
PATTERN = os.getenv('PATTERN', 'ALL_INSTANCES')
TAGGEDINSTANCE = os.getenv('TAGGEDINSTANCE', 'FALSE')
BACKUP_INTERVAL = int(os.getenv('INTERVAL', '24'))

TIMESTAMP_FORMAT = '%Y-%m-%d-%H-%M'

if os.getenv('REGION_OVERRIDE', 'NO') != 'NO':
    REGION = os.getenv('REGION_OVERRIDE').strip()
else:
    REGION = os.getenv('SOURCE_REGION', 'eu-central-1')

logger = logging.getLogger()
logger.setLevel(LOGLEVEL.upper())

def lambda_handler(event, context):
    client = boto3.client('docdb', region_name=REGION)
    db_instances = paginate_api_call(client, 'describe_db_instances', 'DBInstances')
    filtered_instances = filter_instances(TAGGEDINSTANCE, PATTERN, db_instances)
    now = datetime.now()
    pending_backups = 0

    for db_instance in filtered_instances:

        timestamp_format = now.strftime(TIMESTAMP_FORMAT)

        snapshot_identifier = '%s-%s' % (
            db_instance['DBInstanceIdentifier'], timestamp_format)

        print(snapshot_identifier)
        try:
            response = client.create_db_cluster_snapshot(
                DBClusterSnapshotIdentifier=snapshot_identifier,
                DBClusterIdentifier=db_instance['DBInstanceIdentifier'],
                Tags=[
                    {'Key': 'CreatedBy', 'Value': 'Snapshot Tool for RDS'}, 
                    {'Key': 'CreatedOn', 'Value': timestamp_format},
                    {'Key': 'shareAndCopy', 'Value': 'YES'}
                ]
            )
        except Exception as e:
            pending_backups += 1
            logger.info('Could not create snapshot %s (%s)' % (snapshot_identifier, e))

    if pending_backups > 0:
        log_message = 'Could not back up every instance. Backups pending: %s' % pending_backups
        logger.error(log_message)
        raise SnapshotToolException(log_message)

if __name__ == '__main__':
    lambda_handler(None, None)