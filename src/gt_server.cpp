/*
 * grpc test/example -- server side
 */

#include <iostream>
#include <memory>
#include <string>

#include "common.h"

//#include <grpcpp/ext/proto_server_reflection_plugin.h>
#include <grpcpp/grpcpp.h>
//#include <grpcpp/health_check_service_interface.h>

#include "gt.grpc.pb.h"

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;
using gt::GT;
using gt::GTWelcomeReply;
using gt::GTWelcomeRequest;



// Logic and data behind the server's behavior.
class GTServiceImpl final : public GT::Service {
  Status Welcome(ServerContext* context, const GTWelcomeRequest* request,
                  GTWelcomeReply* reply) override {
    std::string prefix("GRPC Test Server welcomes you: ");
    reply->set_message(prefix + request->name());
    return Status::OK;
  }
};

void RunServer() {
  std::string server_address(SERVER_LISTEN_ADDRESS_STR);
  GTServiceImpl service;

  ServerBuilder builder;
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);

  std::unique_ptr<Server> server(builder.BuildAndStart());
  std::cout << "Server listening on " << server_address << std::endl;

  // Wait for the server to shutdown. Note that some other thread must be
  // responsible for shutting down the server for this call to ever return.
  server->Wait();
}

int main(int argc, char** argv) {
  std::cout << " GRPC Test Welcome server started" << std::endl;
  RunServer();
  std::cout << " GRPC Test Welcome server exiting" << std::endl;

  return 0;
}
