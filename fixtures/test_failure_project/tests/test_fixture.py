from fixture_test_failure_project import meaning


def test_intentional_failure() -> None:
    assert meaning() == 0
