FROM frankjoshua/ros2

# ** [Optional] Uncomment this section to install additional packages. **
#
# ENV DEBIAN_FRONTEND=noninteractive
# RUN apt-get update \
#    && apt-get -y install --no-install-recommends <your-package-list-here> \
#    #
#    # Clean up
#    && apt-get autoremove -y \
#    && apt-get clean -y \
#    && rm -rf /var/lib/apt/lists/*
# ENV DEBIAN_FRONTEND=dialog

# Set up auto-source of workspace for ros user
ARG WORKSPACE=/home/ros
RUN echo "if [ -f ${WORKSPACE}/install/setup.bash ]; then source ${WORKSPACE}/install/setup.bash; fi" >> /home/ros/.bashrc
# SHELL [ "/bin/bash", "-i", "-c" ]

WORKDIR /home/ros
COPY src ./src/
USER root
RUN apt-get update && rosdep update && rosdep install --from-paths src --ignore-src -y
USER ros
RUN . /opt/ros/$ROS_DISTRO/setup.sh && colcon build --merge-install --cmake-args '-DCMAKE_BUILD_TYPE=RelWithDebInfo' -Wall -Wextra -Wpedantic

ENTRYPOINT [ "/bin/bash", "-i", "-c" ]
CMD ["ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0 -p ROS_TCP_PORT:=10000"]