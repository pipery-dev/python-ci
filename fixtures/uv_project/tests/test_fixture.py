from fixture_uv_project import status


def test_status() -> None:
    assert status() == "uv-ok"
