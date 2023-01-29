import json
import logging
import os
from datetime import datetime
from typing import Dict, List, TypedDict

import boto3
from pytz import timezone

# ========== Environment Variables to be configured ==========
TIMEZONE = os.getenv("TIMEZONE", "UTC")

logger = logging.getLogger()
logger.setLevel(logging.INFO)
ec2 = boto3.client("ec2")


class EC2Instance(TypedDict):
    id: str
    name: str


def lambda_handler(event: Dict, context: Dict):
    logger.info(f"Input: {json.dumps(event)}")

    current_hour = str(datetime.now(tz=timezone(TIMEZONE)).hour)

    logger.info(f"current hour: {current_hour}")

    stop_instances(current_hour)
    start_instances(current_hour)


def stop_instances(current_hour: str):
    instances = get_instances_by_tag("AutoStopTime", current_hour)
    if not instances:
        logger.info("no instances to stop.")
        return

    logger.info(f"{len(instances)} instances to stop.")
    for i in instances:
        logger.info(f'id: {i["id"]}, name: {i["name"]}')

    instance_ids = [i["id"] for i in instances]
    response = ec2.stop_instances(InstanceIds=instance_ids)
    logger.info(response)


def start_instances(current_hour: str):
    instances = get_instances_by_tag("AutoStartTime", current_hour)
    if not instances:
        logger.info("no instances to start.")
        return

    logger.info(f"{len(instances)} instances to start.")
    for i in instances:
        logger.info(f'id: {i["id"]}, name: {i["name"]}')

    instance_ids = [i["id"] for i in instances]
    response = ec2.start_instances(InstanceIds=instance_ids)
    logger.info(response)


def get_instances_by_tag(name, value) -> List[EC2Instance]:
    reservations = ec2.describe_instances(Filters=[{"Name": f"tag:{name}", "Values": [value]}]).get("Reservations", [])

    instances = []
    for r in reservations:
        for i in r["Instances"]:
            name = next(t for t in i["Tags"] if t["Key"] == "Name")
            instances.append({"id": i["InstanceId"], "name": name})

    return instances
