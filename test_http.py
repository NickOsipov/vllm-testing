"""
Test HTTP request to the Mistral AI API
"""

import os

import httpx
from pprint import pprint
from dotenv import load_dotenv

load_dotenv()

LLM_HOST = os.getenv("LLM_HOST")
LLM_PORT = os.getenv("LLM_PORT")
LLM_URL = f"http://{LLM_HOST}:{LLM_PORT}/v1"

url = f"{LLM_URL}/completions"

headers = {
    "Content-Type": "application/json"
}
data = {
    "model": "mistralai/Mistral-7B-v0.1",
    "prompt": "Tell me a joke.",
    "max_tokens": 100,
    "temperature": 0.5
}

# Make the POST request using httpx
with httpx.Client() as client:
    response = client.post(
        url=url,
        headers=headers,
        json=data
    )
    pprint(response.json())
