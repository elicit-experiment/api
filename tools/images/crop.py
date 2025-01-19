# source python-env/bin/activate

import cv2
import numpy as np
import sys

def replace_white_background_and_crop(image_path):
    # Read the image
    image = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)

    # Check if the image was loaded properly
    if image is None:
        raise ValueError('Invalid image provided.')

    # Convert to RGBA if it's not already
    if image.shape[2] == 3:
        image = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)

    # Define the white color range
    lower_white = np.array([200, 200, 200, 255])
    upper_white = np.array([255, 255, 255, 255])

    # Create a mask for the white areas
    mask = cv2.inRange(image, lower_white, upper_white)

    # Set areas in the original image to transparent
    image[mask == 255] = (0, 0, 0, 0)

    # Find the bounding box of non-transparent pixels
    alpha_channel = image[:,:,3]
    non_zero_pixels = cv2.findNonZero(alpha_channel)
    x, y, w, h = cv2.boundingRect(non_zero_pixels)

    # Crop the image
    cropped_image = image[y:y+h, x:x+w]

    return cropped_image

# Usage
input_image_path = sys.argv[1]
output_image_path = sys.argv[2]

try:
    result = replace_white_background_and_crop(input_image_path)
    cv2.imwrite(output_image_path, result)
    print(f"Processed image saved as {output_image_path}")
except Exception as e:
    print(f"An error occurred: {str(e)}")
