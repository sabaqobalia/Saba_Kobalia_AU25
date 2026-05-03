import pytest


@pytest.mark.smoke
@pytest.mark.integration
def test_user_with_posts(provide_posts_data):
    posts = provide_posts_data

    assert len(posts) == 10

    for post in posts:
        assert post["userId"] == 3


@pytest.mark.smoke
@pytest.mark.integration
def test_data_is_presented_between_staging_raw(list_gcs_blobs, list_aws_blobs):
    assert len(list_gcs_blobs) > 0
    assert len(list_aws_blobs) > 0