import os
import logging
import boto3


AUTOMATED_CLUSTER_SNAPSHOT_CREATED = "RDS-EVENT-0169"
MANUAL_CLUSTER_SNAPSHOT_CREATED = "RDS-EVENT-0075"
AUTOMATED_SNAPSHOT_CREATED = "RDS-EVENT-0091"
MANUAL_SNAPSHOT_CREATED = "RDS-EVENT-0042"

BACKUP_S3_BUCKET = os.environ["BACKUP_S3_BUCKET"]
BACKUP_KMS_KEY = os.environ["BACKUP_KMS_KEY"]
BACKUP_EXPORT_ROLE = os.environ["BACKUP_EXPORT_ROLE"]
BACKUP_FOLDER = os.environ["BACKUP_FOLDER"]

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

rds_client = boto3.client("rds")


def lambda_handler(event, context):
    snapshot_arn = event["detail"]["SourceArn"]
    event_id = event["detail"]["EventID"]

    instance_id = None
    snapshot_time = None
    if event_id in [AUTOMATED_SNAPSHOT_CREATED, MANUAL_SNAPSHOT_CREATED]:
        response = rds_client.describe_db_snapshots(DBSnapshotIdentifier=snapshot_arn)
        instance_id = response["DBSnapshots"][0]["DBInstanceIdentifier"]
        snapshot_time = response["DBSnapshots"][0]["SnapshotCreateTime"]

    elif event_id in [
        AUTOMATED_CLUSTER_SNAPSHOT_CREATED,
        MANUAL_CLUSTER_SNAPSHOT_CREATED,
    ]:
        response = rds_client.describe_db_cluster_snapshots(
            DBClusterSnapshotIdentifier=snapshot_arn
        )
        instance_id = response["DBClusterSnapshots"][0]["DBClusterIdentifier"]
        snapshot_time = response["DBClusterSnapshots"][0]["SnapshotCreateTime"]

    else:
        raise RuntimeError(f"Unsupported EventID: {event_id}")

    s3_prefix = f"{BACKUP_FOLDER}/{instance_id}"
    timestamp = snapshot_time.strftime("%y%m%d%H%M")
    sanitized_id = "".join(filter(str.isalnum, instance_id))
    export_id = f"{sanitized_id}-{timestamp}"

    try:
        rds_client.start_export_task(
            ExportTaskIdentifier=export_id,
            SourceArn=snapshot_arn,
            S3BucketName=BACKUP_S3_BUCKET,
            IamRoleArn=BACKUP_EXPORT_ROLE,
            KmsKeyId=BACKUP_KMS_KEY,
            S3Prefix=s3_prefix,
        )
    except Exception as e:
        raise RuntimeError(
            f"Failed to start export task for {snapshot_arn}: {e}"
        ) from e

    logger.info(f"ExportTaskIdentifier={export_id}, SourceArn={snapshot_arn}")
