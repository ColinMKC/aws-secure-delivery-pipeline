"""Minimal Lambda handler. Deliberately tiny: the pipeline is the project, not the app."""

import json
import os


def handler(event, context):
    # TODO (Stage 2 exercise): plant a Semgrep finding here on a branch,
    # e.g. subprocess with shell=True on user input, watch CI fail, then remove it.
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(
            {
                "service": "aws-secure-delivery-pipeline",
                "version": os.environ.get("APP_VERSION", "dev"),
                "status": "ok",
            }
        ),
    }


if __name__ == "__main__":
    print(handler({}, None))
