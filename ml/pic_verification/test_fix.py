#!/usr/bin/env python3
"""
Simple test script to verify SSL and import fixes work correctly.
"""

import os
import sys

def test_imports():
    """Test that all required imports work"""
    print("🧪 Testing imports...")
    
    try:
        print("  - Testing torch...")
        import torch
        print(f"    ✅ torch {torch.__version__}")
        
        print("  - Testing torchvision...")
        import torchvision
        print(f"    ✅ torchvision {torchvision.__version__}")
        
        print("  - Testing PIL...")
        from PIL import Image
        print("    ✅ PIL (Pillow)")
        
        print("  - Testing other dependencies...")
        import pandas as pd
        import numpy as np
        from tqdm import tqdm
        print("    ✅ pandas, numpy, tqdm")
        
        return True
    except ImportError as e:
        print(f"    ❌ Import error: {e}")
        return False

def test_embedder():
    """Test Embedder class initialization"""
    print("\n🔧 Testing Embedder class...")
    
    try:
        from embedder import Embedder
        print("  - Creating Embedder instance...")
        embedder = Embedder()
        print("  ✅ Embedder created successfully")
        return True
    except Exception as e:
        print(f"  ❌ Embedder error: {e}")
        return False

def test_existing_images():
    """Test loading existing images"""
    print("\n📁 Testing existing image data...")
    
    try:
        from embedder import pic_from_fishbase
        print("  - Loading existing fish data...")
        fish_data = pic_from_fishbase(max_images=5, download_new=False)
        
        if not fish_data.empty:
            print(f"  ✅ Found {len(fish_data)} fish with images")
            print(f"  📊 Columns: {list(fish_data.columns)}")
            return True
        else:
            print("  ⚠️ No existing images found (this is normal if no images were downloaded yet)")
            return True
    except Exception as e:
        print(f"  ❌ Error loading images: {e}")
        return False

def main():
    print("🐟 Fish Image Processing - SSL Fix Test 🐟")
    print("=" * 50)
    
    # Test 1: Check imports
    imports_ok = test_imports()
    
    # Test 2: Check Embedder (this tests SSL fix)
    embedder_ok = test_embedder()
    
    # Test 3: Check existing images
    images_ok = test_existing_images()
    
    print("\n" + "=" * 50)
    print("📋 TEST SUMMARY:")
    print(f"  Imports: {'✅ PASS' if imports_ok else '❌ FAIL'}")
    print(f"  Embedder: {'✅ PASS' if embedder_ok else '❌ FAIL'}")
    print(f"  Images: {'✅ PASS' if images_ok else '❌ FAIL'}")
    
    if all([imports_ok, embedder_ok, images_ok]):
        print("\n🎉 All tests passed! The SSL fix worked.")
        print("💡 You can now run: python embedder.py --test-run")
    else:
        print("\n⚠️ Some tests failed. Check the error messages above.")
        
        if not imports_ok:
            print("\n🔧 To fix import issues, run:")
            print("   pip install torch torchvision pillow pandas tqdm")
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 