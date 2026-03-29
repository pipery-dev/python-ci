from fixture_pip_project import meaning


def test_meaning() -> None:
    assert meaning() == 42
