"""Unit tests — the 'Test' stage of Build -> Test -> Deploy runs these."""
import app as application


def test_add():
    assert application.add(2, 3) == 5
    assert application.add(-1, 1) == 0


def test_index():
    client = application.app.test_client()
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"


def test_health():
    client = application.app.test_client()
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "healthy"


def test_add_route():
    client = application.app.test_client()
    resp = client.get("/add/4/5")
    assert resp.status_code == 200
    assert resp.get_json()["result"] == 9
