# Snapshot Tool for Amazon DOCDB

The Snapshot Tool for DOCDB automates the task of creating manual snapshots, copying them into a different account and a different region, and deleting them after a specified number of days. It also allows you to specify the backup schedule (at what times and how often) and a retention period in days.

## How to use on Terragrunt
1. Create a copy of *terraform/_modules/docdb-snapshot_tool* folder inside your project directory.
2. Create a copy of *terraform/env* folder inside your project directory.
3. Edit *terraform/env/env.hcl* file so that it matches your configuration.
4. Inside *terraform/env/env.hcl* file specify cloudformation template (inside *docdb_snapshot_tools/cftemplates* folder) that best fits your needs.

## How to select the right CloudFormation Template
Inside *terraform/env/env.hcl* file specify cloudformation template (inside *docdb_snapshot_tools/cftemplates* folder) that best fits your needs.\
Possibilities are:
* snapshot_tool_docdb.json: provides take, copy and delete methods
* snapshot_tool_docdb_copy_and_delete.json: provides only copy and delete methods

## To Be Implemented
Create new template that enables delete of old snapshot in both regions.