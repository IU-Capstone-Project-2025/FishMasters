#!/usr/bin/env python3
"""
Example script demonstrating how to use the FishMasters ML API
"""

import requests
import json
import time
from typing import Dict, Any


class FishSearchClient:
    """Client for interacting with the FishMasters ML API"""
    
    def __init__(self, base_url: str = "http://localhost:5001"):
        self.base_url = base_url.rstrip('/')
        
    def get_status(self) -> Dict[str, Any]:
        """Get current API status"""
        response = requests.get(f"{self.base_url}/status")
        response.raise_for_status()
        return response.json()
    
    def initialize_system(self, mode: str) -> Dict[str, Any]:
        """Initialize the system with specified mode"""
        data = {"mode": mode}
        response = requests.post(f"{self.base_url}/initialize", json=data)
        response.raise_for_status()
        return response.json()
    
    def search_fish(self, description: str, top_k: int = 5, mode: str = "auto") -> Dict[str, Any]:
        """Search for fish by description"""
        data = {
            "description": description,
            "top_k": top_k,
            "mode": mode
        }
        response = requests.post(f"{self.base_url}/search", json=data)
        response.raise_for_status()
        return response.json()
    
    def health_check(self) -> Dict[str, Any]:
        """Check API health"""
        response = requests.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()


def print_separator(title: str):
    """Print a formatted separator"""
    print("\n" + "="*60)
    print(f" {title}")
    print("="*60)


def print_search_results(result: Dict[str, Any]):
    """Print search results in a formatted way"""
    print(f"\n🔍 Query: '{result['query']}'")
    print(f"🤖 Mode used: {result['mode_used']}")
    print(f"⏱️  Total time: {result['total_time']:.4f} seconds")
    
    if result['timing']:
        print("\n📊 Timing breakdown:")
        for key, value in result['timing'].items():
            print(f"   {key}: {value:.6f}s")
    
    print(f"\n🎯 Found {len(result['results'])} results:")
    print("-" * 50)
    
    for i, fish in enumerate(result['results'], 1):
        print(f"\n{i}. 🐟 {fish['name']}")
        print(f"   📊 Similarity: {fish['similarity_score']:.4f}")
        
        if fish['genus'] or fish['species']:
            taxonomy = f"{fish['genus'] or ''} {fish['species'] or ''}".strip()
            print(f"   🧬 Taxonomy: {taxonomy}")
        
        if fish['fbname'] and fish['fbname'] != fish['name']:
            print(f"   🏷️  Common name: {fish['fbname']}")
        
        if fish['description']:
            print(f"   📝 Description: {fish['description']}")


def demo_low_resources(client: FishSearchClient):
    """Demonstrate low resources mode"""
    print_separator("LOW RESOURCES MODE DEMO")
    
    print("Initializing system in low resources mode...")
    init_result = client.initialize_system("low_resources")
    print(f"✅ {init_result['message']}")
    
    # Test searches with random vectors
    queries = [
        "large predatory fish with sharp teeth",
        "small colorful tropical fish",
        "elongated eel-like fish"
    ]
    
    for query in queries:
        print(f"\n🔍 Searching: '{query}'")
        result = client.search_fish(query, top_k=3)
        print_search_results(result)
        time.sleep(1)  # Small delay between requests


def demo_high_resources(client: FishSearchClient):
    """Demonstrate high resources mode"""
    print_separator("HIGH RESOURCES MODE DEMO")
    
    print("Initializing system in high resources mode...")
    print("⚠️  This will download and load the Qwen model (may take a while)...")
    
    try:
        init_result = client.initialize_system("high_resources")
        print(f"✅ {init_result['message']}")
        
        # Test semantic searches
        queries = [
            "aggressive predator with powerful jaws",
            "bottom-dwelling scavenger fish",
            "fast swimming oceanic species",
            "colorful reef fish with stripes"
        ]
        
        for query in queries:
            print(f"\n🔍 Semantic search: '{query}'")
            result = client.search_fish(query, top_k=3)
            print_search_results(result)
            time.sleep(1)
            
    except Exception as e:
        print(f"❌ Failed to initialize high resources mode: {e}")
        print("💡 This might be due to missing dependencies or insufficient resources")


def demo_mode_comparison(client: FishSearchClient):
    """Compare results between different modes"""
    print_separator("MODE COMPARISON DEMO")
    
    query = "large predatory fish"
    
    # Initialize in high resources mode
    try:
        client.initialize_system("high_resources")
        
        print(f"Comparing search results for: '{query}'")
        
        # Low resources search
        print(f"\n🎲 Low resources mode (random vectors):")
        low_result = client.search_fish(query, top_k=3, mode="low_resources")
        print_search_results(low_result)
        
        # High resources search  
        print(f"\n🤖 High resources mode (semantic search):")
        high_result = client.search_fish(query, top_k=3, mode="high_resources")
        print_search_results(high_result)
        
        # Performance comparison
        print(f"\n📈 Performance comparison:")
        print(f"   Low resources:  {low_result['total_time']:.4f}s")
        print(f"   High resources: {high_result['total_time']:.4f}s")
        speedup = high_result['total_time'] / low_result['total_time']
        print(f"   Speed ratio:    {speedup:.2f}x")
        
    except Exception as e:
        print(f"❌ Could not run comparison: {e}")


def main():
    """Main demo function"""
    print("🐟 FishMasters ML API Demo")
    print("This script demonstrates the fish search API functionality")
    
    client = FishSearchClient()
    
    # Check if API is running
    try:
        health = client.health_check()
        print(f"✅ API is running: {health['service']}")
    except Exception as e:
        print(f"❌ Could not connect to API: {e}")
        print("💡 Make sure the API server is running with: python app.py")
        return
    
    # Show initial status
    status = client.get_status()
    print(f"\n📊 Initial status: {status['message']}")
    print(f"   Database loaded: {status['database_loaded']}")
    print(f"   Qwen loaded: {status['qwen_loaded']}")
    print(f"   Fish count: {status['fish_count']}")
    
    try:
        # Demo low resources mode
        demo_low_resources(client)
        
        # Ask user if they want to try high resources mode
        print(f"\n" + "="*60)
        user_input = input("Try high resources mode? (y/N): ").strip().lower()
        
        if user_input in ['y', 'yes']:
            demo_high_resources(client)
            
            # Ask about comparison
            user_input = input("\nRun mode comparison? (y/N): ").strip().lower()
            if user_input in ['y', 'yes']:
                demo_mode_comparison(client)
        
        print_separator("DEMO COMPLETED")
        print("✅ Demo completed successfully!")
        print("💡 You can now use the API endpoints in your applications")
        print("📖 Visit http://localhost:5001/docs for interactive API documentation")
        
    except KeyboardInterrupt:
        print("\n🛑 Demo interrupted by user")
    except Exception as e:
        print(f"\n❌ Demo failed: {e}")


if __name__ == "__main__":
    main() 