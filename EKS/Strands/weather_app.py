from bedrock_agentcore import BedrockAgentCoreApp
from strands import Agent
import requests
from datetime import datetime

app = BedrockAgentCoreApp()

# Define weather tool
def get_weather(location: str) -> dict:
    """
    Get current weather information for a location.
    
    Args:
        location: City name or location to get weather for
    
    Returns:
        Dictionary with weather information
    """
    try:
        # Using a free weather API (you'll need to replace with actual API key)
        # Example using wttr.in which doesn't require API key
        url = f"https://wttr.in/{location}?format=j1"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            current = data['current_condition'][0]
            
            return {
                "location": location,
                "temperature": f"{current['temp_C']}°C / {current['temp_F']}°F",
                "condition": current['weatherDesc'][0]['value'],
                "humidity": f"{current['humidity']}%",
                "wind_speed": f"{current['windspeedKmph']} km/h",
                "feels_like": f"{current['FeelsLikeC']}°C",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
        else:
            return {"error": f"Unable to fetch weather for {location}"}
    except Exception as e:
        return {"error": f"Weather API error: {str(e)}"}


def search_web(query: str) -> str:
    """
    Search the web for information.
    
    Args:
        query: Search query string
    
    Returns:
        Search results as string
    """
    # Placeholder - integrate with actual search API if needed
    return f"Search results for: {query} (Integrate with your preferred search API)"


def calculate(expression: str) -> str:
    """
    Perform mathematical calculations.
    
    Args:
        expression: Mathematical expression to evaluate
    
    Returns:
        Calculation result
    """
    try:
        # Simple safe evaluation for basic math
        result = eval(expression, {"__builtins__": {}}, {})
        return f"Result: {result}"
    except Exception as e:
        return f"Calculation error: {str(e)}"


# Create agent with tools
agent = Agent(
    tools=[get_weather, search_web, calculate],
    model="us.anthropic.claude-3-5-sonnet-20241022-v2:0"  # or your preferred model
)


@app.entrypoint
def invoke(payload):
    """
    Main entrypoint for the agent.
    
    Args:
        payload: Input payload containing the prompt
    
    Returns:
        Agent response with result
    """
    user_message = payload.get("prompt", "Hello! How can I help you today?")
    
    # Invoke the agent with the user message
    result = agent(user_message)
    
    return {
        "result": result.message,
        "tools_used": getattr(result, 'tools_used', None)
    }


if __name__ == "__main__":
    # For local testing
    app.run()