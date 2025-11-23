# Enabling Basic Authentication with Nginx

This guide explains how to restrict access to specific parts of your website using Basic Authentication with Nginx.

> **Note:** This authentication method is supported by Chrome browser. Other browsers may have varying levels of support or behavior.

## 1. Install `htpasswd`

**On Ubuntu/Debian:**
```sh
sudo apt-get install apache2-utils
```

**On CentOS/RHEL:**
```sh
sudo yum install httpd-tools
```

## 2. Create a Password File

Replace `your_username` with your desired username:

```sh
sudo htpasswd -c /etc/nginx/.htpasswd your_username
```

- The `-c` flag creates the file. Omit it if you're adding more users later.
- You'll be prompted to enter a password.

## 3. Configure Nginx

Edit your Nginx server block (e.g., `/etc/nginx/sites-available/default` or your custom config):

```nginx
location /secure/ {
    auth_basic "Restricted Content";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

- Replace `/secure/` with the path you want to protect.
- To protect the entire site, use `/` instead of `/secure/`.

## 4. Reload Nginx

Test and reload the Nginx configuration:

```sh
sudo nginx -t  # Test configuration
sudo nginx -s reload  # Reload config
```

---

Now, when you access the protected path, your browser will prompt for a username and password.
