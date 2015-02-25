# kindai-cropper
A client-side JavaScript library that removes unnecessary margins from the images available at Kindai Digital Library 

## How it works
Given a scanned image of a book, kindai-cropper detects the edge lines of the book according to the following procedure:

1. Draw vertical and horizontal scanning lines on the image at regular intervals.
2. Calculate the gradient of intensity at each pixel on the scnning lines.
3. Mark the pixels on the scanning lines which located nearby the edges of the image and where the intensities change rapidly. These pixels can be regarded as the edge points of the book.
4. Remove outliers from the points marked in the third phase to reduce the influences of false recognitions.
5. Draw lines which will minimize the sums of the squares of the distances from each point to the line. In statistics, such lines are called orthogonal regression lines and can be easily calculated.

