import streamlit as st
import os
import asyncio
import json
from dotenv import load_dotenv
import vertexai
from vertexai import agent_engines
from google.adk.sessions import VertexAiSessionService

# Load environment variables
load_dotenv("dataops/.env")

# Configure page
st.set_page_config(
    page_title="DataOps GitHub Analysis Agent",
    page_icon="🔍",
    layout="wide"
)

# Initialize Vertex AI
@st.cache_resource
def init_vertex_ai():
    vertexai.init(
        project=os.getenv("GOOGLE_CLOUD_PROJECT"),
        location=os.getenv("GOOGLE_CLOUD_LOCATION"),
    )
    return True

# Get agent engine
@st.cache_resource
def get_agent_engine():
    agent_engine_id = os.getenv("AGENT_ENGINE_ID")
    return agent_engines.get(agent_engine_id)

# Session service
@st.cache_resource
def get_session_service():
    return VertexAiSessionService(
        project=os.getenv("GOOGLE_CLOUD_PROJECT"),
        location=os.getenv("GOOGLE_CLOUD_LOCATION"),
    )

def format_event_content(event):
    """Format event content for display"""
    if "content" not in event:
        return f"**{event.get('author', 'unknown')}**: {event}"
    
    author = event.get("author", "unknown")
    parts = event["content"].get("parts", [])
    
    formatted_parts = []
    
    for part in parts:
        if "text" in part:
            text = part["text"]
            formatted_parts.append(f"**{author}**: {text}")
        elif "functionCall" in part:
            func_call = part["functionCall"]
            func_name = func_call.get('name', 'unknown')
            args = json.dumps(func_call.get("args", {}), indent=2)
            formatted_parts.append(f"**{author}** - Function Call: `{func_name}`\n```json\n{args}\n```")
        elif "functionResponse" in part:
            func_response = part["functionResponse"]
            func_name = func_response.get('name', 'unknown')
            response = json.dumps(func_response.get("response", {}), indent=2)
            formatted_parts.append(f"**{author}** - Function Response: `{func_name}`\n```json\n{response}\n```")
    
    return "\n\n".join(formatted_parts)

async def query_agent(user_input, session_id):
    """Query the agent and return formatted results"""
    agent_engine = get_agent_engine()
    results = []
    
    try:
        for event in agent_engine.stream_query(
            user_id="streamlit_user", 
            session_id=session_id, 
            message=user_input
        ):
            formatted_content = format_event_content(event)
            results.append(formatted_content)
        
        return results
    except Exception as e:
        return [f"Error: {str(e)}"]

def main():
    st.title("🔍 DataOps GitHub Analysis Agent")
    st.markdown("Ask questions about GitHub repositories and get insights powered by BigQuery!")
    
    # Initialize services
    try:
        init_vertex_ai()
        session_service = get_session_service()
        st.success("✅ Connected to Agent Engine")
    except Exception as e:
        st.error(f"❌ Failed to initialize: {str(e)}")
        st.stop()
    
    # Example queries
    with st.expander("💡 Example Queries"):
        st.markdown("""
        - **Language Analysis**: "What are the top 10 languages by bytes for tensorflow/tensorflow?"
        - **Code Search**: "Find files in microsoft/vscode that contain the term 'TODO' and show a snippet"
        - **Commit Analysis**: "Who are the top committers in the last year for facebook/react?"
        - **Repository Trends**: "Show the top repositories by watch count (sample set)"
        - **Security Search**: "Search sampled contents for the term 'security' and show paths/snippets"
        - **License Analysis**: "Give license distribution for repositories like 'google/tensorflow', 'microsoft/vscode'"
        """)
    
    # Session management
    if 'session_id' not in st.session_state:
        try:
            # Create a new session
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            session = loop.run_until_complete(
                session_service.create_session(
                    app_name=os.getenv("AGENT_ENGINE_ID"),
                    user_id="streamlit_user",
                )
            )
            st.session_state.session_id = session.id
            st.session_state.conversation_history = []
        except Exception as e:
            st.error(f"Failed to create session: {str(e)}")
            st.stop()
    
    # Chat interface
    user_input = st.text_input(
        "Ask a question about GitHub repositories:",
        placeholder="e.g., What are the top languages in tensorflow/tensorflow?",
        key="user_input"
    )
    
    col1, col2 = st.columns([1, 4])
    
    with col1:
        submit_button = st.button("🚀 Ask Agent", type="primary")
    
    with col2:
        if st.button("🗑️ Clear Conversation"):
            st.session_state.conversation_history = []
            st.rerun()
    
    # Process query
    if submit_button and user_input:
        with st.spinner("🤖 Agent is thinking..."):
            try:
                # Create event loop for async operation
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                
                results = loop.run_until_complete(
                    query_agent(user_input, st.session_state.session_id)
                )
                
                # Add to conversation history
                st.session_state.conversation_history.append({
                    "user": user_input,
                    "agent": results
                })
                
            except Exception as e:
                st.error(f"Error querying agent: {str(e)}")
    
    # Display conversation history
    if st.session_state.conversation_history:
        st.markdown("---")
        st.subheader("💬 Conversation History")
        
        for i, exchange in enumerate(reversed(st.session_state.conversation_history)):
            with st.container():
                st.markdown(f"**🙋 You:** {exchange['user']}")
                
                # Display agent responses
                for j, response in enumerate(exchange['agent']):
                    if response.strip():
                        with st.expander(f"Agent Response {j+1}", expanded=(j == len(exchange['agent'])-1)):
                            st.markdown(response)
                
                if i < len(st.session_state.conversation_history) - 1:
                    st.markdown("---")
    
    # Sidebar with info
    with st.sidebar:
        st.markdown("### 📊 Agent Info")
        st.markdown(f"**Project:** {os.getenv('GOOGLE_CLOUD_PROJECT', 'Not configured')}")
        st.markdown(f"**Location:** {os.getenv('GOOGLE_CLOUD_LOCATION', 'Not configured')}")
        st.markdown(f"**Session ID:** {st.session_state.get('session_id', 'No session')[:20]}...")
        
        st.markdown("### 🔧 Agent Pipeline")
        st.markdown("""
        1. **SQL Generator**: Creates BigQuery SQL from your question
        2. **Query Explainer**: Analyzes query cost and asks permission
        3. **Query Executor**: Runs the query and provides insights
        """)
        
        st.markdown("### 📚 Data Source")
        st.markdown("**BigQuery Public Dataset**: `bigquery-public-data.github_repos`")
        st.markdown("- 265M+ commits")
        st.markdown("- 280M+ file contents")
        st.markdown("- 2.3B+ file metadata")
        st.markdown("- 3.3M+ repositories")

if __name__ == "__main__":
    main()