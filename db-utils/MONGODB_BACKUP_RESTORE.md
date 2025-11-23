# MongoDB Backup and Restore Guide

This guide provides comprehensive instructions for backing up and restoring MongoDB databases in both Kubernetes (K8s) and server-based environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Admin User Creation](#admin-user-creation)
- [Backup Process](#backup-process)
  - [Kubernetes Setup](#kubernetes-backup)
  - [Server-Based Setup](#server-based-backup)
- [Restore Process](#restore-process)
  - [Kubernetes Setup](#kubernetes-restore)
  - [Server-Based Setup](#server-based-restore)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Prerequisites

### For Kubernetes Setup
- `kubectl` installed and configured
- Access to the Kubernetes cluster
- MongoDB client pod running in the cluster
- AWS CLI configured (if using S3 for backup storage)
- Appropriate RBAC permissions

### For Server-Based Setup
- MongoDB client tools installed (`mongodump`, `mongorestore`, `mongosh`)
- Network access to MongoDB server
- Sufficient disk space for backups
- SSH access to the server (if remote)
- AWS CLI configured (if using S3 for backup storage)

### Required Tools
```bash
# Verify MongoDB tools installation
mongodump --version
mongorestore --version
mongosh --version

# For K8s
kubectl version --client

# For S3 storage
aws --version
```

---

## Admin User Creation

### Kubernetes Environment

1. **Connect to MongoDB instance:**
   ```bash
   # Connect to MongoDB pod
   kubectl exec -it mongo-0 -n mongo-auth -- mongosh \
     --host mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
     -u mongo-admin \
     -p Password1234567890
   ```

2. **Create backup admin user:**
   ```javascript
   use admin
   
   db.createUser({
     user: "backupAdmin",
     pwd: "YourSecurePassword123!@#",  // Use a strong password
     roles: [
       { role: "backup", db: "admin" },
       { role: "restore", db: "admin" },
       { role: "readWriteAnyDatabase", db: "admin" }
     ]
   });
   
   // Verify user creation
   db.getUsers();
   ```

### Server-Based Environment

1. **Connect to MongoDB instance:**
   ```bash
   # Connect via mongosh
   mongosh --host <mongodb-host> --port 27017 -u mongo-admin -p Password1234567890
   
   # Or using legacy mongo shell
   mongo --host <mongodb-host> --port 27017 -u mongo-admin -p Password1234567890
   ```

2. **Create backup admin user:**
   ```javascript
   use admin
   
   db.createUser({
     user: "backupAdmin",
     pwd: "YourSecurePassword123!@#",  // Use a strong password
     roles: [
       { role: "backup", db: "admin" },
       { role: "restore", db: "admin" },
       { role: "readWriteAnyDatabase", db: "admin" }
     ]
   });
   
   // Verify user creation
   db.getUsers();
   ```

> **Security Note:** Replace `Password1234567890` and `YourSecurePassword123!@#` with strong passwords following your organization's password policy.

---

## Backup Process

### Kubernetes Backup

#### Step 1: Access MongoDB Client Pod

```bash
# List available pods
kubectl get pods -n mongo-auth

# Exec into the MongoDB client pod
kubectl exec -it mongo-client-0 -n mongo-auth -- bash
```

#### Step 2: Create Backup

```bash
# Create backup directory
mkdir -p /tmp/mongo-dump-db

# Perform MongoDB dump
mongodump \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --out=/tmp/mongo-dump-db/

# Optional: Backup specific database
mongodump \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --db=epoch \
  --out=/tmp/mongo-dump-db/

# Optional: Backup with gzip compression
mongodump \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --gzip \
  --out=/tmp/mongo-dump-db/
```

#### Step 3: Verify and Compress Backup

```bash
# Check backup size
du -sh /tmp/mongo-dump-db/

# Create compressed archive with timestamp
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
tar -czvf /tmp/mongo-dump-db-${BACKUP_DATE}.tar.gz /tmp/mongo-dump-db/

# Verify archive
ls -lh /tmp/mongo-dump-db-${BACKUP_DATE}.tar.gz
```

#### Step 4: Upload to S3

```bash
# Upload to S3
aws s3 cp /tmp/mongo-dump-db-${BACKUP_DATE}.tar.gz \
  s3://your-bucket-name/mongodb-backups/

# Verify upload
aws s3 ls s3://your-bucket-name/mongodb-backups/

# Optional: Add lifecycle policy for automatic cleanup
```

#### Step 5: Cleanup (Optional)

```bash
# Remove local backup after successful upload
rm -rf /tmp/mongo-dump-db/
rm /tmp/mongo-dump-db-${BACKUP_DATE}.tar.gz
```

### Server-Based Backup

#### Step 1: Connect to Server

```bash
# SSH to the server
ssh user@mongodb-server

# Or run locally if on the same server
```

#### Step 2: Create Backup

```bash
# Create backup directory
mkdir -p /backup/mongo-dump-db

# Perform MongoDB dump
mongodump \
  --host=localhost \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --out=/backup/mongo-dump-db/

# For remote MongoDB server
mongodump \
  --host=mongodb-server.example.com \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --out=/backup/mongo-dump-db/

# Optional: Backup specific database
mongodump \
  --host=localhost \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --db=epoch \
  --out=/backup/mongo-dump-db/
```

#### Step 3: Verify and Compress Backup

```bash
# Check backup size
du -sh /backup/mongo-dump-db/

# Create compressed archive with timestamp
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
tar -czvf /backup/mongo-dump-db-${BACKUP_DATE}.tar.gz /backup/mongo-dump-db/

# Verify archive
ls -lh /backup/mongo-dump-db-${BACKUP_DATE}.tar.gz
```

#### Step 4: Upload to Remote Storage

**Option 1: S3**
```bash
# Upload to S3
aws s3 cp /backup/mongo-dump-db-${BACKUP_DATE}.tar.gz \
  s3://your-bucket-name/mongodb-backups/
```

**Option 2: SCP to Remote Server**
```bash
# Copy to remote backup server
scp /backup/mongo-dump-db-${BACKUP_DATE}.tar.gz \
  backup-user@backup-server:/backups/mongodb/
```

**Option 3: Network Storage**
```bash
# Copy to NFS or network storage
cp /backup/mongo-dump-db-${BACKUP_DATE}.tar.gz \
  /mnt/network-storage/mongodb-backups/
```

---

## Restore Process

### Kubernetes Restore

#### Step 1: Access MongoDB Client Pod

```bash
# Exec into the MongoDB client pod
kubectl exec -it mongo-client-0 -n mongo-auth -- bash
```

#### Step 2: Download Backup

```bash
# Download from S3
aws s3 cp s3://your-bucket-name/mongodb-backups/mongo-dump-db-20250117_143000.tar.gz \
  /tmp/mongo-dump-db.tar.gz

# Verify download
ls -lh /tmp/mongo-dump-db.tar.gz
```

#### Step 3: Extract Backup

```bash
# Extract the archive
tar -xzvf /tmp/mongo-dump-db.tar.gz -C /tmp/

# Verify extraction
ls -lh /tmp/mongo-dump-db/
```

#### Step 4: Restore Database

```bash
# Restore all databases
mongorestore \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  /tmp/mongo-dump-db/

# Restore specific database
mongorestore \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --db=epoch \
  /tmp/mongo-dump-db/epoch/

# Drop existing database before restore
mongorestore \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --drop \
  /tmp/mongo-dump-db/

# Restore with gzip decompression (if backup was compressed)
mongorestore \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --gzip \
  /tmp/mongo-dump-db/
```

### Server-Based Restore

#### Step 1: Download Backup

**From S3:**
```bash
# Download from S3
aws s3 cp s3://your-bucket-name/mongodb-backups/mongo-dump-db-20250117_143000.tar.gz \
  /restore/mongo-dump-db.tar.gz
```

**From Remote Server:**
```bash
# Download via SCP
scp backup-user@backup-server:/backups/mongodb/mongo-dump-db-20250117_143000.tar.gz \
  /restore/mongo-dump-db.tar.gz
```

#### Step 2: Extract Backup

```bash
# Create restore directory
mkdir -p /restore

# Extract the archive
tar -xzvf /restore/mongo-dump-db.tar.gz -C /restore/

# Verify extraction
ls -lh /restore/mongo-dump-db/
```

#### Step 3: Restore Database

```bash
# Restore to local MongoDB
mongorestore \
  --host=localhost \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  /restore/mongo-dump-db/

# Restore to remote MongoDB
mongorestore \
  --host=mongodb-server.example.com \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  /restore/mongo-dump-db/

# Restore specific database
mongorestore \
  --host=localhost \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --db=epoch \
  /restore/mongo-dump-db/epoch/

# Drop existing database before restore
mongorestore \
  --host=localhost \
  --port=27017 \
  --username=backupAdmin \
  --password="YourSecurePassword123!@#" \
  --authenticationDatabase=admin \
  --drop \
  /restore/mongo-dump-db/
```

---

## Verification

### Kubernetes Environment

```bash
# Connect to MongoDB
kubectl exec -it mongo-0 -n mongo-auth -- mongosh \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=myUserAdmin \
  --password="Password123456790" \
  --authenticationDatabase=admin

# Or from mongo-client pod
mongosh \
  --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
  --port=27017 \
  --username=myUserAdmin \
  --password="Password123456790" \
  --authenticationDatabase=admin
```

### Server-Based Environment

```bash
# Connect to MongoDB
mongosh \
  --host=localhost \
  --port=27017 \
  --username=myUserAdmin \
  --password="Password123456790" \
  --authenticationDatabase=admin

# Or for remote server
mongosh \
  --host=mongodb-server.example.com \
  --port=27017 \
  --username=myUserAdmin \
  --password="Password123456790" \
  --authenticationDatabase=admin
```

### Verification Commands (Both Environments)

```javascript
// List all databases
show dbs

// Switch to specific database
use sales

// Count documents in a collection
db.users.countDocuments()

// Find specific user
db.getCollection("users").find({"email": "user@example.com"}).pretty()

// List all collections
show collections

// Get collection statistics
db.users.stats()

// Verify indexes
db.users.getIndexes()

// Check database size
db.stats()
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Authentication Failed

**Problem:** `Authentication failed` error during backup/restore.

**Solution:**
```bash
# Verify user exists and has correct roles
mongosh --host=<mongodb-host> -u mongo-admin -p <password>

use admin
db.getUsers()

# Grant necessary roles
db.grantRolesToUser("backupAdmin", [
  { role: "backup", db: "admin" },
  { role: "restore", db: "admin" }
])
```

#### 2. Insufficient Disk Space

**Problem:** `No space left on device` during backup.

**Solution:**
```bash
# Check available disk space
df -h

# For K8s, check PVC size
kubectl get pvc -n mongo-auth

# Clean up old backups
rm -rf /tmp/old-backups/*

# Use external storage (S3) directly
mongodump --archive | aws s3 cp - s3://bucket/backup.archive
```

#### 3. Network Timeout

**Problem:** Connection timeout during backup/restore.

**Solution:**
```bash
# Increase timeout values
mongodump \
  --host=<mongodb-host> \
  --socketTimeoutMS=300000 \
  --connectTimeoutMS=30000 \
  --username=backupAdmin \
  --password="YourPassword" \
  --authenticationDatabase=admin \
  --out=/backup/
```

#### 4. Pod Not Ready (K8s)

**Problem:** MongoDB pod is not ready.

**Solution:**
```bash
# Check pod status
kubectl get pods -n mongo-auth

# Check pod logs
kubectl logs mongo-0 -n mongo-auth

# Describe pod for events
kubectl describe pod mongo-0 -n mongo-auth

# Check service endpoints
kubectl get endpoints -n mongo-auth
```

#### 5. S3 Access Denied

**Problem:** Cannot upload/download from S3.

**Solution:**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check S3 bucket permissions
aws s3 ls s3://your-bucket-name/

# For K8s pods, ensure service account has IAM role
kubectl describe pod mongo-client-0 -n mongo-auth | grep ServiceAccount
```

---

## Best Practices

### 1. Backup Strategy

- **Frequency:**
  - Production: Daily full backups + hourly incremental backups
  - Development: Weekly or bi-weekly backups
  
- **Retention Policy:**
  - Daily backups: Keep for 7 days
  - Weekly backups: Keep for 4 weeks
  - Monthly backups: Keep for 12 months

- **Automated Backups:**
  ```bash
  # Create a CronJob for K8s
  apiVersion: batch/v1
  kind: CronJob
  metadata:
    name: mongodb-backup
    namespace: mongo-auth
  spec:
    schedule: "0 2 * * *"  # Daily at 2 AM
    jobTemplate:
      spec:
        template:
          spec:
            containers:
            - name: backup
              image: mongo:7.0
              command:
              - /bin/bash
              - -c
              - |
                BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
                mongodump --host=mongo-0.mongo-svc.mongo-auth.svc.cluster.local \
                  --port=27017 \
                  --username=backupAdmin \
                  --password="${MONGODB_PASSWORD}" \
                  --authenticationDatabase=admin \
                  --out=/tmp/backup/
                tar -czvf /tmp/backup-${BACKUP_DATE}.tar.gz /tmp/backup/
                aws s3 cp /tmp/backup-${BACKUP_DATE}.tar.gz s3://backups/mongodb/
              env:
              - name: MONGODB_PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: mongodb-backup-secret
                    key: password
            restartPolicy: OnFailure
  ```

### 2. Security

- Use strong passwords (minimum 16 characters with special characters)
- Store credentials in Kubernetes secrets or environment variables
- Use SSL/TLS for MongoDB connections
- Encrypt backups at rest and in transit
- Implement least-privilege access for backup users
- Regularly rotate backup credentials

### 3. Testing

- Regularly test restore procedures
- Perform test restores in non-production environments
- Document recovery time objectives (RTO) and recovery point objectives (RPO)
- Validate backup integrity after creation

### 4. Monitoring

- Monitor backup job completion
- Alert on backup failures
- Track backup size trends
- Monitor S3 storage costs
- Set up CloudWatch/Prometheus alerts for backup jobs

### 5. Documentation

- Document all backup and restore procedures
- Maintain a runbook for disaster recovery
- Keep an inventory of all backups
- Document any custom configurations or special requirements

### 6. Performance Optimization

```bash
# Use parallel backup for large databases
mongodump \
  --numParallelCollections=4 \
  --host=<mongodb-host> \
  --username=backupAdmin \
  --password="YourPassword" \
  --authenticationDatabase=admin \
  --out=/backup/

# Use oplog for point-in-time recovery
mongodump \
  --host=<mongodb-host> \
  --username=backupAdmin \
  --password="YourPassword" \
  --authenticationDatabase=admin \
  --oplog \
  --out=/backup/
```

---

## Backup Script Examples

### Kubernetes Backup Script

Create a file `k8s-mongo-backup.sh`:

```bash
#!/bin/bash

# Configuration
NAMESPACE="mongo-auth"
POD_NAME="mongo-client-0"
MONGO_HOST="mongo-0.mongo-svc.mongo-auth.svc.cluster.local"
MONGO_PORT="27017"
BACKUP_USER="backupAdmin"
S3_BUCKET="s3://your-bucket-name/mongodb-backups"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

# Read password from secret
MONGO_PASSWORD=$(kubectl get secret mongodb-backup-secret -n ${NAMESPACE} -o jsonpath='{.data.password}' | base64 -d)

echo "Starting MongoDB backup at ${BACKUP_DATE}..."

# Execute backup in pod
kubectl exec -it ${POD_NAME} -n ${NAMESPACE} -- bash -c "
  mongodump \
    --host=${MONGO_HOST} \
    --port=${MONGO_PORT} \
    --username=${BACKUP_USER} \
    --password='${MONGO_PASSWORD}' \
    --authenticationDatabase=admin \
    --gzip \
    --out=/tmp/mongo-dump-db/
  
  tar -czvf /tmp/mongo-dump-db-${BACKUP_DATE}.tar.gz /tmp/mongo-dump-db/
  
  aws s3 cp /tmp/mongo-dump-db-${BACKUP_DATE}.tar.gz ${S3_BUCKET}/
  
  rm -rf /tmp/mongo-dump-db/
  rm /tmp/mongo-dump-db-${BACKUP_DATE}.tar.gz
"

echo "Backup completed: mongo-dump-db-${BACKUP_DATE}.tar.gz"
```

### Server-Based Backup Script

Create a file `server-mongo-backup.sh`:

```bash
#!/bin/bash

# Configuration
MONGO_HOST="localhost"
MONGO_PORT="27017"
BACKUP_USER="backupAdmin"
BACKUP_PASSWORD="YourSecurePassword123!@#"
BACKUP_DIR="/backup"
S3_BUCKET="s3://your-bucket-name/mongodb-backups"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

echo "Starting MongoDB backup at ${BACKUP_DATE}..."

# Create backup directory
mkdir -p ${BACKUP_DIR}/mongo-dump-db

# Perform backup
mongodump \
  --host=${MONGO_HOST} \
  --port=${MONGO_PORT} \
  --username=${BACKUP_USER} \
  --password="${BACKUP_PASSWORD}" \
  --authenticationDatabase=admin \
  --gzip \
  --out=${BACKUP_DIR}/mongo-dump-db/

# Check if backup was successful
if [ $? -eq 0 ]; then
  echo "Backup completed successfully. Compressing..."
  
  # Compress backup
  tar -czvf ${BACKUP_DIR}/mongo-dump-db-${BACKUP_DATE}.tar.gz ${BACKUP_DIR}/mongo-dump-db/
  
  # Upload to S3
  aws s3 cp ${BACKUP_DIR}/mongo-dump-db-${BACKUP_DATE}.tar.gz ${S3_BUCKET}/
  
  if [ $? -eq 0 ]; then
    echo "Backup uploaded to S3 successfully"
    
    # Cleanup local backup
    rm -rf ${BACKUP_DIR}/mongo-dump-db/
    rm ${BACKUP_DIR}/mongo-dump-db-${BACKUP_DATE}.tar.gz
    
    # Delete old backups from S3 (older than RETENTION_DAYS)
    aws s3 ls ${S3_BUCKET}/ | while read -r line; do
      createDate=$(echo $line | awk '{print $1" "$2}')
      createDate=$(date -d "$createDate" +%s)
      olderThan=$(date -d "-${RETENTION_DAYS} days" +%s)
      if [[ $createDate -lt $olderThan ]]; then
        fileName=$(echo $line | awk '{print $4}')
        if [[ $fileName != "" ]]; then
          echo "Deleting old backup: $fileName"
          aws s3 rm ${S3_BUCKET}/$fileName
        fi
      fi
    done
  else
    echo "Failed to upload backup to S3"
    exit 1
  fi
else
  echo "Backup failed"
  exit 1
fi

echo "Backup process completed"
```

Make scripts executable:
```bash
chmod +x k8s-mongo-backup.sh
chmod +x server-mongo-backup.sh
```

---

## Additional Resources

- [MongoDB Backup Methods](https://docs.mongodb.com/manual/core/backups/)
- [mongodump Documentation](https://docs.mongodb.com/database-tools/mongodump/)
- [mongorestore Documentation](https://docs.mongodb.com/database-tools/mongorestore/)
- [Kubernetes CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [AWS S3 CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/s3/)

---

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review MongoDB logs
3. Contact your DevOps team
4. Open an issue in the repository

---

**Last Updated:** November 17, 2025
