# ROS2 Control Workspace

A containerized ROS2 development environment using Dev Containers for consistent, reproducible builds across different systems.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Development Setup](#development-setup)
- [Building and Running](#building-and-running)
- [Project Structure](#project-structure)
- [Common Commands](#common-commands)
- [GUI Applications](#gui-applications)
- [GPU Support](#gpu-support)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

## Overview

This workspace is configured for ROS2 development using Docker Dev Containers. The setup provides:

- **Containerized Environment**: Isolated development environment with consistent ROS2 distribution (Jazzy)
- **VS Code Integration**: Seamless development experience with VS Code Dev Containers extension
- **GPU Support**: NVIDIA GPU acceleration for accelerated applications
- **X11 Forwarding**: GUI application support for RViz and other visualization tools
- **DDS Communication**: Network and IPC configuration for ROS2 DDS middleware

## Prerequisites

### System Requirements

- **Docker** (20.10+) with [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) for GPU support (optional)
- **VS Code** (1.75+) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- **Linux/macOS** (or Windows with WSL2)


## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ros2_control_ws
```

### 2. Open in VS Code Dev Container

1. Open VS Code
2. Open the workspace folder
3. When prompted, click **"Reopen in Container"** (or use Command Palette: `Dev Containers: Reopen in Container`)
4. VS Code will build and open the Dev Container

### 3. Build the Workspace

Inside the container terminal:

```bash
cd ~/ws
colcon build
```

### 4. Source the Installation

```bash
source install/setup.bash
```

## Development Setup

### Workspace Configuration

The Dev Container is configured via two files:

#### `.devcontainer/devcontainer.json`

Configures VS Code, build context, and container runtime parameters:

- **Container Name**: `localization_container`
- **Base Image**: `osrf/ros:jazzy-desktop-full`
- **Workspace Mount**: Local workspace → `/home/$USER/ws`
- **Extensions**: Pre-installed ROS2 development tools
- **Environment Variables**: ROS settings, ccache, X11 forwarding

#### `Dockerfile`

Builds the container image with:

- ROS2 Jazzy desktop-full distribution
- Development dependencies (gdb, python3-pip, etc.)
- User account matching host system (avoids permission issues)
- Pre-installed Python packages (bottle, glances)

### Key Configuration Features

| Feature | Purpose |
|---------|---------|
| `--cap-add=SYS_PTRACE` | Enable debugging with gdb |
| `--ipc=host` | Shared memory transport (RViz GUIs) |
| `--network=host` | DDS discovery and network access |
| `--pid=host` | Process namespace sharing |
| `--privileged` | USB device access |
| `--gpus=all` | GPU acceleration |
| `--runtime=nvidia` | NVIDIA container runtime |
| X11 volume mount | GUI forwarding to host display |

## Building and Running

### Build Commands

```bash
# Full build of entire workspace
colcon build

# Build specific package
colcon build --packages-select <package_name>

# Build with specific mixin (release, debug, ccache, lld)
colcon build --mixin release ccache

# Build without tests
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release
```

### Source Setup Files

```bash
# Source the install space
source install/setup.bash

# Use overlay (if building on top of existing ROS2 installation)
source /opt/ros/jazzy/setup.bash
source install/setup.bash
```

### Run ROS2 Nodes

```bash
# List available packages
colcon list

# Run a node
ros2 run <package_name> <node_name>

# View the computational graph
ros2 graph
```

### Launch Files

```bash
# Run a launch file
ros2 launch <package_name> <launch_file>.py

# With arguments
ros2 launch <package_name> <launch_file>.py argument:=value
```

## Project Structure

```
ros2_control_ws/
├── .devcontainer/
│   └── devcontainer.json     # VS Code Dev Container configuration
├── src/                       # ROS2 source code
│   └── <packages>            # Individual ROS2 packages
├── build/                     # Colcon build output (generated)
├── install/                   # Installation directory (generated)
├── log/                       # Colcon log output (generated)
├── Dockerfile                # Container image definition
└── README.md                 # This file
```

### Adding Packages

Create new packages in the `src/` directory:

```bash
# Create a new Python package
ros2 pkg create --build-type ament_python <package_name>

# Create a new C++ package
ros2 pkg create --build-type ament_cmake <package_name>
```

## Common Commands

### Development Workflow

```bash
# One-time setup (inside container)
cd ~/ws && source /opt/ros/jazzy/setup.bash

# Build everything
colcon build --symlink-install

# Build and test
colcon test

# View test results
colcon test-result --verbose

# Clean build artifacts
colcon clean build --remove-on-error

# Full clean
colcon clean workspace
```

### ROS2 Tools

```bash
# List packages
ros2 pkg list

# View package info
ros2 pkg prefix <package_name>

# Topic introspection
ros2 topic list
ros2 topic echo <topic_name>
ros2 topic info <topic_name>

# Service discovery
ros2 service list
ros2 service call <service_name> <service_type> "{<args>}"

# Node information
ros2 node list
ros2 node info <node_name>

# Check dependencies
ros2 dependency graph <package_name>
```

### System Introspection

```bash
# View system architecture
ros2 graph

# Record bag file
ros2 bag record <topic_names>

# Play bag file
ros2 bag play <bag_file>

# Check ROS2 environment
ros2 doctor
```

## GUI Applications

### RViz

Launch the ROS2 visualization tool:

```bash
rviz2
```

**Requirements**:
- X11 display forwarding configured in devcontainer.json
- Host X11 socket mounted in container
- `DISPLAY` environment variable set

### Other GUI Tools

Works with any X11-based application:
- Gazebo simulation
- rqt tools
- Custom visualization applications

**Note**: GUI forwarding works best on Linux. macOS users may need [XQuartz](https://www.xquartz.org/), and Windows users should use [WSL2 with X11 support](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps).

## GPU Support

The Dev Container is configured for NVIDIA GPU acceleration using the NVIDIA Container Runtime.

### Verify GPU Access

```bash
# Inside the container
nvidia-smi
```

### Requirements

- NVIDIA GPU with CUDA compute capability 3.5+
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) installed on host
- Docker daemon configured with NVIDIA runtime

### Disable GPU (if needed)

Remove `"--gpus=all"` and `"--runtime=nvidia"` from `devcontainer.json` and rebuild.

## Troubleshooting

### Container Won't Start

1. **Verify Docker is running**:
   ```bash
   docker ps
   ```

2. **Check Docker permissions**:
   ```bash
   sudo usermod -aG docker $USER
   ```

3. **Rebuild the container**:
   - Command Palette: `Dev Containers: Rebuild Container`

### GUI Not Working

1. **Check DISPLAY variable**:
   ```bash
   echo $DISPLAY
   ```

2. **Verify X11 socket access**:
   ```bash
   ls -la /tmp/.X11-unix/
   ```

3. **On Linux, allow X11 access**:
   ```bash
   xhost +local:
   ```

### Build Failures

1. **Update packages**:
   ```bash
   sudo apt-get update && sudo apt-get upgrade
   ```

2. **Missing dependencies**:
   ```bash
   rosdep update
   rosdep install --from-paths src --ignore-src -y
   ```

3. **Rebuild from scratch**:
   ```bash
   colcon clean workspace
   colcon build
   ```

### Permission Errors

The container creates a user matching your host system UID/GID to avoid permission issues. If problems persist:

```bash
# Check user ID
id

# File permissions inside container
ls -la ~/ws
```

### DDS Communication Issues

The container uses `--network=host` and `--ipc=host` for DDS middleware. Verify with:

```bash
ros2 node list
ros2 topic list
```

## Resources

### Official ROS2 Documentation

- [ROS2 Documentation](https://docs.ros.org/)
- [ROS2 Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html)
- [ROS2 Colcon Build Tool](https://colcon.readthedocs.io/)

### Dev Containers

- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Specification](https://containers.dev/)
- [Docker Documentation](https://docs.docker.com/)

### Related Tools

- [RViz2 Documentation](https://github.com/ros2/rviz)
- [Gazebo Simulation](https://gazebosim.org/)
- [rqt Framework](https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-RQt.html)

---

## License

[Specify your license here]

## Contributing

[Contribution guidelines, if applicable]

## Contact

[Contact information or support resources]
