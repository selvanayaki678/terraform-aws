from strands import Agent
from strands_tools import http_request
from bedrock_agentcore.runtime import BedrockAgentCoreApp

app= BedrockAgentCoreApp()
systemPrompt="""
You are a helpful assistant.Use the API's that doesn't require auth     
"""
agent=Agent(
    system_prompt=systemPrompt,
    model="us.anthropic.claude-3-5-sonnet-20241022-v2:0",
    tools=[http_request]
)

@app.entrypoint
def invoke(payload):

    user_input=payload.get("prompt")
    response=agent(user_input)
    return response
if __name__ == "__main__":
    print("Starting the app") 
    app.run(port=8080)
