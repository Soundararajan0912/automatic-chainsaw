# PostgreSQL Read-Only User Setup Guide

## 🔐 Prerequisites

Before proceeding with this guide, ensure you have:

- **Admin credentials** for your PostgreSQL database
- **PostgreSQL version 15+** (required for `pg_read_all_data` role support)
- **psql client** installed (tested with version 17.4)

> **Note**: This guide was tested with `psql (PostgreSQL) 17.4 (Ubuntu 17.4-1.pgdg24.04+2)`

---

## 🧭 Step 1: Verify the Built-in Read-Only Role

PostgreSQL 15 and later versions include a default role called `pg_read_all_data`, which provides read-only access to all tables across all schemas.

### ✅ Check if the role exists

Connect to your PostgreSQL instance and run:

```sql
\du
```

Or query the system catalog:

```sql
SELECT rolname FROM pg_roles WHERE rolname = 'pg_read_all_data';
```

**Expected Output:**

If the role exists, you'll see `pg_read_all_data` listed in the output.

---

## 👤 Step 2: Create a Read-Only User with a Password

Create a new database role that can log in to the database.

```sql
CREATE ROLE postgres_readonly WITH LOGIN PASSWORD 'your_secure_password';
```

### 🔒 Security Best Practices

- Replace `postgres_readonly` with your desired username
- Replace `'your_secure_password'` with a strong, unique password
- **Never use default or example passwords in production environments**

---

## 🔗 Step 3: Grant Read-Only Access

Assign the built-in read-only role to your newly created user:

```sql
GRANT pg_read_all_data TO postgres_readonly;
```

This command allows the `postgres_readonly` user to inherit all read-only privileges from the `pg_read_all_data` role, providing:

- **SELECT** access to all tables
- **SELECT** access to all views
- **SELECT** access to all sequences
- Access across **all schemas** in the current database

### ✅ Verify the Grant

To confirm the privileges were granted successfully:

```sql
\du postgres_readonly
```

You should see `pg_read_all_data` listed in the member of column.

---

## 📂 Optional: Grant Access Across Multiple Databases

If you manage multiple databases and want to automate granting read-only access, you can use a shell script with admin credentials.

### Bash Script for Multi-Database Access

Create a file named `grant_readonly_access.sh`:

```bash
#!/bin/bash

# =============================================================================
# PostgreSQL Read-Only User Setup Script
# =============================================================================
# This script creates a read-only user and grants SELECT privileges across
# multiple databases.
# =============================================================================

# Admin connection details
DB_HOST="your-db-host"
DB_PORT="5432"
DB_ADMIN_USER="your-admin-username"
DB_ADMIN_PASSWORD="your-admin-password"

# Export environment variables for psql
export PGHOST=$DB_HOST
export PGPORT=$DB_PORT
export PGUSER=$DB_ADMIN_USER
export PGPASSWORD=$DB_ADMIN_PASSWORD

# Read-only user credentials
READONLY_USER="readonly_user"
READONLY_PASSWORD="readonly_password"

# =============================================================================
# Step 1: Create the read-only user if it doesn't exist
# =============================================================================
echo "Creating read-only user: $READONLY_USER"

psql -d postgres -c "DO \$\$ 
BEGIN 
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$READONLY_USER') THEN 
    CREATE ROLE \"$READONLY_USER\" LOGIN PASSWORD '$READONLY_PASSWORD'; 
    RAISE NOTICE 'User % created successfully', '$READONLY_USER';
  ELSE
    RAISE NOTICE 'User % already exists', '$READONLY_USER';
  END IF; 
END 
\$\$;"

# =============================================================================
# Step 2: List of target databases
# =============================================================================
databases=(
  "database_one"
  "database_two"
  "database_three"
  # Add more databases as needed
)

# =============================================================================
# Step 3: Grant privileges to the read-only user
# =============================================================================
for db in "${databases[@]}"; do
  echo "=========================================="
  echo "Granting privileges on database: $db"
  echo "=========================================="
  
  psql -d "$db" <<EOF
    -- Grant connection privileges
    GRANT CONNECT ON DATABASE "$db" TO "$READONLY_USER";
    
    -- Grant usage on public schema
    GRANT USAGE ON SCHEMA public TO "$READONLY_USER";
    
    -- Grant SELECT on all existing tables
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO "$READONLY_USER";
    
    -- Grant SELECT on all existing sequences
    GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "$READONLY_USER";
    
    -- Set default privileges for future tables
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "$READONLY_USER";
    
    -- Set default privileges for future sequences
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO "$READONLY_USER";
EOF
  
  if [ $? -eq 0 ]; then
    echo "✅ Successfully granted privileges on $db"
  else
    echo "❌ Failed to grant privileges on $db"
  fi
  echo ""
done

echo "=========================================="
echo "Read-only user setup completed!"
echo "=========================================="
```

### 🚀 How to Use the Script

1. **Save the script** to a file named `grant_readonly_access.sh`

2. **Update the configuration** with your actual values:
   - `DB_HOST`: Your PostgreSQL server hostname or IP
   - `DB_PORT`: PostgreSQL port (default: 5432)
   - `DB_ADMIN_USER`: Admin username
   - `DB_ADMIN_PASSWORD`: Admin password
   - `READONLY_USER`: Desired read-only username
   - `READONLY_PASSWORD`: Desired read-only password
   - `databases`: Array of database names

3. **Make the script executable**:
   ```bash
   chmod +x grant_readonly_access.sh
   ```

4. **Run the script**:
   ```bash
   ./grant_readonly_access.sh
   ```

### 🔍 Key Components Explained

| Component | Description |
|-----------|-------------|
| **Admin Connection Setup** | Uses environment variables (`PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`) to securely pass admin credentials to `psql` |
| **User Creation Block** | Checks if the read-only user exists using a PL/pgSQL `DO` block; creates the user if it doesn't exist |
| **Database List** | An array of database names where read-only access should be granted |
| **Privilege Granting Loop** | Iterates through each database and grants:<br>• Connection rights<br>• Schema usage<br>• SELECT access on existing tables and sequences<br>• Default privileges for future tables and sequences |

---

## 🔐 Alternative: Using pg_read_all_data Role

For PostgreSQL 15+, you can also use the built-in `pg_read_all_data` role instead of manually granting SELECT privileges:

```bash
#!/bin/bash

# Admin connection details
DB_HOST="your-db-host"
DB_PORT="5432"
DB_ADMIN_USER="your-admin-username"
DB_ADMIN_PASSWORD="your-admin-password"

export PGHOST=$DB_HOST
export PGPORT=$DB_PORT
export PGUSER=$DB_ADMIN_USER
export PGPASSWORD=$DB_ADMIN_PASSWORD

READONLY_USER="readonly_user"
READONLY_PASSWORD="readonly_password"

# Create the read-only user
psql -d postgres -c "DO \$\$ 
BEGIN 
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$READONLY_USER') THEN 
    CREATE ROLE \"$READONLY_USER\" LOGIN PASSWORD '$READONLY_PASSWORD'; 
  END IF; 
END 
\$\$;"

# List of target databases
databases=(
  "database_one"
  "database_two"
  "database_three"
)

# Grant pg_read_all_data role and connection rights
for db in "${databases[@]}"; do
  echo "Configuring database: $db"
  psql -d "$db" <<EOF
    GRANT CONNECT ON DATABASE "$db" TO "$READONLY_USER";
    GRANT pg_read_all_data TO "$READONLY_USER";
EOF
done
```

### ✅ Advantages of Using pg_read_all_data

- **Automatic coverage**: Automatically includes all current and future tables, views, and sequences
- **Simpler maintenance**: No need to set default privileges manually
- **Consistent access**: Works across all schemas without explicit grants

---

## 🧪 Testing the Read-Only User

After setting up the read-only user, verify that it works correctly:

### 1. Connect as the read-only user

```bash
psql -h your-db-host -p 5432 -U postgres_readonly -d your_database
```

### 2. Test SELECT query

```sql
SELECT * FROM your_table LIMIT 5;
```

**Expected**: Query should execute successfully

### 3. Test INSERT query (should fail)

```sql
INSERT INTO your_table (column1) VALUES ('test');
```

**Expected**: Error message indicating insufficient permissions

```
ERROR:  permission denied for table your_table
```

### 4. Verify role membership

```sql
SELECT r.rolname, m.rolname AS member_of
FROM pg_roles r
LEFT JOIN pg_auth_members am ON r.oid = am.member
LEFT JOIN pg_roles m ON am.roleid = m.oid
WHERE r.rolname = 'postgres_readonly';
```

---

## 🛡️ Security Considerations

### Password Management

- **Never hardcode passwords** in scripts that are committed to version control
- Use environment variables or secret management tools (e.g., AWS Secrets Manager, HashiCorp Vault)
- Rotate passwords regularly

### Network Security

- Restrict database access using `pg_hba.conf`
- Use SSL/TLS for connections
- Implement IP allowlisting when possible

### Principle of Least Privilege

- Only grant access to databases that the user truly needs
- Consider creating schema-specific read-only users if full database access isn't required
- Regularly audit user permissions

---

## 📚 Additional Resources

- [PostgreSQL Documentation: Predefined Roles](https://www.postgresql.org/docs/current/predefined-roles.html)
- [PostgreSQL Documentation: GRANT Command](https://www.postgresql.org/docs/current/sql-grant.html)
- [PostgreSQL Documentation: Role Membership](https://www.postgresql.org/docs/current/role-membership.html)

---

## 🐛 Troubleshooting

### Issue: "role pg_read_all_data does not exist"

**Solution**: Upgrade to PostgreSQL 15 or later, or manually grant SELECT privileges using the script provided above.

### Issue: Read-only user cannot connect

**Solution**: Check `pg_hba.conf` to ensure the user is allowed to connect from their IP address.

```conf
# Example pg_hba.conf entry
host    all    postgres_readonly    0.0.0.0/0    md5
```

### Issue: User can see schema but not tables

**Solution**: Ensure USAGE privilege is granted on the schema:

```sql
GRANT USAGE ON SCHEMA public TO postgres_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres_readonly;
```

### Issue: User cannot access new tables created after setup

**Solution**: Set default privileges:

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO postgres_readonly;
```

---

## 📝 License

This documentation is provided as-is for educational and operational purposes.

---

**Last Updated**: November 2025  
**PostgreSQL Version**: 15+  
**Tested On**: PostgreSQL 17.4 (Ubuntu 17.4-1.pgdg24.04+2)
