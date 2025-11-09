"""
Bedrock Agent Core Runtime - Production Ready
Simple, clean FastAPI server for SSE streaming
"""

from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from strands import Agent
from strands.models import BedrockModel
from strands.tools.mcp import MCPClient
from mcp.client.sse import sse_client
from bedrock_agentcore.runtime import BedrockAgentCoreApp
import json
import asyncio
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize
app = FastAPI(title="Bedrock Agent Core Runtime")
agentcore_app = BedrockAgentCoreApp()

# Configuration
MCP_SERVER_URL = "http://aa2a00ddccde14e4291689f79b08504f-612606699.us-east-1.elb.amazonaws.com:8080/sse"  # Set your MCP server URL or None for no tools

@app.get("/")
def health():
    """Health check"""
    return {"status": "healthy", "service": "agentcore-runtime"}

@app.get("/sse")
async def sse_stream(message: str):
    """
    SSE endpoint for streaming agent responses
    Usage: curl -N "http://your-server:8000/sse?message=Hello"
    """
    
    async def generate():
        client = None
        try:
            logger.info(f"Request: {message}")
            
            # Initialize MCP (optional)
            tools = []
            if MCP_SERVER_URL:
                try:
                    client = MCPClient(lambda: sse_client(MCP_SERVER_URL))
                    client.start()
                    tools = client.list_tools_sync()
                    logger.info(f"Loaded {len(tools)} tools")
                except Exception as e:
                    logger.warning(f"MCP unavailable: {e}")
            
            # Create agent
            agent = Agent(
                name="Bedrock Agent",
                system_prompt=(
                    "You are a helpful assistant with expertise in "
                    "Kubernetes troubleshooting."
                ),
                model=BedrockModel(
                    model_id="us.anthropic.claude-3-5-sonnet-20241022-v2:0"
                ),
                tools=tools
            )
            
            # Get response
            response = agent(message)
            
            # Stream response
            words = str(response).split()
            for i, word in enumerate(words):
                yield f"data: {json.dumps({'chunk': word + ' ', 'index': i})}\n\n"
                await asyncio.sleep(0.03)
            
            yield f"data: {json.dumps({'done': True})}\n\n"
            logger.info("Response completed")
            
        except Exception as e:
            logger.error(f"Error: {e}")
            yield f"data: {json.dumps({'error': str(e)})}\n\n"
        finally:
            if client:
                try:
                    client.stop()
                except:
                    pass
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"
        }
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")