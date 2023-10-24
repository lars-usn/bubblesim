# Ultrasound Contrast Bubble Simulation
## Bubblesim Overview

- Simulator for estimating the radial oscillation and scattered sound from an ultrasound contrast bubble.
- Implemented as a toolbox in MATLAB.
- Updated and tested in Matlab ver. 7.0, originally written for Matlab 5.2
- Developed as a part of my doctoral studies at NTNU, The Norwegian University of Science and Technology.
- Main application is to simulate contrast agents for medical ultrasound imaging
- Designed for micrometer-sized bubbles exposed to Megahertz-frequency ultrasound.
- Only the radial oscillation mode is included, i.e. the oscillation is spherically symmetric.
- Nonlinear terms are fully included, the response is calculated by simulating an ODE in the time domain.
- Shell is included by a viscoelastic material model. Thickness and viscoelastic parameters of the shell must be specified by the user.

## Warning
Please be aware that this program is very experimental, and the documentation is not as extensive as it should be.

## Examples of use
An example of program operation is shown below. The left image is the graphical user interface used to specify bubble, pulse and calculation parameters. The right image shows the results of the simulation, containing the driving ultrasound pulse, the bubble radius and scattered sound pulse in the time domain, and the power spectra of the driving pulse and of the scattered sound.

!(BubblesimMenuSmall.png)
