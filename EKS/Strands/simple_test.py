from strands import Agent
from strands_tools import calculator, current_time

# Create the agent
agent = Agent(
    name="Strands Bedrock Agent",
    system_prompt="You are a helpful assistant.",
    model="anthropic.claude-3-haiku-20240307-v1:0",
    tools=[calculator, current_time]
)

# Run the agent and print the response
response = agent("What is kubernetes why we need to use?")
print("Agent response:", response)
