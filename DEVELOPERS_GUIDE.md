# DataOps ADK Agent - Developer's Guide

A comprehensive GitHub repository analysis agent built with Google's Agent Development Kit (ADK) that leverages BigQuery to provide insights into open-source repositories.

## 🏗️ Project Architecture

This project implements a sophisticated AI agent pipeline that can analyze GitHub repositories using natural language queries. The agent generates SQL queries, estimates costs, and executes them against the `bigquery-public-data.github_repos` dataset.

### 🧩 Core Components

```
dataops-adk-agent/
├── agent-deployment/     # Agent deployment scripts and testing
├── dataops/             # Core agent logic and configuration
├── infra/               # Terraform infrastructure as code
├── app/                 # Streamlit web application
├── docker-compose.yml   # Local Docker development setup
├── Dockerfile           # Container configuration
└── pyproject.toml       # Python dependencies and project config
```

## 📦 Component Overview

### 1. **`dataops/` - Core Agent Implementation**

The heart of the project containing the AI agent logic built with Google ADK.

#### **Structure:**
```
dataops/
├── __init__.py                    # Package initialization
├── agent.py                       # Main agent pipeline definition
├── tools.py                       # BigQuery interaction tools
├── prompt.py                      # Dynamic prompt loading
├── .env                          # Environment configuration
├── Dockerfile                     # Legacy container config
└── prompt-template/               # Jinja2 templates
    ├── github_analysis_example.j2    # Example queries
    ├── github_table_structure.j2     # BigQuery schema info
    └── github_repos_tables.json      # Complete table definitions
```

#### **Key Files:**

**`agent.py`** - Implements a 3-stage Sequential Agent pipeline:
- **GitHub Query Generator Agent**: Converts natural language to BigQuery SQL
- **GitHub Query Explainer Agent**: Performs dry-run analysis and cost estimation
- **GitHub Query Executor Agent**: Executes approved queries and provides insights

**`tools.py`** - BigQuery integration utilities:
- `execute_bigquery_sql()`: Executes SQL queries and returns JSON results
- `explain_query()`: Dry-run query analysis for cost estimation
- SQL query cleaning and formatting utilities

**`prompt.py`** - Dynamic prompt management:
- Loads Jinja2 templates for agent instructions
- Combines table schemas with example queries
- Provides fallback instructions for error scenarios

### 2. **`agent-deployment/` - Deployment & Testing**

Scripts for deploying agents to Google Cloud and testing deployed instances.

#### **Structure:**
```
agent-deployment/
├── deploy.py              # Deploy agent to Vertex AI Agent Engine
└── test_deployment.py     # Test deployed agent functionality
```

#### **Key Files:**

**`deploy.py`** - Production deployment script:
- Creates AdkApp from the root agent
- Deploys to Vertex AI Agent Engine
- Updates environment with new Agent Engine ID
- Manages Python dependencies from pyproject.toml

**`test_deployment.py`** - Testing framework:
- Interactive testing of deployed agents
- Session management for persistent conversations
- Pretty-printed event formatting for debugging

### 3. **`infra/` - Infrastructure as Code**

Terraform configuration for provisioning Google Cloud resources.

#### **Structure:**
```
infra/
├── main.tf              # Primary resource definitions
├── variables.tf         # Input variable declarations
├── outputs.tf           # Output value definitions
├── provider.tf          # Terraform and provider configuration
└── terraform.tfvars    # Variable values (environment-specific)
```

#### **Key Resources:**

**Google Cloud APIs:**
- AI Platform API (aiplatform.googleapis.com)
- BigQuery API (bigquery.googleapis.com)
- Cloud Run API (run.googleapis.com)
- Artifact Registry API (artifactregistry.googleapis.com)

**IAM & Security:**
- Service accounts for agent execution
- BigQuery User and Job User roles
- AI Platform Reasoning Engine permissions

**Storage & Artifacts:**
- Cloud Storage bucket for staging
- Artifact Registry for container images
- BigQuery dataset access permissions

### 4. **`app/` - Web Application**

Streamlit-based web interface for interacting with the deployed agent.

#### **Structure:**
```
app/
└── app.py              # Streamlit web application
```

#### **Features:**
- Interactive chat interface with the Agent Engine
- Real-time display of agent pipeline execution
- Example queries and templates
- Conversation history management
- Agent status and configuration display

## 🛠️ Technology Stack

### **Core Technologies:**

- **Python 3.12+**: Modern Python with latest features
- **UV Package Manager**: Fast, reliable Python dependency management
- **Google ADK**: Agent Development Kit for building AI agents
- **Streamlit**: Interactive web application framework
- **Docker**: Containerization for consistent deployments

### **Google Cloud Services:**

- **Vertex AI Agent Engine**: Managed agent hosting and execution
- **BigQuery**: Data warehouse for GitHub repository analysis
- **Cloud Storage**: Artifact and model storage
- **IAM**: Identity and access management

### **Infrastructure:**

- **Terraform**: Infrastructure as Code for reproducible deployments
- **Docker Compose**: Local development environment orchestration

## 🚀 Development Workflow

### **1. Local Development Setup**

```bash
# Clone the repository
git clone <repository-url>
cd dataops-adk-agent

# Install Python 3.12+
# Install UV package manager
pip install uv

# Initialize and sync dependencies
uv sync

# Activate virtual environment
source .venv/bin/activate
```

### **2. Environment Configuration**

Create `dataops/.env` with your Google Cloud configuration:

```env
GOOGLE_GENAI_USE_VERTEXAI=1
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=your-region
GOOGLE_CLOUD_STORAGE_BUCKET=gs://your-bucket-name
AGENT_ENGINE_ID=projects/.../reasoningEngines/...
```

### **3. Infrastructure Deployment**

```bash
cd infra/

# Configure your project details
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

### **4. Agent Development & Testing**

```bash
# Local testing with ADK
cd dataops/
adk run    # Interactive testing
adk web    # Web interface testing

# Deploy to Vertex AI
cd ../agent-deployment/
python deploy.py

# Test deployed agent
python test_deployment.py
```

### **5. Web Application Development**

```bash
# Local Streamlit development
streamlit run app/app.py

# Docker development
./run_docker.sh

# Production deployment
./run_production.sh
```

## 🐳 Docker Development

### **Local Development with Docker**

The project includes comprehensive Docker support for consistent development environments.

#### **Quick Start:**
```bash
# Build and run with single command
./run_docker.sh

# Manual Docker Compose
docker-compose up --build

# Background mode
docker-compose up -d

# View logs
docker-compose logs -f
```

#### **Production Deployment:**
```bash
# Build and run production container
./run_production.sh

# Manual production build
docker build -t dataops-agent:latest .
docker run -p 8501:8501 --env-file .env.docker dataops-agent:latest
```

#### **Docker Configuration:**

**Environment Variables** (`.env.docker`):
```env
GOOGLE_CLOUD_PROJECT=your-project
GOOGLE_CLOUD_LOCATION=your-region
AGENT_ENGINE_ID=your-agent-engine-id
```

**Container Features:**
- 🔒 Non-root user execution for security
- 🏥 Built-in health checks
- 🔄 Automatic restart policies
- 📊 Resource optimization
- 🎯 Production-ready configuration

## 🧪 Testing & Validation

### **Local Agent Testing**

```bash
# Test agent locally
cd dataops/
adk run

# Example queries to test:
# "What are the top 10 languages by bytes for tensorflow/tensorflow?"
# "Find files in microsoft/vscode that contain the term 'TODO'"
# "Who are the top committers in the last year for facebook/react?"
```

### **Deployed Agent Testing**

```bash
# Test deployed agent
cd agent-deployment/
python test_deployment.py

# Interactive testing with session management
# Real-time event streaming and formatting
```

### **Web Application Testing**

```bash
# Local Streamlit testing
streamlit run app/app.py

# Docker testing
./run_docker.sh

# Access at http://localhost:8501
```

## 🔧 Helper Scripts

### **Development Scripts:**

- **`run_streamlit.sh`**: Local Streamlit development server
- **`run_docker.sh`**: Docker Compose development environment
- **`run_production.sh`**: Production Docker container deployment

### **Deployment Scripts:**

- **`agent-deployment/deploy.py`**: Deploy agent to Vertex AI
- **`agent-deployment/test_deployment.py`**: Test deployed agents

### **Infrastructure Scripts:**

- **`infra/`**: Complete Terraform configuration for Google Cloud

## 📊 Agent Pipeline Details

### **Three-Stage Sequential Pipeline:**

1. **SQL Generation Stage**:
   - Analyzes natural language queries
   - Generates optimized BigQuery SQL
   - Applies cost-optimization rules
   - Uses comprehensive GitHub schema knowledge

2. **Query Explanation Stage**:
   - Performs dry-run query analysis
   - Estimates data processing costs
   - Requests user permission for execution
   - Provides query statistics and insights

3. **Query Execution Stage**:
   - Executes approved SQL queries
   - Processes and formats results
   - Provides data insights and analysis
   - Returns structured JSON responses

### **Data Sources:**

**BigQuery Public Dataset**: `bigquery-public-data.github_repos`
- 265M+ commits across repositories
- 280M+ file contents (text files < 1MB)
- 2.3B+ file metadata entries
- 3.3M+ repository information records

## 🔐 Security & Best Practices

### **Security Measures:**

- **IAM Roles**: Minimal required permissions
- **Service Accounts**: Dedicated accounts per service
- **Environment Isolation**: Separate configurations per environment
- **Container Security**: Non-root user execution
- **API Security**: Authenticated Google Cloud API access

### **Best Practices:**

- **Dependency Management**: UV for fast, reliable package management
- **Infrastructure as Code**: Terraform for reproducible deployments
- **Containerization**: Docker for consistent environments
- **Testing**: Comprehensive local and deployed testing
- **Documentation**: Detailed guides and examples

## 🚀 Production Deployment

### **Deployment Checklist:**

1. ✅ **Infrastructure**: Deploy via Terraform
2. ✅ **Agent**: Deploy to Vertex AI Agent Engine
3. ✅ **Application**: Build and deploy container
4. ✅ **Testing**: Validate all components
5. ✅ **Monitoring**: Configure health checks and logging

### **Scaling Considerations:**

- **Agent Engine**: Auto-scaling managed by Google Cloud
- **BigQuery**: Pay-per-query with cost controls
- **Container**: Horizontal scaling with Docker Swarm/Kubernetes
- **Storage**: Cloud Storage for artifacts and logs

## 🐛 Troubleshooting

### **Common Issues:**

**Agent Stuck on First Stage**:
- Verify IAM permissions (BigQuery Job User role)
- Check Agent Engine deployment status
- Validate environment variables

**Docker Build Failures**:
- Ensure Git is available in container
- Verify UV and Python versions
- Check network connectivity for Git clone

**BigQuery Permissions**:
- Verify service account has `bigquery.jobUser` role
- Check project-level IAM settings
- Validate dataset access permissions

### **Debug Commands:**

```bash
# Check agent status
python agent-deployment/test_deployment.py

# View Docker logs
docker-compose logs -f

# Test BigQuery connectivity
bq query --use_legacy_sql=false "SELECT 1"

# Validate Terraform
terraform validate
terraform plan
```

## 📚 Additional Resources

- [Google ADK Documentation](https://cloud.google.com/vertex-ai/docs/agent-builder)
- [BigQuery GitHub Repos Dataset](https://cloud.google.com/bigquery/public-data/github)
- [Streamlit Documentation](https://docs.streamlit.io/)
- [UV Package Manager](https://docs.astral.sh/uv/)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)