import boto3
import pytest
import requests
from botocore import UNSIGNED
from botocore.config import Config
from google.cloud import storage


@pytest.fixture(scope="function")
def provide_config():
    return {
        "prefix": "2024/01/01/KTLX/",
        "gcp_bucket_name": "gcp-public-data-nexrad-l2",
        "aws_bucket_name": "unidata-nexrad-level2",
        "s3_anon_client": boto3.client(
            "s3",
            config=Config(signature_version=UNSIGNED)
        ),
        "gcp_storage_anon_client": storage.Client.create_anonymous_client()
    }


@pytest.fixture(scope="function")
def list_gcs_blobs(provide_config):
    blobs = provide_config["gcp_storage_anon_client"].list_blobs(
        provide_config["gcp_bucket_name"],
        prefix=provide_config["prefix"]
    )
    return [blob.name for blob in blobs]


@pytest.fixture(scope="function")
def list_aws_blobs(provide_config):
    response = provide_config["s3_anon_client"].list_objects_v2(
        Bucket=provide_config["aws_bucket_name"],
        Prefix=provide_config["prefix"]
    )
    return [content["Key"] for content in response.get("Contents", [])]


@pytest.fixture(scope="function")
def provide_posts_data():
    response = requests.get(
        "https://jsonplaceholder.typicode.com/posts",
        params={"userId": 3}
    )

    assert response.status_code == 200
    return response.json()