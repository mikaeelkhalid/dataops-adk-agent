import os
from jinja2 import Environment, FileSystemLoader
from datetime import datetime, timedelta


def load_github_analysis_examples() -> str:
    """Loads and renders the GitHub Analysis examples template.

    Returns:
        str: The rendered template with populated values.
    """
    try:
        # Set up Jinja environment
        current_dir = os.path.dirname(os.path.abspath(__file__))
        template_dir = os.path.join(current_dir, "prompt-template")
        env = Environment(loader=FileSystemLoader(template_dir))
        template = env.get_template("github_analysis_example.j2")

        # Render the template
        rendered_template = template.render()
        return rendered_template

    except Exception as e:
        print(f"Error loading github analysis examples template: {str(e)}")
        raise


def load_table_structure_prompt() -> str:
    """Loads and renders the GitHub Repos table structure and rules template.

    Returns:
        str: The rendered template content.
    """
    try:
        # Set up Jinja environment
        current_dir = os.path.dirname(os.path.abspath(__file__))
        template_dir = os.path.join(current_dir, "prompt-template")
        env = Environment(loader=FileSystemLoader(template_dir))
        template = env.get_template("github_table_structure.j2")

        # Render the template
        return template.render()

    except Exception as e:
        print(f"Error loading table structure template: {str(e)}")
        raise


def load_agent_instructions():
    """Dynamically loads agent instructions and github analysis examples."""
    try:
        # Load prompts
        table_structure_prompt = load_table_structure_prompt()
        github_analysis_examples = load_github_analysis_examples()

        # Combine prompts to form the full instruction
        full_instruction = f"{table_structure_prompt}\n\n{github_analysis_examples}"
        print("Successfully loaded agent instructions.")
        return full_instruction

    except Exception as e:
        print(f"FATAL: Could not load agent instructions: {e}")
        # Fallback to a basic instruction if dynamic loading fails
        return "You are an agent that can query Github Repos data."
