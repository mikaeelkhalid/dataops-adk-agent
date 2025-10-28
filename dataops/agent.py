import os
from dotenv import load_dotenv

from google.adk.agents import LlmAgent, SequentialAgent
from .tools import execute_bigquery_sql
from .prompt import load_agent_instructions
from .tools import explain_query 

# Construct the path to the .env file in the parent directory
dotenv_path = os.path.join(os.path.dirname(__file__), ".env")

# Load the environment variables from the .env file
load_dotenv(dotenv_path)

# Now you can access your environment variables using os.getenv()

MODEL_AGENT = os.getenv("MODEL_AGENT", "gemini-2.5-flash")
MODEL_TOOL = os.getenv("MODEL_TOOL", "gemini-2.5-flash")

# --- Dynamically load agent instructions ---
full_instruction = load_agent_instructions()

# --- 1. Define Sub-Agents for the Pipeline ---

# GitHub Repos SQL Generator Agent
# Takes the user's question and generates a BigQuery SQL query.
github_query_generator_agent = LlmAgent(
    name="GithubQueryGeneratorAgent",
    model=MODEL_AGENT,
    instruction=full_instruction,
    description="Generates a BigQuery SQL query based on the user's question about Github Repos.",
    output_key="generated_sql",  # Stores output in state['generated_sql']
)

# GitHub Repos SQL Explainer Agent
# Takes the generated SQL from the state and executes it using a tool in dry-run mode and returns the query statistics
github_query_explainer_agent = LlmAgent(
    name="GithubQueryExplainerAgent",
    model=MODEL_TOOL,
    # This instruction tells the agent how to use the state and the tool.
    instruction="""You are a SQL Explainer agent.
Your task is to execute the BigQuery SQL query provided in the `{generated_sql}` placeholder in dry run mode.
Use the explain_query tool to run the query.
The query is already written; do not modify it. Simply pass it to the tool.
Provide query statistics to the user and ask for permissions whether to run it or not. If the user consents, the next agent will execute the query.
Passe the query statistics and user consent to the next agent. Also pass the original query in the `{generated_sql}` placeholder.
""",
    description="Explains the generated SQL query using the explain_query tool in dry-run mode.",
    tools=[explain_query],
    output_key="generated_sql",  # Stores output in state['generated_sql']
)

# GitHub Repos SQL Executor Agent
# Takes the generated SQL from the state and executes it using a tool.
github_query_executor_agent = LlmAgent(
    name="GithubExecutorAgent",
    model=MODEL_TOOL,
    # This instruction tells the agent how to use the state and the tool.
    instruction="""You are a SQL execution agent.
Your task is to execute the BigQuery SQL query provided in the `{generated_sql}` placeholder.
Use the execute_bigquery_sql tool to run the query.
The query is already written; do not modify it. Simply pass it to the tool.
Read the query results and give insights to the user.
""",
    description="Executes the generated SQL query using the execute_bigquery_sql tool.",
    tools=[execute_bigquery_sql],
)

print(github_query_executor_agent.instruction)

# --- 2. Create the SequentialAgent ---
# This agent orchestrates the pipeline by running the sub_agents in order.
root_agent = SequentialAgent(
    name="GithubAnalysisAgent",
    sub_agents=[github_query_generator_agent, github_query_explainer_agent, github_query_executor_agent],
    description="""A three-step pipeline that first generates a SQL query for Github Repos , then dry run it and ask for user permissions to execute it.
    Then waits for user consent before executing the query and providing insights from the results.""",
)
