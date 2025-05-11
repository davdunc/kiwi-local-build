# Fedora Cloud Base Amazon EC2 Image Changelog

## Fedora Rawhide (May 2025)
This release includes the latest Fedora Rawhide build with GCC 15.1, featuring significant compiler improvements and optimizations. The image is built with the Cloud-Base-AmazonEC2 profile, providing a minimal cloud-ready base image optimized for AWS EC2 instances. Key updates include kernel optimizations for virtualized environments, enhanced cloud-init integration, and improved boot performance.

## Fedora 42 (May 2025)
The Fedora 42 Cloud Base image for Amazon EC2 includes the stable 6.14.5-300 kernel with improved virtualization support and cloud performance optimizations. This release features systemd 257.5 with enhanced service management capabilities, updated cloud-init for better AWS integration, and the latest security patches.

## Build Information
These images were built using the kiwi-local-build system, which creates standardized Fedora Cloud images using the official fedora-kiwi-descriptions repository. The build process ensures consistent image creation with proper AWS EC2 integration, including optimized partition layout, secure boot support, minimal package selection, and cloud-init configuration for AWS.
