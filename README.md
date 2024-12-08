# PostgreSQL High Availability (HA) Setup Project

This project automates the **deployment and testing of a PostgreSQL High Availability cluster** using **Patroni**, **Pgpool-II**, and **Etcd**. The cluster is designed for production environments with features like automatic failover, load balancing, and centralized connection management.

---

## Key Features

- **Automated Deployment**:
  - Configures a PostgreSQL HA cluster across three nodes.
  - Uses Ansible for consistent setup and management.
  - All tasks are containerized for simplicity and isolation.

- **Testing Suite**:
  - Validates the cluster with:
    - Patroni cluster health checks.
    - Pgpool-II connectivity and query routing.
    - Failover simulation and recovery testing.

- **Production-Ready Practices**:
  - Secure handling of sensitive information with Ansible Vault.
  - Environment-based configuration for flexibility and scalability.
  - Centralized logging for easier debugging and monitoring.

---

## Project Structure

```
postansible/
├── Dockerfile                     # Dockerfile for deployment and testing
├── run.sh                         # Main script to deploy and test the cluster
├── ansible/                       # Ansible-related files
│   ├── inventory/
│   │   ├── production.yml         # Inventory file for production
│   ├── playbooks/
│   │   ├── setup_postgresql.yml   # Playbook for PostgreSQL HA setup
│   │   └── templates/
│   │       ├── patroni.yml.j2     # Patroni configuration template
│   │       └── pgpool.conf.j2     # Pgpool-II configuration template
├── scripts/                       # Test scripts for validation
│   ├── test_patroni.sh            # Tests Patroni cluster health
│   ├── test_pgpool.sh             # Tests Pgpool-II connectivity
│   ├── test_failover.sh           # Simulates failover and tests recovery
├── secrets/                       # Encrypted secrets and credentials
│   ├── vault_pass.txt             # Ansible Vault password file
│   └── credentials.yml            # Encrypted credentials file
├── logs/                          # Directory for storing logs
│   └── deployment.log             # Log file for deployment
├── .env                           # Environment variables for configuration
└── README.md                      # Project documentation
```

---

## Prerequisites

1. **Infrastructure**:
   - Three nodes with private IPs:
     - `172.28.0.10` (node1)
     - `172.28.0.11` (node2)
     - `172.28.0.12` (node3)
   - Ensure SSH access is configured with the same username and private key.

2. **Docker**:
   - Install Docker on the management machine (e.g., your laptop or a dedicated server).

3. **Environment Setup**:
   - Create a `.env` file in the project root with the following content:
     ```bash
     ANSIBLE_USER=your-username
     ANSIBLE_VAULT_PASS=/workspace/secrets/vault_pass.txt
     ```

4. **Sensitive Data Management**:
   - Encrypt sensitive variables using Ansible Vault:
     ```bash
     ansible-vault encrypt secrets/credentials.yml
     ```

---

## Usage

### 1. Clone the Repository
```bash
git clone https://github.com/your-repo/postgresql-ha-setup.git
cd postgresql-ha-setup
```

### 2. Build the Docker Image
```bash
docker build -t postgresql-ha-setup .
```

### 3. Configure Inventory
Edit `ansible/inventory/production.yml` to match your node details:
```yaml
all:
  hosts:
    node1:
      ansible_host: 172.28.0.10
    node2:
      ansible_host: 172.28.0.11
    node3:
      ansible_host: 172.28.0.12
  vars:
    ansible_user: "{{ vault_ansible_user }}"
    ansible_ssh_private_key_file: "{{ vault_ssh_key }}"
```

### 4. Run Deployment and Tests
Run the setup and validation process:
```bash
docker run --rm -it \
  -v ~/.ssh:/root/.ssh \
  -v $(pwd):/workspace \
  postgresql-ha-setup \
  bash run.sh
```

---

## Sensitive Data Management

This project uses **Ansible Vault** to encrypt and securely store sensitive information such as credentials and private keys.

### 1. Set Up Vault Password

The vault password is stored in a file (`secrets/vault_pass.txt`) and referenced in the `.env` file for automated decryption.

#### Example `vault_pass.txt`
Create the file `secrets/vault_pass.txt` and add a secure password:
```bash
secure_vault_password_here
```

Make sure this file is not exposed accidentally:
```bash
chmod 600 secrets/vault_pass.txt
```

---

### 2. Encrypt Sensitive Credentials

Create a file named `secrets/credentials.yml` with your sensitive data. Here's an example of its unencrypted content:

#### Example `credentials.yml`
```yaml
vault_ansible_user: your-ssh-username
vault_ssh_key: /root/.ssh/id_rsa
vault_db_password: secure_db_password
vault_pgpool_user: pgpool_user
vault_pgpool_password: pgpool_secure_password
```

Encrypt the file using Ansible Vault:
```bash
ansible-vault encrypt secrets/credentials.yml
```

After encryption, the file content will look something like this:
```
$ANSIBLE_VAULT;1.1;AES256
6162636465666768696a6b6c6d6e6f70...
```

---

### 3. Reference Encrypted Variables in Ansible

The encrypted variables are used in the `inventory.yml` and configuration templates:

#### Example `ansible/inventory/production.yml`
```yaml
all:
  hosts:
    node1:
      ansible_host: 172.28.0.10
    node2:
      ansible_host: 172.28.0.11
    node3:
      ansible_host: 172.28.0.12
  vars:
    ansible_user: "{{ vault_ansible_user }}"
    ansible_ssh_private_key_file: "{{ vault_ssh_key }}"
    db_password: "{{ vault_db_password }}"
```

#### Example Template Usage (e.g., `patroni.yml.j2`)
```yaml
postgresql:
  authentication:
    superuser:
      username: postgres
      password: "{{ db_password }}"
```

---

### 4. Automate Vault Password Usage

In the `.env` file, specify the path to the vault password file:
```bash
ANSIBLE_USER=your-username
ANSIBLE_VAULT_PASS=/workspace/secrets/vault_pass.txt
```

Ansible will automatically use this file to decrypt `credentials.yml` during playbook execution.

---

### 5. Best Practices for Sensitive Data

1. **Protect the Vault Password**:
   - Keep the `vault_pass.txt` file out of version control by adding it to `.gitignore`.

2. **Encrypt the Vault File Regularly**:
   - If changes are made to `credentials.yml`, re-encrypt it:
     ```bash
     ansible-vault edit secrets/credentials.yml
     ```

3. **Limit Access**:
   - Ensure only authorized users have access to the `secrets` directory.

---

## Post-Deployment Information

### Connection Details
Once deployed, clients can connect to the cluster via Pgpool-II:

- **Pgpool-II Connection**:
  ```
  Host: 172.28.0.10
  Port: 5432
  Connection String: postgres://<username>:<password>@172.28.0.10:5432/<database_name>
  ```

- **Patroni REST API**:
  - Retrieve cluster status using the API available on port `8008`:
    ```bash
    curl http://172.28.0.10:8008/cluster
    ```

---

## Testing Details

The deployment includes automated tests to verify the cluster’s functionality:

1. **Patroni Cluster Health**:
   - Validates node roles (leader/replica) and service status.

2. **Pgpool-II Connectivity**:
   - Ensures query routing and load balancing work as expected.

3. **Failover Test**:
   - Simulates a primary node failure and verifies leader election.

To re-run individual tests:
```bash
bash scripts/test_patroni.sh
bash scripts/test_pgpool.sh
bash scripts/test_failover.sh
```

---

## Logs
Deployment logs are stored in the `logs/deployment.log` file. Check this file for troubleshooting and auditing.

---

## Customization

1. **Adjust Cluster Configuration**:
   - Update `ansible/playbooks/templates/patroni.yml.j2` to modify PostgreSQL parameters (e.g., `max_connections`, `shared_buffers`).

2. **Load Balancing in Pgpool-II**:
   - Edit `ansible/playbooks/templates/pgpool.conf.j2` to configure read/write query distribution.

---

## Troubleshooting

- **SSH Connection Errors**:
  - Verify that SSH keys are correctly configured and accessible.

- **Cluster Issues**:
  - Check the Patroni logs on each node (`/var/log/patroni.log`) for errors.

- **Pgpool-II Connectivity**:
  - Verify that Pgpool-II is reachable at the specified IP and port.

---

## License
This project is licensed under the Apache 2.0 License. See the `LICENSE` file for more details.

---

## Future Improvements
- Integrate monitoring tools like **Prometheus** and **Grafana** for real-time cluster insights.
- Add backup support with **pgBackRest** or **Barman**.

---