cmake_minimum_required(VERSION 3.14.1)

project(HelloWorld C CXX)

set (CMAKE_CXX_STANDARD 14)
find_package(Threads REQUIRED)

#Nb: use specific tag for grpc release - to avoid default to latest
include(FetchContent)
FetchContent_Declare(
  grpc
  GIT_REPOSITORY https://github.com/grpc/grpc.git
  GIT_TAG        v1.45.2)
FetchContent_MakeAvailable(grpc)

# Indirect names of common grpc/protobuf utilities and libraries 
set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:grpc_cpp_plugin>)
set(_PROTOBUF_PROTOC $<TARGET_FILE:protoc>)
set(_PROTOBUF_LIBPROTOBUF libprotobuf)
set(_REFLECTION grpc++_reflection)
set(_GRPC_GRPCPP grpc++)

# Proto file location - to be added as an include directory later
get_filename_component(GT_PROTO "./proto/gt.proto" ABSOLUTE)
get_filename_component(GT_PROTO_PATH "${GT_PROTO}" PATH)

# Run protobuf compiler as a custom step
set(GT_PROTO_SRCS "${CMAKE_CURRENT_BINARY_DIR}/gt.pb.cc")
set(GT_PROTO_HDRS "${CMAKE_CURRENT_BINARY_DIR}/gt.pb.h")
set(GT_GRPC_SRCS "${CMAKE_CURRENT_BINARY_DIR}/gt.grpc.pb.cc")
set(GT_GRPC_HDRS "${CMAKE_CURRENT_BINARY_DIR}/gt.grpc.pb.h")
add_custom_command(
      OUTPUT "${GT_PROTO_SRCS}" "${GT_PROTO_HDRS}" "${GT_GRPC_SRCS}" "${GT_GRPC_HDRS}"
      COMMAND ${_PROTOBUF_PROTOC}
      ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
        --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
        -I "${GT_PROTO_PATH}"
        --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
        "${GT_PROTO}"
      DEPENDS "${GT_PROTO}")

# Add build directory to include generated *.pb.h files
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

# Build gt_grpc_proto library
add_library(gt_grpc_proto
  ${GT_GRPC_SRCS}
  ${GT_GRPC_HDRS}
  ${GT_PROTO_SRCS}
  ${GT_PROTO_HDRS})
target_link_libraries(gt_grpc_proto
    grpc++
    ${_REFLECTION}
    ${_PROTOBUF_LIBPROTOBUF})

# Targets gt_(client|server)
foreach(_target
  gt_client gt_server)
  add_executable(${_target} "./src/${_target}.cpp")
  target_link_libraries(${_target}
    gt_grpc_proto
    ${_GRPC_GRPCPP}
    ${_REFLECTION}
    ${_PROTOBUF_LIBPROTOBUF})
endforeach()
