FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip sshpass git curl jq netcat postgresql-client && \
    pip3 install ansible

# Set work directory
WORKDIR /workspace
COPY . /workspace

# Ensure scripts are executable
RUN chmod +x /workspace/scripts/*.sh /workspace/run.sh

# Default command
CMD ["/bin/bash"]
