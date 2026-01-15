# external_url 'http://gitlab.example.com:8089'

# gitlab_rails['gitlab_shell_ssh_port'] = 22
gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password').gsub("\n", "")

# Optimize for low memory
# prometheus_monitoring['enable'] = false
# puma['worker_processes'] = 2
# sidekiq['max_concurrency'] = 10

# gitlab_rails['smtp_enable'] = true
# gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
# gitlab_rails['smtp_port'] = 465
# gitlab_rails['smtp_user_name'] = "xxxx@xx.com"
# gitlab_rails['smtp_password'] = "password"
# gitlab_rails['smtp_authentication'] = "login"
# gitlab_rails['smtp_enable_starttls_auto'] = false
# gitlab_rails['smtp_tls'] = true
# gitlab_rails['gitlab_email_from'] = 'xxxx@xx.com'
# gitlab_rails['smtp_domain'] = "exmail.qq.com"


# 禁用注册审批
# gitlab_rails['gitlab_account_approval_required'] = false

# https://docs.gitlab.com/omnibus/settings/nginx/
# nginx['listen_port'] = 80
# nginx['listen_https'] = false   # 因为外部 Nginx 已处理 HTTPS
