#!/usr/bin/env python3
"""
Script to make icon background transparent
"""
from PIL import Image
import sys

def make_transparent(input_path, output_path, threshold=250):
    """
    Convert white/light backgrounds to transparent
    threshold: RGB value above which pixels become transparent (default 250)
    """
    # Open the image
    img = Image.open(input_path)
    
    # Convert to RGBA if not already
    img = img.convert("RGBA")
    
    # Get pixel data
    datas = img.getdata()
    
    # Create new data with transparency
    newData = []
    for item in datas:
        # Change all white (or near-white) pixels to transparent
        if item[0] > threshold and item[1] > threshold and item[2] > threshold:
            newData.append((255, 255, 255, 0))  # Transparent
        else:
            newData.append(item)
    
    # Update image data
    img.putdata(newData)
    
    # Save as PNG with transparency
    img.save(output_path, "PNG")
    print(f"Created transparent icon: {output_path}")

if __name__ == "__main__":
    input_file = "window/Assets.xcassets/win.imageset/win.png"
    output_file = "window/Assets.xcassets/win.imageset/win.png"
    
    make_transparent(input_file, output_file)
