from fixture_poetry_project import salute


def test_salute() -> None:
    assert salute("workflow") == "hello workflow"
