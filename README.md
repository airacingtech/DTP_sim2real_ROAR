# How to Do Sim2Real - A Guide

for an in depth look please refer to [Leveraging Zero-Shot Sim2Real Learning
to Improve Autonomous Vehicle Perception](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2024/EECS-2024-90.pdf) 

So… you have a ton of simulation data, and want to make it look realistic. Well, look no further, since you’re in the right place. Welcome to a guide on sim2real conversion using the Deep Translation Prior paper. The process is outlined below:

### 1. Gather Your Simulation Data Images
These are typically images taken from the OSSDC/LGSVL simulator through one of the simulated “vimba” cameras. Extract however many images you would like from the rosbags, at any sampling rate you desire (depending on how many output images you would like).

### 2. Resize Your Simulation Images
Ideally, if the simulator is configured correctly, your images should be in the proper true-to-world vehicle image dimensions of 512 x 384. If not, then be sure to run the `resize_images_to_512_384.py` script from the GitHub repository.

### 3. Label Your Simulation Images
Labeling images can often be a very tedious process, but nonetheless is an essential and mandatory part of the process. To create segmentation masks for each of the simulation images, utilize the Computer Vision Annotation Tool (CVAT) software. For instructions on how to do this, please refer to the ROAR tool **roar-seg-and-track-anything** [here](https://github.com/airacingtech/roar-seg-and-track-anything). Thereafter, you should receive a set of images, and corresponding bounding box labels for all race cars in the frame.

### 4. Convert Bounding Box Labels to Segmentation Masks
To convert from bounding boxes (YOLOv7) to segmentation masks (YOLOv8), we can leverage the Segment Anything Model (SAM) from Meta AI, in order to do the conversion for us. Clone the `yolobbox2seg` repository found [here](https://github.com/facebookresearch/segment-anything) into your computer, and follow the instructions provided in the README. Finally, you should now have a series of images and their corresponding segmentation masks in YOLOv8 format, and can now proceed forth!

### 5. Gather Your Real-World Images
This step may take a little experimenting, so my recommendation is to gather a small subset (a few dozen) of real-world images that you would like the outputs to visually match. The reason for selecting a few images is because some may produce artifacts (depending on the quality of images, resolution, etc.), but typically this step is not needed. Nonetheless, better safe than sorry.

### 6. Create Your Data Folders
First, create an `inputs/` folder in the main repository, and two subfolders within it titled `sim/` and `real/`. Then, place all the simulation data and real data from previous steps into each respective corresponding folder. Finally, create a `results/` folder on the same level as the `inputs/` folder, to store all output experimental runs.

### 7. Modify Your Model Parameters
Open up the `optimizer.sh` file in the repository, and recognize a few key parameters:

**Mandatory Parameters to Modify:**

- Change `--content_root` to point to the `real/` directory you defined above.
- Modify `--style_root` to point to the `sim/` directory.
- Finally, set `--save_root` to point to an output directory you would like to save to, typically in a descriptive naming format `./results/your_experiment_name` for future reference.
- In addition, set `--fileType jpg` to save `.jpg` outputs, or feel free to use `.png` or another file format if desired.

**Modifiable Parameters Affecting Output:**

- `--iter` represents the total number of iterations you would like to fine-tune the image for. For our purposes, I recommend using 1000 iterations to experiment with different iteration values, but ultimately ended up with good results anywhere above 750-800 iterations max (saving time).
- `--sample_freq` represents how often you want to checkpoint the image outputs in the above process. I recommend a value of 200 just to store intermediate results and see whether an earlier value may be just as good quality as a higher iteration value, but is faster to create and saves time.
- `--content_style_wt` represents how much you want to weigh the content (sim) and style (real) images in the sim2real conversion process. Through extensive testing, I have determined a value of 0.4 works perfectly for our use-case, but this may change as the real-world images used in the process differ from the 2023/2024 camera visuals.
- `--cycle_wt` represents how much you want to weigh the cycle consistency loss value in the process. This has a default value of 1.0, and I have determined that this value tends to work best for our specific real image domain at the time. Feel free to increase or decrease this value accordingly if desired.

### 8. Run the Sim2Real Model!
To do this, simply run the `bash optimizer.sh` command in your terminal, and watch as the magic unfolds.

### 9. Observe the Outputs and Conversion Quality
The way the codebase is designed, it will store a plethora of information for every image pair used in the sim2real generation process. The reason I coded it this way is to make it easy for the user to run visual experiments and compare outputs for the sim2real conversions, and quickly iterate on tuning parameters if needed to achieve the desired output. In order to have an easier way to compare the outputs, run the `make_new_dir_grouped_by_sim.py` script, which will group together all the outputs by their respective simulation image, in order to see how each real image and set of parameters affects the simulation → sim2real output. If the outputs don’t appear up to standard, return to Step 5 and try a new set of parameters. Once the outputs look good, proceed forth to Step 10 below for next steps.

### 10. Extract the Sim2Real Converted Images to Be Placed Into Your Dataset
In order to extract only the output sim2real converted images from the detailed directory structure, simply run the script titled `make_new_dir_with_output_images_only.py`, which will create an output directory containing only the sim2real images. This directory will serve as a perfect 1:1 match to every single input simulation image you provided in the `sim/` folder early in the process. Now, instead of training your output model on the simulation image, you can train on the newly generated folder of sim2real converted images, and the process is complete!


## Citation
If you find this research useful, please consider citing:
````BibTeX
@article{kim2021deep,
  title={Deep Translation Prior: Test-time Training for Photorealistic Style Transfer},
  author={Kim, Sunwoo and Kim, Soohyun and Kim, Seungryong},
  journal={arXiv preprint arXiv:2112.06150},
  year={2021}
}
````
