# -*- coding: utf-8 -*-
import requests
import json
import base64
import time
import datetime
import os
from markdown2 import markdown

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

def get_domain():
    """获取昨天的域名列表 Markdown 文件并返回标题和内容"""
    try:
        # 获取昨天的日期，格式为 YYYYMMDD
        today = datetime.datetime.now().strftime('%Y%m%d')
        
        # 构建 Markdown 文件 URL
        markdown_url = f'https://raw.githubusercontent.com/flydo/available-domain/refs/heads/main/daily/{today}.md'
        
        # 发送请求
        response = requests.get(markdown_url, timeout=10)
        response.raise_for_status()  # 检查请求是否成功
        
        content = response.text
        title = f"{today} 可注册的 CN/TOP 域名列表"
        
        return {"title": title, "content": markdown(content)}
    
    except requests.RequestException as e:
        print(f"无法获取 Markdown 文件: {e}")
        return None

def main():
    # 配置信息
    site_url = os.environ.get("WORDPRESS_URL")
    username = os.environ.get("WORDPRESS_USERNAME")
    app_password = os.environ.get("WORDPRESS_APP_PASSWORD")
    category_id = os.environ.get("WORDPRESS_CATEGORY_ID", 1)

    # 检查配置是否完整
    if not site_url or not username or not app_password or not category_id:
        print("环境变量未设置完整")
        exit(1)

    # 获取域名列表
    domain = get_domain()
    if domain is None:
        print("无法获取域名列表，程序退出")
        exit(1)

    # 发布文章
    result = publish_post(
        site_url,
        username,
        app_password,
        domain["title"],
        domain["content"],
        category_id
    )
    
    if result:
        print(f"文章 ID: {result.get('id')}, 链接: {result.get('link')}")

if __name__ == "__main__":
    main()
    