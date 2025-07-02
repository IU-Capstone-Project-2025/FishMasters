#!/usr/bin/env python3
"""
Benchmark script for FAISS fish search performance
Tests 20 predefined queries measuring accuracy and timing
Includes interactive menu for different benchmark configurations
"""

import os
import sys
import time
import statistics
import json
from typing import List, Dict, Any, Tuple
from dotenv import load_dotenv
from faiss_from_qdrant import FaissFromQdrantDatabase
from qwen_embeddings import QwenEmbedder

# Load environment variables
load_dotenv()


class FishSearchBenchmark:
    """Benchmark class for testing fish search performance"""
    
    def __init__(self, collection_name: str = "fish_embeddings_20250627_102709", 
                 faiss_index_path: str = "qdrant_faiss_index.faiss"):
        """Initialize benchmark with database and embedder"""
        self.vector_db = FaissFromQdrantDatabase(
            collection_name=collection_name,
            faiss_index_path=faiss_index_path
        )
        self.embedder = QwenEmbedder()
        
        # 20 predefined test queries
        self.test_queries = [
            "small colorful tropical fish with bright stripes",
            "large predatory fish with sharp teeth in deep ocean",
            "freshwater fish commonly used for aquaculture",
            "bottom-dwelling fish that feeds on algae and debris",
            "schooling fish that forms large groups in open water",
            "flatfish that camouflages with sandy ocean floor",
            "eel-like fish that burrows in mud",
            "brightly colored reef fish with venomous spines",
            "salmon-like fish that migrates between fresh and salt water",
            "ray or skate with electric organs",
            "tiny fish used as bait for larger species",
            "fish with elongated snout used for spearing prey",
            "cold water fish found in polar regions",
            "fish with transparent or translucent body",
            "aggressive territorial fish that guards its nest",
            "filter-feeding fish that consumes plankton",
            "nocturnal fish that hunts at night",
            "fish with barbels used for sensing food",
            "high-speed pelagic fish capable of long migrations",
            "ornamental fish popular in home aquariums"
        ]
        
        # Expected accuracy thresholds
        self.accuracy_thresholds = {
            "excellent": 0.8,
            "good": 0.6,
            "fair": 0.4,
            "poor": 0.2
        }
        
    def run_benchmark(self, top_k: int = 5, iterations: int = 3) -> Dict[str, Any]:
        """
        Run complete benchmark test
        
        Args:
            top_k: Number of top results to retrieve per query
            iterations: Number of times to run each query for timing accuracy
            
        Returns:
            Dictionary with benchmark results
        """
        print("🚀 Starting Fish Search Benchmark")
        print(f"📊 Testing {len(self.test_queries)} queries with top_k={top_k}")
        print(f"🔄 Running {iterations} iterations per query for timing accuracy")
        print("=" * 60)
        
        # Verify database status
        stats = self.vector_db.get_stats()
        print(f"📋 Database Status:")
        print(f"   Qdrant points: {stats['qdrant_points']}")
        print(f"   FAISS vectors: {stats['faiss_vectors']}")
        print(f"   Index synchronized: {stats['index_synchronized']}")
        print()
        
        if stats['qdrant_points'] == 0:
            raise RuntimeError("No fish data found in database. Please load data first.")
        
        # Run benchmark
        results = {
            "benchmark_info": {
                "total_queries": len(self.test_queries),
                "top_k": top_k,
                "iterations_per_query": iterations,
                "database_stats": stats
            },
            "query_results": [],
            "timing_statistics": {},
            "accuracy_statistics": {},
            "summary": {}
        }
        
        all_embedding_times = []
        all_search_times = []
        all_total_times = []
        all_similarity_scores = []
        
        # Process each query
        for i, query in enumerate(self.test_queries):
            print(f"🔍 Query {i+1}/{len(self.test_queries)}: '{query[:50]}{'...' if len(query) > 50 else ''}'")
            
            query_results = self._benchmark_single_query(query, top_k, iterations)
            results["query_results"].append(query_results)
            
            # Collect statistics
            all_embedding_times.extend(query_results["embedding_times_ms"])
            all_search_times.extend(query_results["search_times_ms"])
            all_total_times.extend(query_results["total_times_ms"])
            all_similarity_scores.extend([score for result_set in query_results["results"] 
                                        for _, score in result_set])
            
            # Show quick results
            avg_search_time = statistics.mean(query_results["search_times_ms"])
            best_similarity = max(score for result_set in query_results["results"] 
                                for _, score in result_set) if query_results["results"] else 0
            
            print(f"   ⏱️  Avg search time: {avg_search_time:.2f}ms")
            print(f"   🎯 Best similarity: {best_similarity:.4f}")
            print()
        
        # Calculate overall statistics
        results["timing_statistics"] = {
            "embedding_time_ms": {
                "mean": statistics.mean(all_embedding_times),
                "median": statistics.median(all_embedding_times),
                "min": min(all_embedding_times),
                "max": max(all_embedding_times),
                "std_dev": statistics.stdev(all_embedding_times) if len(all_embedding_times) > 1 else 0
            },
            "search_time_ms": {
                "mean": statistics.mean(all_search_times),
                "median": statistics.median(all_search_times),
                "min": min(all_search_times),
                "max": max(all_search_times),
                "std_dev": statistics.stdev(all_search_times) if len(all_search_times) > 1 else 0
            },
            "total_time_ms": {
                "mean": statistics.mean(all_total_times),
                "median": statistics.median(all_total_times),
                "min": min(all_total_times),
                "max": max(all_total_times),
                "std_dev": statistics.stdev(all_total_times) if len(all_total_times) > 1 else 0
            }
        }
        
        results["accuracy_statistics"] = {
            "similarity_scores": {
                "mean": statistics.mean(all_similarity_scores),
                "median": statistics.median(all_similarity_scores),
                "min": min(all_similarity_scores),
                "max": max(all_similarity_scores),
                "std_dev": statistics.stdev(all_similarity_scores) if len(all_similarity_scores) > 1 else 0
            },
            "accuracy_distribution": self._calculate_accuracy_distribution(all_similarity_scores)
        }
        
        # Generate summary
        results["summary"] = self._generate_summary(results)
        
        return results
    
    def _benchmark_single_query(self, query: str, top_k: int, iterations: int) -> Dict[str, Any]:
        """Benchmark a single query multiple times"""
        
        query_result = {
            "query": query,
            "embedding_times_ms": [],
            "search_times_ms": [],
            "total_times_ms": [],
            "results": [],
            "embeddings": []  # Store embeddings for potential analysis
        }
        
        for iteration in range(iterations):
            # Time embedding generation
            embed_start = time.time()
            query_embedding = self.embedder.encode_fish_query(query)
            embed_time_ms = (time.time() - embed_start) * 1000
            
            # Time FAISS search
            search_start = time.time()
            search_results, timing_info = self.vector_db.search_with_timing(query_embedding, top_k)
            search_time_ms = timing_info.get('total_time', 0) * 1000
            
            total_time_ms = embed_time_ms + search_time_ms
            
            # Store timing results
            query_result["embedding_times_ms"].append(embed_time_ms)
            query_result["search_times_ms"].append(search_time_ms)
            query_result["total_times_ms"].append(total_time_ms)
            query_result["results"].append(search_results)
            
            if iteration == 0:  # Store embedding only once
                query_result["embeddings"].append(query_embedding[:10])  # First 10 dims for analysis
        
        return query_result
    
    def _calculate_accuracy_distribution(self, similarity_scores: List[float]) -> Dict[str, Any]:
        """Calculate how results are distributed across accuracy thresholds"""
        distribution = {category: 0 for category in self.accuracy_thresholds.keys()}
        distribution["total"] = len(similarity_scores)
        
        for score in similarity_scores:
            if score >= self.accuracy_thresholds["excellent"]:
                distribution["excellent"] += 1
            elif score >= self.accuracy_thresholds["good"]:
                distribution["good"] += 1
            elif score >= self.accuracy_thresholds["fair"]:
                distribution["fair"] += 1
            else:
                distribution["poor"] += 1
        
        # Calculate percentages
        distribution_pct = {}
        for category in self.accuracy_thresholds.keys():
            distribution_pct[f"{category}_pct"] = (distribution[category] / distribution["total"] * 100) if distribution["total"] > 0 else 0
        
        distribution.update(distribution_pct)
        return distribution
    
    def _generate_summary(self, results: Dict[str, Any]) -> Dict[str, Any]:
        """Generate benchmark summary"""
        timing_stats = results["timing_statistics"]
        accuracy_stats = results["accuracy_statistics"]
        
        return {
            "performance_grade": self._calculate_performance_grade(timing_stats, accuracy_stats),
            "key_metrics": {
                "avg_search_time_ms": timing_stats["search_time_ms"]["mean"],
                "avg_accuracy": accuracy_stats["similarity_scores"]["mean"],
                "excellent_results_pct": accuracy_stats["accuracy_distribution"]["excellent_pct"],
                "total_operations": len(results["query_results"]) * results["benchmark_info"]["iterations_per_query"]
            },
            "recommendations": self._generate_recommendations(timing_stats, accuracy_stats)
        }
    
    def _calculate_performance_grade(self, timing_stats: Dict, accuracy_stats: Dict) -> str:
        """Calculate overall performance grade"""
        avg_search_time = timing_stats["search_time_ms"]["mean"]
        avg_accuracy = accuracy_stats["similarity_scores"]["mean"]
        excellent_pct = accuracy_stats["accuracy_distribution"]["excellent_pct"]
        
        # Speed scoring (lower is better)
        if avg_search_time < 10:
            speed_score = 4
        elif avg_search_time < 50:
            speed_score = 3
        elif avg_search_time < 100:
            speed_score = 2
        else:
            speed_score = 1
        
        # Accuracy scoring
        if excellent_pct > 70:
            accuracy_score = 4
        elif excellent_pct > 50:
            accuracy_score = 3
        elif excellent_pct > 30:
            accuracy_score = 2
        else:
            accuracy_score = 1
        
        total_score = (speed_score + accuracy_score) / 2
        
        if total_score >= 3.5:
            return "A"
        elif total_score >= 2.5:
            return "B"
        elif total_score >= 1.5:
            return "C"
        else:
            return "D"
    
    def _generate_recommendations(self, timing_stats: Dict, accuracy_stats: Dict) -> List[str]:
        """Generate performance improvement recommendations"""
        recommendations = []
        
        avg_search_time = timing_stats["search_time_ms"]["mean"]
        avg_embedding_time = timing_stats["embedding_time_ms"]["mean"]
        excellent_pct = accuracy_stats["accuracy_distribution"]["excellent_pct"]
        
        if avg_search_time > 100:
            recommendations.append("Search time is high - consider optimizing FAISS index or reducing database size")
        
        if avg_embedding_time > 500:
            recommendations.append("Embedding generation is slow - consider using a faster embedding model or GPU acceleration")
        
        if excellent_pct < 30:
            recommendations.append("Low accuracy results - consider improving embedding model or expanding fish dataset")
        
        if timing_stats["search_time_ms"]["std_dev"] > avg_search_time * 0.5:
            recommendations.append("High timing variance detected - system may be under load or index needs rebuilding")
        
        if not recommendations:
            recommendations.append("System performance is good - consider running larger benchmarks or stress tests")
        
        return recommendations
    
    def print_results(self, results: Dict[str, Any]):
        """Print formatted benchmark results"""
        print("\n" + "=" * 60)
        print("📊 BENCHMARK RESULTS")
        print("=" * 60)
        
        # Summary
        summary = results["summary"]
        print(f"\n🏆 Performance Grade: {summary['performance_grade']}")
        print(f"⚡ Average Search Time: {summary['key_metrics']['avg_search_time_ms']:.2f}ms")
        print(f"🎯 Average Accuracy: {summary['key_metrics']['avg_accuracy']:.4f}")
        print(f"✨ Excellent Results: {summary['key_metrics']['excellent_results_pct']:.1f}%")
        
        # Detailed timing statistics
        timing = results["timing_statistics"]
        print(f"\n⏱️  TIMING STATISTICS:")
        print(f"   Embedding Generation:")
        print(f"     Mean: {timing['embedding_time_ms']['mean']:.2f}ms")
        print(f"     Range: {timing['embedding_time_ms']['min']:.2f} - {timing['embedding_time_ms']['max']:.2f}ms")
        print(f"   FAISS Search:")
        print(f"     Mean: {timing['search_time_ms']['mean']:.2f}ms")
        print(f"     Range: {timing['search_time_ms']['min']:.2f} - {timing['search_time_ms']['max']:.2f}ms")
        print(f"   Total Time:")
        print(f"     Mean: {timing['total_time_ms']['mean']:.2f}ms")
        print(f"     Range: {timing['total_time_ms']['min']:.2f} - {timing['total_time_ms']['max']:.2f}ms")
        
        # Accuracy statistics
        accuracy = results["accuracy_statistics"]
        print(f"\n🎯 ACCURACY STATISTICS:")
        print(f"   Similarity Scores:")
        print(f"     Mean: {accuracy['similarity_scores']['mean']:.4f}")
        print(f"     Range: {accuracy['similarity_scores']['min']:.4f} - {accuracy['similarity_scores']['max']:.4f}")
        print(f"   Result Distribution:")
        dist = accuracy["accuracy_distribution"]
        print(f"     Excellent (≥0.8): {dist['excellent']} ({dist['excellent_pct']:.1f}%)")
        print(f"     Good (≥0.6): {dist['good']} ({dist['good_pct']:.1f}%)")
        print(f"     Fair (≥0.4): {dist['fair']} ({dist['fair_pct']:.1f}%)")
        print(f"     Poor (<0.4): {dist['poor']} ({dist['poor_pct']:.1f}%)")
        
        # Recommendations
        print(f"\n💡 RECOMMENDATIONS:")
        for rec in summary["recommendations"]:
            print(f"   • {rec}")
        
        print("\n" + "=" * 60)
    
    def save_results(self, results: Dict[str, Any], filename: str = "benchmark_results.json"):
        """Save benchmark results to JSON file"""
        with open(filename, 'w') as f:
            json.dump(results, f, indent=2, default=str)
        print(f"📁 Results saved to {filename}")


# Benchmark runner functions
def run_quick_benchmark():
    """Run a quick benchmark with fewer iterations"""
    print("🚀 Running Quick Benchmark (1 iteration per query)")
    print("=" * 50)
    
    benchmark = FishSearchBenchmark()
    results = benchmark.run_benchmark(top_k=3, iterations=1)
    benchmark.print_results(results)
    benchmark.save_results(results, "quick_benchmark.json")

def run_standard_benchmark():
    """Run standard benchmark"""
    print("🚀 Running Standard Benchmark (3 iterations per query)")
    print("=" * 50)
    
    benchmark = FishSearchBenchmark()
    results = benchmark.run_benchmark(top_k=5, iterations=3)
    benchmark.print_results(results)
    benchmark.save_results(results, "standard_benchmark.json")

def run_comprehensive_benchmark():
    """Run comprehensive benchmark with more iterations"""
    print("🚀 Running Comprehensive Benchmark (5 iterations per query)")
    print("=" * 50)
    
    benchmark = FishSearchBenchmark()
    results = benchmark.run_benchmark(top_k=10, iterations=5)
    benchmark.print_results(results)
    benchmark.save_results(results, "comprehensive_benchmark.json")

def run_custom_benchmark():
    """Run benchmark with custom parameters"""
    print("🚀 Running Custom Benchmark")
    print("=" * 50)
    
    # Get custom parameters
    try:
        top_k = int(input("Enter top_k (number of results per query, default 5): ") or "5")
        iterations = int(input("Enter iterations (number of runs per query, default 3): ") or "3")
        filename = input("Enter output filename (default: custom_benchmark.json): ") or "custom_benchmark.json"
        
        print(f"\nRunning benchmark with top_k={top_k}, iterations={iterations}")
        
        benchmark = FishSearchBenchmark()
        results = benchmark.run_benchmark(top_k=top_k, iterations=iterations)
        benchmark.print_results(results)
        benchmark.save_results(results, filename)
        
    except ValueError as e:
        print(f"❌ Invalid input: {e}")
    except KeyboardInterrupt:
        print("\n⚠️  Benchmark cancelled by user")

def show_test_queries():
    """Display the 20 test queries that will be used"""
    benchmark = FishSearchBenchmark()
    
    print("📋 TEST QUERIES")
    print("=" * 50)
    print("The benchmark will test these 20 fish-related queries:")
    print()
    
    for i, query in enumerate(benchmark.test_queries, 1):
        print(f"{i:2d}. {query}")
    
    print(f"\nTotal: {len(benchmark.test_queries)} queries")

def run_interactive_menu():
    """Main menu for benchmark runner"""
    print("🐟 Fish Search Benchmark Runner")
    print("=" * 40)
    print("Choose a benchmark configuration:")
    print()
    print("1. Quick Benchmark (1 iteration, top_k=3)")
    print("2. Standard Benchmark (3 iterations, top_k=5)")
    print("3. Comprehensive Benchmark (5 iterations, top_k=10)")
    print("4. Custom Benchmark (choose your parameters)")
    print("5. Show Test Queries")
    print("6. Exit")
    print()
    
    try:
        choice = input("Enter your choice (1-6): ").strip()
        
        if choice == "1":
            run_quick_benchmark()
        elif choice == "2":
            run_standard_benchmark()
        elif choice == "3":
            run_comprehensive_benchmark()
        elif choice == "4":
            run_custom_benchmark()
        elif choice == "5":
            show_test_queries()
        elif choice == "6":
            print("👋 Goodbye!")
            sys.exit(0)
        else:
            print("❌ Invalid choice. Please select 1-6.")
            run_interactive_menu()
    
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")
        sys.exit(0)
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    """Main entry point"""
    try:
        if len(sys.argv) > 1:
            # Command line arguments
            if sys.argv[1] == "quick":
                run_quick_benchmark()
            elif sys.argv[1] == "standard":
                run_standard_benchmark()
            elif sys.argv[1] == "comprehensive":
                run_comprehensive_benchmark()
            elif sys.argv[1] == "queries":
                show_test_queries()
            elif sys.argv[1] == "menu":
                run_interactive_menu()
            else:
                print("Usage: python benchmark.py [quick|standard|comprehensive|queries|menu]")
                print("Or run without arguments for default standard benchmark")
        else:
            # Default: run standard benchmark
            run_standard_benchmark()
            
    except Exception as e:
        print(f"❌ Benchmark failed: {e}")
        print("\nMake sure you have:")
        print("1. Set up QDRANT_URL and QDRANT_API_KEY in .env file")
        print("2. Loaded fish embeddings data")
        print("3. Built FAISS index")


if __name__ == "__main__":
    main()