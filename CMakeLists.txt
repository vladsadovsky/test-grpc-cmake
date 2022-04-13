cmake_minimum_required(VERSION 3.14.1)

project(HelloWorld C CXX)

set (CMAKE_CXX_STANDARD 17)
find_package(Threads REQUIRED)

include(FetchContent)
FetchContent_Declare(
  grpc
  GIT_REPOSITORY https://github.com/grpc/grpc.git
  GIT_TAG        v1.45.2)
FetchContent_MakeAvailable(grpc)

set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:grpc_cpp_plugin>)
set(_PROTOBUF_LIBPROTOBUF libprotobuf)
set(_REFLECTION grpc++_reflection)
set(_PROTOBUF_PROTOC $<TARGET_FILE:protoc>)
set(_GRPC_GRPCPP grpc++)

# Proto file location - to be added as an include directory later
get_filename_component(gt_proto "./gt.proto" ABSOLUTE)
get_filename_component(gt_proto_path "${gt_proto}" PATH)

# Generated sources
set(gt_proto_srcs "${CMAKE_CURRENT_BINARY_DIR}/gt.pb.cc")
set(gt_proto_hdrs "${CMAKE_CURRENT_BINARY_DIR}/gt.pb.h")
set(gt_grpc_srcs "${CMAKE_CURRENT_BINARY_DIR}/gt.grpc.pb.cc")
set(gt_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/gt.grpc.pb.h")
add_custom_command(
      OUTPUT "${gt_proto_srcs}" "${gt_proto_hdrs}" "${gt_grpc_srcs}" "${gt_grpc_hdrs}"
      COMMAND protoc
      ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
        --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
        -I "${gt_proto_path}"
        --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
        "${gt_proto}"
      DEPENDS "${gt_proto}")

# Include generated *.pb.h files
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

# gt_grpc_proto
add_library(gt_grpc_proto
  ${gt_grpc_srcs}
  ${gt_grpc_hdrs}
  ${gt_proto_srcs}
  ${gt_proto_hdrs})
target_link_libraries(gt_grpc_proto
    grpc++
    ${_REFLECTION}
    libprotobuf)

# Targets gt_(client|server)
foreach(_target
  gt_client gt_server)
  add_executable(${_target} "${_target}.cpp")
  target_link_libraries(${_target}
    gt_grpc_proto
    grpc++
    ${_REFLECTION}
    libprotobuf)
endforeach()
