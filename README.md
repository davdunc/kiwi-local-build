# Kiwi Local Build System for Cloud-Base-AmazonEC2

This project provides tools to build Fedora kiwi images locally using Podman containers. It specifically builds the "Cloud-Base-AmazonEC2" OEM image profile from the official Fedora kiwi-descriptions repository for the specified branches.

## Prerequisites

- Podman installed and running
- Sudo privileges (required for running privileged containers)
- Sufficient disk space for building images
- Internet connection to pull repositories
- SELinux in Permissive or Disabled mode (kiwi will not function correctly with SELinux in Enforcing mode)

## Quick Start

1. Clone this repository:
   ```
   git clone https://github.com/davdunc/kiwi-local-build.git
   cd kiwi-local-build
   ```

2. Ensure SELinux is in Permissive mode:
   ```
   sudo setenforce 0
   ```

3. Run the build script:
   ```
   ./run-local-build.sh
   ```

This will build the Cloud-Base-AmazonEC2 image for all branches (rawhide, f41, f42).

## SELinux Requirements

Kiwi builds require SELinux to be in Permissive or Disabled mode. The build script will:
- Check your current SELinux mode
- Fail with an error if SELinux is in Enforcing mode

To check your SELinux status:
```
getenforce
```

To temporarily set SELinux to Permissive mode:
```
sudo setenforce 0
```

To permanently change SELinux mode, edit `/etc/selinux/config` and set `SELINUX=permissive`.

## Usage Options

### Build for a specific branch

```
./run-local-build.sh --branch rawhide
```

Available branch options: `rawhide`, `f41`, `f42`

### Specify output directory

```
./run-local-build.sh --output-dir /path/to/output
```

### Combine options

```
./run-local-build.sh --branch f41 --output-dir ./my-images
```

## Output

Built images will be available in the `output` directory (or your specified output directory), organized by branch. The script will automatically fix permissions on the output directory since it's created by the root user inside the container.

## Troubleshooting

If you encounter issues:

1. Verify SELinux is in Permissive or Disabled mode
2. Ensure you have sudo privileges
3. Ensure Podman has sufficient resources allocated
4. Check network connectivity to Pagure and Fedora repositories
5. Verify you have sufficient disk space
6. Look at the build logs for specific error messages

## Directory Structure

- `Containerfile`: Container definition for building images
- `scripts/`: Build scripts used inside the container
- `output/`: Default location for built images

## Important Note

This build system uses Podman exclusively. Do not use Docker for these builds.
The script requires sudo privileges to run privileged containers.
