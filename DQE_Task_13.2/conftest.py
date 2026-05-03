import os
import yaml
import pytest
import requests
import boto3

from botocore import UNSIGNED
from botocore.config import Config
from google.cloud import storage

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager


def get_config(config_name):
    base_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(base_dir, "Configs", config_name)

    with open(path, "r") as stream:
        return yaml.safe_load(stream)


@pytest.fixture(scope="function")
def driver():
    options = webdriver.ChromeOptions()
    options.add_argument("--start-maximized")

    driver = webdriver.Chrome(
        service=Service(ChromeDriverManager().install()),
        options=options
    )

    yield driver
    driver.quit()


@pytest.fixture(scope="function")
def selenium_config():
    return get_config("config_selenium.yaml")["global"]


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