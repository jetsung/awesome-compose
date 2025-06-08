# -*- coding: utf-8 -*-
import requests
import json
import base64
import time

# 发布文章
def publish_post(site_url, username, app_password, title, content, category_id=1, status="publish"):
    session = requests.Session()
    url = f"{site_url}/wp-json/wp/v2/posts"
    
    # 使用应用程序密码进行 Basic Auth
    auth_string = f"{username}:{app_password}"
    auth_encoded = base64.b64encode(auth_string.encode()).decode()
    headers = {
        "User-Agent": "Mozilla/5.0",
        "Authorization": f"Basic {auth_encoded}",
        "Content-Type": "application/json"
    }
    
    data = {
        "title": title,
        "content": content,
        "status": status,  # 可选：publish, draft, private
        "categories": [category_id],  # 分类 ID
        "date": time.strftime('%Y-%m-%d %H:%M:%S', time.localtime()),
        "date_gmt": time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime())
    }
    
    try:
        response = session.post(url, json=data, headers=headers, timeout=10)
        response.raise_for_status()
        print("文章发布成功！")
        return json.loads(response.content)
    except requests.RequestException as e:
        print(f"文章发布失败: {e}")
        return None

if __name__ == "__main__":
    # 配置信息
    SITE_URL = "http://127.0.0.1:8080"  # 替换为你的 WordPress 站点地址
    USERNAME = "robot"  # 替换为你的 WordPress 用户名
    APP_PASSWORD = "sypK VwzF ckCG JFnX xrCn T2UH"  # 替换为你的应用程序密码
    POST_TITLE = "通过 REST API 和应用程序密码发布的测试文章"
    POST_CONTENT = "这是一篇通过 Python 和 WordPress REST API 自动发布的文章内容。"
    CATEGORY_ID = 1  # 替换为你的分类 ID

    # 发布文章
    publish_post(SITE_URL, USERNAME, APP_PASSWORD, POST_TITLE, POST_CONTENT, CATEGORY_ID)