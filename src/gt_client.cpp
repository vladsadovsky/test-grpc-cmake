/*
 * grpc test/example  -- client side
 */

#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>

#include "common.h"
#include "gt.grpc.pb.h"


using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;
using gt::GT;
using gt::GTWelcomeReply;
using gt::GTWelcomeRequest;

class GTClient {
 public:
  GTClient(std::shared_ptr<Channel> channel)
      : stub_(GT::NewStub(channel)) {}

  std::string Welcome(const std::string& user) {
    GTWelcomeRequest request;
    request.set_name(user);

    GTWelcomeReply reply;
    ClientContext context;

    Status status = stub_->Welcome(&context, request, &reply);

    if (status.ok()) {
      return reply.message();
    } else {
      std::cout << " GRPC Test: Error: "
                << status.error_code() << ": " << status.error_message()
                << std::endl;
      return "RPC call failed";
    }
  }

 private:
  std::unique_ptr<GT::Stub> stub_;
};

int main(int argc, char** argv) {
  
  std::string target_str;
  std::string arg_str("--target");
  target_str = TARGET_STR;

  GTClient GT(
      grpc::CreateChannel(target_str, grpc::InsecureChannelCredentials()));
  std::string user("TestWorld");
  std::string reply = GT.Welcome(user);
  std::cout << "GRPC Test client received welcome reply: " << reply << std::endl;

  return 0;
}
