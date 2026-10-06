from urllib.parse import parse_qs

import pytest

import backlog
from common import ApiError

HOST = "example.backlog.com"
API = f"https://{HOST}/api/v2"
KEY = "dummy-api-key-456"
LINK = f"https://{HOST}/view/ABC-12"

ISSUE = {"issueKey": "ABC-12", "summary": "ログイン画面の文言の修正", "description": "ボタンの文言を直してください",
         "status": {"name": "未対応"}, "assignee": None, "dueDate": "2026-10-08T00:00:00Z",
         "createdUser": {"name": "山田"}, "created": "2026-10-06T01:00:00Z"}


def comment(n, content="確認お願いします", change_log=()):
    return {"id": n, "content": content, "createdUser": {"name": "佐藤"},
            "created": "2026-10-06T02:00:00Z", "changeLog": list(change_log)}


def comments_url(min_id=None):
    query = "count=100&order=asc" + (f"&minId={min_id}" if min_id is not None else "")
    return ("GET", f"{API}/issues/ABC-12/comments?{query}")


@pytest.fixture(autouse=True)
def allowed_space(monkeypatch):
    monkeypatch.setenv("BACKLOG_SPACE", HOST)


@pytest.fixture
def fetch(fake_api):
    """課題の取得は共通にし、コメントの返り方だけを場面ごとに渡す。"""
    def run(routes, link=LINK):
        api = fake_api({("GET", f"{API}/issues/ABC-12"): ISSUE, **routes})
        return backlog.fetch(link, KEY), api
    return run


# --- リンク ---

def test_issue_link():
    assert backlog.parse_link(LINK) == (HOST, "ABC-12", None)


def test_comment_link_on_jp():
    assert backlog.parse_link("https://example.backlog.jp/view/ABC_X-3#comment-77") == \
        ("example.backlog.jp", "ABC_X-3", 77)


def test_project_key_may_start_with_digit():
    assert backlog.parse_link("https://example.backlog.com/view/12X34-567") == (HOST, "12X34-567", None)


def test_other_text_is_rejected():
    with pytest.raises(ApiError, match="Backlog の課題のリンクではありません"):
        backlog.parse_link("https://example.com/view/ABC-12")


# --- 取得 ---

def test_shows_issue_and_comments(fetch):
    out, api = fetch({comments_url(): [comment(1), comment(2, "対応します")]})
    assert "課題: ABC-12 ログイン画面の文言の修正" in out
    assert "状態: 未対応 / 担当: 未設定 / 期限: 2026-10-08" in out
    assert "起票: 山田 2026-10-06 10:00" in out
    assert "ボタンの文言を直してください" in out
    assert "## コメント（古い順、2 件）" in out
    assert "対応します" in out
    assert all("apiKey=dummy-api-key-456" in r.full_url for r in api.requests)


def test_comment_link_marks_the_request(fetch):
    out, _ = fetch({comments_url(): [comment(1), comment(2)]}, link=LINK + "#comment-2")
    assert "（comment_id 2） ← 依頼の本体" in out
    assert "（comment_id 1） ← 依頼の本体" not in out


def test_missing_linked_comment_is_noted(fetch):
    out, _ = fetch({comments_url(): [comment(1)]}, link=LINK + "#comment-9")
    assert "リンクのコメント（ID 9）が見つかりません" in out


def test_change_only_comment(fetch):
    change = {"field": "status", "originalValue": "未対応", "newValue": "処理中"}
    out, _ = fetch({comments_url(): [comment(1, content="", change_log=[change])]})
    assert "（変更のみ）status: 未対応 → 処理中" in out


def test_follows_pages_beyond_100_comments(fetch):
    # minId が「以上」か「より大きい」かは資料に書かれていない。どちらでも抜けず重ならないよう、
    # 前のページの最後の ID から取り直し、取得済みの ID を捨てる
    out, api = fetch({comments_url(): [comment(n) for n in range(1, 101)],
                      comments_url(min_id=100): [comment(100), comment(101)]})
    assert "## コメント（古い順、101 件）" in out
    assert out.count("（comment_id 100）") == 1
    assert len(api.requests) == 3


def test_stops_when_a_full_page_brings_nothing_new(fetch):
    page = [comment(n) for n in range(1, 101)]
    out, api = fetch({comments_url(): page, comments_url(min_id=100): [comment(100)] * 100})
    assert "## コメント（古い順、100 件）" in out
    assert len(api.requests) == 3


def test_error_message_has_no_api_key(fake_api):
    fake_api({("GET", f"{API}/issues/ABC-12"): 401})
    with pytest.raises(ApiError) as e:
        backlog.fetch(LINK, KEY)
    assert KEY not in str(e.value)
    assert HOST not in str(e.value)


# --- コメント ---

def test_comment_returns_link(fake_api, tmp_path):
    body = tmp_path / "body.txt"
    body.write_text("対応しました。", encoding="utf-8")
    api = fake_api({("POST", f"{API}/issues/ABC-12/comments"): {"id": 55}})
    assert backlog.comment(LINK + "#comment-2", body, KEY) == f"コメントしました: https://{HOST}/view/ABC-12#comment-55"
    assert parse_qs(api.requests[0].data.decode("utf-8")) == {"content": ["対応しました。"]}


# --- 送り先のスペース ---

def test_other_space_is_refused_before_sending(fake_api):
    api = fake_api({})
    with pytest.raises(ApiError, match="許可していない Backlog のスペースです（other.backlog.com）"):
        backlog.fetch("https://other.backlog.com/view/ABC-12", KEY)
    assert api.requests == []


def test_comment_to_other_space_is_refused(fake_api, tmp_path):
    body = tmp_path / "body.txt"
    body.write_text("対応しました。", encoding="utf-8")
    api = fake_api({})
    with pytest.raises(ApiError, match="許可していない"):
        backlog.comment("https://other.backlog.com/view/ABC-12", body, KEY)
    assert api.requests == []


def test_several_spaces_can_be_allowed(monkeypatch, fetch):
    monkeypatch.setenv("BACKLOG_SPACE", f"other.backlog.jp, {HOST}")
    out, _ = fetch({comments_url(): []})
    assert "課題: ABC-12" in out


def test_missing_space_setting(monkeypatch):
    monkeypatch.delenv("BACKLOG_SPACE")
    with pytest.raises(ApiError, match="環境変数 BACKLOG_SPACE がありません"):
        backlog.fetch(LINK, KEY)
